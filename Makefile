
sinclude ../../Makeconf

ifndef MKOCTFILE
# assumptions to make if not using ./configure script
MKOCTFILE=mkoctfile
HAVE_GINAC=1
endif

SRC=symbols.cc ov-ex.cc ov-sym.cc ov-vpa.cc
OBJ=$(SRC:.cc=.o)

%.o: %.cc ; $(MKOCTFILE) -v $(GINAC_CPP_FLAGS) -c $<

ifdef HAVE_GINAC

GINAC_CPP_FLAGS=$(shell ginac-config --cppflags)
GINAC_LD_FLAGS=$(shell ginac-config --libs)

all: symbols.oct

symbols.oct: $(OBJ)
	$(MKOCTFILE) -v -o $@ $(OBJ) $(GINAC_LD_FLAGS)

else

all:

endif

clean:
	$(RM) *.o *.oct core octave-core *~


