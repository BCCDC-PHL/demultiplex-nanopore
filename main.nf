#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { guppy_barcoder }               from './modules/guppy_barcoder.nf'
include { summarize_barcoding_summary }  from './modules/guppy_barcoder.nf'
include { combine_fastqs }               from './modules/guppy_barcoder.nf'

workflow {
    ch_samplesheet = Channel.fromPath(params.samplesheet)
    ch_barcodes = ch_samplesheet.splitCsv(header: true, sep: ',').map{ it -> [it['barcode'], it['alias'].split('_')[0]] }
    ch_run_dir = Channel.fromPath(params.run_dir).filter{ it -> it.isDirectory() }

    main:
    guppy_barcoder(ch_barcodes.combine(ch_run_dir))

    ch_barcoding_summary_summaries = summarize_barcoding_summary(guppy_barcoder.out.barcoding_summary)
    ch_barcoding_summary_summaries.map{ it -> it[1] }.collectFile(keepHeader: true, name: 'barcoding_summary_summary.csv', storeDir: params.outdir)

    combine_fastqs(guppy_barcoder.out.fastqs)
    
}
