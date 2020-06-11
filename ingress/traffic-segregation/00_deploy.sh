export Version=v0.12.4
export DownloadUrl="https://github.com/bitnami-labs/sealed-secrets/releases/download/${Version}/controller.yaml"

curl -L ${DownloadUrl} --output ./base/controller.yaml

oc apply -k base/

wget https://github.com/bitnami-labs/sealed-secrets/releases/download/${Version}/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

exit;
