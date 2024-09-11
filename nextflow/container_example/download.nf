nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.accession="SRR1777174"

process prefetch {
  storeDir params.storeDir
  input:
    val accession
  output:
    path "${accession}"
  script:
  """
  prefetch $accession
  """
}

workflow {
  prefetch(Channel.from(params.accession))
}
