CHART_DIR = ../common-test

ROOT_DIR := ../..

COMMON_MAKEFILE := $(ROOT_DIR)/charts/common.mk

include $(COMMON_MAKEFILE)

package upload index: CHART_DIR = .

.PHONY: test
test:
	helm unittest $(ARGS) $(CHART_DIR) | grep -v trim
