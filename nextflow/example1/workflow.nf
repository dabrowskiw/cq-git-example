nextflow.enable.dsl=2

params.out = "$launchDir/output"

process downloadFile {
  publishDir params.out, mode: "copy", overwrite: true
  output:
    path "blub.fasta"
  """
  wget https://tinyurl.com/cqbatch1 -O blub.fasta
  """
}

process countSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "numseq*"
  """
  grep "^>" $infile | wc -l > numseqs.txt
  """
}

process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  split -d -l 2 --additional-suffix .fasta $infile seq_
  """
}

workflow {
  downloadFile | splitSequences
}
