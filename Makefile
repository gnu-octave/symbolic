sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = $(patsubst %,symbolic/%, COPYING DESCRIPTION INDEX PKG_ADD \
	$(wildcard doc/*) $(wildcard inst/*) $(wildcard src/*))
