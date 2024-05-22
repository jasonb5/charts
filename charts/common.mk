CHART_DIR ?= .

include $(wildcard custom.mk)

.PHONY: package
package:
	cr package --config ../../cr.yaml $(ARGS) $(CHART_DIR)

.PHONY: upload
upload:
	cr upload --config ../../cr.yaml --token $(GH_TOKEN) --git-repo charts $(CHART_DIR)

.PHONY: index
index:
	mkdir .cr-index || exit 0
	git checkout gh-pages; git pull; git checkout main
	cr index --config ../../cr.yaml --token $(GH_TOKEN) --git-repo charts $(CHART_DIR)

.PHONY: dep
dep:
	helm dep update $(ARGS) $(CHART_DIR)

.PHONY: release
release: dep package upload index

.PHONY: update
update:
	python $(ROOT_DIR)/scripts/chart.py $(GLOBAL) update $(ARGS) $(CHART_DIR)

.PHONY: version
version:
	@printf "%s\n" $(shell python $(ROOT_DIR)/scripts/chart.py version $(CHART_DIR))

.PHONY: update-template
update-template: CHART_VERSION := $(shell python $(ROOT_DIR)/scripts/chart.py version --chart $(CHART_DIR))
update-template: APP_VERSION := $(shell python $(ROOT_DIR)/scripts/chart.py version $(CHART_DIR))
update-template: ANSWERS_FILE := $(shell basename `pwd`)/.copier-answers.yml
update-template: SKIP := -s test_chart.py -s test.yaml -s values.yaml
update-template:
	copier copy $(ARGS) $(SKIP) -a $(ANSWERS_FILE) -d version=$(CHART_VERSION) -d app_version=$(APP_VERSION) $(ROOT_DIR)/charts/template $(CHART_DIR)/..

.PHONY: install
install:
	helm upgrade -f test.yaml --wait --install $(ARGS) $(shell basename $(PWD)) .

.PHONY: uninstall
uninstall:
	helm delete $(shell basename $(PWD))

.PHONY: open
open: NAME ?= $(shell basename $(PWD))
open: POD ?= $(shell kubectl get pod -l app.kubernetes.io/name=$(NAME) -oname)
open: PORT ?= $(shell kubectl get service -l app.kubernetes.io/name=$(NAME) -ojsonpath="{.items[0].spec.ports[0].port}")
open:
	kubectl port-forward $(POD) 8080:$(PORT)

.PHONY: docs
docs:
	helm-docs --log-level DEBUG --sort-values-order file $(CHART_DIR)
ifneq ($(wildcard ../../docs/charts),)
	chart=$(shell basename $(PWD)); \
    ln -sf ../../charts/$${chart}/README.md ../../docs/charts/$${chart}.md
endif

.PHONY: changelog
changelog: FILENAME := _changelog.gotmpl
changelog:
	echo '{{ define "changelog" -}}' > $(FILENAME)
	echo '## Changelog' >> $(FILENAME)
	git log --pretty="- %s (%as)" --after="2023-12-28" . >> $(FILENAME)
	echo '{{- end }}' >> $(FILENAME)

.PHONY: bump-%
bump-%:
	tbump $(ARGS) --no-tag $(shell pysemver bump $* $(shell tbump current-version))

.PHONY: template
template:
	helm template $(ARGS) $(CHART_DIR)

.PHONY: lint
lint:
	helm lint $(ARGS) $(CHART_DIR)
