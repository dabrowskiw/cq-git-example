nextflow.enable.dsl=2

process downloadFile {
  publishDir "/home/wojtek/cq-git-example/nextflow/example1", mode: "copy", overwrite: true
  output:
    path "blub.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O blub.fasta
  """
}

process countSequences {
  publishDir "/home/wojtek/cq-git-example/nextflow/example1", mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "numseqs.txt"
  """
  grep "^>" $infile | wc -l > numseqs.txt
  """
}

workflow {
  downloadFile | countSequences
}
