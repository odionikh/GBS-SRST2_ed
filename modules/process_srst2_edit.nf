process SRST2_SRST2 {
    tag "$meta"

    container 'staphb/srst2:latest'

    publishDir "${params.output_dir}/", mode:'copy'

    input:
    tuple val(meta), path(fastq_s), path(gene_db)

    output:
    tuple val(meta), path("*_genes_*_results.txt")               , optional:true, emit: gene_results
    path("*_fullgenes_*_results.txt")           , optional:true, emit: fullgene_results
    tuple val(meta), path("*_mlst_*_results.txt")                , optional:true, emit: mlst_results
    tuple val(meta), path("*.pileup")                            ,                emit: pileup
    tuple val(meta), path("*.sorted.bam")                        ,                emit: sorted_bam
    path "versions.yml"                                          ,                emit: versions

    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""

    """
    srst2 \\
        --input_pe ${fastq_s[0]}  ${fastq_s[1]} --forward _R1 --reverse _R2 \\
        --threads $task.cpus \\
        --output ${meta} \\
        --gene_db ${gene_db} \\
        $args
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        srst2: \$(echo \$(srst2 --version 2>&1) | sed 's/srst2 //' ))
    END_VERSIONS
    """
}


process COLLATE_FULL_GENE_RESULTS {

    tag 'collate GBS serotype'

    publishDir "${params.output_dir}/fullgenes/", mode:'copy'
    
    input:
    path(fullgene_results)

    output:
    path "final_GBS.txt"

    script:
    
    """
    FULL_GENE_RESULT_FILES=(${fullgene_results})
    for index in \${!FULL_GENE_RESULT_FILES[@]}; do
    FULL_GENE_RESULT_FILE=\${FULL_GENE_RESULT_FILES[\$index]}
    awk -v OFS='\\t' 'FNR>=1 { print \$0 }' \${FULL_GENE_RESULT_FILE} >> final_GBS.txt

    done

    """
}


//    cat ${fullgene_results.join(' ')} > final_GBS.txt
//    awk 'FNR==1 && NR!=1{next;}{print}' ${fullgene_results} > final_GBS.txt
//    cat ${fullgene_results}  >> final_GBS.txt
