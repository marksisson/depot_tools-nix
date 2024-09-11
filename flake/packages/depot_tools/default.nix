{
  perSystem = { inputs', pkgs, ... }:
    let
      inherit (inputs'.xcode-nix.packages) stdenv;
    in
    {
      packages.depot_tools =
        let
          src = pkgs.fetchgit {
            url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
            leaveDotGit = true;
            hash = "sha256-/yXb+j/eD9MWITjrpiDQZZ6u+IumkZA0vMpbmPlb/So=";
          };
          patchedSrc = pkgs.applyPatches {
            name = "depot_tools";
            inherit src;
            patches = [
              ./patches/cipd_bin_setup.sh.patch
              ./patches/ninja.py.patch
              ./patches/utils.py.patch
            ];
          };
          revision = pkgs.runCommand "get-rev"
            {
              nativeBuildInputs = [ pkgs.git ];
            } "GIT_DIR=${src}/.git git rev-parse --short HEAD | tr -d '\n' > $out";
        in
        stdenv.mkDerivation {
          pname = "depot_tools";
          src = patchedSrc;
          version = "0" + builtins.readFile revision;
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          propagatedNativeBuildInputs = [ pkgs.python3 ];
          buildPhase = ''
            patchShebangs .
            ./update_depot_tools_toggle.py --disable
            echo "\$HOME/.config/depot_tools-''${version}" > .cipd_client_root
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
