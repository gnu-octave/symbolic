
sinclude ../../Makeconf

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

%.o: %.cc ; $(MKOCTFILE) -v $(GINAC_CPP_FLAGS) $(HAVE_ND_ARRAYS) $(TYPEID_HAS_CLASS) -c $<

FUNCTIONS=vpa sym is_vpa is_sym is_ex to_double digits\
          Cos Sin Tan aCos aSin aTan Cosh Sinh Tanh aCosh\
          aSinh aTanh Exp Log Sqrt subs differentiate expand\
          collect coeff lcoeff tcoeff degree ldegree quotient\
          remainder premainder Pi ex_matrix probably_prime\
	  findsymbols numden syminfo symlsolve sumterms
	  
SYMBOLS_LINKS=$(addsuffix .oct,$(FUNCTIONS))

ifdef HAVE_GINAC
	PROGS=symbols.oct $(SYMBOLS_LINKS)
	GINAC_CPP_FLAGS=$(shell ginac-config --cppflags)
	GINAC_LD_FLAGS=$(shell ginac-config --libs)
else
	PROGS=
endif


all: $(PROGS)

$(PROGS): Makefile

symbols.oct: $(OBJ)
	$(MKOCTFILE) -v -o $@ $(OBJ) $(GINAC_LD_FLAGS)

$(SYMBOLS_LINKS):
	-$(RM) $@
	$(LN_S) symbols.oct $@

clean: ; $(RM) *.o core octave-core *.oct *~
