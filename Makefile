APP_NAME=reliability-app
NAMESPACE=reliability-lab
KIND_CLUSTER=reliability-lab

.PHONY: verify tree

verify:
	 @echo "Checking local toolchain..."
	 @git --version
	 @docker version --format '{{.Server.Version}}'
	 @kubectl version --client
	 @kind version
	 @helm version --short
	 @terraform version
	 @aws --version
	 @gh --version
	 @jq --version
	 @python3 --version

tree:
	@find . -maxdepth 3 -type d | sort

docker-build:
	docker build -t $(APP_NAME):local ./app

docker-run:
	docker run --rm -p 8000:8000 $(APP_NAME):local

docker-run-detached:
	docker run -d --name $(APP_NAME)-test -p 8000:8000 $(APP_NAME):local

docker-logs:
	docker logs $(APP_NAME)-test

docker-stop:
	docker stop $(APP_NAME)-test || true
	docker rm $(APP_NAME)-test || true

docker-test:
	curl -f http://127.0.0.1:8000/healthz
	curl -f http://127.0.0.1:8000/readyz

kind-create:
	kind create cluster --config k8s/kind-config.yaml

kind-delete:
	kind delete cluster --name $(KIND_CLUSTER)

kind-clusters:
	kind get clusters

kubectl-context:
	kubectl config current-context

nodes:
	kubectl get nodes

pods-all:
	kubectl get pods -A

kind-load:
	kind load docker-image $(APP_NAME):local --name $(KIND_CLUSTER)

kind-image-check:
	docker exec -it $(KIND_CLUSTER)-worker crictl images | grep $(APP_NAME)

namespace-apply:
	kubectl apply -f k8s/base/namespace.yaml

namespace-get:
	kubectl get namespace $(NAMESPACE) --show-labels

namespace-use:
	kubectl config set-context --current --namespace=$(NAMESPACE)

deploy-apply:
	kubectl apply -f k8s/base/deployment.yaml

deploy-status:
	kubectl rollout status deployment/$(APP_NAME) -n $(NAMESPACE)

deploy-get:
	kubectl get deployment $(APP_NAME) -n $(NAMESPACE)

pods:
	kubectl get pods -n $(NAMESPACE) -o wide

app-logs:
	kubectl logs deployment/$(APP_NAME) -n $(NAMESPACE)

pod-describe:
	kubectl describe pod -l app.kubernetes.io/name=$(APP_NAME) -n $(NAMESPACE)

service-apply:
	kubectl apply -f k8s/base/service.yaml

service-get:
	kubectl get svc $(APP_NAME) -n $(NAMESPACE)

service-describe:
	kubectl describe svc $(APP_NAME) -n $(NAMESPACE)

service-endpoints:
	kubectl get endpoints $(APP_NAME) -n $(NAMESPACE)

service-port-forward:
	kubectl port-forward svc/$(APP_NAME) 8080:80 -n $(NAMESPACE)

config-apply:
	kubectl apply -f k8s/base/configmap.yaml

config-get:
	kubectl get configmap reliability-app-config -n $(NAMESPACE)

config-describe:
	kubectl describe configmap reliability-app-config -n $(NAMESPACE)

restart-app:
	kubectl rollout restart deployment/$(APP_NAME) -n $(NAMESPACE)
	kubectl rollout status deployment/$(APP_NAME) -n $(NAMESPACE)

secret-example:
	kubectl apply -f k8s/base/secret.example.yaml

secret-local:
	kubectl apply -f k8s/base/secret.local.yaml

secret-get:
	kubectl get secret reliability-app-secret -n $(NAMESPACE)

secret-describe:
	kubectl describe secret reliability-app-secret -n $(NAMESPACE)

pdb-apply:
	kubectl apply -f k8s/base/pdb.yaml

pdb-get:
	kubectl get pdb -n $(NAMESPACE)

pdb-describe:
	kubectl describe pdb reliability-app-pdb -n $(NAMESPACE)

drain-worker:
	kubectl drain $(KIND_CLUSTER)-worker --ignore-daemonsets --delete-emptydir-data

uncordon-worker:
	kubectl uncordon $(KIND_CLUSTER)-worker

metrics-server-install:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true
	kubectl rollout status deployment/metrics-server -n kube-system

top-nodes:
	kubectl top nodes

top-pods:
	kubectl top pods -n $(NAMESPACE)

hpa-apply:
	kubectl apply -f k8s/base/hpa.yaml

hpa-get:
	kubectl get hpa -n $(NAMESPACE)

hpa-describe:
	kubectl describe hpa reliability-app-hpa -n $(NAMESPACE)

load-test:
	./experiments/scripts/load-test.sh http://127.0.0.1:8080/cpu 180

netpol-apply:
	kubectl apply -f k8s/base/networkpolicy.yaml

netpol-get:
	kubectl get networkpolicy -n $(NAMESPACE)

netpol-describe:
	kubectl describe networkpolicy reliability-app-ingress-policy -n $(NAMESPACE)

netpol-test-allowed:
	kubectl run curl-allowed-evidence --rm --image=curlimages/curl:8.10.1 -n $(NAMESPACE) --restart=Never --labels="access=allowed" --command -- sh -c 'curl -s -o /dev/null -w "%{http_code}\n" http://$(APP_NAME)/healthz'

netpol-test-denied:
	kubectl run curl-denied-evidence --rm --image=curlimages/curl:8.10.1 -n $(NAMESPACE) --restart=Never --command -- sh -c 'curl --connect-timeout 5 -s -o /dev/null -w "%{http_code}\n" http://$(APP_NAME)/healthz || true'

