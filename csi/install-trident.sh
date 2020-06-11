set -x

TRIDENT_VERSION=20.01.1
TRIDENT_PROJ=trident-ns

wget https://github.com/NetApp/trident/releases/download/v${TRIDENT_VERSION}/trident-installer-${TRIDENT_VERSION}.tar.gz

tar -xf trident-installer-${TRIDENT_VERSION}.tar.gz

cd trident-installer


oc adm new-project ${TRIDENT_PROJ} --node-selector="region=infra"


tridentctl install -n ${TRIDENT_PROJ}

oc get pod -n ${TRIDENT_PROJ} -w

mkdir ./ocp_setup

#cp ./sample-input/backend-ontap-nas.json ./ocp_setup/backend-ontap-nas.json
cat <<EOT >> ./ocp_setup/backend_nas.json
{
    "debug":true,
    "version": 1,
    "storageDriverName": "ontap-nas",
    "managementLIF": "10.147.12.242",
    "dataLIF": "10.147.12.242",
    "svm": "ocp",
    "username": "vsadmin",
    "password": "01temporal",
    "storagePrefix": "ocp"
}
EOT

tridentctl create backend -f ./ocp_setup/backend_nas.json -n ${TRIDENT_PROJ}

#cp ./sample-input/storage-class-ontapnas-gold.yaml ./ocp_setup/storage-class-ontapnas-gold.yaml
cat <<EOT >> ./ocp_setup/sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ontap-gold
provisioner: netapp.io/trident
parameters:
  backendType: "ontap-nas"
#  media: "ssd"
  provisioningType: "thin"
  snapshots: "true"
  encryption: "true"
EOT


oc create -f ./ocp_setup/sc.yaml

#cp ./sample-input/storage-class-ontapnas-gold.yaml ./ocp_setup/storage-class-ontapnas-gold.yaml

cat <<EOT >> ./ocp_setup/pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: full
  annotations:
    volume.beta.kubernetes.io/storage-class: ontap-gold
    trident.netapp.io/reclaimPolicy: "Retain"
    trident.netapp.io/exportPolicy: "default"
    trident.netapp.io/snapshotPolicy: "default-1weekly"
#    trident.netapp.io/protocol: "file"
#    trident.netapp.io/snapshotDirectory: "false"
#    trident.netapp.io/unixPermissions: "---rwxrwxrwx"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Mi
  storageClassName: "ontap-gold"
EOT

oc create -f ./ocp_setup/pvc.yaml

