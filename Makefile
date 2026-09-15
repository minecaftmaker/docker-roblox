.PHONY: build up down logs shell status rebuild

build:
	docker compose build

up:
	docker compose up -d

rebuild:
	docker compose build --no-cache
	docker compose up -d --force-recreate

down:
	docker compose down

logs:
	docker compose logs -f

shell:
	docker compose exec roblox bash

status:
	docker compose exec roblox /opt/roblox-docker/status.sh
