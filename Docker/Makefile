IMAGE_NAME = "ap"
PORTS = "8080:80"

all: build

build: Dockerfile
	docker build -t $(IMAGE_NAME) .

run: Dockerfile
	docker run -i -p $(PORTS)  -t $(IMAGE_NAME)
