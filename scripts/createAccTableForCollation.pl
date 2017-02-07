#! /usr/bin/perl

use strict;

my $acc;
my $tax;
my $prj;
my $smp;
my $asm;
my $pls;
my $org;

print "#Acc\tTax\tBioPrj\tBioSmp\tAsm\tPlas\tOrg\tFile\n";

foreach my $file ( @ARGV )
{
	if ( $file =~ /.gz$/ )
	{
		open FILE, "gunzip -c $file |" or die $file;
	}
	else
	{
		open FILE, $file or die $file;
	}
	
	while ( <FILE> )
	{
		if ( /^VERSION\s+(\S+)/ )
		{
			$acc = $1;
		}
		elsif ( $acc && /\s+ORGANISM\s+([^\t\n]+)/ )
		{
			$org = $1;
		}
		elsif ( $acc && /^\s+BioProject:\s+(\S+)\n/ )
		{
			$prj = $1;
		}
		elsif ( $acc && /^\s+BioSample:\s+(\S+)\n/ )
		{
			$smp = $1;
		}
		elsif ( $acc && /^\s+Assembly:\s+(\S+)\n/ )
		{
			$asm = $1;
		}
		elsif ( $acc && /\/plasmid=\"([^\"]+)\"/ )
		{
			$pls = $1;
		}
		elsif ( $acc && /taxon:(\d+)/ )
		{
			$tax = $1;
		}
		elsif ( /^\/\// )
		{
			print "$acc\t$tax\t$prj\t$smp\t$asm\t$pls\t$org\t$file\n";
			undef $acc;
			undef $tax;
			undef $prj;
			undef $smp;
			undef $asm;
			undef $pls;
			undef $org;
		}
	}
	
	close FILE;
}
