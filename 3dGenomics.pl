##Create by Sanyuan Liu##
########2024.9.19########
#! /usr/bin/perl
use strict;
use warnings;
my $pairix = "/home/liusy22/pairix/bin/pairix";
my $chromap = "/home/106public/software/chromap/chromap";
my $processor = 50;
my $ref = shift or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";
my $pair1 = shift or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";
my $pair2 = shift or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";
my $prefix = shift or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";
open O0, "> 0.samtools.sh" or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";                                                                                         
open O1, "> 1.chromap.sh" or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";                                                                                          
open O2, "> 2.cooler.sh" or die "Usage : perl $0 Refernece_Genome Pair_end_1 Pair_end_2 Outprefix";                                                                                           
print O0  "samtools faidx $ref\ncat $ref.fai | cut -f 1,2 > $prefix.chr.size";
print "......0.samtools.sh Created......\n";
print O1 "$chromap -i -r $ref  -o $prefix\n$chromap --preset hic -r $ref -x $pair1 -2 $pair2 -t $processor -o $prefix.pairs\nbgzip $prefix.pairs\n$pairix $prefix.pairs.gz";                  
print ".......1.chromap.sh Created......\n";
print O2 "cooler cload pairix $prefix.chr.size:50000 $prefix.pairs.gz $prefix.cool -p $processor\ncooler balance $prefix.cool\ncooler zoomify $prefix.cool\ncooler ls $prefix.mcool";         
print ".......2.cooler.sh Created.......\n";
print "........Bash scripts Done........\n";
