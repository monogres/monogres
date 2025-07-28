local common = import 'common.libsonnet';

{
  grpcServers: [{
    listenAddresses: [':8980'],
    authenticationPolicy: {
      jwt: {
        jwksInline: {
          keys: [
            {
              use: 'sig',
              kty: 'OKP',
              kid: 'V05_j3uDy6HsnWV-3hVIBFPUlvG1G3LEDAJIqap0ojk',
              crv: 'Ed25519',
              alg: 'EdDSA',
              x: 'F9AKe-FxYDBj3iVLhBPYclPm0xbGYsblAyY1KpTbKk0',
            },
          ],
        },
        maximumCacheSize: 1000,
        cacheReplacementPolicy: 'LEAST_RECENTLY_USED',
        metadataExtractionJmespathExpression: '`{}`',
        claimsValidationJmespathExpression: '`true`',
      },
    },
  }],
  schedulers: {
    '': {
      endpoint: {
        address: 'scheduler:8982',
        addMetadataJmespathExpression: |||
          {
            "build.bazel.remote.execution.v2.requestmetadata-bin": incomingGRPCMetadata."build.bazel.remote.execution.v2.requestmetadata-bin"
          }
        |||,
      },
    },
  },
  maximumMessageSizeBytes: common.maximumMessageSizeBytes,
  global: common.global,
  contentAddressableStorage: {
    backend: common.blobstore.contentAddressableStorage,
    getAuthorizer: { allow: {} },
    putAuthorizer: { allow: {} },
    findMissingAuthorizer: { allow: {} },
  },
  actionCache: {
    backend: common.blobstore.actionCache,
    getAuthorizer: { allow: {} },
    putAuthorizer: { allow: {} },
  },
  executeAuthorizer: { allow: {} },
}
