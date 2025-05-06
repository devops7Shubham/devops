#!/bin/bash
set -e

# 1️⃣ Tear everything down
echo "🔴 Cleaning up existing resources…"
kubectl delete ingress --all    -n default || true
kubectl delete svc     --all    -n default || true
kubectl delete deployment --all -n default || true
kubectl delete pods    --all    -n default || true
kubectl delete pvc     --all    -n default || true

# (If you ever created a custom namespace for ingress, you can clean it too:)
# kubectl delete namespace ingress-nginx || true

# 2️⃣ Re-enable the Minikube ingress addon
echo "🔄 Restarting Minikube’s NGINX Ingress…"
minikube addons disable ingress
minikube addons enable  ingress
kubectl -n kube-system rollout status deploy ingress-nginx-controller

# 3️⃣ Build your images inside Minikube’s Docker
echo "📦 Building Docker images…"
eval $(minikube docker-env)  # ensure this is set
docker build -t shubhamdevops/backend-app:latest  ./backend
docker build -t shubhamdevops/frontend-app:latest ./frontend

# 4️⃣ Deploy Postgres (no PVC, ephemeral)
echo "🗄️  Deploying Postgres…"
kubectl apply -f postgres-deployment.yaml
kubectl rollout status deployment/postgres

# 5️⃣ Deploy your Backend
echo "⚙️  Deploying Backend…"
kubectl apply -f backend-deployment.yaml
kubectl rollout status deployment/backend

# 6️⃣ Deploy your Frontend
echo "🌐 Deploying Frontend…"
kubectl apply -f rontend-deployment.yaml
kubectl rollout status deployment/react-frontend

# 7️⃣ Finally, re-apply your Ingress resource
echo "🚪 Applying Ingress…"
kubectl apply -f ingress.yaml

# 8️⃣ Give the ingress a few seconds and then show what’s up
sleep 5
echo
kubectl get pods,svc,ingress -n default
kubectl get svc -n kube-system | grep ingress-nginx-controller

echo
echo "✅ All done!  Now access your app via your Ingress host:"
echo "   • curl -H \"Host: myapp.local\" http://$(minikube ip):$(kubectl get svc -n kube-system ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')/"
echo "   • or, if you added myapp.local → $(minikube ip) in /etc/hosts, just open http://myapp.local/ in your browser."
