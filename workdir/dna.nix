{ inputs, ... }:

{
  perSystem = { inputs', self', lib, system, ... }: {
    packages.service_providers_test_dna =
      inputs.tnesh-stack.outputs.builders.${system}.dna {
        dnaManifest = ./dna.yaml;
        zomes = {
          # This overrides all the "bundled" properties for the DNA manifest
          service_providers_integrity =
            self'.packages.service_providers_integrity;
          service_providers = self'.packages.service_providers;
        };
      };
  };
}

