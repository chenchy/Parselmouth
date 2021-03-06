# Praat script createTests.praat
# Paul Boersma 2017-10-08

# This script extracts tests from C++ source code files
# in which Praat script snippets have been inserted
# between a "/*@praat" line and a "@*/" line,
# or after "//@praat " at the end of a line.
#
# For instance, the tests in the source code file sys/Formula.cpp
# are put into the new file test/sys/Formula.cpp.praat.

stopwatch

writeInfoLine: "Creating tests..."
numberOfTestFiles = 0
totalNumberOfTests = 0

@createAllPraatTestsInFolder: "kar"
@createAllPraatTestsInFolder: "num"
@createAllPraatTestsInFolder: "sys"
@createAllPraatTestsInFolder: "stat"
@createAllPraatTestsInFolder: "fon"
@createAllPraatTestsInFolder: "gram"
@createAllPraatTestsInFolder: "artsynth"
@createAllPraatTestsInFolder: "EEG"
@createAllPraatTestsInFolder: "contrib/ola"
@createAllPraatTestsInFolder: "main"

procedure createAllPraatTestsInFolder: .folder$
	.files.Strings = Create Strings as file list: "files", "../" + .folder$ + "/*.cpp"
	.numberOfFiles = Get number of strings
	for .ifile to .numberOfFiles
		selectObject: .files.Strings
		.fileName$ = Get string: .ifile
		@createTest: .folder$, .fileName$
	endfor
	removeObject: .files.Strings
	.files.Strings = Create Strings as file list: "files", "../" + .folder$ + "/*.h"
	.numberOfFiles = Get number of strings
	for .ifile to .numberOfFiles
		selectObject: .files.Strings
		.fileName$ = Get string: .ifile
		@createTest: .folder$, .fileName$
	endfor
	removeObject: .files.Strings
endproc

procedure createTest: .folder$, .file$
	.sourceFile$ = "../" + .folder$ + "/" + .file$
	.lines = Read Strings from raw text file: .sourceFile$
	.numberOfLines = Get number of strings
	.targetFile$ = .folder$ + "/" + .file$ + ".praat"
	.numberOfTestsInThisFile = 0
	for .iline to .numberOfLines - 2
		.line$ = Get string: .iline
		if index (.line$, "/*@praat") or index (.line$, "//@praat")
			if .numberOfTestsInThisFile = 0
				writeFileLine: .targetFile$, "# File ", .folder$, "/", .file$, ".praat"
				appendFileLine: .targetFile$, "# Generated by test/createTests.praat"
				appendFileLine: .targetFile$, "# ", date$ ()
			endif
			.numberOfTestsInThisFile += 1
			appendFileLine: .targetFile$, ""
			if index (.line$, "//@praat")
				appendFileLine: .targetFile$, mid$ (.line$, index (.line$, "//@praat") + 9, 1000)
			else
				.numberOfLeadingTabs = index (.line$, "/*@praat")
				label again
				.iline += 1
				.line$ = Get string: .iline
				goto finish index (.line$, "@*/")
				appendFileLine: .targetFile$, mid$ (.line$, .numberOfLeadingTabs + 1, 1000)
				goto again
			endif
		endif
		label finish
	endfor
	Remove
	if .numberOfTestsInThisFile > 0
		appendFileLine: .targetFile$, newline$, "appendInfoLine: """, .targetFile$, """", ", "" OK"""
		appendInfoLine: "Written ", .numberOfTestsInThisFile, " tests into ", .targetFile$
		numberOfTestFiles += 1
		totalNumberOfTests += .numberOfTestsInThisFile
	endif
endproc

appendInfoLine: newline$, "Written ", numberOfTestFiles, " files with ", totalNumberOfTests, " tests in ", fixed$ (stopwatch, 3) , " seconds"
appendInfoLine: "OK"