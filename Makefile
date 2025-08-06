SHELL := /bin/bash

ROOT_DIR       ?= .

CO_DIR         ?= $(ROOT_DIR)/_checkouts
DIST_DIR       ?= $(ROOT_DIR)/dist
SRC_DIR        ?= $(ROOT_DIR)/src
VAULT_DIR      ?= $(ROOT_DIR)/vault

QUARTZ_REPO    ?= https://github.com/jackyzha0/quartz.git
QUARTZ_VERSION ?= v4.5.1
QUARTZ_DIR     ?= $(SRC_DIR)/quartz
QUARTZ_SRC_DIR ?= $(CO_DIR)/quartz
QUARTZ_FILES   ?= globals.d.ts index.d.ts package.json quartz.config.ts quartz.layout.ts tsconfig.json
QUARTZ_THREADS ?= 8


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