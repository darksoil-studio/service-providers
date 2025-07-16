{
  description = "Template for Holochain app development";

  inputs = {
    holochain-utils.url = "github:darksoil-studio/holochain-utils/main-0.5";
    nixpkgs.follows = "holochain-utils/nixpkgs";

    roles-zome.url = "github:darksoil-studio/roles-zome/main-0.5";
    roles-zome.inputs.holochain-utils.follows = "holochain-utils";
  };

  nixConfig = {
    extra-substituters = [
      "https://holochain-ci.cachix.org"
      "https://darksoil-studio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "holochain-ci.cachix.org-1:5IUSkZc0aoRS53rfkvH9Kid40NpyjwCMCzwRTXy+QN8="
      "darksoil-studio.cachix.org-1:UEi+aujy44s41XL/pscLw37KEVpTEIn8N/kn7jO8rkc="
    ];
  };

  outputs = inputs:
    inputs.holochain-utils.inputs.holonix.inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } {
      imports = [
        ./zomes/integrity/service_providers/zome.nix
        ./zomes/coordinator/service_providers/zome.nix
        ./zomes/coordinator/example_gateway/zome.nix
        # Just for testing purposes
        ./workdir/dna.nix
        ./workdir/happ.nix
        inputs.holochain-utils.outputs.flakeModules.builders
      ];

      flake = {
        progenitors =
          [ "uhCAk13OZ84d5HFum5PZYcl61kHHMfL2EJ4yNbHwSp4vn6QeOdFii" ];
      };

      systems =
        builtins.attrNames inputs.holochain-utils.inputs.holonix.devShells;
      perSystem = { inputs', config, pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            inputs'.holochain-utils.devShells.synchronized-pnpm
            inputs'.holochain-utils.devShells.default
          ];

          packages = [
            inputs'.holochain-utils.packages.holochain
            inputs'.holochain-utils.packages.hc-scaffold-zome
            inputs'.holochain-utils.packages.hc-playground
          ];
        };
        devShells.npm-ci = inputs'.holochain-utils.devShells.synchronized-pnpm;

        packages.scaffold = pkgs.symlinkJoin {
          name = "scaffold-remote-zome";
          paths = [ inputs'.holochain-utils.packages.scaffold-remote-zome ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/scaffold-remote-zome \
              --add-flags "service-providers-zome \
                --integrity-zome-name service_providers_integrity \
                --coordinator-zome-name service_providers \
                --remote-zome-git-url github:darksoil-studio/service-providers-zome \
                --remote-npm-package-name @darksoil-studio/service-providers-zome \
                --remote-zome-git-branch main-0.5 \
                --context-element service-providers-context \
                --context-element-import @darksoil-studio/service-providers-zome/dist/elements/service-providers-context.js" 
          '';
        };
      };
    };
}
