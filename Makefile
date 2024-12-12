# Makefile for Django + Vite project

# Variables
COMPOSE_FILE = compose.yml
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE)
DOCKER_EXEC = $(DOCKER_COMPOSE) exec
DOCKER_RUN = $(DOCKER_COMPOSE) run --rm
APP_SERVICE = app

.PHONY: init dev build up down restart logs status prune help db-shell collectstatic migrate

# Development Commands
init: build migrate collectstatic createsuperuser ## Initialize project for first time setup
	@echo "Project initialized successfully!"

dev: build ## Start development servers (Django + Vite)
	cd frontend && pnpm dev

# Docker Commands
build: ## Build or rebuild services
	$(DOCKER_COMPOSE) up -d --build

up: ## Start all services
	$(DOCKER_COMPOSE) up -d

down: ## Stop all services
	$(DOCKER_COMPOSE) down

restart: down up ## Restart all services

status: ## Show status of services
	$(DOCKER_COMPOSE) ps

logs: ## View logs from all services
	$(DOCKER_COMPOSE) logs -f

logs-app: ## View logs from Django app
	$(DOCKER_COMPOSE) logs -f $(APP_SERVICE)

# Database Commands
migrate: db-makemigrations db-migrate ## Run database migrations

db-shell: ## Access database shell
	$(DOCKER_EXEC) db psql -U postgres

db-makemigrations: ## Generate database migrations
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py makemigrations

db-migrate: ## Apply database migrations
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py migrate

db-flush: ## Flush database
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py flush --no-input

# Static Files
collectstatic: ## Collect static files
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py collectstatic --no-input

# User Management
createsuperuser: ## Create a superuser
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py createsuperuser

# App Management
app-create: ## Create a new Django app (usage: make app-create name=myapp)
	$(DOCKER_RUN) $(APP_SERVICE) python manage.py startapp $(name)

# Development Shell
shell: ## Access Django shell
	$(DOCKER_EXEC) $(APP_SERVICE) python manage.py shell

# System Maintenance
prune: down ## Clean up unused Docker resources
	docker system prune -f
	docker volume prune -f
	docker network prune -f

resetdb: down ## Reset database (WARNING: destroys all data)
	docker volume rm $$(docker volume ls -q | grep "_db_data") || true
	make up
	make migrate

# Help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)