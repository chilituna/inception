# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aarponen <aarponen@student.42berlin.de>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/29 15:41:10 by aarponen          #+#    #+#              #
#    Updated: 2025/06/25 11:42:41 by aarponen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


NAME = inception

WP_DATA_DIR = ${HOME}/data/database
WP_WEB_DIR = ${HOME}/data/html

DOCKER_COMPOSE_FILE = srcs/docker-compose.yml

SECRETS_DIR = ./secrets
ENV = srcs/.env
SOURCE_SECRETS_DIR = /media/sf_Inception/secrets
SOURCE_ENV_FILE = /media/sf_Inception/srcs/.env

# Build the project: create volumes, build and start containers
build: credentials set-domain
	@if [ ! -f $(ENV) ]; then \
		echo "Error: $(ENV) file not found!"; \
		exit 1; \
    fi
	mkdir -p $(WP_DATA_DIR)
	mkdir -p $(WP_WEB_DIR)
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) build
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) up -d

# Stop and remove containers and networks
down:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) down

# Start stopped containers
start:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) start

# Stop running containers
stop:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) stop

# Restart containers
restart:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) restart

# Print the current status of the containers
status:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) ps

# Full clean: stop containers and remove everything
# (NOTE! this will remove all containers, images, volumes, and networks)
fclean: down
	docker rmi nginx:latest mariadb:latest wordpress:latest
	@if [ -d "$(WP_DATA_DIR)" ]; then sudo rm -rf $(WP_DATA_DIR); fi
	@if [ -d "$(WP_WEB_DIR)" ]; then sudo rm -rf $(WP_WEB_DIR); fi

# Force rebuild without cache
# (NOTE! this will remove all containers, images, volumes, and networks)
fullreset: credentials set-domain
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) down --rmi all --remove-orphans
	@if [ -d "$(WP_DATA_DIR)" ]; then sudo rm -rf $(WP_DATA_DIR); fi
	@if [ -d "$(WP_WEB_DIR)" ]; then sudo rm -rf $(WP_WEB_DIR); fi
	mkdir -p $(WP_DATA_DIR)
	mkdir -p $(WP_WEB_DIR)
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) build --no-cache
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) up -d

# Guide for using the Makefile
help:
	@echo "Makefile commands:"
	@echo "  make build   - Build the project and start containers"
	@echo "  make down    - Stop and remove containers and networks"
	@echo "  make start   - Start stopped containers"
	@echo "  make stop    - Stop running containers"
	@echo "  make restart - Restart containers"
	@echo "  make status  - Print the current status of the containers"
	@echo "  make fclean  - Full clean: stop containers and remove associated images, volumes, and networks"
	@echo "  make fullreset - Force rebuild. This will remove all containers, images, volumes, and networks and rebuld everything without cache."

# View logs of the containers"
logs:
	docker compose -p $(NAME) -f $(DOCKER_COMPOSE_FILE) logs -f

# Check and copy secrets and .env if missing
credentials:
	@if [ ! -d "$(SECRETS_DIR)" ]; then \
		echo "Secrets folder not found. Copying from $(SOURCE_ENV_FILE)..."; \
		cp -r $(SOURCE_SECRETS_DIR) $(SECRETS_DIR); \
	fi

	@if [ ! -f "$(ENV)" ]; then \
		echo "Environment file not found. Copying from $(SOURCE_SECRETS_DIR)/.env..."; \
		cp $(SOURCE_ENV_FILE) $(ENV); \
	fi

# Connect the domain to the local server:
set-domain:
	@if ! grep -q "^127.0.0.1[[:space:]]\+aarponen.42.fr" /etc/hosts; then \
		echo "Adding 127.0.0.1 aarponen.42.fr to /etc/hosts (requires sudo)"; \
		echo "127.0.0.1 aarponen.42.fr" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "Entry already exists in /etc/hosts"; \
	fi

.PHONY: build down start stop restart status fclean fullreset help logs credentials set-domain
