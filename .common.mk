SHELL := /bin/bash

# Directories
ROOT_DIR       ?= .
BUILD_DIR       ?= $(ROOT_DIR)/_build
SRC_DIR        ?= $(ROOT_DIR)/src
CO_DIR         ?= $(SRC_DIR)/_checkouts

# Git information
GIT_MASTER        ?= main
GIT_BRANCH		  := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
GIT_REVISION      := $(shell git rev-parse --short HEAD 2>/dev/null || echo "latest")

# Quartz configuration
QUARTZ_REPO      ?= https://github.com/jackyzha0/quartz.git
QUARTZ_VERSION   ?= v4.5.1
QUARTZ_DIR       ?= $(SRC_DIR)/quartz
QUARTZ_SRC_DIR   ?= $(CO_DIR)/quartz
QUARTZ_VAULT_DIR ?= $(SRC_DIR)/vault
QUARTZ_BUILD_DIR ?= $(BUILD_DIR)/quartz
QUARTZ_FILES     ?= globals.d.ts index.d.ts package.json quartz.config.ts quartz.layout.ts tsconfig.json
QUARTZ_THREADS   ?= 8

# Release configuration
# Get the current git tag, or default to v0.0.0 if none exists
CUR_GIT_TAG	      ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CUR_GIT_TAG_MAJOR := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')
CUR_GIT_TAG_MINOR := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v[0-9]+\.([0-9]+).*$$/\1/')
CUR_GIT_TAG_PATCH := $(shell echo $(CUR_GIT_TAG) | sed -E 's/^v[0-9]+\.[0-9]+\.([0-9]+).*$$/\1/')

# Read the VERSION file to get the last released version
# If the VERSION file does not exist, default to v0.0.0
FILE_TAG       ?= $(shell cat $(ROOT_DIR)/VERSION 2>/dev/null || echo "0.0.0")
FILE_TAG_MAJOR := $(shell echo $(FILE_TAG) | sed -E 's/^v([0-9]+)\..*$$/\1/')
FILE_TAG_MINOR := $(shell echo $(FILE_TAG) | sed -E 's/^v[0-9]+\.([0-9]+).*$$/\1/')
FILE_TAG_PATCH := $(shell echo $(FILE_TAG) | sed -E 's/^v[0-9]+\.[0-9]+\.([0-9]+).*$$/\1/')

# Determine the next version based on git tags and the VERSION file
TAG_MAJOR := $(CUR_GIT_TAG_MAJOR)
TAG_MINOR := $(CUR_GIT_TAG_MINOR)
TAG_PATCH := $(CUR_GIT_TAG_PATCH)
ifeq ([[ $(CUR_GIT_TAG_MAJOR) -lt $(FILE_TAG_MAJOR) ]], 0)
	TAG_MAJOR := ${FILE_TAG_MAJOR}
	TAG_MINOR := 0
	TAG_PATCH := 0
else ifeq ([[ $(CUR_GIT_TAG_MINOR) -lt $(FILE_TAG_MINOR) ]], 0)
	TAG_MINOR := ${FILE_TAG_MINOR}
	TAG_PATCH := 0
else ifeq ([[ $(CUR_GIT_TAG_PATCH) -lt $(FILE_TAG_PATCH) ]], 0)
	TAG_PATCH := ${FILE_TAG_PATCH}
else
	TAG_PATCH := $(shell echo $$(($(CUR_GIT_TAG_PATCH)+1)))
endif

# Build version and revision
BUILD_VERSION := v$(TAG_MAJOR).$(TAG_MINOR).$(TAG_PATCH)
BUILD_REVISION := $(GIT_REVISION)

# Semantic versioning
SEMV_VERSION_SHORT := $(TAG_MAJOR).$(TAG_MINOR).$(TAG_PATCH)
SEMV_VERSION       := $(SEM_VERSION_SHORT)-$(GIT_BRANCH)+$(GIT_REVISION)

# Docker tags
DOCKER_TAG_MAJOR := v$(TAG_MAJOR)
DOCKER_TAG_MINOR := v$(TAG_MAJOR).$(TAG_MINOR)
DOCKER_TAG_PATCH := v$(TAG_MAJOR).$(TAG_MINOR).$(TAG_PATCH)
DOCKER_TAG_BUILD := $(shell [[ $(GIT_BRANCH) != $(GIT_MASTER) ]] && echo -n "$(DOCKER_TAG_PATCH)-$(GIT_BRANCH).$(GIT_REVISION)")
DOCKER_TAGS      := $(DOCKER_TAG_MAJOR) $(DOCKER_TAG_MINOR) $(DOCKER_TAG_PATCH) $(DOCKER_TAG_BUILD)

${info Current Git Tag:      $(CUR_GIT_TAG)}
${info Current Git Branch:   $(GIT_BRANCH)}
${info Current Git Revision: $(GIT_REVISION)}
${info File Tag:             $(FILE_TAG_MAJOR).$(FILE_TAG_MINOR).$(FILE_TAG_PATCH)}
${info Build Version:        $(BUILD_VERSION)}
${info Build Revision:       $(BUILD_REVISION)}
${info Docker Tags:          $(DOCKER_TAGS)}
