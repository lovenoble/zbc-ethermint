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

For now this is only exploratory work.

The roadmap is:

1. Start from the original go-ethereum version i.e. v1.10.26
2. Upgrade go-ethereum version by version and updates ethermint accordingly
   until the most up-to-date go-ethereum
3. Clean most of modules we do not need
4. Integrate fhevm-go

## How to proceed

- Update go.mod with the new version of go-ethereum, e.g. v1.11.0
- Another way is to use a custom go-ethereum with the right version and link it
  to ethermint thank to go.mod file (in replace section at the bottom):
  ```bash
  github.com/ethereum/go-ethereum v1.10.26 => ../go-ethereum
  ```
- Check build is ok.
  ```bash
  make build
  ```
- If errors, fix them on Ethermint, commit and continue with the new version
  v.1.11.1 ...

- The goal is to reach go-ethereum v1.13.4.

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
