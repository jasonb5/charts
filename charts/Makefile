.DEFAULT_GOAL := test

CHART_DIR ?= .

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
