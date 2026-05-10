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
