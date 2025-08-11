include .common.mk

static: build-quartz

build-quartz: init-quartz
	@echo "Building Quartz site..."
	cd $(QUARTZ_DIR); npx quartz build --directory ../../$(QUARTZ_VAULT_DIR) --output ../../$(QUARTZ_BUILD_DIR) --concurrency $(QUARTZ_THREADS)

init: init-quartz

init-quartz:
	[[ -d $(CO_DIR) ]] || mkdir -p $(CO_DIR)
	[[ -d $(QUARTZ_SRC_DIR) ]] || git clone --depth 1 --branch $(QUARTZ_VERSION) $(QUARTZ_REPO) $(QUARTZ_SRC_DIR)
	[[ -d $(QUARTZ_DIR) ]] || mkdir -p $(QUARTZ_DIR)
	[[ -d $(QUARTZ_DIR)/quartz ]] || cp -r $(QUARTZ_SRC_DIR)/quartz $(QUARTZ_DIR)/quartz
	$(foreach file, $(QUARTZ_FILES), [[ -f $(QUARTZ_DIR)/$(file) ]] || cp $(QUARTZ_SRC_DIR)/$(file) $(QUARTZ_DIR)/$(file);)
	[[ -d $(QUARTZ_DIR)/node_modules ]] || (cd $(QUARTZ_DIR); npm install .)
	[[ -d $(QUARTZ_VAULT_DIR) ]] || mkdir -p $(QUARTZ_VAULT_DIR)

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
	[[ "$(RELEASE_ENV)" -ne "dev" ]] || helm upgrade $(RELEASE) -f `pwd`/_ops/helm/gameday/$(RELEASE_ENV).yaml _ops/helm/gameday/ --set Version=$(BUILD_VERSION) --set Env=$(RELEASE_ENV) --set Logging.Level=trace
	[[ "$(RELEASE_ENV)" -eq "dev" ]] || helm upgrade $(RELEASE) -f `pwd`/_ops/helm/gameday/$(RELEASE_ENV).yaml _ops/helm/gameday/ --set Version=$(BUILD_VERSION) --set Env=$(RELEASE_ENV)


cloud-uninstall:
	helm uninstall $(RELEASE) 
