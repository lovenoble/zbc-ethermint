<!--
parent:
  order: false
-->

<div align="center">
  <h1> Ethermint </h1>
</div>

![banner](docs/ethermint.jpg)

<div align="center">
  <a href="https://github.com/evmos/ethermint/releases/latest">
    <img alt="Version" src="https://img.shields.io/github/tag/tharsis/ethermint.svg" />
  </a>
  <a href="https://github.com/evmos/ethermint/blob/main/LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/github/license/tharsis/ethermint.svg" />
  </a>
  <a href="https://pkg.go.dev/github.com/evmos/ethermint">
    <img alt="GoDoc" src="https://godoc.org/github.com/evmos/ethermint?status.svg" />
  </a>
  <a href="https://goreportcard.com/report/github.com/evmos/ethermint">
    <img alt="Go report card" src="https://goreportcard.com/badge/github.com/evmos/ethermint"/>
  </a>
  <a href="https://bestpractices.coreinfrastructure.org/projects/5018">
    <img alt="Lines of code" src="https://img.shields.io/tokei/lines/github/tharsis/ethermint">
  </a>
</div>
<div align="center">
  <a href="https://discord.gg/trje9XuAmy">
    <img alt="Discord" src="https://img.shields.io/discord/809048090249134080.svg" />
  </a>
  <a href="https://github.com/evmos/ethermint/actions?query=branch%3Amain+workflow%3ALint">
    <img alt="Lint Status" src="https://github.com/evmos/ethermint/actions/workflows/lint.yml/badge.svg?branch=main" />
  </a>
  <a href="https://codecov.io/gh/tharsis/ethermint">
    <img alt="Code Coverage" src="https://codecov.io/gh/tharsis/ethermint/branch/main/graph/badge.svg" />
  </a>
</div>

## A new ethermint, why?

THe goal of this repository is to take the last version of Ethermint using
CometBFT and use it for our own lightweight, easy to upgrade stack.

STATUS:

For now Ethermint is using the last version of go-ethereum (v1.13.5).
Fhevm-go is integrated. 



## How to run using docker locally

```bash
make build-local-docker
```

This create the image **ethermintnodelocal**

Init the node (configuration files)

```bash
make init-ethermint-node-local
```

THis will create every need files under __running_node/node1/.ethermintd__.
```bash
running_node/node1/.ethermintd/
├── config
│   ├── app.toml
│   ├── client.toml
│   ├── config.toml
│   ├── genesis.json
│   ├── gentx
│   │   └── gentx-e65f04e8cb66e1978bf41a3b0d3149cdb5cd8f78.json
│   ├── node_key.json
│   └── priv_validator_key.json
├── data
│   └── priv_validator_state.json
├── keyring-test
│   ├── 757bf1fc01075ac7c95bc8407e306cb21c1476c1.address
│   └── orchestrator.info
└── zama
    ├── config
    └── keys
        ├── network-fhe-keys
        │   ├── cks
        │   ├── pks
        │   └── sks
        └── users-fhe-keys
```

Run/stop the node
```bash
make run-ethermint
make stop-ethermint
```

Get the logs
```bash
docker logs ethermintnodelocal0 -f
```

Give Alice (first account in fhevm test) some coins:
```bash
docker exec -i ethermintnodelocal0 faucet 0xa5e1defb98EFe38EBb2D958CEe052410247F4c80
# bob
docker exec -i ethermintnodelocal0 faucet 0xfCefe53c7012a075b8a711df391100d9c431c468

```



> [!WARNING] Evmos, the team behind Ethermint, has fully shifted its focus to
> [Evmos](https://github.com/evmos/evmos), where we continue to build
> interoperability solutions for the future! As a result, this repository is no
> longer maintained for that reason and all relevant code has been migrated.
>
> **NOTE: If you are interested in using this software** email us at
> [evmos-sdk@evmos.org](mailto:evmos-sdk@evmos.org) with copy to
> [legal@thars.is](mailto:legal@thars.is)

## About

Ethermint is a scalable and interoperable Ethereum library, built on
Proof-of-Stake with fast-finality using the
[Cosmos SDK](https://github.com/cosmos/cosmos-sdk/) which runs on top of
[Tendermint Core](https://github.com/tendermint/tendermint) consensus engine.

## Careers

See our open positions on [Greenhouse](https://evmos.org/careers).

## Community

The following chat channels and forums are a great spot to ask questions about
Ethermint:

- [Evmos Twitter](https://twitter.com/EvmosOrg)
- [Evmos Discord](https://discord.gg/trje9XuAmy)
- [Evmos Telegram](https://t.me/EvmosOrg)
- [Altiplanic Twitter](https://twitter.com/Altiplanic_io)
