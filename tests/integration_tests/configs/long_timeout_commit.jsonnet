local default = import 'default.jsonnet';

default {
  'inco-gentry-1'+: {
    config+: {
      consensus+: {
        timeout_commit: '5s',
      },
    },
  },
}
