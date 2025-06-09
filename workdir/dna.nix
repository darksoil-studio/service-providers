{ self, inputs, ... }:

{
  perSystem = { inputs', self', lib, system, ... }:
    let
      dnaManifest = { gateway, progenitors }: ''
        manifest_version: '1'
        name: service_providers
        integrity:
          network_seed: null
          properties: 
            progenitors: ${
              builtins.toString (builtins.map (p: "\n      - ${p}") progenitors)
            }
          zomes:
          - name: service_providers_integrity
            hash: null
            bundled: ../target/wasm32-unknown-unknown/release/service_providers_integrity.wasm
            dependencies: null
            dylib: null
          - name: roles_integrity
            hash: null
            bundled: <NIX_PACKAGE>
            dependencies: null
            dylib: null
        coordinator:
          zomes:
          - name: service_providers
            hash: null
            bundled: ../target/wasm32-unknown-unknown/release/service_providers.wasm
            dependencies:
            - name: service_providers_integrity
            dylib: null
          - name: roles
            hash: null
            bundled: <NIX_PACKAGE>
            dependencies:
            - name: roles_integrity
            dylib: null
          ${
            if gateway then ''
              - name: gateway
                  hash: null
                  bundled: <NIX_PACKAGE>
                  dependencies: []
                  dylib: null
            '' else
              ""
          }
      '';
    in rec {
      builders.service_providers_dna = { progenitors }:
        inputs.holochain-nix-builders.outputs.builders.${system}.dna {
          dnaManifest = builtins.toFile "dna.yaml" (builtins.trace
            (dnaManifest {
              inherit progenitors;
              gateway = false;
            }) (dnaManifest {
              inherit progenitors;
              gateway = false;
            }));
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
      packages.service_providers_dna = builders.service_providers_dna {
        progenitors = self.outputs.progenitors;
      };
      builders.service_providers_dna_with_gateway_and_progenitors =
        { gatewayZome, progenitors }:
        inputs.holochain-nix-builders.outputs.builders.${system}.dna {
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
      builders.service_providers_dna_with_gateway = { gatewayZome }:
        builders.service_providers_dna_with_gateway_and_progenitors {
          inherit gatewayZome;
          progenitors = self.outputs.progenitors;
        };
    };
}

