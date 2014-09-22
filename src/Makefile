# the three main targets, all, matlab and clean

OCTAVE=octave
PYTHON=python

all: codegen

matlab: all ml_copy ml_convert ml_extract_tests ml_tidyup

clean: codegen_clean matlab_clean

#######################################################

codegen:
	${PYTHON} generate_functions.py install
	${PYTHON} make_embedded_header.py

codegen_clean:
	${PYTHON} generate_functions.py clean
	rm -f ../inst/private/python_header_embed.m

ml_tidyup: ml_copy ml_convert ml_extract_tests
	rm -f ../matlab/extract_tests_for_matlab.m
	rm -f ../matlab/octsympy_tests.m

ml_extract_tests: ml_copy
	mkdir -p ../matlab/tests_matlab/
	cp -ra extract_tests_for_matlab.m ../matlab/
	cp -ra octsympy_tests_matlab.m ../matlab/
	cd ../matlab/; ${OCTAVE} -q --eval "extract_tests_for_matlab"

ml_copy: ml_convert
	cp -ra ../inst/private ../matlab/
	cp -ra ../inst/@sym/private ../matlab/@sym/
	cp -ra ../inst/@symfun/private ../matlab/@symfun/
	cp -af ../CONTRIBUTORS ../matlab/
	cp -af ../NEWS ../matlab/
	cp -af ../COPYING ../matlab/
	cp -af ../matlab_smt_differences.md ../matlab/
	cp -af ../README.md ../matlab/
	cp -af ../README.matlab.md ../matlab/

ml_convert:
	mkdir -p ../matlab/@sym/
	mkdir -p ../matlab/@symfun/
	mkdir -p ../matlab/@logical/
	${OCTAVE} -q --eval "convert_comments('../inst/', '',         '../matlab/')"
	${OCTAVE} -q --eval "convert_comments('../inst/', '@symfun',  '../matlab/')"
	${OCTAVE} -q --eval "convert_comments('../inst/', '@sym',     '../matlab/')"
	${OCTAVE} -q --eval "convert_comments('../inst/', '@logical', '../matlab/')"

matlab_clean:
	rm -f ../matlab/*.m
	rm -f ../matlab/CONTRIBUTORS
	rm -f ../matlab/COPYING
	rm -f ../matlab/*.md
	rm -rf ../matlab/@sym
	rm -rf ../matlab/@symfun
	rm -rf ../matlab/@logical
	rm -rf ../matlab/private
	rm -rf ../matlab/tests_matlab

