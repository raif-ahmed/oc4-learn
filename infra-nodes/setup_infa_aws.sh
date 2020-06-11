

export WorkerInstanceType=m5.4xlarge

# distrbute machinesets in three different zones
for i in {1..3};do \
  AZ=$(aws ec2 describe-subnets --subnet-id $(echo $PrivateSubnetIds | cut -d, -f$i) | jq -r '.Subnets[0].AvailabilityZone')

  cat ./09_new-machineset.json \
    | jq -s '.[]
    | .metadata.labels."machine.openshift.io/cluster-api-cluster"="'"$INFRA_ID"'"
    | .metadata.name="'"$INFRA_ID"'-infra-'"$AZ"'"
    | .spec.selector.matchLabels."machine.openshift.io/cluster-api-cluster"="'"$INFRA_ID"'"
    | .spec.selector.matchLabels."machine.openshift.io/cluster-api-machineset"="'"$INFRA_ID"'-infra-'"$AZ"'"
    | .spec.template.metadata.labels."machine.openshift.io/cluster-api-cluster"="'"$INFRA_ID"'"
    | .spec.template.metadata.labels."machine.openshift.io/cluster-api-machineset"="'"$INFRA_ID"'-infra-'"$AZ"'"
    | .spec.template.spec.metadata.labels."infra"="infra"
    | .spec.template.spec.metadata.labels."node-role.kubernetes.io/infra"=""
    | .spec.template.spec.providerSpec.value.ami.id="'"$AMIID"'"
    | .spec.template.spec.providerSpec.value.iamInstanceProfile.id="'"$WorkerInstanceProfile"'"
    | .spec.template.spec.providerSpec.value.iamInstanceType="'"$WorkerInstanceType"'"
    | .spec.template.spec.providerSpec.value.placement.availabilityZone="'"$AZ"'"
    | .spec.template.spec.providerSpec.value.placement.region="'"$REGION"'"
    | .spec.template.spec.providerSpec.value.securityGroups[].filters[].name="group-id"
    | .spec.template.spec.providerSpec.value.securityGroups[].filters[].values[]="'"$WorkerSecurityGroupId"'"
    | .spec.template.spec.providerSpec.value.subnet.filters[].name="subnet-id"
    | .spec.template.spec.providerSpec.value.subnet.filters[].values[]="'"$(echo $PrivateSubnetIds | cut -d, -f$i)"'"
    | .spec.template.spec.providerSpec.value.tags[].name="kubernetes.io/cluster/'"$INFRA_ID"'"' \
    | oc create -n openshift-machine-api -f -;
done

oc patch scheduler cluster --type=merge -p '{"spec":{"defaultNodeSelector": "node-role.kubernetes.io/worker="}}'

# allow the daemonsets to work on taint nodes
oc patch ds machine-config-daemon -n openshift-machine-config-operator  --type=merge -p '{"spec": {"template": { "spec": {"tolerations":[{"operator":"Exists"}]}}}}'

oc patch ds node-ca -n openshift-image-registry --type=merge -p '{"spec": {"template": { "spec": {"tolerations":[{"operator":"Exists"}]}}}}'

oc patch namespace openshift-dns --type=merge -p '{"metadata": {"annotations": { "scheduler.alpha.kubernetes.io/defaultTolerations": "[{\"operator\": \"Exists\"}]"}}}'


# https://docs.openshift.com/container-platform/4.3/machine_management/creating-infrastructure-machinesets.html#moving-resources-to-infrastructure-machinesets

oc patch ingresscontroller default -n openshift-ingress-operator --type=merge -p '{"spec":{"nodePlacement": {"nodeSelector": {"matchLabels": {"node-role.kubernetes.io/infra":""}}}}}'

oc patch configs.imageregistry.operator.openshift.io/cluster -n openshift-image-registry --type=merge -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""}}}'

# Moving the monitoring comp
oc apply -f ./cluster-monitoring-config.yaml

# Missing on Request

# Moving the cluster logging resources

