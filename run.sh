#!/bin/bash
# Run the provisioning example.
# We have a few prerequisites

if [[ ! -x "$(which which)" ]]
then
        yum -y install which
fi

if [[ ! -x "$(which wget)" ]]
then
	yum -y install wget
fi
if [[ ! -x "$(which terraform)" ]]
then 
	wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
	unzip terraform_0.11.8_linux_amd64.zip
	mv terraform /usr/bin/
        rm -rf terraform_0.11.8_linux_amd64.zip
fi
if [[ ! -x "$(which curl)" ]]
then
	yum -y install curl
fi
if [[ ! -x "$(which chef-solo)" ]]
then 
	curl -L https://www.opscode.com/chef/install.sh | bash
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
terraform plan -var "management_ip=$MANAGEMENT_IP" -var-file=terraform.tfvars
##terraform apply -var "management_ip=$MANAGEMENT_IP"

# Verify that the load balancer works as expected
echo "Provisioning complete:"
##curl -s $(terraform output lb-ip)
####echo
####curl -s $(terraform output lb-ip)
echo
