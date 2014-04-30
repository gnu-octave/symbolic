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


# FIXME: need to do the autogeneration here too!
matlab:
	mkdir -p ../matlab/@sym/
	mkdir -p ../matlab/@symfun/
	mkdir -p ../matlab/@logical/
	octave -q --eval "convert_comments('../inst/', '',         '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@symfun',  '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@sym',     '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@logical', '../matlab/')"
	cp -ra ../inst/private ../matlab/
	cp -ra ../inst/@sym/private ../matlab/@sym/
	cp -ra ../inst/unittests ../matlab/
	cp -ra ../CONTRIBUTORS ../matlab/
	cp -ra ../COPYING ../matlab/
	cp -ra ../matlab_smt_differences.md ../matlab/
	cp -ra ../README.md ../matlab/


matlab_clean:
	rm -f ../matlab/*.m
	rm -f ../matlab/CONTRIBUTORS
	rm -f ../matlab/COPYING
	rm -f ../matlab/*.md
	rm -rf ../matlab/@sym
	rm -rf ../matlab/@symfun
	rm -rf ../matlab/@logical
	rm -rf ../matlab/private
	rm -rf ../matlab/unittests

