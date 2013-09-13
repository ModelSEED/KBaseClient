#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger, Mike Mundy, Matt Benedict
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::Helpers qw(get_fba_client runFBACommand universalFBAScriptCode );
use Bio::KBase::CDMI::CDMIClient;
use SeedUtils;
use Try::Tiny;

#Defining globals describing behavior
my $primaryArgs = ["Cofactor list filename"];
my $servercommand = "set_cofactors";
my $script = "fba-setcofactors";
my $translation = {
	biochem => "biochemistry",
	biochemws => "biochemistry_workspace",
	reset => "reset",
	auth => "auth",
	overwrite => "overwrite",
};
#Defining usage and options
my $specs = [
	[ 'biochem|b:s', 'ID of biochemistry database', { "default" => "default"} ],
    [ 'biochemws|w:s', 'Workspace where biochemistry database is located', { "default" => workspace() } ],
    [ 'reset|r', 'Reset (turn off) compounds as universal cofactors', { "default" => 0 } ],
    [ 'overwrite|o', 'Overwrite existing biochemistry database with same name', { "default" => 0 } ]
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);


my $client = get_fba_client();
my $clientO = get_ws_client();
my $subclaHash = {
    "Carbohydrates" => '1',
    "Cofactors, Vitamins, Prosthetic Groups, Pigments" => '1',
    "Respiration" => '1',
    "Protein Metabolism" => '1',
    "AminoAcidsandDerivatives" => '1',
    "Stress Response" => '1',
    "Nucleosides and Nucleotides" => '1',
    "Regulation and Cell signaling" => '1',
    "Miscellaneous" => '1',
    "Amino Acids and Derivatives" => '1',
    "Fatty Acids, Lipids, and Isoprenoids" => '1',
    "RNA Metabolism" => '1',
    "Metabolism of Aromatic Compounds" => '1',
    "Membrane Transport" => '1',
    "Phosphorus Metabolism" => '1',
    "Secondary Metabolism" => '1',
    "Iron acquisition and metabolism" => '1',
    "Phages, Prophages, Transposable elements, Plasmids" => '1',
    "Cell Division and Cell Cycle" => '1',
    "Nitrogen Metabolism" => '1',
    "Sulfur Metabolism" => '1',
    "DNA Metabolism" => '1',
    "Arabinose Sensor and transport module" => '1',
    "Potassium metabolism" => '1',
    "Transcriptional regulation" => '1',
    "Plasmids" => '1',
    "Central metabolism" => '1',
};
my $universal = {
      rxn00062 => '1',
      rxn01208 => '1',
      rxn04132 => '1',
      rxn04133 => '1',
      rxn05319 => '1',
      rxn05467 => '1',
      rxn05468 => '1',
      rxn02374 => '1',
      rxn05116 => '1',
      rxn03012 => '1',
      rxn05064 => '1',
      rxn02666 => '1',
      rxn04457 => '1',
      rxn04456 => '1',
      rxn01664 => '1',
      rxn02916 => '1',
      rxn05667 => '1',
      rxn05651 => '1',
      rxn10473 => '1',
      rxn10571 => '1',
      rxn05195 => '1',
      rxn05555 => '1',
};





#Make sure cofactor list file exists
if (!-e $opt->{"Cofactor list filename"}) {
	print "Could not find input cofactor list file!\n";
	exit(1);
}
#Read the lines from the cofactor list file into the data array
open(my $fh, "<", $opt->{"Cofactor list filename"}) || return;
my $data = [];
while (my $line = <$fh>) {
	chomp($line);
	push(@{$data},$line);
}
close($fh);
#Build the array of cofactor compounds from each line in the file
foreach my $line (@{$data}) {
	push(@{$params->{cofactors}},$line);
}
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "Setting cofactors failed!\n";
	exit(1);
} else {
	print "Cofactors successfully set in biochemistry:\n";
	printObjectMeta($output);
}
exit(0);



open INFILECL, "/homes/janakae/PamGenomes/subsystem_classification_text.txt" or die "Couldn't open subsysclassification file $!\n";

# If you want your annotations filters by a selected list of subsystems include them here




my %classroleHash;
my %classifyHash;
my %cCheck;
my %allrxns;
my %nonCoreRxn;
my %corerxns;
my %modelrxnHashComp;
my %pegid_hash;
my %pegid_hash_check;

 while (my $subClaArray = <INFILECL>){
    chomp $subClaArray;
    
    my @ClaArray = split /\t/, $subClaArray;

    $ClaArray[0] =~ s/^\s+//;
    $ClaArray[0] =~ s/\s+$//;
    $ClaArray[1] =~ s/^\s+//;
    $ClaArray[1] =~ s/\s+$//;
    $ClaArray[2] =~ s/^\s+//;
    $ClaArray[2] =~ s/\s+$//;

    $classroleHash{$ClaArray[0]}{$ClaArray[2]} = [$ClaArray[0],$ClaArray[1],$ClaArray[2]];


#   if (exists $subclaHash{$ClaArray[0]}){

    $cCheck{$ClaArray[0]}=$ClaArray[2];
    $classifyHash{$ClaArray[0]}->{$ClaArray[1]}->{$ClaArray[2]} = $ClaArray[2];

#   }
    
 }
  

close INFILECL;


