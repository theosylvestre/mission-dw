init-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml up -d --build

start-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml up -d \
		clickhouse \
		prometheus \
		grafana \
		minio \

stop-and-remove-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml down -v

stop-dev: docker-compose.dev.yml
	docker-compose -f docker-compose.dev.yml stop