helm-lint:
	helm lint helm/$(APP_NAME)

helm-template:
	helm template $(APP_NAME) helm/$(APP_NAME) -n $(NAMESPACE) -f helm/$(APP_NAME)/values-local.yaml

helm-install:
	helm upgrade --install $(APP_NAME) helm/$(APP_NAME) -n $(NAMESPACE) --create-namespace -f helm/$(APP_NAME)/values-local.yaml

helm-status:
	helm status $(APP_NAME) -n $(NAMESPACE)

helm-list:
	helm list -n $(NAMESPACE)

helm-uninstall:
	helm uninstall $(APP_NAME) -n $(NAMESPACE)

monitoring-repo:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

monitoring-install:
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f observability/prometheus-values.yaml

monitoring-pods:
	kubectl get pods -n monitoring -o wide

monitoring-status:
	helm status monitoring -n monitoring

grafana-port-forward:
	kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring

prometheus-port-forward:
	kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring

alerts-apply:
	kubectl apply -f observability/alerts.yaml

alerts-get:
	kubectl get prometheusrule reliability-app-alerts -n monitoring

alerts-describe:
	kubectl describe prometheusrule reliability-app-alerts -n monitoring

alerts-test-scale-down:
	kubectl scale deployment $(APP_NAME) -n $(NAMESPACE) --replicas=1

alerts-test-restore:
	kubectl scale deployment $(APP_NAME) -n $(NAMESPACE) --replicas=3
	helm upgrade --install $(APP_NAME) helm/$(APP_NAME) -n $(NAMESPACE) -f helm/$(APP_NAME)/values-local.yaml

experiment-kill-pod:
	kubectl delete pod $$(kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/name=$(APP_NAME) -o jsonpath='{.items[0].metadata.name}') -n $(NAMESPACE)

experiment-kill-pod-evidence:
	mkdir -p experiments/evidence/kill-pod
	kubectl get deployment $(APP_NAME) -n $(NAMESPACE) > experiments/evidence/kill-pod/01-before-deployment.txt
	kubectl get pods -n $(NAMESPACE) -o wide > experiments/evidence/kill-pod/02-before-pods.txt
	kubectl get rs -n $(NAMESPACE) > experiments/evidence/kill-pod/03-before-replicasets.txt


experiment-bad-rollout:
	helm upgrade $(APP_NAME) helm/$(APP_NAME) -n $(NAMESPACE) -f helm/$(APP_NAME)/values-local.yaml --set image.repository=missing-image --set image.tag=notfound

experiment-rollout-status:
	kubectl rollout status deployment/$(APP_NAME) -n $(NAMESPACE) --timeout=90s

experiment-helm-history:
	helm history $(APP_NAME) -n $(NAMESPACE)

experiment-restore-good:
	helm upgrade --install $(APP_NAME) helm/$(APP_NAME) -n $(NAMESPACE) -f helm/$(APP_NAME)/values-local.yaml
	kubectl rollout status deployment/$(APP_NAME) -n $(NAMESPACE)

experiment-cpu-hpa-baseline:
	mkdir -p experiments/evidence/cpu-hpa
	kubectl get deployment $(APP_NAME) -n $(NAMESPACE) > experiments/evidence/cpu-hpa/01-before-deployment.txt
	kubectl get hpa $(APP_NAME)-hpa -n $(NAMESPACE) > experiments/evidence/cpu-hpa/02-before-hpa.txt
	kubectl get pods -n $(NAMESPACE) -o wide > experiments/evidence/cpu-hpa/03-before-pods.txt
	kubectl top pods -n $(NAMESPACE) > experiments/evidence/cpu-hpa/04-before-top-pods.txt

experiment-cpu-hpa-load:
	./experiments/scripts/load-test.sh http://127.0.0.1:8080/cpu 180

experiment-cpu-hpa-capture:
	kubectl get hpa $(APP_NAME)-hpa -n $(NAMESPACE) > experiments/evidence/cpu-hpa/05-during-hpa.txt
	kubectl get deployment $(APP_NAME) -n $(NAMESPACE) > experiments/evidence/cpu-hpa/06-during-deployment.txt
	kubectl get pods -n $(NAMESPACE) -o wide > experiments/evidence/cpu-hpa/07-during-pods.txt
	kubectl top pods -n $(NAMESPACE) > experiments/evidence/cpu-hpa/08-during-top-pods.txt
	kubectl describe hpa $(APP_NAME)-hpa -n $(NAMESPACE) > experiments/evidence/cpu-hpa/09-hpa-describe.txt


experiment-node-drain-baseline:
	mkdir -p experiments/evidence/node-drain
	kubectl get nodes > experiments/evidence/node-drain/01-before-nodes.txt
	kubectl get deployment $(APP_NAME) -n $(NAMESPACE) > experiments/evidence/node-drain/02-before-deployment.txt
	kubectl get pods -n $(NAMESPACE) -o wide > experiments/evidence/node-drain/03-before-pods.txt
	kubectl get pdb $(APP_NAME)-pdb -n $(NAMESPACE) > experiments/evidence/node-drain/04-before-pdb.txt

experiment-node-drain:
	kubectl drain $(DRAIN_NODE) --ignore-daemonsets --delete-emptydir-data

experiment-node-uncordon:
	kubectl uncordon $(DRAIN_NODE)
