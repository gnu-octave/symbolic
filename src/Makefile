# the three main targets, all, matlab and clean

all: codegen workaround

matlab: ml_copy ml_workaround ml_codegen

clean: codegen_clean workaround_undo matlab_clean

#######################################################

codegen:
	python generate_functions.py install
	python make_embedded_header.py oct

workaround:
	cp -fa ../inst/@sym/poly2sym.m ../inst/
	cp -fa ../inst/@sym/assumptions.m ../inst/
ml_workaround: ml_copy
	cp -fa ../matlab/@sym/poly2sym.m ../matlab/
	cp -fa ../matlab/@sym/assumptions.m ../matlab/


codegen_clean:
	python generate_functions.py clean
	rm -f ../inst/private/python_header_embed.m

workaround_undo:
	rm -f ../inst/poly2sym.m
	rm -f ../inst/assumptions.m

ml_codegen: ml_copy
	python generate_functions.py ml_install
	python make_embedded_header.py ml


ml_copy: ml_convert
	cp -ra ../inst/private ../matlab/
	cp -ra ../inst/@sym/private ../matlab/@sym/
	cp -ra ../inst/unittests ../matlab/
	cp -af ../CONTRIBUTORS ../matlab/
	cp -af ../COPYING ../matlab/
	cp -af ../matlab_smt_differences.md ../matlab/
	cp -af ../README.md ../matlab/
	cp -af ../README.matlab.md ../matlab/

ml_convert:
	mkdir -p ../matlab/@sym/
	mkdir -p ../matlab/@symfun/
	mkdir -p ../matlab/@logical/
	octave -q --eval "convert_comments('../inst/', '',         '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@symfun',  '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@sym',     '../matlab/')"
	octave -q --eval "convert_comments('../inst/', '@logical', '../matlab/')"

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

