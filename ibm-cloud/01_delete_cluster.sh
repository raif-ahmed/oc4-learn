export DataCenterZone=ams03
export ClusterName="newopenshift"


ibmcloud login --apikey @oc-deploy.key -c 63cf37b8c3bb448cbf9b7507cc8ca57d -g benelux --sso

ibmcloud resource service-instance "$ClusterName"-cos

if [ $? -eq 0 ]
then
  export COSServiceId=$(ibmcloud resource service-instance "$ClusterName"-cos --output json | jq '.[]'|  jq .'crn')
  COSServiceId=$(sed -e 's/^"//' -e 's/"$//' <<<"$COSServiceId")
  echo "$COSServiceId"
  ibmcloud cos config auth --method IAM
  ibmcloud cos config crn --crn $COSServiceId --force

  ibmcloud cos delete-bucket --bucket "$ClusterName"-bucket 
  if [ $? -eq 0 ]
  then
    echo "Bucket Deleted Successfully, deleteing service"
    ibmcloud resource service-key-delete "$ClusterName"-creds -f
    ibmcloud resource service-instance-delete "$ClusterName"-cos -f

  else
    echo "Failed to delete Bucket, please try manually"
  fi
else
  echo "Failed to find the requested COS, please try manually"
fi


ibmcloud oc cluster rm --cluster $ClusterName -f


exit;
