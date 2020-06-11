# $1 is kind (User, Group, ServiceAccount)
# $2 is name ("system:nodes", etc)
# $3 is namespace (optional, only applies to kind=ServiceAccount)
function getRoles() {
    local kind="${1}"
    local name="${2}"
    local namespace="${3:-}"

    kubectl get clusterrolebinding -o json | jq -r "
      .items[]
      | 
      select(
        .subjects[]?
        | 
        select(
            .kind == \"${kind}\" 
            and
            .name == \"${name}\"
            and
            (if .namespace then .namespace else \"\" end) == \"${namespace}\"
        )
      )
      |
      (.roleRef.kind + \"/\" + .roleRef.name)
    "
}

# getRoles Group system:authenticated

# getRoles ServiceAccount attachdetach-controller kube-system

