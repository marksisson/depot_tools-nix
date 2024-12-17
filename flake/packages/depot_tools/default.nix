{ self, ... }: {
  perSystem = { inputs', pkgs, ... }: {
    packages.depot_tools =
      let
        pname = "depot_tools";
        src = pkgs.fetchgit {
          name = "${pname}-src";
          url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
          rev = "263e08dde32e8917411f09bdc095be6da3a86311";
          leaveDotGit = true;
          hash = "sha256-6AQUaTYHYw/Ix7d2orYJXz+vZKd+JjmoNs05nAGrsQo=";
        };
        patchedSrc = pkgs.applyPatches {
          inherit pname src;
          patches = [
            ./patches/cipd_bin_setup.sh.patch
            ./patches/ninja.py.patch
            ./patches/utils.py.patch
          ];
        };
        revision = pkgs.runCommand "${pname}-rev-parse" { nativeBuildInputs = [ pkgs.git ]; } ''
          GIT_DIR=${src}/.git git rev-parse --short HEAD | tr -d '\n' > $out
        '';
        commitCount = pkgs.runCommand "${pname}-rev-list" { nativeBuildInputs = [ pkgs.git ]; } ''
          GIT_DIR=${src}/.git git rev-list --count HEAD | tr -d '\n' > $out
        '';
      in
      pkgs.stdenv.mkDerivation {
        pname = builtins.readFile revision + "_" + pname;
        version = "0.1." + builtins.readFile commitCount;
        src = patchedSrc;
        phases = [ "unpackPhase" "buildPhase" "installPhase" ];
        postUnpack = ''
          cp ${self}/flake/packages/depot_tools/src/fetch_configs/airscrew.py $sourceRoot/fetch_configs/
        '';
        propagatedNativeBuildInputs = [ pkgs.python3 ];
        buildPhase = ''
          patchShebangs .
          ./update_depot_tools_toggle.py --disable
          echo "\$CIPD_ROOT_PREFIX/.cipd_bin" > .cipd_client_root
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp -r . $out/bin
        '';
        passthru = {
          CUSTOM_CIPD_CLIENT = "${inputs'.luci-go.packages.luci-go}/bin/cipd";
        };
      };
  };
}
