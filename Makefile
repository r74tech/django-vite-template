init:
	make build
	make db/flush
	make db/makemigrations
	make db/migrate
	make collectstatic
	make createsuperuser


build:
	docker compose -f compose.yml up -d --build

db/flush:
	docker compose -f compose.yml run --rm app python manage.py flush --no-input

db/makemigrations:
	docker compose -f compose.yml run --rm app python manage.py makemigrations

db/migrate:
	docker compose -f compose.yml run --rm app python manage.py migrate

collectstatic:
	docker compose -f compose.yml run --rm app python manage.py collectstatic --no-input

createsuperuser:
	docker compose -f compose.yml run --rm app python manage.py createsuperuser

app/makeapp:
	docker compose -f compose.yml run --rm app python manage.py startapp $(name)

migrate:
	make db/makemigrations
	make db/migrate