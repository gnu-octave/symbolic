
sinclude ../../Makeconf

ifndef MKOCTFILE
# assumptions to make if not using ./configure script
MKOCTFILE=mkoctfile
HAVE_GINAC=1
endif

SRC=symbols.cc ov-ex.cc ov-sym.cc ov-vpa.cc ov-ex-mat.cc
OBJ=$(SRC:.cc=.o)

%.o: %.cc ; $(MKOCTFILE) -v $(GINAC_CPP_FLAGS) -c $<

ifdef HAVE_GINAC

GINAC_CPP_FLAGS=$(shell ginac-config --cppflags)
GINAC_LD_FLAGS=$(shell ginac-config --libs)

FUNCTIONS=vpa sym is_vpa is_sym is_ex to_double digits\
          Cos Sin Tan aCos aSin aTan Cosh Sinh Tanh aCosh\
          aSinh aTanh Exp Log subs differentiate expand\
          collect coeff lcoeff tcoeff degree ldegree quotient\
          remainder premainder Pi ex_matrix
OBJLINKS=$(addsuffix .oct,$(FUNCTIONS))

all: symbols.oct

symbols.oct: $(OBJ)
	$(MKOCTFILE) -v -o $@ $(OBJ) $(GINAC_LD_FLAGS) ; \
	for i in $(OBJLINKS); do ln -sf symbols.oct $$i ; done

else

all:

endif

clean:
	$(RM) *.o *.oct core octave-core *~


