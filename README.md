# Run OCI Conformance Tests

The OCI Distribution spec [repo](https://github.com/opencontainers/distribution-spec) provides `go` tests that will verify an OCI Registry conformance to the spec.

This nix flake will build the tests and exposes the parameters it takes. You can use the flake on its own to test a registry on `127.0.0.1:3001` by running `nix run` or `nix run .#conformanceTest`.

You can also use the `conformance` package on its own to pass your own parameters.
