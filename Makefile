.PHONY: docs-build
docs-build:
	mkdocs build

.PHONY: docs
docs:
	mkdocs serve -a 0.0.0.0:8000
