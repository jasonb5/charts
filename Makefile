.PHONY: docs-build
docs-build:
	mkdocs build

.PHONY: docs-serve
docs-serve:
	mkdocs serve -a 0.0.0.0:8000
