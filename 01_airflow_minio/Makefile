init: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml up -d --build

start: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml up -d --build --scale airflow-init=0
	
stop-and-remove: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml down -v

stop: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml stop