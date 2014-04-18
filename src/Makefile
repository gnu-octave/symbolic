all: codegen workaround

codegen:
	python generate_functions.py install
	python make_embedded_header.py

workaround:
	cp -f ../inst/@sym/poly2sym.m ../inst/


clean: codegen_clean workaround_undo

codegen_clean:
	python generate_functions.py clean
	rm -f ../inst/private/python_header_embed.m

workaround_undo:
	rm -f ../inst/poly2sym.m

