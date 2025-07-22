// mkShard.libsonnet

function(i)
  {
    backend: {
      grpc: {
        address: 'storage-' + std.toString(i) + '.storage.buildbarn.svc.cluster.local:8981',
      },
    },
    weight: 1,
  }
