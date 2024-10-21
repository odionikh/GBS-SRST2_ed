nextflow.enable.dsl=2

include { SRST2_SRST2 } from './modules/process_srst2.nf'

workflow {
    // Define inputs, typically passed via command line parameters
	reads_ch = channel
                          .fromPath( "${params.reads}/*.{R1,R2}.{fastq,fq}.gz", checkIfExists: true )
                          .map { file -> tuple(file.simpleName, file) }
	   
	   SRST2_SRST2(reads_ch)

//    reads_ch = Channel.fromPath("${params.reads}/*{.fastq,.fq}.gz")            // FASTQ files path

    db_ch = Channel.fromPath(params.db)                   // Database file

}
