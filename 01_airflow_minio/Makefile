build-dev:
	docker build -t airflow-snefmaintenance:latest .

init-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml up -d --build

start-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml up -d --build --scale airflow-init=0 

stop-and-remove-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml down -v

stop-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml stop

scale-worker-dev: docker-compose.dev.yml
	@if [ -z "$(N)" ]; then \
		echo "❌ Veuillez spécifier le nombre de workers avec N (ex: make scale-worker N=3)"; \
		exit 1; \
	fi; \
	docker-compose -f docker-compose.dev.yml up -d --scale worker=$(N)