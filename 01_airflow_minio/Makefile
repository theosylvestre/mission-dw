start-and-build: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml up -d --build

stop-and-remove: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml down -v

stop: docker-compose-dev.yml
	docker-compose -f docker-compose-dev.yml stop