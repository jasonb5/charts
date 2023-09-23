.DEFAULT_GOAL := test

CHART_DIR ?= .

.PHONY: package
package:
	cr package --config ../../cr.yaml $(ARGS) $(CHART_DIR)

.PHONY: upload
upload:
	cr upload --config ../../cr.yaml --git-repo charts $(ARGS) $(CHART_DIR)

.PHONY: index
index:
	cr index --config ../../cr.yaml --git-repo charts $(ARGS) $(CHART_DIR)

.PHONY: new-chart
new-chart:
	copier copy template/ .

.PHONY: docs
docs:
	helm-docs --sort-values-order file $(CHART_DIR)

.PHONY: bump-%
bump-%:
	tbump $(ARGS) --no-tag $(shell pysemver bump $* $(shell tbump current-version))

.PHONY: template
template: dep
	helm template $(ARGS) $(CHART_DIR)

.PHONY: lint
lint: dep
	helm lint $(ARGS) $(CHART_DIR)

.PHONY: test
test: dep
	helm unittest $(ARGS) $(CHART_DIR)

.PHONY: dep
dep:
	helm dep update $(CHART_DIR)
