#!/bin/bash
# Run the provisioning example.
# We have a few prerequisites
if [[ ! -x "$(which wget)" ]]
then
	sudo yum -y install wget
fi
if [[ ! -x "$(which terraform)" ]]
then 
	wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
	unzip terraform_0.11.8_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
fi
if [[ ! -x "$(which curl)" ]]
then
	sudo yum -y install curl
fi
if [[ ! -x "$(which terraform)" ]]
then 
	wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
	unzip terraform_0.11.8_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
fi
[[ ! -x "$(which ssh)" ]] && echo "Couldn't find ssh in your PATH." && exit 1
[[ ! -x "$(which ssh-keygen)" ]] && echo "Couldn't find ssh-keygen in your PATH." && exit 1

#if [[ "$1" == "" || "$2" == "" ]]; then
#	echo "Usage: $0 <aws_access_key> <aws_secret_key>"
#	exit 1
#fi

# Generate the SSH key pair, if it doesn't exist
if [[ ! -f "id_rsa_example" ]]; then
	echo "Generating 4096-bit RSA SSH key pair. This can take a few seconds."
	ssh-keygen -t rsa -b 4096 -f id_rsa_example -N ""
fi

# Grab our external IP for the security groups
MANAGEMENT_IP=$(curl -s http://ipinfo.io/ip)
[[ ! "$MANAGEMENT_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && echo "Couldn't determine your external IP: $MANAGEMENT_IP" && exit 1

# Run terraform to create the resources
cd terraform
##terraform plan -var "management_ip=$MANAGEMENT_IP"
terraform apply -var "management_ip=$MANAGEMENT_IP"

# Verify that the load balancer works as expected
echo "Provisioning complete:"
##curl -s $(terraform output lb-ip)
####echo
####curl -s $(terraform output lb-ip)
echo
