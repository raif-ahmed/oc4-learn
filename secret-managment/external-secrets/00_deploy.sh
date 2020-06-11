export DownloadUrl="https://github.com/godaddy/kubernetes-external-secrets.git"
export InstanaceName=dev
export Namespace="kubernetes-external-secrets"
git clone ${DownloadUrl}

helm template ${InstanaceName} --namespace ${Namespace} -f kubernetes-external-secrets/charts/kubernetes-external-secrets/values.yaml --output-dir ./output_dir ./kubernetes-external-secrets/charts/kubernetes-external-secrets/

mv output_dir/kubernetes-external-secrets/templates base/

rm -Rf kubernetes-external-secrets output_dir

oc apply -k  overlays/alibaba/

exit;
