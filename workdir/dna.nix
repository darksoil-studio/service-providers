{ inputs, ... }:

{
  perSystem = { inputs', self', lib, system, ... }: {
    packages.service_providers_test_dna =
      inputs.tnesh-stack.outputs.builders.${system}.dna {
        dnaManifest = ./dna.yaml;
        zomes = {
          roles_integrity = inputs'.roles-zome.packages.roles_integrity;
          roles = inputs'.roles-zome.packages.roles;
          # This overrides all the "bundled" properties for the DNA manifest
          service_providers_integrity =
            self'.packages.service_providers_integrity;
          service_providers = self'.packages.service_providers;
        };
      };
  };
}

