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

process splitSequencesPython {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  python $projectDir/split.py $infile seq_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.basecount"
  """
  grep -v "^>" $infile | wc -m > ${infile.getSimpleName()}.basecount
  """
}

workflow {
//  downloadFile | splitSequencesPython | countBases
  fastachannel = downloadFile()
  singlefastachannel = splitSequencesPython(fastachannel)
  singlefastachannel_flat = singlefastachannel.flatten()
  countBases(singlefastachannel_flat)
}
