#! /usr/bin/perl

use strict;

if ( @ARGV != 2 )
{
	print "See collateGenomes.sh\n";
	exit 0;
}

my ($table, $prefix) = @ARGV;

system("rm -f $prefix/*.fasta");

my %accByAcc;
my %taxByAcc;
my %prjByAcc;
my %smpByAcc;
my %asmByAcc;
my %plsByAcc;
my %orgByAcc;

open TABLE, "$table" or die $table;

<TABLE>; # eat header

while ( <TABLE> )
{
	chomp;
	my ($acc, $tax, $prj, $smp, $asm, $pls, $org) = split /\t/;
	
	if ( ! $asm && $acc =~ /(NZ_[A-Z]{4})/ )
	{
		$asm = $1;
	}
	
	$accByAcc{$acc} = substr $acc, 0, 2;
	$taxByAcc{$acc} = $tax;
	$prjByAcc{$acc} = $prj;
	$smpByAcc{$acc} = $smp;
	$asmByAcc{$acc} = $asm;
	
	$pls =~ s/[^\w\.]+/_/g;
	
	$plsByAcc{$acc} = $pls;
	
	$org =~ s/[^\w\.]+/_/g;
	$org =~ s/^_//;
	$org =~ s/_$//;
	
	$orgByAcc{$acc} = $org;
}

close TABLE;

my %accUsed;
my $idCurrent;

while ( <STDIN> )
{
	chomp;
	my $file = $_;
	
	if ( $file =~ /.gz$/ )
	{
		open FILE, "gunzip -c $file |" or die $file;
	}
	else
	{
		open FILE, $file or die $file;
	}
	
	#print "$file\n";
	
	while ( <FILE> )
	{
		if ( /^>(\S+)/ )
		{
			my $tag = $1;
			my $acc;
			
			if ( $tag =~ /\|/ )
			{
				$acc = (split /\|/, $tag)[3];
			}
			else
			{
				$acc = $tag;
			}
			
			if ( $accUsed{$acc} )
			{
				undef $idCurrent;
				next;
			}
			else
			{
				$accUsed{$acc} = 1;
			}
			
			my $idNew = join '-',
			(
				$accByAcc{$acc} ? $accByAcc{$acc} : '.',
				$taxByAcc{$acc} ? $taxByAcc{$acc} : '.',
				$prjByAcc{$acc} ? $prjByAcc{$acc} : '.',
				$smpByAcc{$acc} ? $smpByAcc{$acc} : '.',
				$asmByAcc{$acc} ? $asmByAcc{$acc} : '.',
				$plsByAcc{$acc} ? $plsByAcc{$acc} : '.',
				$orgByAcc{$acc} ? $orgByAcc{$acc} : '.',
			);
			
			if ( $idNew ne $idCurrent )
			{
				$idCurrent = $idNew;
				
				my $file = "$prefix/$idCurrent.fasta";
				open OUT, ">>$file" or die "writing to $file";
			}
		}
		
		if ( $idCurrent )
		{
			print OUT;
		}
	}
	
	close FILE
}

close OUT;
