{
  buildGoModule,
  fetchFromGitHub,
  writeShellScriptBin,
}: let
  conformanceBin = buildGoModule rec {
    pname = "conformance";
    version = "1.1.0-rc3";

    src =
      (fetchFromGitHub {
        owner = "opencontainers";
        repo = "distribution-spec";
        rev = "v${version}";
        hash = "sha256-sYJeILOYSnPpurctsrbyhx9oKSs0d1YPM80pHsgYI9s=";
      })
      + "/conformance";
    doCheck = false;
    vendorHash = "sha256-5gn9RpjCALZB/GFjlJHDqPs2fIHl7NJr5QjPmsLnnO4=";
    buildPhase = "go test -c";
    installPhase = ''
      mkdir -p $out/bin
      cp conformance.test $out/bin/conformance
    '';

    meta = {
      description = "Conformance testing an OCI Registry";
      homepage = "https://github.com/opencontainers/distribution-spec";
    };
  };
  defaultSkipInfo = {
    enabled = false;
    manifestDigest = "sha256:c86f7763873b6c0aae22d963bab59b4f5debbed6685761b5951584f6efb0633b";
    blobDigest = "sha256:9d3dd9504c685a304985025df4ed0283e47ac9ffa9bd0326fddf4d59513f0827";
    tagName = "test";
  };
in {
  inherit conformanceBin;
  conformanceTest = {
    rootURL,
    namespace,
    crossmountNamespace,
    username ? "tester",
    password ? "test",
    testPull ? true,
    skipSetupInfo ? defaultSkipInfo,
    testPush ? true,
    testDiscovery ? false,
    testManagement ? false,
    hideSkipped ? true,
    debug ? false,
  }: (writeShellScriptBin "conformance" ''
    # Registry details
    export OCI_ROOT_URL=${rootURL}
    export OCI_NAMESPACE=${namespace}
    export OCI_CROSSMOUNT_NAMESPACE=${crossmountNamespace}
    export OCI_USERNAME=${username}
    export OCI_PASSWORD=${password}

    # Which workflows to run
    export OCI_TEST_PULL=${(toString testPull)}
    export OCI_TEST_PUSH=${(toString testPush)}
    export OCI_TEST_CONTENT_DISCOVERY=${(toString testDiscovery)}
    export OCI_TEST_CONTENT_MANAGEMENT=${(toString testManagement)}

    # Optional: set to prevent automatic setup
    ${
      let
        skipInfo = defaultSkipInfo // skipSetupInfo;
      in
        if skipInfo.enabled
        then ''
          export OCI_MANIFEST_DIGEST=${skipInfo.manifestDigest}
          export OCI_TAG_NAME=${skipInfo.tagName}
          export OCI_BLOB_DIGEST=${skipInfo.blobDigest}
        ''
        else ""
    }

    # Extra settings
    export OCI_HIDE_SKIPPED_WORKFLOWS=${(toString hideSkipped)}
    export OCI_DEBUG=${(toString debug)}
    export OCI_DELETE_MANIFEST_BEFORE_BLOBS=0 # defaults to OCI_DELETE_MANIFEST_BEFORE_BLOBS=1 if not set
    exec ${conformanceBin}/bin/conformance
  '');
}
