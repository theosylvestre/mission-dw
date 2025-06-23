build:
	docker build -t airflow-snefmaintenance:latest .

init: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml up -d --build

start: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml up -d --build --scale airflow-init=0

stop-and-remove: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml down -v

stop: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml stop

scale-worker: docker-compose-dev.yml
	@if [ -z "$(N)" ]; then \
		echo "❌ Veuillez spécifier le nombre de workers avec N (ex: make scale-worker N=3)"; \
		exit 1; \
	fi; \
	docker-compose -f docker-compose-dev.yml up -d --scale worker=$(N)