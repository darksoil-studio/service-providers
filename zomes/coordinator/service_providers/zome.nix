{ inputs, ... }:

{
  perSystem = { inputs', system, self', ... }: {
    packages.service_providers =
      inputs.tnesh-stack.outputs.builders.${system}.rustZome {
        workspacePath = inputs.self.outPath;
        crateCargoToml = ./Cargo.toml;
        excludedCrates = [ "service_providers_utils" ];
      };

  };
}

