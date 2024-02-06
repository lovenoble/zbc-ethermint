local config = import 'default.jsonnet';

config {
  'inco-gentry-1'+: {
    'app-config'+: {
      'minimum-gas-prices': '100000000000ainco',
    },
    genesis+: {
      app_state+: {
        feemarket+: {
          params+: {
            base_fee:: super.base_fee,
          },
        },
      },
    },
  },
}
