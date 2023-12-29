.DEFAULT_GOAL := test

CHART_DIR ?= .

package upload index: CR_ARGS = $(if $(wildcard ../../cr.yaml),--config ../../cr.yaml,) $(ARGS) 

.PHONY: package
package:
	cr package $(CR_ARGS) $(CHART_DIR)

.PHONY: upload
upload:
	cr upload $(CR_ARGS) --git-repo charts $(CHART_DIR)

.PHONY: index
index:
	cr index $(CR_ARGS) --git-repo charts $(CHART_DIR)

.PHONY: new-chart
new-chart:
	copier copy $(ARGS) template/ .

.PHONY: init-chart
init-chart: update-dep docs

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
bump-%:
	tbump $(ARGS) --no-tag $(shell pysemver bump $* $(shell tbump current-version))

.PHONY: template
template:
	helm template $(ARGS) $(CHART_DIR)

.PHONY: lint
lint:
	helm lint $(ARGS) $(CHART_DIR)

.PHONY: test
test:
	helm unittest $(ARGS) $(CHART_DIR) | grep -v trim

.PHONY: update-dep
update-dep:
	helm dep update $(CHART_DIR)

.PHONY: update-all-dep
update-all-dep:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common\|template\)' | xargs -I% -P 4 make -C % update-dep

.PHONY: clean
clean:
	rm -rf .cr-release-packages
