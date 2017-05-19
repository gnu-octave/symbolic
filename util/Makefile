# Copyright 2016 Colin B. Macdonald
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

OCTAVE ?= octave
PYTHON ?= python

.PHONY: help codegen

help:
	@echo "Available development tasks:"
	@echo "  codegen            regenerate the auto-generated .m functions"

codegen:
	${PYTHON} generate_functions.py install
