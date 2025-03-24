{ inputs, ... }:

{
  perSystem = { inputs', self', lib, system, ... }: {
    builders.service_providers_dna = { gatewayZome }:
      inputs.tnesh-stack.outputs.builders.${system}.dna {
        dnaManifest = builtins.toFile "dna.yaml" ''
          manifest_version: '1'
          name: service_providers
          integrity:
            network_seed: null
            properties: null
            origin_time: 1676140846503210
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
            - name: gateway
              hash: null
              bundled: <NIX_PACKAGE>
              dependencies: []
              dylib: null
          lineage: []        '';
        zomes = {
          roles_integrity = inputs'.roles-zome.packages.roles_integrity;
          roles = inputs'.roles-zome.packages.roles;
          # This overrides all the "bundled" properties for the DNA manifest
          service_providers_integrity =
            self'.packages.service_providers_integrity;
          service_providers = self'.packages.service_providers;
          gateway = gatewayZome;
        };
      };
  };
}

