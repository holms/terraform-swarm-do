man:
	docker-compose up -d docs

build:
	docker-compose build docs

clean:
	-docker system prune -f

kill:
	-docker kill $(shell docker ps -q)

github:
	docker-compose run docs mkdocs gh-deploy -f /docs/docs/mkdocs.yml

