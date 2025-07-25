{ inputs, ... }:

{
  perSystem = { inputs', lib, self', system, ... }: {
    packages.service_consumer_test_happ =
      inputs.holochain-utils.outputs.builders.${system}.happ {
        happManifest = ./happ.yaml;

        dnas = {
          # Include here the DNA packages for this hApp, e.g.:
          # my_dna = inputs'.some_input.packages.my_dna;
          # This overrides all the "bundled" properties for the hApp manifest 
          services_test = self'.packages.services_dna;
        };
      };
    packages.service_provider_test_happ =
      inputs.holochain-utils.outputs.builders.${system}.happ {
        happManifest = ./happ.yaml;

        dnas = {
          # Include here the DNA packages for this hApp, e.g.:
          # my_dna = inputs'.some_input.packages.my_dna;
          # This overrides all the "bundled" properties for the hApp manifest 
          services_test = self'.builders.services_dna_with_gateway {
            gatewayZome = self'.packages.example_gateway;
          };
        };
      };
  };
}
