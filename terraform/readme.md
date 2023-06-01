# terraform iac code for proposed architecture

this is divided into 2 parts 
1. apigateway folder that contains the iac for apigateway, vpclinks and cognito userpool
2. the rest of the resources used are availale in the main folder 

## instructions to deploy 

1.deploy the iac in the main terraform folder initially this will output the nlb dns name and arn that we need to pass in a terraform.tfvars file to the apigateway iac

2 .deploy the apigatway iac next to complete the infra

## steps to deploy

### go to the respective folder and do
1. terraform init
2. terraform plan 
3. terraform apply


## delete the infra

### go to the respective folder and do
1. terraform delete