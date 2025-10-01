# Allows reference to files that might not be there currently
.PHONY: clean

# Removes artifacts from project file
clean :
	rm -rf figures
	rm -rf derived_data
	rm exploration.md

<derived data>: <r script that tidy's data>
	<shell commands>
