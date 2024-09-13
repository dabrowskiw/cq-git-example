nextflow.enable.dsl = 2

process doSomething {
  publishDir launchDir
  input:
    tuple val(project), path(files)
  output:
    path "${project}.txt"
  """
  echo "The project contains the following files:" > ${project}.txt
  echo ${files[0]} >> ${project}.txt
  echo ${files[1]} >> ${project}.txt
  """
}

workflow {
  Channel.fromFilePairs("input/*_{1,2}.fastq") | doSomething
}
