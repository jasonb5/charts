CHART_DIR ?= .

include $(wildcard custom.mk)

.PHONY: release
release: dep package upload index

.PHONY: package
package:
	cr package --config ../../cr.yaml --package-path /tmp/cr/packages $(ARGS) $(CHART_DIR)

.PHONY: upload
upload:
	cr upload --config ../../cr.yaml --token $(GH_TOKEN) --git-repo charts --package-path /tmp/cr/packages $(ARGS) $(CHART_DIR)

.PHONY: index
index: BRANCH ?= $(shell git branch --show-current)
index:
	git checkout gh-pages; git pull; git checkout $(BRANCH)
	cr index --config ../../cr.yaml --token $(GH_TOKEN) --git-repo charts --package-path /tmp/cr/packages --index-path /tmp/cr/index.yaml $(ARGS) $(CHART_DIR)

.PHONY: dep
dep:
	helm dep update $(ARGS) $(CHART_DIR)

.PHONY: test
test:
	pytest -vvv $(ARGS) $(ROOT_DIR)/charts/test_chart.py

.PHONY: update
update:
	python $(ROOT_DIR)/scripts/chart.py update -i $(if $(FORMAT),-f $(FORMAT),) $(ARGS) $(CHART_DIR)

.PHONY: version
version:
	@printf "%s\n" $(shell python $(ROOT_DIR)/scripts/chart.py current $(CHART_DIR))

.PHONY: update-template
update-template: CHART_VERSION := $(shell python $(ROOT_DIR)/scripts/chart.py current --chart-version $(CHART_DIR))
update-template: APP_VERSION := $(shell python $(ROOT_DIR)/scripts/chart.py current $(CHART_DIR))
update-template: ANSWERS_FILE := $(shell basename `pwd`)/.copier-answers.yml
update-template: SKIP := -s test_config.py -s test.yaml -s values.yaml -s CUSTOM.md
update-template:
	copier copy $(ARGS) $(SKIP) -a $(ANSWERS_FILE) -d version=$(CHART_VERSION) -d app_version=$(APP_VERSION) $(ROOT_DIR)/charts/template $(CHART_DIR)/..

install uninstall open docs: NAME ?= $(shell basename $(PWD))

install uninstall open: INSTALL_NAME ?= test-$(NAME)

.PHONY: install
install:
	helm upgrade -f test.yaml --wait --install $(ARGS) $(INSTALL_NAME) .

.PHONY: uninstall
uninstall:
	helm delete $(INSTALL_NAME)

.PHONY: open
open: POD ?= $(shell kubectl get pod -l app.kubernetes.io/name=$(INSTALL_NAME) -oname)
open: PORT ?= $(shell kubectl get service -l app.kubernetes.io/name=$(INSTALL_NAME) -ojsonpath="{.items[0].spec.ports[0].port}")
open:
	kubectl port-forward $(POD) 8080:$(PORT)

.PHONY: docs
docs:
	helm-docs --log-level DEBUG --sort-values-order file $(CHART_DIR)
	ln -sf $(ROOT_DIR)/charts/$(NAME)/README.md $(ROOT_DIR)/docs/charts/$(NAME).md

.PHONY: changelog
changelog: FILENAME := _changelog.gotmpl
changelog:
	echo '{{ define "changelog" -}}' > $(FILENAME)
	echo '## Changelog' >> $(FILENAME)
	git log --pretty="- %s (%as)" --after="2023-12-28" . >> $(FILENAME)
	echo '{{- end }}' >> $(FILENAME)

.PHONY: bump-%
bump-%:
	tbump --no-tag $(ARGS) $(shell pysemver bump $* $(shell tbump current-version))

.PHONY: template
template:
	helm template $(ARGS) $(CHART_DIR)

.PHONY: lint
lint:
	helm lint $(ARGS) $(CHART_DIR)
