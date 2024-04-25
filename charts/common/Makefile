CHART_DIR = ../common-test

include ../Makefile

package upload index: CHART_DIR = .

.PHONY: test
test:
	helm unittest $(ARGS) $(CHART_DIR) | grep -v trim
