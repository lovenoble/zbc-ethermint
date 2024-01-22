
MNEMONIC ?= stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver
DOCKER_IMAGE ?= ghcr.io/zama-ai/ethermint-node:v0.2.3
PUBLIC_NODE_IP_EXPR = jq -r '.resources[] | select(.type=="aws_instance") | select(.instances[].attributes.public_ip != "") | .instances[].attributes.public_ip' terraform.tfstate
CHAINID ?= ethermint_8009-1
AWS_REGION ?= eu-west-2

.PHONY: check_ssh_key
check_ssh_key:
	ssh-add -L | grep 'ssh-'

.PHONY: check_env
check_env:
ifndef DOCKER_PULL_GITHUB_TOKEN
	$(error DOCKER_PULL_GITHUB_TOKEN is undefined, needed for pulling image from gcr in remote host)
endif
ifndef DOCKER_PULL_GITHUB_USER
	$(error DOCKER_PULL_GITHUB_USER is undefined, needed for pulling image from gcr in remote host)
endif

.PHONY: login_public_node
login_public_node: check_ssh_key terraform.tfstate
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$(shell $(PUBLIC_NODE_IP_EXPR))

.PHONY: setup_periodic_tests
setup_periodic_tests: check_ssh_key terraform.tfstate
	cat setup_periodic_tests.sh | \
	  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
	  ubuntu@$(shell $(PUBLIC_NODE_IP_EXPR)) '/bin/bash'

terraform.tfvars:
	echo 'ssh_public_key = "$(shell ssh-add -L)" \
	region = "$(AWS_REGION)"' > terraform.tfvars

.PHONY: localnet
localnet: localnet/fhevm-keys
	DOCKER_IMAGE="$(DOCKER_IMAGE)" \
	MNEMONIC="$(MNEMONIC)" \
	CHAINID="$(CHAINID)" \
	REGION="$(AWS_REGION)" \
	  ./setup_genesis.sh

localnet/fhevm-keys:
	mkdir -p localnet/fhevm-keys
	fhevm-tfhe-cli generate-keys -d ./localnet/fhevm-keys

.PHONY: generate_genesis
generate_genesis: localnet

.PHONY: upload_keys
upload_keys: localnet/fhevm-keys
	rsync -avz --progress \
	 -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
	 localnet/fhevm-keys/ \
	 ubuntu@$(shell $(PUBLIC_NODE_IP_EXPR)):~/fhevm-keys/

.PHONY: upload_genesis
upload_genesis:
	./upload_genesis.sh

.PHONY: start_validators
start_validators: check_env
	DOCKER_PULL_GITHUB_TOKEN=$(DOCKER_PULL_GITHUB_TOKEN) \
	DOCKER_PULL_GITHUB_USER=$(DOCKER_PULL_GITHUB_USER) \
	MNEMONIC="$(MNEMONIC)" \
	CHAINID="$(CHAINID)" \
	 ./start_validators.sh

.PHONY: start_kms
start_kms: check_env
	DOCKER_PULL_GITHUB_TOKEN=$(DOCKER_PULL_GITHUB_TOKEN) \
	DOCKER_PULL_GITHUB_USER=$(DOCKER_PULL_GITHUB_USER) \
	REGION=$(AWS_REGION) \
	 ./start_kms.sh

.PHONY: sshuttle
sshuttle: check_ssh_key
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	sshuttle -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
	 -D -r ubuntu@$(shell $(PUBLIC_NODE_IP_EXPR)) 10.0.0.0/24

terraform_apply: check_ssh_key terraform.tfvars
	terraform apply -auto-approve

full_setup: check_env generate_genesis
	$(MAKE) terraform_apply
	# TODO: find better option to wait
	sleep 20 # wait for servers to boot
	$(MAKE) sshuttle
	$(MAKE) upload_keys
	$(MAKE) upload_genesis
	$(MAKE) start_kms
	$(MAKE) start_validators
	$(MAKE) setup_periodic_tests

teardown:
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	rm -rf ./localnet
	terraform destroy -auto-approve
