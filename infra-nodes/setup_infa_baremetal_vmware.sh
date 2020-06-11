
for host in infra1.cluster.corp infra2.cluster.corp infra3.cluster.corp
do
printf "%s" ${host}
oc label node ${host} node-role.kubernetes.io/infra=""
# oc label node ${host} node-role.kubernetes.io/worker-
oc patch node ${host} --type=merge -p '{"spec":{"taints": [{ "key":"infra", "value":"reserved", "effect":"NoSchedule"},{ "key":"infra", "value":"reserved", "effect":"NoExecute"}]}}'
done


# oc create -f ./infra-mcp.yaml

# Optional 
# Adding this cause debug node to fail to schedule on masters, should not be the case as the default node selector is ony a suggestion

oc patch scheduler cluster --type=merge -p '{"spec":{"defaultNodeSelector": "node-role.kubernetes.io/worker="}}'

# oc debug node/invd086.nxdi.nl-htc01.nxp.com --> Fail Generated from kubelet on invd088.nxdi.nl-htc01.nxp.com Predicate MatchNodeSelector failed
# you can overcome this issue by oc adm new-project debug --node-selector=""



#Then any node which have taint fail to schedule any debug node pod due to the taint controller. Generated from taint-controller Marking for deletion Pod argocd/invd094nxdinl-htc01nxpcom-debug
# I reported a bug https://bugzilla.redhat.com/show_bug.cgi?id=1822211 & KB was published https://access.redhat.com/solutions/4976641

# Add a toleration on a "debug" namespace allowing the debug pod to run:
# oc patch namespace debug --type=merge -p '{"metadata": {"annotations": { "scheduler.alpha.kubernetes.io/defaultTolerations": "[{\"operator\": \"Exists\"}]"}}}'


# allow the daemonsets to work on taint nodes, altough dns-default ds is also impacted but it is not reuired to have it running on all nodes (it is a must to run to masters at least) 
oc patch ds machine-config-daemon -n openshift-machine-config-operator  --type=merge -p '{"spec": {"template": { "spec": {"tolerations":[{"operator":"Exists"}]}}}}'

oc patch ds node-ca -n openshift-image-registry --type=merge -p '{"spec": {"template": { "spec": {"tolerations":[{"operator":"Exists"}]}}}}'



# https://docs.openshift.com/container-platform/4.3/machine_management/creating-infrastructure-machinesets.html#moving-resources-to-infrastructure-machinesets

oc patch ingresscontroller default -n openshift-ingress-operator --type=merge -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}},"tolerations":[{"effect":"NoSchedule","key":"infra","operator":"Exists"},{"effect":"NoExecute","key":"infra","operator":"Exists"}]}}}'


oc patch configs.imageregistry.operator.openshift.io/cluster -n openshift-image-registry --type=merge -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""},"tolerations":[{"effect":"NoSchedule","key":"infra","value":"reserved"},{"effect":"NoExecute","key":"infra","value":"reserved"}]}}'

# Moving the monitoring comp
oc apply -f ./cluster-monitoring-config.yaml

# Missing on Request

# Moving the cluster logging resources

