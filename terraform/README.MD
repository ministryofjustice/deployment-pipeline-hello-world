Install aws-vault

`brew cask install aws-vault`

This means we can support our preferred security configuration of having MFA enabled for IAM user
accounts. See [this GitHub issue for more context as to why aws-vault is needed](https://github.com/terraform-providers/terraform-provider-aws/issues/2420).

Configure your AWS CLI install as per [the Identity Access Management Confluence page](https://dsdmoj.atlassian.net/wiki/spaces/LM/pages/293536178/Identity+Access+Management).

`aws-vault add laa-shared-services`

This configures aws-vault to contain the details needed to interact with terraform (namely MFA session management).

Initiate Terraform with:

`aws-vault exec laa-shared-services-lz -- terraform init`

Switch to the desired workspace with:

`aws-vault exec laa-shared-services-lz -- terraform workspace select development`

Then you should be able to run terraform, similar to:

`aws-vault exec laa-shared-services-lz -- terraform plan`

You might be prompted for your MFA token, but the plan should be created.
