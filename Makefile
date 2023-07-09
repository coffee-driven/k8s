.PHONY: build infra platform

ansible_deb:
	@echo installing Ansible requirements
	ansible-galaxy install -r platform/requirements.yml

infra:
	@echo "Building infrastructure"
	cd infra
	terraform destroy -auto-approve
	terraform apply -auto-approve
	cd ../

platform: ansible_deb
	@echo "Building platform"
	ansible-playbook platform/provision.yml -i platform/inventory/kvm.yml --vault-password-file platform/.vault_password

build: infra platform
	@echo "Building k8s"
