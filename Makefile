SHELL := /bin/bash

IMAGE ?= workspace
NAMESPACE ?= posen

CONTAINER := $(NAMESPACE)-$(IMAGE)
REPOSITORY := $(NAMESPACE)/$(IMAGE)
VERSION ?= $(shell git describe --always)

GID ?= $(shell id -g)
UID ?= $(shell id -u)


chown-root:
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -f "name=$(CONTAINER)"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker exec $$CONTAINER_ID /bin/bash -c "chown -R root:root ."; \
	fi;

chown-user:
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -f "name=$(CONTAINER)"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker exec $$CONTAINER_ID /bin/bash -c "chown -R $(UID):$(GID) ."; \
	fi;

start:
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -a -f "name=$(CONTAINER)"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker start $$CONTAINER_ID; \
	fi;

stop: chown-user
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -a -f "name=$(CONTAINER)"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker stop $$CONTAINER_ID; \
	fi;

kill: stop
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -a -f "name=$(CONTAINER)"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker rm $$CONTAINER_ID; \
	fi;

clean: kill
	@set -euo pipefail; \
	IMAGE_ID=$$(docker images -q "$(REPOSITORY):$(VERSION)"); \
	if [[ -n $$IMAGE_ID ]]; then \
		docker rmi -f $$IMAGE_ID; \
	fi;

build: kill
	docker build --no-cache -t $(REPOSITORY):$(VERSION) .

run:
	docker run -itd --privileged --restart=unless-stopped \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume ~/.ssh:/root/.ssh \
		--volume $$(pwd)/main:/main \
		--name $(CONTAINER) $(REPOSITORY):$(VERSION)

exec: start chown-root
	docker exec -it $(CONTAINER) /bin/bash

dev: build run exec

push:
	docker push $(REPOSITORY):$(VERSION)
