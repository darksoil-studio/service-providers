{ self, inputs, ... }:

{
  perSystem = { inputs', self', lib, system, ... }:
    let
      dnaManifest = { gateway, progenitors }: ''
        manifest_version: '0'
        name: services
        integrity:
          network_seed: null
          properties: 
            progenitors: ${
              builtins.toString (builtins.map (p: "\n      - ${p}") progenitors)
            }
          zomes:
          - name: service_providers_integrity
            hash: null
            path: ../target/wasm32-unknown-unknown/release/service_providers_integrity.wasm
            dependencies: null
          - name: roles_integrity
            hash: null
            path: <NIX_PACKAGE>
            dependencies: null
        coordinator:
          zomes:
          - name: service_providers
            hash: null
            path: ../target/wasm32-unknown-unknown/release/service_providers.wasm
            dependencies:
            - name: service_providers_integrity
          - name: roles
            hash: null
            path: <NIX_PACKAGE>
            dependencies:
            - name: roles_integrity
          ${
            if gateway then ''
              - name: gateway
                  hash: null
                  path: <NIX_PACKAGE>
                  dependencies: []
            '' else
              ""
          }
      '';
    in rec {
      builders.services_dna = { progenitors }:
        inputs.holochain-utils.outputs.builders.${system}.dna {
          dnaManifest = builtins.toFile "dna.yaml" (dnaManifest {
            inherit progenitors;
            gateway = false;
          });
          zomes = {
            roles_integrity = inputs'.roles-zome.builders.roles_integrity {
              linked_devices_integrity_zome_name = null;
            };
            roles = inputs'.roles-zome.builders.roles {
              notifications_coordinator_zome_name = null;
              linked_devices_coordinator_zome_name = null;
            };
            # This overrides all the "bundled" properties for the DNA manifest
            service_providers_integrity =
              self'.packages.service_providers_integrity;
            service_providers = self'.packages.service_providers;
          };
        };
      packages.services_dna =
        builders.services_dna { progenitors = self.outputs.progenitors; };
      builders.services_dna_with_gateway_and_progenitors =
        { gatewayZome, progenitors }:
        inputs.holochain-utils.outputs.builders.${system}.dna {
          dnaManifest = builtins.toFile "dna.yaml" (dnaManifest {
            inherit progenitors;
            gateway = true;
          });
          zomes = {
            roles_integrity = inputs'.roles-zome.builders.roles_integrity {
              linked_devices_integrity_zome_name = null;
            };
            roles = inputs'.roles-zome.builders.roles {
              notifications_coordinator_zome_name = null;
              linked_devices_coordinator_zome_name = null;
            };
            # This overrides all the "bundled" properties for the DNA manifest
            service_providers_integrity =
              self'.packages.service_providers_integrity;
            service_providers = self'.packages.service_providers;
            gateway = gatewayZome;
          };
        };
      builders.services_dna_with_gateway = { gatewayZome }:
        builders.services_dna_with_gateway_and_progenitors {
          inherit gatewayZome;
          progenitors = self.outputs.progenitors;
        };
    };
}

