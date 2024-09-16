nextflow.enable.dsl = 2

params.accession = null
params.cache = "${launchDir}/cache"
params.out = "${launchDir}/out"

process prefetch {
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  storeDir params.cache
  input:
    val accession
  output:
    path "${accession}"
  """
  prefetch ${accession}
  """
}

process fasterqdump {
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  storeDir params.cache
  input:
    path sradir
  output:
    path "${sradir}.fastq"
  """
  fasterq-dump ${sradir} 
  """
} 

process fastqc {
  container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
  input:
    path fastqfile
  output:
    path "fastqc_${fastqfile.getSimpleName()}"
  """
  mkdir fastqc_${fastqfile.getSimpleName()} 
  fastqc -o fastqc_${fastqfile.getSimpleName()} ${fastqfile}
  """
}

process fastp {
  publishDir params.out, mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--hadf994f_3"
  input:
    path fastqfile
  output:
    path "${fastqfile.getSimpleName()}_trimmed.*"
  """
  fastp -i $fastqfile -o ${fastqfile.getSimpleName()}_trimmed.fastq
  mv fastp.json ${fastqfile.getSimpleName()}_trimmed.json
  """
}

process multiqc {
  publishDir params.out, mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/multiqc%3A1.24.1--pyhdfd78af_0"
  input:
    path stuff
  output:
    path "multiqc_report.html", emit: report
  """
  multiqc .
  """
}

workflow {
  if(params.accession == null) {
    print("Please provide an accession, e.g. '--accession SRR1777174'.")
    System.exit(1)
  }
  accession_channel = Channel.from(params.accession)
  sra_channel = prefetch(accession_channel)
  rawfastq_channel = fasterqdump(sra_channel)
  fastqc_channel = fastqc(rawfastq_channel)
  fastp_channel = fastp(rawfastq_channel)
  combined_channel = fastqc_channel.concat(fastp_channel)
  combined_collected_channel = combined_channel.collect()
  multiqc(combined_collected_channel)

}
