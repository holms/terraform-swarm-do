deploy:
	ssh-add terraform/pitchup.pem
	docker login
	DOCKER_HOST=tcp://`cd terraform && terraform output |  grep master.ip | cut -d"=" -f2 | xargs`:2376 docker --tls stack deploy --compose-file=compose.yml --prune --with-registry-auth infra
