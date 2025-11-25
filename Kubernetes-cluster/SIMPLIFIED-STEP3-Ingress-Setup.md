# Step 3: Ingress-NGINX Setup for External Access

**Run on:** Master node only (10.0.0.108)  
**Time:** ~20 minutes  
**Prerequisites:** Step 1 & 2 completed, cluster is running

---

## 🎯 Overview

**What is Ingress?**
- Acts as a "smart router" for your cluster
- Routes HTTP/HTTPS traffic from outside to services inside
- Replaces need for multiple NodePorts or LoadBalancers
- Enables domain-based routing (e.g., grafana.internal → Grafana service)

**Traffic Flow:**
```
Your Browser
    ↓
grafana.internal (DNS resolves to 10.0.0.108)
    ↓
Master Node 10.0.0.108:32080 (NodePort)
    ↓
Ingress-NGINX Service (load balances to Ingress pods)
    ↓
Grafana Service → Grafana Pod
```

---

## 📦 Part 1: Install Ingress-NGINX

**Why "bare-metal" version?**  
Cloud providers (AWS, GCP, Azure) provide automatic LoadBalancers. Home labs don't have this, so we use the bare-metal configuration with NodePort.

### 1.1 Deploy Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/baremetal/deploy.yaml
```

**What this installs:**
- Namespace: `ingress-nginx`
- NGINX Ingress Controller deployment (2 pods by default)
- Service with NodePort type
- ConfigMaps and webhooks for configuration

### 1.2 Wait for Deployment

```bash
# Check pods are running (wait 1-2 minutes)
kubectl get pods -n ingress-nginx

# Watch until all pods are Running or Completed
kubectl get pods -n ingress-nginx -w
```

**Expected output:**

```
NAME                                        READY   STATUS
ingress-nginx-admission-create-xxx          0/1     Completed
ingress-nginx-admission-patch-xxx           0/1     Completed
ingress-nginx-controller-xxx                1/1     Running
ingress-nginx-controller-yyy                1/1     Running
```

**Note:** Admission jobs show "Completed" - this is normal. They run once during installation.

---

## 🔌 Part 2: Understand NodePort Exposure

### 2.1 Check Service Configuration

kubectl get svc -n ingress-nginx
```

**Expected output:**

```
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
ingress-nginx-controller             NodePort    10.96.173.148   <none>        80:32080/TCP,443:32443/TCP
ingress-nginx-controller-admission   ClusterIP   10.96.xxx.xxx   <none>        443/TCP
```

**Important ports:**
- `80:32080` - HTTP traffic → NodePort 32080
- `443:32443` - HTTPS traffic → NodePort 32443

### 2.2 How NodePort Works

**Key concept:** NodePort opens the same port on **every node** in your cluster.

You can access Ingress through:
- `http://10.0.0.108:32080` (master)
- `http://10.0.0.112:32080` (worker1)
- `http://10.0.0.109:32080` (worker2)

All requests are load-balanced to the Ingress Controller pods (which run on worker nodes only by default).

**Best practice:** Use one entry point (master IP) for DNS.

---

## 📝 Part 3: Create Ingress Resource for Grafana

**What is an Ingress Resource?**
- Defines routing rules
- Maps domain names to services
- Can handle multiple domains in one file

### 3.1 Create Ingress Configuration

```bash
# Create config directory
mkdir -p ~/kubernetes-addons/ingress
cd ~/kubernetes-addons/ingress

# Create the Ingress file
nano grafana-ingress.yaml
```

**Paste this configuration:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    # Tell Kubernetes to use NGINX Ingress Controller
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  # Define routing rule for grafana.internal
  - host: grafana.internal
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            # Must match your Grafana service name
            name: prometheus-grafana
            port:
              number: 80
```

**Configuration explained:**

| Field | Purpose |
|-------|---------|
| `name: grafana-ingress` | Name of this Ingress resource |
| `namespace: monitoring` | Must match Grafana's namespace |
| `kubernetes.io/ingress.class` | Tells Kubernetes which Ingress controller to use |
| `host: grafana.internal` | Domain name for routing |
| `path: /` | Route all paths under this domain |
| `pathType: Prefix` | Match all paths starting with `/` |
| `service.name` | Backend service name (check with `kubectl get svc -n monitoring`) |
| `service.port.number: 80` | Grafana service port |

### 3.2 Apply Configuration

```bash
kubectl apply -f grafana-ingress.yaml
```

### 3.3 Verify Ingress

```bash
# Check Ingress was created
kubectl get ingress -n monitoring

