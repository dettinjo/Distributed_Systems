# Makefile for the Zipf's Law analysis pipeline.
# This file defines a series of rules to automate the entire workflow,
# from preprocessing text files to generating final plots via SLURM.

# ---------------------------------
# 1. Variable and File Definitions
# ---------------------------------

# Automatically find all input book files.
BOOKS       := $(wildcard books/*.txt)

# Define output directories for organization.
LOWER_DIR   := results/lowercase
SORTED_DIR  := results/sorted
DAT_DIR     := results/dat
PNG_DIR     := results/png

# Generate lists of all target files based on the input BOOKS list.
LOWER_FILES  := $(patsubst books/%.txt, $(LOWER_DIR)/%.lower, $(BOOKS))
SORTED_FILES := $(patsubst books/%.txt, $(SORTED_DIR)/%.sorted, $(BOOKS))
DAT_FILES    := $(patsubst books/%.txt, $(DAT_DIR)/%.dat, $(BOOKS))
PNG_FILES    := $(patsubst books/%.txt, $(PNG_DIR)/%.png, $(BOOKS))

# ---------------------------------
# 2. Main Targets
# ---------------------------------

# The default target 'all' depends on the final plot files.
.PHONY: all
all: $(PNG_FILES)
	@echo "Pipeline complete. All plots generated in $(PNG_DIR)."

# The 'clean' target removes all generated files and directories.
.PHONY: clean
clean:
	@echo "Cleaning up generated files and SLURM logs..."
	rm -rf results slurm_plot_*.out

# ---------------------------------
# 3. Special Targets
# ---------------------------------

# Mark intermediate files as .PRECIOUS to prevent 'make' from deleting them
# after they've been used in a subsequent rule.
.PRECIOUS: $(LOWER_FILES) $(SORTED_FILES) $(DAT_FILES)

# ---------------------------------
# 4. Pipeline Pattern Rules
# ---------------------------------

# Rule for converting text to lowercase.
$(LOWER_DIR)/%.lower: books/%.txt | $(LOWER_DIR)
	@echo "Preprocessing: Converting $< to lowercase..."
	tr '[:upper:]' '[:lower:]' < $< > $@

# Rule for sorting the lowercase text.
$(SORTED_DIR)/%.sorted: $(LOWER_DIR)/%.lower | $(SORTED_DIR)
	@echo "Sorting: $<..."
	sort $< > $@

# Rule for counting word frequencies. The python script requires
# the input and output filenames as arguments.
$(DAT_DIR)/%.dat: $(SORTED_DIR)/%.sorted countwords.py | $(DAT_DIR)
	@echo "Counting words: $< -> $@"
	python3 countwords.py $< $@

# Rule for generating plots by submitting a SLURM job.
# The --wait flag is used to make this a synchronous operation, forcing 'make'
# to pause until the SLURM job completes.
$(PNG_DIR)/%.png: $(DAT_DIR)/%.dat plotcounts.py plot_job.slurm | $(PNG_DIR)
	@echo "Submitting SLURM job to generate plot for $@..."
	sbatch --wait plot_job.slurm "$<" "$@"

# ---------------------------------
# 5. Directory Creation
# ---------------------------------

# A single rule to create any of the necessary output directories on demand.
$(LOWER_DIR) $(SORTED_DIR) $(DAT_DIR) $(PNG_DIR):
	@mkdir -p $@