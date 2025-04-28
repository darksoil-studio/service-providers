{ inputs, ... }:

{
  perSystem = { inputs', system, ... }: {
    packages.service_providers_integrity =
      inputs.holochain-nix-builders.outputs.builders.${system}.rustZome {
        workspacePath = inputs.self.outPath;
        crateCargoToml = ./Cargo.toml;
        excludedCrates = [ "service_providers_utils" ];
      };
  };
}

