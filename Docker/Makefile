IMAGE_NAME = "accessproxy"
PORTS = "8080:80"
HUB_URL = "656532927350.dkr.ecr.us-west-2.amazonaws.com"

all: build

build: Dockerfile
	docker build -t $(IMAGE_NAME) .

compose: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.dev.yml up

compose-staging: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.norebuild.yml -f compose/docker-compose.stg.yml up

compose-production: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.norebuild.yml -f compose/docker-compose.prod.yml up

run: Dockerfile
	docker run -i -p $(PORTS)  -t $(IMAGE_NAME)

awslogin: Dockerfile build
	# See also https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/firstRun
	@echo "Logging you in the hub at $(HUB_URL)"
	aws ecr get-login --no-include-email --region us-west-2  | grep -v MFA | bash
	@echo "Tagging latest built image"
	docker tag $(IMAGE_NAME):latest $(HUB_URL)/$(IMAGE_NAME):latest
	@echo "Uploading image to hub"
	docker push $(HUB_URL)/$(IMAGE_NAME):latest

.PHONY: build run awslogin compose compose-staging compose-production
