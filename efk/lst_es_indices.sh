oc exec elasticsearch-cdm-coglxh59-1-587f47798c-wglt8 -n openshift-logging -- curl -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://localhost:9200/_cat/indices?v

# To delete a specific index
#oc exec -c elasticsearch $es_pod -n openshift-logging -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XDELETE https://localhost:9200/.myindex

#Ran the following command to make sure the shards were assigned:  
oc exec elasticsearch-cdm-3bv2fogl-1-7f7c59766f-qrsbt  -c elasticsearch -- es_util --query=_cluster/settings?pretty=true -XPUT 'https://localhost:9200/_cluster/settings' -d '{ "transient": { "cluster.routing.allocation.enable" : "all" } }'