# See detailed configuration and status
kubectl describe ingress grafana-ingress -n monitoring
```

**Expected output:**

```
NAME               CLASS   HOSTS              ADDRESS         PORTS   AGE
```

**Important fields:**
- `ADDRESS` - Internal service IP
- `PORTS: 80` - HTTP enabled

---

## 🌐 Part 4: Configure DNS/Hosts

**Problem:** Your browser doesn't know what `grafana.internal` means.

**Solution:** Add DNS entry or local hosts file entry.

### Option A: Local Machine Hosts File (Quick Test)

**On your laptop/desktop:**

**Linux/Mac:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```
notepad C:\Windows\System32\drivers\etc\hosts
```

**Add this line:**
```
10.0.0.108   grafana.internal
```

**Explanation:** Routes all `grafana.internal` requests to master node (10.0.0.108)

---

### Option B: Internal DNS Server (Recommended)

**If you have Pi-hole, Unbound, or pfSense:**

Add DNS record:
```
grafana.internal → A record → 10.0.0.108
```

**Benefits:**
- Works for all devices on your network
- No need to edit hosts files on every device
- More professional setup

---

## 🧪 Part 5: Test Ingress Access

### 5.1 Test Using NodePort Directly

**From your laptop browser:**

```
http://10.0.0.108:32080/
```

**Expected:** Should show "404 Not Found" (this is good! Ingress is working, just no route for `/`)

### 5.2 Test Using Domain Name (HTTP)

**From your laptop browser:**

```
http://grafana.internal:32080/
```

**Expected:** Grafana login page

**Login credentials:**
- Username: `admin`
- Password: `admin123` (from Step 2 configuration)

### 5.3 Test Without Port (Standard HTTP)

**To remove `:32080` from URL, you need to:**
1. Forward port 80 to 32080 on your router/firewall, OR
2. Use a reverse proxy (like Nginx on a separate server), OR
3. Use Cloudflare Tunnel (next step in your setup)

**For now, using `:32080` is expected and correct.**

---

## 📊 Part 6: Verify Full Setup

### 6.1 Check Where Ingress Pods Are Running

```bash
kubectl get pods -n ingress-nginx -o wide
```

**Expected output:**

```
NAME                                    READY   NODE
ingress-nginx-controller-xxx            1/1     ubuntu-k8-node1
ingress-nginx-controller-yyy            1/1     ubuntu-k8-node2
```

**Note:** Ingress pods run on **worker nodes only** (master has a taint preventing non-system pods by default).

### 6.2 Verify Complete Traffic Path

```bash
# 1. Check Ingress Service
kubectl get svc -n ingress-nginx ingress-nginx-controller

# 2. Check Grafana Service
kubectl get svc -n monitoring prometheus-grafana

# 3. Check Grafana Pod
kubectl get pods -n monitoring | grep grafana

# 4. Test from within cluster
kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -- curl -I http://prometheus-grafana.monitoring.svc.cluster.local
```

---

## 🎨 Part 7: Add More Services to Ingress

**You can route multiple services through one Ingress:**

```bash
nano multi-service-ingress.yaml
```

**Example with multiple services:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  # Grafana on grafana.internal
  - host: grafana.internal
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
  
  # Prometheus on prometheus.internal
  - host: prometheus.internal
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-kube-prometheus-prometheus
            port:
              number: 9090
```

**Apply:**
```bash
kubectl apply -f multi-service-ingress.yaml
```

**Add to hosts file:**
```
10.0.0.108   grafana.internal prometheus.internal
```

---

## 🔐 Part 8: (Optional) Enable TLS/HTTPS

**For production or advanced setups, add SSL certificates:**

### 8.1 Install Cert-Manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

### 8.2 Create Certificate Issuer

**For self-signed certificates (home lab):**

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

### 8.3 Update Ingress with TLS

```yaml
spec:
  tls:
  - hosts:
    - grafana.internal
    secretName: grafana-tls
  rules:
  - host: grafana.internal
    # ... rest of config
```

**Note:** This is optional for now. Your current setup works with HTTP.

---

## 🔍 Troubleshooting

### Issue: "404 Not Found" for domain

**Symptoms:** `grafana.internal:32080` shows 404

**Solutions:**
1. Verify Ingress rules:
   ```bash
   kubectl describe ingress grafana-ingress -n monitoring
   ```
2. Check service name matches:
   ```bash
   kubectl get svc -n monitoring
   ```
3. Verify host entry in `/etc/hosts` or DNS

---

### Issue: "Connection refused"

**Symptoms:** Browser can't connect to NodePort

**Solutions:**
1. Check Ingress Controller is running:
   ```bash
   kubectl get pods -n ingress-nginx
   ```
2. Verify NodePort is open:
   ```bash
   sudo ss -tulpn | grep 32080
   ```
3. Check firewall rules on master node
4. Verify using master node IP directly

---

### Issue: Ingress Controller pods are pending

**Symptoms:** Ingress pods stuck in "Pending" state

**Solutions:**
1. Check node resources:
   ```bash
   kubectl top nodes
   ```
