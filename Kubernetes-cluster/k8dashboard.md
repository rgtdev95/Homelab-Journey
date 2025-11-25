# Kubernetes Dashboard Setup

## 1. Install Dashboard with Helm
Run the following command to install or upgrade the Kubernetes Dashboard using Helm:

```bash
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --version 7.14.0
```

## 2. Create Admin User
Apply the `admin-sa.yaml` file to create the admin user:

```bash
kubectl apply -f ~/kubernetes-addons/dashboard/admin-sa.yaml
```

### `admin-sa.yaml` File Content
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: dashboard-admin
  namespace: kubernetes-dashboard
```

## 3. Configure Manual Ingress
Since the Helm chart does not configure ingress, create the `ingress.yaml` file manually:

```bash
cat > ~/kubernetes-addons/dashboard/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dashboard
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: k8-dashboard.internal.rtg-homelabs.tech
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard-kong-proxy
            port:
              number: 443
  tls:
  - hosts:
    - k8-dashboard.internal.rtg-homelabs.tech
EOF

kubectl apply -f ~/kubernetes-addons/dashboard/ingress.yaml
```

### `ingress.yaml` File Content
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dashboard
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: k8-dashboard.internal.rtg-homelabs.tech
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard-kong-proxy
            port:
              number: 443
  tls:
  - hosts:
    - k8-dashboard.internal.rtg-homelabs.tech
```

## 4. Generate Login Token
To generate a login token for the dashboard admin, run the following command:

```bash
kubectl -n kubernetes-dashboard create token dashboard-admin --duration=8760h
```