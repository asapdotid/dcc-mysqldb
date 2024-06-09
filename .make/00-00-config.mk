# Container names
## must match the names used in the docker-composer.yml files
DOCKER_SERVICE_NAME?=

# FYI:
# Naming convention for images is $(DOCKER_REGISTRY)/$(DOCKER_NAMESPACE)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
# e.g.                      docker.io/bitnami/mariadb:10.11.3
# $(DOCKER_REGISTRY)    ------^           ^       ^      ^    docker.io
# $(DOCKER_NAMESPACE)   ------------------^       ^      ^    bitnami
# $(DOCKER_IMAGE_NAME)  --------------------------^      ^    mariadb
# $(DOCKER_IMAGE_TAG)   ---------------------------------^    10.11.3

DOCKER_DIR:=${PWD}/src
DOCKER_ENV_FILE:=$(DOCKER_DIR)/.env
DOCKER_COMPOSE_FILE:=$(DOCKER_DIR)/compose.yml
DOCKER_COMPOSE_DEV_FILE:=$(DOCKER_DIR)/compose.dev.yml
