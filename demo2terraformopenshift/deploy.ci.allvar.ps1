$ARM_CLIENT_ID='changeme'
$ARM_CLIENT_SECRET='changeme'
$ARM_SUBSCRIPTION_ID='changeme'
$ARM_TENANT_ID='changeme'
$KEY='OCPPrefix'
$PASSWORD='P4ssw0rd1'
$KEY_VAULT_RESOURCE_GROUP='permanent'
$KEY_VAULT_NAME='TerraformVault'
$KEY_VAULT_SECRET='OpenShiftSSH'
$OS_PUBLIC_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfo8KzhpChsu6D/Mfj5MxJRDbtPJip3JbTsrR0cxfs8aftcauo7uTZikOBmECWkd2fzHPHm3FD+/3ImWHGPmgMkcnWF7YwoQq8JsDLNljdy4dDLapPx7gssISJLHDuvTdRFRlTGx2E8mjtJdbhmnTlgy4CsYPOiXt9Pz5q04c8kWYVcMfeBDNCAT2vSG4UzwmEikIbGHJouBCUTVp+kRcf9Gvx/aXA4M0e6Qo/Cwk0Aaxw9agOe8Sibo8+DrNBPE30JXy/FfiKVXsc+FFQH2wNh2RAlfQZDicEuQL7YrPw1nGDdPhtmjMI0YFJ0gTBNk+LV2m3rtGIxfaChzISukXn gabriel@GAB-MSFT-SB2'
$CONTAINER_PRIVATE_KEY_PATH='$HOME/.ssh/id_rsa'
$LOCAL_SCRIPT_PATH='$HOME/scripts'
$MASTER_COUNT=1
$INFRA_COUNT=1
$NODE_COUNT=1

docker run --rm -it `
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID `
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET `
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID `
  -e ARM_TENANT_ID=$ARM_TENANT_ID `
  -e KEY=$KEY `
  -e PASSWORD=$PASSWORD `
  -e KEY_VAULT_RESOURCE_GROUP=$KEY_VAULT_RESOURCE_GROUP `
  -e KEY_VAULT_NAME=$KEY_VAULT_NAME `
  -e KEY_VAULT_SECRET=$KEY_VAULT_SECRET `
  -e OS_PUBLIC_KEY=$OS_PUBLIC_KEY `
  -e CONTAINER_PRIVATE_KEY_PATH=$CONTAINER_PRIVATE_KEY_PATH `
  -e LOCAL_SCRIPT_PATH=$LOCAL_SCRIPT_PATH `
  -e MASTER_COUNT=$MASTER_COUNT `
  -e INFRA_COUNT=$INFRA_COUNT `
  -e NODE_COUNT=$NODE_COUNT `
  --volume "c:\Users\gabechar\OneDrive - Microsoft\msft\azuredemos\demo2terraformopenshift:/demo2terraformopenshift" `
  --workdir /demo2terraformopenshift  `
  --entrypoint "/bin/sh" `
  hashicorp/terraform:light `
  -c "/bin/terraform init; \
      /bin/terraform get; \
      /bin/terraform validate \
        -var subscription_id=$ARM_SUBSCRIPTION_ID \
        -var tenant_id=$ARM_TENANT_ID \
        -var aad_client_id=$ARM_CLIENT_ID \
        -var aad_client_secret=$ARM_CLIENT_SECRET \
        -var resource_group_name=$KEY \
        -var key_vault_name=$KEY_VAULT_NAME \
        -var key_vault_resource_group=$KEY_VAULT_RESOURCE_GROUP \
        -var key_vault_secret=$KEY_VAULT_SECRET \
        -var openshift_cluster_prefix=$KEY \
        -var openshift_password=$PASSWORD \
        -var openshift_script_path=$LOCAL_SCRIPT_PATH \
        -var connection_private_ssh_key_path=$CONTAINER_PRIVATE_KEY_PATH \
        -var master_instance_count=$MASTER_COUNT \
        -var infra_instance_count=$INFRA_COUNT \
        -var node_instance_count=$NODE_COUNT; \
      /bin/terraform plan -out=out.tfplan \
        -var subscription_id=$ARM_SUBSCRIPTION_ID \
        -var tenant_id=$ARM_TENANT_ID \
        -var aad_client_id=$ARM_CLIENT_ID \
        -var aad_client_secret=$ARM_CLIENT_SECRET \
        -var resource_group_name=$KEY \
        -var key_vault_name=$KEY_VAULT_NAME \
        -var key_vault_resource_group=$KEY_VAULT_RESOURCE_GROUP \
        -var key_vault_secret=$KEY_VAULT_SECRET \
        -var openshift_cluster_prefix=$KEY \
        -var openshift_password=$PASSWORD \
        -var openshift_script_path=$LOCAL_SCRIPT_PATH \
        -var connection_private_ssh_key_path=$CONTAINER_PRIVATE_KEY_PATH \
        -var master_instance_count=$MASTER_COUNT \
        -var infra_instance_count=$INFRA_COUNT \
        -var node_instance_count=$NODE_COUNT; \
      /bin/terraform apply out.tfplan;"
