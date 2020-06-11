export DataCenterZone=ams03
export ClusterName="myopenshift"


ibmcloud login -a https://api.eu-de.bluemix.net -r eu-de -u rahmed@redhat.com -p xxxxx -c 63cf37b8c3bb448cbf9b7507cc8ca57d -g benelux

ibmcloud cos delete-bucket --bucket "$ClusterName"-bucket --force

ibmcloud resource service-key-delete "$ClusterName"-creds -f

ibmcloud resource service-instance-delete "$ClusterName"-cos -f

ibmcloud oc cluster rm --cluster $ClusterName -f

exit;
