.DEFAULT_GOAL := test

CHART_DIR ?= .

include $(wildcard custom.mk)

package upload index: CR_ARGS = $(if $(wildcard ../../cr.yaml),--config ../../cr.yaml,) $(ARGS) 

.PHONY: package
package:
	cr package $(CR_ARGS) $(CHART_DIR)

.PHONY: package-all
package-all:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common.*\|template\|\.cr-.*\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make package ARGS='--package-path ../.cr-release-packages'"

.PHONY: upload
upload:
	cr upload $(CR_ARGS) --git-repo charts $(CHART_DIR)

.PHONY: upload-all
upload-all:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common.*\|template\|\.cr-.*\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make upload ARGS='--package-path ../.cr-release-packages $(ARGS)'"

.PHONY: index
index:
	mkdir .cr-index || exit 0
	cr index $(CR_ARGS) --git-repo charts $(CHART_DIR)

.PHONY: index-all
index-all:
	mkdir .cr-index || exit 0
	git checkout gh-pages; git pull; git checkout main
	cr index --config ../cr.yaml --git-repo charts --package-path .cr-release-packages $(ARGS) $(CHART_DIR)

.PHONY: release-all
release-all: package-all upload-all index-all

.PHONY: update
update:
	python ../../scripts/chart.py $(GLOBAL) update $(ARGS) $(_ARGS) .

.PHONY: version
version:
	@printf "%s\n" $(shell python ../../scripts/chart.py version .)

.PHONY: new-chart
new-chart:
	copier copy $(ARGS) template/ .

.PHONY: init-chart
init-chart: dep docs

.PHONY: update-chart
update-chart:
	copier copy $(ARGS) -a $(shell basename `pwd`)/.copier-answers.yml ../template/ ../

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

.PHONY: dep
dep:
	helm dep update $(ARGS) $(CHART_DIR)

.PHONY: update-common-dep
update-common-dep:
	helm repo update
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common\|template\|\.cr-index-packages\)' \
		| xargs -I% -P 4 /bin/bash -c "pushd %; make dep ARGS='--skip-refresh'; make bump-patch ARGS='--non-interactive --only-patch'"

.PHONY: clean
clean:
	rm -rf .cr-release-packages
