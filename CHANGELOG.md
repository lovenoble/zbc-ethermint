<!--
Guiding Principles:

Changelogs are for humans, not machines.
There should be an entry for every single version.
The same types of changes should be grouped.
Versions and sections should be linkable.
The latest version comes first.
The release date of each version is displayed.
Mention whether you follow Semantic Versioning.

Usage:

Change log entries are to be added to the Unreleased section under the
appropriate stanza (see below). Each entry should ideally include a tag and
the Github issue reference in the following format:

* (<tag>) \#<issue-number> message

The issue numbers will later be link-ified during the release process so you do
not have to worry about including a link manually, but you can if you wish.

Types of changes (Stanzas):

"Features" for new features.
"Improvements" for changes in existing functionality.
"Deprecated" for soon-to-be removed features.
"Bug Fixes" for any bug fixes.
"Client Breaking" for breaking CLI commands and REST routes used by end-users.
"API Breaking" for breaking exported APIs used by developers building on SDK.
"State Machine Breaking" for any changes that result in a different AppState given same genesisState and txList.

Ref: https://keepachangelog.com/en/1.0.0/
-->

# Changelog

## [v0.1.0] - 2023-12-21

Ethermint-node docker image: ghcr.io/zama-ai/ethermint-node:v0.1.0

Ethermint-node developer docker image: ghcr.io/zama-ai/ethermint-dev-node:v0.1.0


## Notes

- First version with a fully integrated fhevm-go
- Use the last version of go-ethereum, i.e. `v1.13.5`
- Private key (cks) is still stored in the validator (without Key Management System)
- All tests from fhevm (solidity) are passing


For build:

|      Name       |    Type    | version |
| :-------------: | :--------: | :-----: |
| zbc-go-ethereum | repository | v0.1.1  |
|  zbc-ethermint  | repository | v0.1.0  |
|    fhevm-go     | repository | v0.1.1  |

For e2e test:

|      Name      |    Type    |                 version                  |
| :------------: | :--------: | :--------------------------------------: |
| fhevm-solidity | repository | d7e0e96468356f910678151a54cbe0784f2a7ff2 |
| fhevm-tfhe-cli | repository |                  v0.2.1                  |


