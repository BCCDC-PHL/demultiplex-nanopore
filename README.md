# demultiplex-nanopore

# Setup
This pipeline assumes that `guppy_barcoder` is available on the `PATH`. It is known to be compatible with ont-guppy-cpu v6.3.7, and may not be compatible with other versions.

## Usage

```
nextflow run BCCDC-PHL/demultiplex-nanopore \
  --run_dir </path/to/nanopore_run>
  --samplesheet </path/to/nanopore_run/sample_sheet.csv>
  --outdir </path/to/nanopore_run/fastq_pass_combined>
```
