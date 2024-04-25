include ../Makefile

install: $(ARGS) --timeout 8m

.PHONY: test
test:
	pytest $(ARGS) -vvv test_chart.py
