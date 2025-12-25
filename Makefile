.PHONY: dev dev-mcp up down shell bundle db-migrate test

DEV_SERVICES=web vite ssr
COMPOSE_RUN=docker compose run --rm web

dev:
	@echo "Starting docker compose ($(DEV_SERVICES))..."
	docker compose up $(DEV_SERVICES)

dev-mcp:
	@echo "Starting Playwright MCP..."
	yarn mcp:playwright

up:
	@echo "Starting docker compose and Playwright MCP together..."
	bin/dev_with_mcp

down:
	docker compose down

shell:
	$(COMPOSE_RUN) bash

bundle:
	$(COMPOSE_RUN) bundle install

db-migrate:
	$(COMPOSE_RUN) bin/rails db:migrate

test:
	$(COMPOSE_RUN) bin/rails test
