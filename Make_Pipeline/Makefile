# -----------------------------------------------------------------------------
# Makefile for Zipf's Law Analysis Pipeline (FINAL VERSION)
# -----------------------------------------------------------------------------

# --- 1. Variable Definitions ---
BOOKS       := $(wildcard books/*.txt)
LOWER_DIR   := results/lowercase
SORTED_DIR  := results/sorted
DAT_DIR     := results/dat
PNG_DIR     := results/png

LOWER_FILES  := $(patsubst books/%.txt, $(LOWER_DIR)/%.lower, $(BOOKS))
SORTED_FILES := $(patsubst books/%.txt, $(SORTED_DIR)/%.sorted, $(BOOKS))
DAT_FILES    := $(patsubst books/%.txt, $(DAT_DIR)/%.dat, $(BOOKS))
PNG_FILES    := $(patsubst books/%.txt, $(PNG_DIR)/%.png, $(BOOKS))


# --- 2. Phony and Special Targets ---
.PHONY: all clean

# --- SOLUTION TO FILE DELETION ---
# Declare all intermediate file patterns as .PRECIOUS.
# This tells 'make' not to automatically delete them upon completion.
.PRECIOUS: $(LOWER_FILES) $(SORTED_FILES) $(DAT_FILES)


# --- 3. Main Rule ---
all: $(PNG_FILES)
	@echo "✅ Pipeline complete. All plots generated in $(PNG_DIR)."


# --- 4. Pipeline Pattern Rules ---
$(LOWER_DIR)/%.lower: books/%.txt | $(LOWER_DIR)
	@echo "Preprocessing: Converting $< to lowercase..."
	tr '[:upper:]' '[:lower:]' < $< > $@

$(SORTED_DIR)/%.sorted: $(LOWER_DIR)/%.lower | $(SORTED_DIR)
	@echo "Sorting: $<..."
	sort $< > $@

$(DAT_DIR)/%.dat: $(SORTED_DIR)/%.sorted countwords.py | $(DAT_DIR)
	@echo "Counting words: $< -> $@"
	python3 countwords.py $< $@

$(PNG_DIR)/%.png: $(DAT_DIR)/%.dat plotcounts.py plot_job.slurm | $(PNG_DIR)
	@echo "Submitting SLURM job to generate plot for $@..."
	sbatch --wait plot_job.slurm "$<" "$@"


# --- 5. Directory Creation Rule ---
$(LOWER_DIR) $(SORTED_DIR) $(DAT_DIR) $(PNG_DIR):
	@mkdir -p $@


# --- 6. Cleanup Rule ---
clean:
	@echo "Cleaning up all generated files and SLURM logs..."
	rm -rf results slurm_plot_*.out