2. Describe pod for events:
   ```bash
   kubectl describe pod -n ingress-nginx <pod-name>
   ```
3. Check for taints on worker nodes:
   ```bash
   kubectl describe nodes | grep -i taint
   ```

---

## 📋 Cluster Overview After Step 3

**Your complete cluster now has:**

| Component | Namespace | Access Method | Purpose |
|-----------|-----------|---------------|---------|
| **Metrics Server** | kube-system | `kubectl top` | Resource monitoring |
| **Local Path Storage** | local-path-storage | StorageClass | Persistent volumes |
| **Prometheus** | monitoring | Port-forward | Metrics collection |
| **Grafana** | monitoring | `grafana.internal:32080` | Metrics visualization |
| **Ingress-NGINX** | ingress-nginx | NodePorts 32080/32443 | External routing |

**Network Flow:**
```
Internet/LAN
    ↓
DNS (grafana.internal → 10.0.0.108)
    ↓
Master Node :32080 (NodePort)
    ↓
Ingress Service 10.96.173.148 (ClusterIP)
    ↓
Ingress Controller Pods (on workers)
    ↓
Grafana Service 10.96.113.213 (ClusterIP)
    ↓
Grafana Pod 10.244.x.x (on worker node)
```

---

## 🎯 Quick Status Commands

**Save these for daily use:**

```bash
# Overall cluster health
kubectl get nodes -o wide

# Ingress status
kubectl get pods,svc -n ingress-nginx

# Monitoring stack status
kubectl get pods,svc,pvc -n monitoring

# Check Ingress routes
kubectl get ingress -A

# View resource usage
kubectl top nodes
kubectl top pods -A
```

**One-liner for complete status:**
```bash
echo "=== NODES ==="; kubectl get nodes -o wide; \
echo -e "\n=== INGRESS ==="; kubectl -n ingress-nginx get pods -o wide; \
echo -e "\n=== MONITORING ==="; kubectl -n monitoring get pods -o wide; \
echo -e "\n=== STORAGE ==="; kubectl get pvc -A
```

---

## ✅ Verification Checklist

- [ ] Ingress Controller pods are Running on worker nodes
- [ ] NodePorts 32080 and 32443 are accessible
- [ ] Ingress resource shows correct HOST
- [ ] DNS/hosts file configured for `grafana.internal`
- [ ] Grafana accessible at `http://grafana.internal:32080`
- [ ] Can login to Grafana and see dashboards
- [ ] `kubectl top nodes` shows metrics
- [ ] All monitoring pods are Running

---

## ⏭️ Next Steps

**Future enhancements for your cluster:**

1. **Cloudflare Tunnel** - Secure external access without port forwarding
2. **CI/CD Pipeline** - GitHub Actions to auto-deploy apps
3. **Additional Applications** - Deploy your own apps to the cluster
4. **Backup Strategy** - etcd backups, PVC backups
5. **Monitoring Alerts** - Set up alerting in Grafana
6. **Resource Limits** - Set CPU/memory limits on pods

---

## 📁 Final Directory Structure

```
~/kubernetes-addons/
├── metrics-server/
│   └── metrics-server.yaml
├── storage/
│   └── local-path-storage.yaml
├── monitoring/
│   └── prometheus-values.yaml
└── ingress/
    ├── grafana-ingress.yaml
    └── multi-service-ingress.yaml (optional)
```

---

## 📊 Resource Usage Summary

**Total cluster resource consumption:**

| Component | CPU | Memory | Storage | Network Ports |
|-----------|-----|--------|---------|---------------|
| Metrics Server | ~50m | ~100Mi | - | - |
| Storage Provisioner | ~10m | ~50Mi | - | - |
| Ingress Controller (x2) | ~200m | ~200Mi | - | 32080, 32443 |
| Prometheus | ~500m | ~1Gi | 10Gi | - |
| Grafana | ~100m | ~200Mi | 5Gi | - |
| Node Exporters (x3) | ~30m | ~50Mi | - | - |
| Kube State Metrics | ~50m | ~100Mi | - | - |
| **Total** | **~1000m** | **~1.7Gi** | **15Gi** | **2 NodePorts** |

**Recommended cluster specs:**
- **Master:** 2 CPU, 4GB RAM, 50GB disk
- **Worker:** 2 CPU, 4GB RAM, 100GB disk (each)
- **Network:** Gigabit LAN recommended

---

**✅ Ingress-NGINX setup complete!** Your Kubernetes cluster is now fully functional with external access to services.

**🎉 Congratulations!** You now have a production-ready home lab Kubernetes cluster with:
- Automated resource monitoring
- Persistent storage
- Professional monitoring stack (Prometheus + Grafana)
- External access via Ingress controller
- Domain-based routing

Your cluster is ready for deploying applications! 🚀
