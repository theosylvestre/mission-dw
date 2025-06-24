build:
	docker build -t airflow-snefmaintenance:latest .

init: docker-compose.yml
	docker-compose -f docker-compose.yml up -d --build

start: docker-compose.yml
	docker-compose -f docker-compose.yml up -d --build --scale airflow-init=0 

stop-and-remove: docker-compose.yml
	docker-compose -f docker-compose.yml down -v

stop: docker-compose.yml
	docker-compose -f docker-compose.yml stop

scale-worker: docker-compose.yml
	@if [ -z "$(N)" ]; then \
		echo "❌ Veuillez spécifier le nombre de workers avec N (ex: make scale-worker N=3)"; \
		exit 1; \
	fi; \
	docker-compose -f docker-compose.yml up -d --scale worker=$(N)