my @hashArray;
my @model_Ref;
my @mArr;
my @wArr;
while (defined($_ = <STDIN>)){

    chop;
    my($g_id,$m_id, $w_id) = split(/\s+/,$_);


my %modelHash = (

    models => [$m_id],
    workspaces => [$w_id],

);

my %genomeHash = (

    id => $g_id,
    type => 'Genome',
    workspace => $w_id,

);


my $genome = $clientO->get_object(\%genomeHash);
my $genomeData = $genome->{data}->{features};
for(my $i =0; $i< @{$genomeData}; $i++){
try {
    my $func = $genomeData->[$i]->{function};
     
    my $id = $genomeData->[$i]->{id};
    $pegid_hash{$id} = $func;
     my @roles = &SeedUtils::roles_of_function($func);
      foreach my $r (@roles){
        $pegid_hash_check{$id}{$r} = $func;
      }
   }

}
    
############################################################################
my $model = $client->get_models(\%modelHash);
my $modelOne = $model->[0]->{reactions}; 
my $mgenome = $model->[0]->{genome}; 
#my %modelrxnHashComp = ();
my %modelGapFill;
my %modelrxnsOnly;
for(my $i =0; $i< @{$modelOne}; $i++){

    my $rxn_co = $modelOne->[$i]->{id};
    my $rname = $modelOne->[$i]->{name};
    my $f = $modelOne->[$i]->{features};
    my @feat = @{$f};
    my @rxn = split /_/, $rxn_co;
    $rxn[0] =~ s/^\s+//;
    $rxn[0] =~ s/\s+$//;
    $allrxns{$rxn[0]}=$rname;    

    #print "**$rxn[0]**\t$rname\n";
    if (@feat && !exists $universal{$rxn[0]} ){
        $modelrxnHashComp{$rxn[0]} = $rname;
        $modelrxnsOnly{$rxn[0]}=$rname;
    }
    elsif(!exists $universal{$rxn[0]} ) {
        
       $modelGapFill{$rxn[0]}=1; 
    }
    else{
       next;
    }
}

push (@hashArray, \%modelrxnsOnly);
push (@model_Ref, $model);
push (@mArr, $m_id);
push (@wArr, $w_id);



}
############################################################################
   
my $core_rxn_count = 22;
my %corerxns;
my %nonCoreRxn;
my %uniqueRxnsR;
my %modelGapFill;
foreach my $key (sort keys %allrxns) {

    #print "here is key   $key\n";
    my @hits = grep {$_->{$key}} @hashArray;

    if (@hits == @hashArray)
    {
        my$hitsA = @hits;
        my$hashA =@hashArray;

        #print OUTFILEW "$key\t$subrxnHash{$key}->[4]\t$subrxnHash{$key}->[7]\n";

        #print  "$key\t$subrxnHash{$key}->[4]\t$subrxnHash{$key}->[7]\t$hitsA\t$hashA\n";

        $corerxns{$key}=$key;
        $core_rxn_count++;
    }

    elsif(@hits < 2 && exists $modelrxnHashComp{$key} ) {

      #print  "unique rxn $key\t$subrxnHash{$key}->[4]\t$subrxnHash{$key}->[7]\n";
         $uniqueRxnsR{$key}=1;
         $nonCoreRxn{$key}=1;

    }

    elsif(@hits < 2 && exists $modelGapFill{$key} ) {

         #print  "unique gap filled rxn $key\t$subrxnHash{$key}->[4]\t$subrxnHash{$key}->[7]\n";
         $modelGapFill{$key}=1;
         #$nonCoreRxn{$key}=1;

    }
    else{
      $nonCoreRxn{$key}=1;

    }

}



print "core reaction count $core_rxn_count\n";

my %modelrxnHash;

my %role_check;
my %classifyCheck;

foreach my $m (@model_Ref){
my $uniquerxnCount =0;

my $modelOne = $m->[0]->{reactions};
my $mgenome = $m->[0]->{name};


for(my $i =0; $i< @{$modelOne}; $i++){

    my $rxn_co = $modelOne->[$i]->{id};
    my $rname = $modelOne->[$i]->{name};
    my $eq = $modelOne->[$i]->{definition};
    my $f = $modelOne->[$i]->{features};
    my @feat = @{$f};
    my @rxn = split /_/, $rxn_co;
    $rxn[0] =~ s/^\s+//;
    $rxn[0] =~ s/\s+$//;
    $modelrxnHash{$rxn[0]} = $rname;
    my @roles_arr;
            if (exists $uniqueRxnsR{$rxn[0]}) {
                
                $uniquerxnCount++;
                #print "$mgenome\t $rxn[0]\n"; 
            }


    foreach my $peg (@feat){

       if (exists $pegid_hash{$peg}){
        
         #if (!exists $role_check{$pegid_hash{$peg}}{$rxn[0]}){
         #if (!exists $role_check{$peg}{$rxn[0]}){
           my @roles = &SeedUtils::roles_of_function($pegid_hash{$peg});

           $role_check{$peg}{$rxn[0]}=1;  

            foreach my $r (@roles){
               foreach my $k1 (keys %classifyHash){  
                 foreach my $k2 (keys(%{$classifyHash{$k1}})){
                   if ( exists $classifyHash{$k1}{$k2}{$r}  && exists $pegid_hash_check{$peg}{$r} && exists $corerxns{$rxn[0]}) {
                        #my $roles_print = join("|",@roles);    #exists $pegid_hash_check{$peg}{$r}
                        print "core\t$peg\t$rxn[0]\t$eq\t$rname\t$k1\t$k2\t$r\n";
                        $classifyCheck{$k1}{$k2}{$r}=1;

                   }   
                   elsif(exists $classifyHash{$k1}{$k2}{$r} && exists $pegid_hash_check{$peg}{$r} &&  exists $uniqueRxnsR{$rxn[0]}) {
                        print "unique\t$peg\t$rxn[0]\t$eq\t$rname\t$k1\t$k2\t$r\n";                 #&& exists $classifyCheck{$k1}{$k2}{$r}
                        $classifyCheck{$k1}{$k2}{$r}=1;

                   }  
                   else{
                      next;
                   } 
                
                 }
               }
            }
         }      
    
      # }

    }



}