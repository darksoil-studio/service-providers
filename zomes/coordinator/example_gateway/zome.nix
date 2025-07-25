{ inputs, ... }:

{
  perSystem = { inputs', system, self', ... }: {
    packages.example_gateway =
      inputs.holochain-utils.outputs.builders.${system}.rustZome {
        workspacePath = inputs.self.outPath;
        crateCargoToml = ./Cargo.toml;
        excludedCrates = [ "service_providers_utils" ];
      };

  };
}

