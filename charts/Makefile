.DEFAULT_GOAL := test

CHART_DIR ?= .

include $(wildcard custom.mk)

package upload index: _ARGS = $(if $(wildcard ../../cr.yaml),--config ../../cr.yaml,) $(ARGS) 

.PHONY: package
package:
	cr package $(_ARGS) $(CHART_DIR)

.PHONY: package-all
package-all:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common.*\|template\|\.cr-.*\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make package ARGS='--package-path ../.cr-release-packages'"

.PHONY: upload
upload:
	cr upload $(_ARGS) --token $(GH_TOKEN) --git-repo charts $(CHART_DIR)

.PHONY: upload-all
upload-all:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common.*\|template\|\.cr-.*\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make upload ARGS='--package-path ../.cr-release-packages $(ARGS)' GH_TOKEN=$(GH_TOKEN)"

.PHONY: index
index:
	mkdir .cr-index || exit 0
	git checkout gh-pages; git pull; git checkout main
	cr index $(_ARGS) --token $(GH_TOKEN) --git-repo charts $(CHART_DIR)

.PHONY: index-all
index-all:
	mkdir .cr-index || exit 0
	git checkout gh-pages; git pull; git checkout main
	cr index $(_ARGS) --token $(GH_TOKEN) --git-repo charts --package-path .cr-release-packages $(CHART_DIR)

.PHONY: dep
dep:
	helm dep update $(ARGS) $(CHART_DIR)

.PHONY: dep-all
dep-all:
	helm repo update
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common\|template\|\.cr-index-packages\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make dep ARGS='--skip-refresh'"

.PHONY: bump-all
bump-all:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common\|template\|\.cr-index-packages\)' \
		| xargs -I% -P 1 /bin/bash -c "pushd %; make bump-patch ARGS='--non-interactive --only-patch'"

.PHONY: release
release: dep package upload index

.PHONY: release-all
release-all: dep-all package-all upload-all index-all

.PHONY: update
update:
	python ../../scripts/chart.py $(GLOBAL) update $(ARGS) $(_ARGS) .

.PHONY: version
version:
	@printf "%s\n" $(shell python ../../scripts/chart.py version .)

.PHONY: new-chart
new-chart:
	copier copy -d name=$(NAME) $(ARGS) template/ .

	pushd $(NAME); make init-chart

.PHONY: init-chart
init-chart: dep docs

.PHONY: update-chart
update-chart:
	copier copy $(ARGS) -s tbump.toml -s values.yaml -s Chart.yaml -a $(shell basename `pwd`)/.copier-answers.yml ../template/ ../

.PHONY: install
install:
	helm upgrade -f test.yaml --wait --install $(shell basename $(PWD)) .

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
bump-%: ARGS ?= --no-tag
bump-%:
	tbump $(ARGS) $(shell pysemver bump $* $(shell tbump current-version))

.PHONY: template
template:
	helm template $(ARGS) $(CHART_DIR)

.PHONY: lint
lint:
	helm lint $(ARGS) $(CHART_DIR)

.PHONY: test
test:
	helm unittest $(ARGS) $(CHART_DIR) | grep -v trim

.PHONY: clean
clean:
	rm -rf .cr-release-packages

.PHONY: sync-version
sync-version:
	sed -i"" "s/^version:.*/version: $(shell python ../../scripts/chart.py version .)/g" .copier-answers.yml
