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
