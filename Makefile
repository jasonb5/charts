.PHONY: docs-build
docs-build:
	mkdocs build

.PHONY: docs
docs:
	mkdocs serve -a 0.0.0.0:8000

.PHONY: helm-docs
helm-docs:
	helm-docs --sort-values-order file

.PHONY: list-charts
list-charts:
	ls charts | grep -vE "common(-test)?|Makefile|template" | jq --raw-input --slurp --compact-output 'split("\n")[:-1]'
