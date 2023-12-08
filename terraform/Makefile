
EVMOSD=/Users/deividas/projects/evmos-orig/build
NODE_COUNT=5

.PHONY: check_ssh_key
check_ssh_key:
	ssh-add -L | grep 'ssh-'

terraform.tfvars:
	echo 'ssh_public_key = "$(shell ssh-add -L)"' > terraform.tfvars

localnet:
	./setup_genesis.sh

.PHONY: generate-genesis
generate-genesis: localnet

.PHONY: upload-genesis
upload-genesis:
	./upload_genesis.sh

.PHONY: start-validators
start-validators:
	./start_validators.sh

.PHONY: sshuttle
sshuttle: check_ssh_key
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	sshuttle -D -r ubuntu@$(shell jq -r '.resources[] | select(.type=="aws_instance") | select(.instances[].attributes.public_ip != "") | .instances[].attributes.public_ip' terraform.tfstate) 10.0.0.0/24

terraform_apply: check_ssh_key localnet terraform.tfvars
	terraform apply -auto-approve

full_setup:
	$(MAKE) terraform_apply
	$(MAKE) sshuttle
	$(MAKE) generate-genesis
	# TODO: find better option to wait
	sleep 60 # wait for docker install to finish
	$(MAKE) upload-genesis
	$(MAKE) start-validators

teardown:
	-ps aux | grep -i python | grep sshuttle | awk '{print $$2}' | sudo xargs kill
	rm -rf ./localnet
	terraform destroy -auto-approve
