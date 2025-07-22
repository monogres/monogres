local numShards = 2;

local mkShard(i) =
  {
    backend: {
      grpc: {
        address: 'storage-' + std.toString(i) + '.storage.buildbarn.svc.cluster.local:8981',
      },
    },
    weight: 1,
  };

local mkShards(numShards) =
  {
    shards: {
      [std.toString(i)]: mkShard(i)
      for i in std.range(0, numShards - 1)
    },
  };

local workerImageName = 'ghcr.io/rpostgres/rpostgres/debian-rbe-pgdeps';
local workerImageDigest = '@sha256:104c826449ce4419b19439b21c0534a99ccc11778be9a681504b605f6bc7d50e';

{
  numShards: numShards,
  containerImage: workerImageName + workerImageDigest,
  blobstore: {
    contentAddressableStorage: {
      sharding: mkShards(numShards),
    },
    actionCache: {
      completenessChecking: {
        backend: {
          sharding: mkShards(numShards),
        },
        maximumTotalTreeSizeBytes: 64 * 1024 * 1024,
      },
    },
  },
  browserUrl: 'https://browser.rbe.monogres.dev',
  maximumMessageSizeBytes: 16 * 1024 * 1024,
  global: {
    diagnosticsHttpServer: {
      httpServers: [{
        listenAddresses: [':9980'],
        authenticationPolicy: { allow: {} },
      }],
      enablePrometheus: true,
      enablePprof: true,
      enableActiveSpans: true,
    },
  },
}
