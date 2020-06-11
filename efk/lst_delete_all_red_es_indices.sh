es_pod=NAME-OF-ELASTICSEARCH-POD


oc exec -c elasticsearch  $es_pod -- curl -s -k --cert /etc/elasticsearch/secret/admin-cert --key /etc/elasticsearch/secret/admin-key https://localhost:9200/_cat/indices?v | grep -w 'red' | awk '{print $3}' > /tmp/indices.out

//Check the indices look correct
cat /tmp/indices.out

//Delete the list of indices
for i in $(cat /tmp/indices.out); 
do 
oc exec -c elasticsearch $es_pod -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XDELETE https://localhost:9200/$i ; 
done
