ROOT_DIR       ?= .
DIST_DIR       ?= $(ROOT_DIR)/dist
SRC_DIR        ?= $(ROOT_DIR)/src
VAULT_DIR      ?= $(ROOT_DIR)/vault

GIT_COMMIT_SHORT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

GIT_TAG	  := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
TAG_MAJOR := $(shell echo $(GIT_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')
TAG_MINOR := $(shell echo $(GIT_TAG) | sed -E 's/^v[0-9]+\.([0-9]+).*$$/\1/')
TAG_PATCH := $(shell echo $(GIT_TAG) | sed -E 's/^v[0-9]+\.[0-9]+\.([0-9]+).*$$/\1/')

ifeq [[ -f $(ROOT_DIR)/.version ]] || (echo "Error: .common.mk not found in $(ROOT_DIR)"; exit 1)
endif

TAG_MAJOR := $(shell echo $(GIT_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')



NEXT_PATCH := $(shell echo $$(($(GIT_TAG_PATCH)+1)))
 := v$(GIT_TAG_MAJOR).$(GIT_TAG_MINOR).$(NEXT_TAG_PATCH)
