{
  perSystem = { config, inputs', pkgs, self', ... }:
    {
      devShells.developer =
        let
          inherit (inputs'.xcode-nix.packages) stdenv;
          formatters = [ treefmt ] ++ treefmt-programs;
          language-servers = [
            pkgs.nodePackages.bash-language-server
            pkgs.nil
          ];
          linters = [ pkgs.shellcheck ];
          tools = [ pkgs.just pkgs.nix-output-monitor ];
          treefmt = config.treefmt.build.wrapper;
          treefmt-programs = builtins.attrValues config.treefmt.build.programs;
        in
        pkgs.mkShell.override { inherit stdenv; } {
          packages = formatters ++ language-servers ++ linters ++ tools;
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };
    };
}
