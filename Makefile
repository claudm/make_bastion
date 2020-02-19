
.ONESHELL:
.SHELL := /usr/bin/bash
IP = $(shell cd  build_terraform;terraform output server_ip)
AMI =${shell  aws ec2 describe-images --filter "Name=is-public,Values=false" 'Name=name,Values=bastion*' --query 'reverse(sort_by(Images, &CreationDate)[].ImageId)[0]'}
#AMI=$(ami)
include vars
.PHONY:  create packer destroy user ip

create:
	@cd build_terraform
	@terraform init 
#	terraform apply  -var="server_name=$(server_name)" -var="associate_public_ip_address=true"  -var="ami=$(AMI)" -var="instance_type=$(instance_type)" -auto-approve
	@terraform apply  -var="server_name=$(server_name)"  -var="ami=$(AMI)" -var="instance_type=$(instance_type)" -auto-approve

build:
	@cd build_packer 
	@packer build  -var 'subnet_id=$(subnet_id)' -var 'vpc_id=$(vpc_id)' -var 'aws_region=$(aws_region)' -machine-readable packer-build.json 

destroy:
	@cd build_terraform
	@terraform destroy -auto-approve

user: 
	@ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos  --private-key ../keys/key-hmg.pem  -i '$(IP),' ansible_playbook/provision.yml

ip:
	@echo $(IP)
