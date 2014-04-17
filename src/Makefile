all: codegen workaround

codegen:
	python generate_functions.py install

workaround:
	cp -f ../inst/@sym/poly2sym.m ../inst/

clean: codegen_clean workaround_undo

codegen_clean:
	python generate_functions.py clean

workaround_undo:
	rm -f ../inst/poly2sym.m

