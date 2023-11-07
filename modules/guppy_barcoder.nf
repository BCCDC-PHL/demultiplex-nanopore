process guppy_barcoder {

    tag { barcode + " / " + sample_id }

    input:
    tuple val(barcode), val(sample_id), path(run_dir)

    output:
    tuple val(barcode), val(sample_id), path("guppy_barcoder_output/${barcode}/*.fastq.gz"), emit: fastqs
    tuple val(barcode), val(sample_id), path("${sample_id}_barcoding_summary.tsv"), emit: barcoding_summary
    script:
    """
    guppy_barcoder \
	-t ${task.cpus} \
	-i ${run_dir}/fastq_pass/${barcode} \
	-s guppy_barcoder_output \
	--detect_mid_strand_barcodes \
	--trim_adapters \
	--trim_primers \
	--compress_fastq

    cp guppy_barcoder_output/barcoding_summary.txt ${sample_id}_barcoding_summary.tsv
    """
}


process summarize_barcoding_summary {
    
    tag { barcode + " / " + sample_id }

    input:
    tuple val(barcode), val(sample_id), path(barcoding_summary)

    output:
    tuple val(sample_id), path("${sample_id}_barcoding_summary_summary.csv")

    script:
    """
    summarize_barcoding_summary.py \
	--sample-id ${sample_id} \
	${barcoding_summary} \
	> ${sample_id}_barcoding_summary_summary.csv
    """
}


process combine_fastqs {
    
    tag { barcode + " / " + sample_id }

    publishDir "${params.outdir}", pattern: "combined/${sample_id}_${barcode}_RL.fastq.gz", mode: 'copy', saveAs: { filename -> filename.split("/").last() }

    input:
    tuple val(barcode), val(sample_id), path(fastqs)

    output:
    tuple val(sample_id), path("combined/${sample_id}_${barcode}_RL.fastq.gz")

    script:
    """
    mkdir combined
    cat *.fastq.gz > combined/${sample_id}_${barcode}_RL.fastq.gz
    """
}
