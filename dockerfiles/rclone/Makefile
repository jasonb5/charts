build run push: IMAGE := ghcr.io/jasonb5/rclone:$(shell tbump current-version)

.PHONY: build
build:
	docker build -t $(IMAGE) .

.PHONY: run
run:
	docker run -it --rm $(ARGS) $(if $(ENTRYPOINT),--entrypoint $(ENTRYPOINT),) $(IMAGE)

.PHONY: push
push:
	docker push $(IMAGE)
