local config = import 'default.jsonnet';

config {
  'inco-gentry-1'+: {
    validators: super.validators[0:1] + [{
      name: 'fullnode',
    }],
  },
}
