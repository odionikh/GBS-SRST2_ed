nextflow.enable.dsl=2

// include { SRST2_SRST2 } from './modules/process_srst2.nf'
 include { SRST2_SRST2 } from './modules/process_srst2_edit.nf'
workflow {
    // Define inputs, typically passed via command line parameters
  //	reads_ch = channel
    //                      .fromPath( "${params.reads}", checkIfExists: true )
      //                    .map { file -> tuple(file.simpleName, file) }

       reads_ch = channel
			.fromFilePairs( "${params.reads}/${params.fastq_pattern}", checkIfExists: true )
	    		
           db_ch = Channel.fromPath(params.db)
          reads_ch.combine(db_ch).view()
	  SRST2_SRST2(reads_ch.combine(db_ch))

//    reads_ch = Channel.fromPath("${params.reads}/*{.fastq,.fq}.gz")            // FASTQ files path

  //  db_ch = Channel.fromPath(params.db)                   // Database file

}
