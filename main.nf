nextflow.enable.dsl=2

include { SRST2_SRST2 } from './modules/process_srst2_edit.nf'
include { COLLATE_FULL_GENE_RESULTS } from './modules/process_srst2_edit.nf'

workflow {
  //step1
    reads_ch = channel
	.fromFilePairs( "${params.reads}/${params.fastq_pattern}", checkIfExists: true )
			
    gene_db_ch = Channel.fromPath(params.gene_db)

//          reads_ch.combine(gene_db_ch).view()			
	 
// step 2
    SRST2_SRST2(reads_ch.combine(gene_db_ch))
    
    collected_fullgene_ch = SRST2_SRST2.out.fullgene_result.collect( sort: {a, b -> a[0].getBaseName() <=> b[0].getBaseName()} )

    COLLATE_FULL_GENE_RESULTS(collected_fullgene_ch)

}
