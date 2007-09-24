
sinclude Makeconf

# assumptions to make if not using ./configure script
ifndef OCTAVE_FORGE
	MKOCTFILE=mkoctfile
	HAVE_GINAC=1
endif

#SRC=symbols.cc probably_prime.cc differentiate.cc \
#	sym-bool.cc sym-create.cc \
#	ov-ex.cc ov-sym.cc ov-vpa.cc ov-ex-mat.cc ov-relational.cc \
#	op-ex-mat.cc op-ex.cc op-sym.cc op-vpa.cc 
SRC=symbols.cc probably_prime.cc differentiate.cc \
	findsymbols.cc numden.cc syminfo.cc symlsolve.cc sumterms.cc\
	sym-bool.cc sym-create.cc \
	ov-ex.cc ov-vpa.cc ov-ex-mat.cc ov-relational.cc \
	op-ex-mat.cc op-ex.cc op-vpa.cc 
OBJ=$(SRC:.cc=.o)

%.o: %.cc ; $(MKOCTFILE) -v $(GINAC_CFLAGS) $(HAVE_ND_ARRAYS) $(TYPEID_HAS_CLASS) -c $<

ifdef HAVE_GINAC
PROGS=symbols.oct

all: $(PROGS)
else
all:
	@echo "Ginac library or headers not found"
	false

endif

$(PROGS): Makefile

symbols.oct: $(OBJ)
	$(MKOCTFILE) -v -o $@ $(OBJ) $(GINAC_LIBS)

clean: ; $(RM) *.o core octave-core *.oct *~
