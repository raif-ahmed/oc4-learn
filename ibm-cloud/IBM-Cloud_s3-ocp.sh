export ClusterName="newopenshift"

#Switch kubeconfig context
ibmcloud oc cluster config --cluster $ClusterName --admin

# Creating the IBM object storage service
ibmcloud resource service-instance-create "$ClusterName"-cos cloud-object-storage standard global

export COSServiceId=$(ibmcloud resource service-instance "$ClusterName"-cos --output json | jq '.[]'|  jq .'crn')

COSServiceId=$(sed -e 's/^"//' -e 's/"$//' <<<"$COSServiceId")


echo "COSServiceId=$COSServiceId"

# Creating credentials for IBM object storage service
ibmcloud resource service-key-create "$ClusterName"-creds Writer --instance-name "$ClusterName"-cos --parameters '{"HMAC":true}'

export CredServiceKeyId=$(ibmcloud resource service-key "$ClusterName"-creds --output json | jq '.[]'|  jq .'crn')
export AccessKeyId=$(ibmcloud resource service-key "$ClusterName"-creds --output json | jq '.[]'|  jq .'credentials.cos_hmac_keys.access_key_id')
export SecretAccessKey=$(ibmcloud resource service-key "$ClusterName"-creds --output json | jq '.[]'|  jq .'credentials.cos_hmac_keys.secret_access_key')

AccessKeyId=$(sed -e 's/^"//' -e 's/"$//' <<<"$AccessKeyId")
SecretAccessKey=$(sed -e 's/^"//' -e 's/"$//' <<<"$SecretAccessKey")


export BucketName="$ClusterName"-bucket
echo "BucketName=$BucketName"

ibmcloud cos config auth --method IAM

# Creating bucket
ibmcloud cos create-bucket --bucket "$BucketName" --ibm-service-instance-id $COSServiceId --region eu-de

# OCP, the fun begin
oc create secret generic image-registry-private-configuration-user --from-literal=REGISTRY_STORAGE_S3_ACCESSKEY="$AccessKeyId" --from-literal=REGISTRY_STORAGE_S3_SECRETKEY="$SecretAccessKey" --namespace openshift-image-registry

#TODO: I want to use encrypt, keyID to integarte with IBM KMS and encrypt images .. WIP

oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge -p '{"spec":{"storage":{"pvc":null,"s3":{"bucket":"'$BucketName'","region":"eu-de","regionEndpoint":"s3.direct.eu-de.cloud-object-storage.appdomain.cloud"}}}}'

exit;
