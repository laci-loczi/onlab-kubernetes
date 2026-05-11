param (
    [Parameter(Mandatory=$true)]
    [string]$StudentName
)

$StudentName = $StudentName.ToLower()
$Namespace = "student-$StudentName"

Write-Host "======================================================="
Write-Host " KUBERNETES HALLGATOI KORNYEZET LETREHOZASA: $StudentName"
Write-Host "======================================================="

$yamlLines = @(
"# =========================================="
"# $StudentName hallgato automatikusan generalt kornyezete"
"# =========================================="

"apiVersion: v1"
"kind: Namespace"
"metadata:"
"  name: $Namespace"
"  labels:"
"    pod-security.kubernetes.io/enforce: restricted"
"    pod-security.kubernetes.io/enforce-version: latest"

"---"

"apiVersion: v1"
"kind: ServiceAccount"
"metadata:"
"  name: $StudentName"
"  namespace: $Namespace"

"---"

"apiVersion: rbac.authorization.k8s.io/v1"
"kind: Role"
"metadata:"
"  name: student-role"
"  namespace: $Namespace"
"rules:"
"- apiGroups: ['']"
"  resources: ['pods', 'services', 'configmaps', 'persistentvolumeclaims']"
"  verbs: ['get', 'list', 'create', 'update', 'delete', 'watch']"

"- apiGroups: ['apps']"
"  resources: ['deployments']"
"  verbs: ['get', 'list', 'create', 'update', 'delete']"

"---"

"apiVersion: rbac.authorization.k8s.io/v1"
"kind: RoleBinding"
"metadata:"
"  name: $StudentName-binding"
"  namespace: $Namespace"
"subjects:"
"- kind: ServiceAccount"
"  name: $StudentName"
"  namespace: $Namespace"

"roleRef:"
"  kind: Role"
"  name: student-role"
"  apiGroup: rbac.authorization.k8s.io"

"---"

"apiVersion: v1"
"kind: ResourceQuota"
"metadata:"
"  name: student-quota"
"  namespace: $Namespace"

"spec:"
"  hard:"
"    requests.cpu: '500m'"
"    requests.memory: 256Mi"
"    requests.storage: '5Gi'"
"    limits.cpu: '1'"
"    limits.memory: 512Mi"
"    pods: '5'"
"    services.nodeports: '0'"
"    services.loadbalancers: '0'"

"---"

"apiVersion: v1"
"kind: LimitRange"
"metadata:"
"  name: student-limitrange"
"  namespace: $Namespace"

"spec:"
"  limits:"
"  - type: Container"
"    default:"
"      cpu: 200m"
"      memory: 128Mi"
"    defaultRequest:"
"      cpu: 100m"
"      memory: 64Mi"
"    max:"
"      cpu: '500m'"
"      memory: 256Mi"
"    min:"
"      cpu: '50m'"
"      memory: 32Mi"
)

$yamlContent = $yamlLines -join "`n"

Write-Host "[+] Eroforrasok telepitese..."

$yamlContent | kubectl apply -f -

Write-Host "[+] Kesz!"
Write-Host "--as=system:serviceaccount:${Namespace}:${StudentName}"