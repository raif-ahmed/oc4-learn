oc create -f yaml/eo-namespace.yaml

oc create -f yaml/eo-og.yaml

oc create -f yaml/eo-csc.yaml

oc create -f yaml/eo-sub.yaml

oc create -f yaml/eo-rbac.yaml


oc create -f yaml/clo-namespace.yaml

oc create -f yaml/clo-og.yaml

oc create -f yaml/clo-sub.yaml

oc create -f yaml/cluster-logging-instance-no-node-selector.yaml

# oc patch namespace openshift-marketplace --type=merge -p '{"metadata":{"annotations":{"scheduler.alpha.kubernetes.io/defaultTolerations":"[{\"key\":\"infra\",\"value\":\"reserved\",\"operator\":\"Equal\"}]"}}}'
