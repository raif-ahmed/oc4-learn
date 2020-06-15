oc new-project sample1
oc new-app httpd

oc new-project sample2
oc new-app httpd

sleep 2m

# From sample1 call sample2
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080
# From sample1 call sample1
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080

# From sample2 call sample1
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080
# From sample2 call sample2
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080

# Ensure that this label exists (IBM cloud bug)
#oc label namespace/openshift-ingress network.openshift.io/policy-group=ingress

export networkType=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default --output jsonpath='{.status.endpointPublishingStrategy.type}')


if [ "$networkType" = "HostNetwork" ]; then
    echo "label default namespace" 
    oc label namespace/default 'network.openshift.io/policy-group=ingress'
fi




oc apply -f networkPolicy.yaml -n sample2

# From sample1 call sample2 -- It should fail
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080
# From sample1 call sample1
oc exec -n sample1 $(oc get po -n sample1 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080

# From sample2 call sample1
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample1.svc.cluster.local:8080
# From sample2 call sample2
oc exec -n sample2 $(oc get po -n sample2 -l deploymentconfig=httpd -o name) -- curl --max-time 2 http://httpd.sample2.svc.cluster.local:8080

export POD_IP=$(oc get po -l deploymentconfig=httpd -n sample2 -o=jsonpath="{.items[0].status.podIP}")

# Now test from ingress as it should successes 
oc exec -n openshift-ingress $(oc get po -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default --all-namespaces -o name |head -1) -- curl --max-time 2 http://${POD_IP}:8080


