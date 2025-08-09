SHELL := /bin/bash

. .common.mk

build:
	@echo "Building Quartz site..."
	cd $(QUARTZ_DIR); npx quartz build --directory ../../$(VAULT_DIR) --output ../../$(DIST_DIR) --concurrency $(QUARTZ_THREADS)

init:
	[[ -d $(CO_DIR) ]] || mkdir -p $(CO_DIR)
	[[ -d $(QUARTZ_SRC_DIR) ]] || git clone --depth 1 --branch $(QUARTZ_VERSION) $(QUARTZ_REPO) $(QUARTZ_SRC_DIR)
	[[ -d $(QUARTZ_DIR) ]] || mkdir -p $(QUARTZ_DIR)
	[[ -d $(QUARTZ_DIR)/quartz ]] || cp -r $(QUARTZ_SRC_DIR)/quartz $(QUARTZ_DIR)/quartz
	$(foreach file, $(QUARTZ_FILES), [[ -f $(QUARTZ_DIR)/$(file) ]] || cp $(QUARTZ_SRC_DIR)/$(file) $(QUARTZ_DIR)/$(file);)
	[[ -d $(QUARTZ_DIR)/node_modules ]] || (cd $(QUARTZ_DIR); npm install .)
	[[ -d $(VAULT_DIR) ]] || mkdir -p $(VAULT_DIR)


cloud-init:
	[[ -eq "$(RELEASE_ENV)" "dev" ]] || (echo "Release environment must be set to 'dev' for cloud-init"; exit 1)

	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm install ingress-nginx ingress-nginx/ingress-nginx
	helm upgrade --reuse-values ingress-nginx ingress-nginx/ingress-nginx

cloud-install:
	helm install $(RELEASE) -f `pwd`/_ops/helm/gameday/$(RELEASE_ENV).yaml _ops/helm/gameday/ --set Version=$(BUILD_VERSION) --set Env=$(RELEASE_ENV)

cloud-upgrade:
ifeq "$(RELEASE_ENV)" "dev"
	helm upgrade $(RELEASE) -f `pwd`/_ops/helm/gameday/$(RELEASE_ENV).yaml _ops/helm/gameday/ --set Version=$(BUILD_VERSION) --set Env=$(RELEASE_ENV) --set Logging.Level=trace
else
	helm upgrade $(RELEASE) -f `pwd`/_ops/helm/gameday/$(RELEASE_ENV).yaml _ops/helm/gameday/ --set Version=$(BUILD_VERSION) --set Env=$(RELEASE_ENV)
endif

cloud-uninstall:
	helm uninstall $(RELEASE)