# Terraform Bug Reproduction

This is for https://github.com/hashicorp/terraform-provider-azurerm/issues/22379#issuecomment-1754269602

## Reproduction Steps

1. Create Resource Group and Storage account to store Terraform state
2. Apply terraform and provide a docker_registry_password
3. Change the value of RANDOM_ENV_VAR to something else and apply again.
    - Terraform will show a change in the docker_registry_password but nothing else.
4. Run a second terraform apply: the application stack now needs to be updated.

## Expected Behavior

Terraform should not touch the following variables:
- DOCKER_REGISTRY_SERVER_URL
- DOCKER_REGISTRY_SERVER_USERNAME
- DOCKER_REGISTRY_SERVER_PASSWORD

## Workaround

Whenever doing a change to app_settings, uncomment the DOCKER_REGISTRY variables so they also get applied together with the RANDOM_ENV_VAR. However leaving the workaround in permanently is also not an option, since terraform wants to update them every time.

## Side Note

We have a setup where we ignore the docker_image_name (see commented out lifecycle block), as it is set by our ci and deployed quite often and independently of terraform runs. However it does not seem to have any impact on the described behavior.