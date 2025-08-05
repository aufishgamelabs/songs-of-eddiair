SHELL := /bin/bash

CHECKOUT_DIR ?= ./_checkouts

QUARTZ_DIR ?= $(CHECKOUT_DIR)/quartz
QUARTZ_REPO ?= https://github.com/jackyzha0/quartz.git
QUARTZ_VERSION ?= v4.5.1

VAULT_DIR ?= ./vault

init:
	@[[ -d "$(CHECKOUT_DIR)" ]] || mkdir -p $(CHECKOUT_DIR)
	@[[ -d "$(QUARTZ_DIR)" ]] || git clone --depth 1 --branch $(QUARTZ_VERSION) $(QUARTZ_REPO) $(QUARTZ_DIR)
	@[[ -d "node_modules" ]] || npm install $(QUARTZ_DIR)


