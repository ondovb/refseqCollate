#!/bin/bash

if [ $# -lt 2 ]
then
	echo
	echo "collateGenomes.sh <search_dir> <out_prefix>"
	echo
	echo "All fasta sequences with corresponding Genbank records (by accession) in"
	echo "<search_dir> will be collated and written in <out_prefix>/ with a unique name"
	echo "based on its collating criteria, with '.' for missing information:"
	echo
	echo "<acc_pfx>-<tax_id>-<bio_prj>-<bio_smp>-<asm>-<org>.fasta"
	echo "E.g."
	echo "AC-10090-PRJNA16113-SAMN03004379-GCF_000002165.2-.-Mus_musculus.fna"
	echo
	echo "...where:"
	echo "   <acc_pfx>  Two-letter accession prefix (NOT the whole accession)"
	echo "   <tax_id>   Taxonomy ID"
	echo "   <bio_prj>  BioProject"
	echo "   <bio_smp>  BioSample"
	echo "   <asm>      Assembly ID (NZ_ + 4-letter prefix for WGS)"
	echo "   <pls>      Plasmid ID"
	echo "   <org>      Organism name"
	echo
	echo "Output:"
	echo "   <out_prefix>.info           Collation information"
	echo "   <out_prefix>.genomes/       Collated genome fasta files"
	echo
	echo "Only files that are out of date (based on <search_dir> modification"
	echo "time) will be recreated."
	
	exit 0
fi

search="$1"
out="$2"

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

if [ ! -e "$out.info" ] || [ "$search" -nt "$out.info" ]
then
	echo "Extracting info from Genbank records..."
	rm -f "$out.info"
	find "$search" \( -name "*.gbk" -o -name "*.gbk.gz" -o -name "*.gbff" -o -name "*.gbff.gz" -o -name "*.gb" -o -name "*.gb.gz" \) -exec $scriptPath/scripts/createAccTableForCollation.pl {} >> "$out.info" \+
else
	echo "Genbank info up to date."
fi

if [ ! -e "$out.genomes" ] || [ "$out.info" -nt "$out.genomes" ]
then
	echo "Collating genomes..."
	rm -rf "$out.genomes"
	mkdir "$out.genomes"
	find "$search" \( -name "*.fna" -o -name "*.fna.gz" -o -name "*.fasta" -o -name "*.fasta.gz" \) | $scriptPath/scripts/collateGenomes.pl "$out.info" "$out.genomes"
else
	echo "Collated genomes up to date."
fi

