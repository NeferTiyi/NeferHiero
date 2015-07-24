RM := rm -vf
LTXMK := latexmk -pdf
LTXCL := latexmk -f

# You want latexmk to *always* run, because make does not have all 
# the info. Also, include non-file targets in .PHONY so they are run
# regardless of any file of the given name existing.
.PHONY: $(ROOTDOC).pdf all clean
# .PHONY: Kheops_Grandet_Histoire.pdf all clean

# The first rule in a Makefile is the one executed by default ("make"). 
# It should always be the "all" rule, so that "make" and "make all" are 
# identical.
all: $(ROOTDOC).pdf

# CUSTOM BUILD RULES

# In case you didn't known, '$@' is a variable holding the name of 
# the target, and '$<' is a variable holding the (first) dependancy 
# of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom 
# steps you might have.


# TEXSRCS := $(shell ls *.tex)
HTXSRCS := $(shell ls *.htx)
HTXOBJS := $(HTXSRCS:.htx=.tex)
TMPOBJS := $(ROOTDOC).bbl \
	   $(ROOTDOC).dic \
	   $(ROOTDOC).run.xml

%.tex: %.htx
	htx2tex $<

# HTXFILES: $(HTXOBJS)

# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific 
# options.
# -use-make tells latexmk to call make for generating missing files.

# -interactive=nonstopmode keeps the pdflatex backend from stopping 
# at a missing file reference and interactively asking you for an 
# alternative.

# Kheops_Grandet_Histoire.pdf: Kheops_Grandet_Histoire.tex
# 	latexmk -pdf -pdflatex="pdflatex -interactive=nonstopmode" \
# 		-use-make Kheops_Grandet_Histoire.tex
# $(ROOTDOC).pdf: $(HTXOBJS) $(TEXSRCS)
$(ROOTDOC).pdf: $(HTXOBJS)
	# @echo $(TEXSRCS)
	$(LTXMK) $(ROOTDOC).tex

# Cleaning
cleantmp:
	@$(RM) $(HTXOBJS) $(TMPOBJS)

cleanltxc:
	$(LTXCL) -c $(ROOTDOC).tex

cleanltxC:
	$(LTXCL) -C $(ROOTDOC).tex

clean: cleanltxc cleantmp

realclean: cleanltxC cleantmp
