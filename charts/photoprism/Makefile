ROOT_DIR := ../..

COMMON_MAKEFILE := $(ROOT_DIR)/charts/common.mk

include $(COMMON_MAKEFILE)

FORMAT := "(?P<major>.*)"

.PHONY: test
test:
	pytest $(ARGS) -vvv test_chart.py
