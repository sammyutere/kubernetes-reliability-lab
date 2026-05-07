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
