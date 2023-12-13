
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

terraform.tfvars:
	echo 'ssh_public_key = "$(shell ssh-add -L)"' > terraform.tfvars

localnet: localnet/fhevm-keys
	./setup_genesis.sh

localnet/fhevm-keys:
	mkdir -p localnet/fhevm-keys
	fhevm-tfhe-cli generate-keys -d ./localnet/fhevm-keys

.PHONY: generate_genesis
generate_genesis: localnet

.PHONY: upload_genesis
upload_genesis:
	./upload_genesis.sh

.PHONY: start_validators
start_validators: check_env
	DOCKER_PULL_GITHUB_TOKEN=$(DOCKER_PULL_GITHUB_TOKEN) \
	DOCKER_PULL_GITHUB_USER=$(DOCKER_PULL_GITHUB_USER) \
	 ./start_validators.sh

.PHONY: sshuttle
sshuttle: check_ssh_key
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	sshuttle -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
	 -D -r ubuntu@$(shell jq -r '.resources[] | select(.type=="aws_instance") | select(.instances[].attributes.public_ip != "") | .instances[].attributes.public_ip' terraform.tfstate) 10.0.0.0/24

terraform_apply: check_ssh_key localnet terraform.tfvars
	terraform apply -auto-approve

full_setup: check_env generate_genesis
	$(MAKE) terraform_apply
	# TODO: find better option to wait
	sleep 20 # wait for servers to boot
	$(MAKE) sshuttle
	$(MAKE) upload_genesis
	$(MAKE) start_validators

teardown:
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	rm -rf ./localnet
	terraform destroy -auto-approve
