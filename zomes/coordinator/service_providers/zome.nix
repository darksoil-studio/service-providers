{ inputs, ... }:

{
  perSystem = { inputs', system, self', ... }: {
    packages.service_providers =
      inputs.holochain-nix-builders.outputs.builders.${system}.rustZome {
        workspacePath = inputs.self.outPath;
        crateCargoToml = ./Cargo.toml;
        excludedCrates = [ "service_providers_utils" ];
      };

  };
}

