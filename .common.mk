ROOT_DIR       ?= .
DIST_DIR       ?= $(ROOT_DIR)/dist
SRC_DIR        ?= $(ROOT_DIR)/src
VAULT_DIR      ?= $(ROOT_DIR)/vault

CUR_GIT_TAG	      ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CUR_GIT_TAG_MAJOR := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')
CUR_GIT_TAG_MINOR := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v[0-9]+\.([0-9]+).*$$/\1/')
CUR_GIT_TAG_PATCH := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v[0-9]+\.[0-9]+\.([0-9]+).*$$/\1/')
GIT_REVISION      := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

FILE_TAG       ?= $(shell cat -n $(ROOT_DIR)/VERSION 2>/dev/null || echo "0.0.0")
FILE_TAG_MAJOR := $(shell echo $(FILE_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')
FILE_TAG_MINOR := $(shell echo $(FILE_TAG) | sed -E 's/^v[0-9]+\.([0-9]+).*$$/\1/')
FILE_TAG_PATCH := $(shell echo $(FILE_TAG) | sed -E 's/^v[0-9]+\.[0-9]+\.([0-9]+).*$$/\1/')

ifeq ([[ $(CUR_GIT_TAG_MAJOR) -lt $(FILE_TAG_MAJOR) ]], 0)
else ifeq ([[ $(CUR_GIT_TAG_MAJOR) -lt $(FILE_TAG_MAJOR) ]], 0)
else ifeq ([[ $(CUR_GIT_TAG_MAJOR) -lt $(FILE_TAG_MAJOR) ]], 0)
endif

NEXT_TAG_PATCH := $(shell echo $$(($(GIT_TAG_PATCH)+1)))
NEXT_TAG := v$(GIT_TAG_MAJOR).$(GIT_TAG_MINOR).$(NEXT_TAG_PATCH)
