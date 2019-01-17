\c 30 180
\p 50667
-1"\n\n\t\t\t\t\thttp://localhost:50667";
//######################################GLOBALS#####################################//
PROJ_ROOT:"/Users/Arielle/q/projects/snppl"
DATA_DIR:PROJ_ROOT,"/data"
DB_ROOT:PROJ_ROOT,"/snpdb"
VEP_DIR:PROJ_ROOT,"/tools/vep/ensembl-vep"
VCF_DIR:PROJ_ROOT,"/tools/23andme2vcf"
GENOME_TXT:DATA_DIR,"/genome/23andmegenome.txt"
GENOME_VCF:DATA_DIR,"/output/23andmegenome.vcf"
GENOME_VEP:DATA_DIR,"/output/23andmegenome.vep.vcf"
VEP_OPTS:"--sift b --polyphen b --protein --uniprot --nearest symbol --numbers --domains --gene_phenotype --af --af_1kg --max_af --pubmed --variant_class --biotype --regulatory --no_stats --humdiv --force_overwrite --individual all --fork ",string .z.c
CHIP:enlist"5"
PARAMS:(!). flip 2 cut(
  `txt2vcf;     (" "sv("perl";"23andme2vcf.pl";GENOME_TXT;GENOME_VCF;CHIP);VCF_DIR);
  `vep;         (" "sv("./vep";VEP_OPTS;"-i";GENOME_VCF;"-o";GENOME_VEP;"-offline");VEP_DIR);
  `vep2kdb;     enlist GENOME_VEP;
  `vcf2kdb;     enlist GENOME_VCF;
  `savevep;     (DB_ROOT;`vepdata);
  `savevcf;     (DB_ROOT;`vcfdata))
//#####################################UTILS#######################################//
sumry:{{100*x%sum[x]`per}desc?[vepdata;();enlist[x]!enlist x;enlist[`per]!enlist(count;`i)]}
/Time a function - timefn[`myfuncWithoutParams]
timefn:{[fn] st:.z.T;r:fn[];0N!(.z.T-st);r}
/System Command
scmd:{-1@x;@[system;x;{show`cmd`err!(x;y);}[x;]]}
/Current Working Directory
cwd:{first scmd"pwd"}
/Change Directory
cd:{scmd"cd ",x;}
/Save data(x) splayed to location (y) with name(z) -- return table path
s2d:{.Q.dd[y;(z;`)]set .Q.en[y;x]}
/RunToTool - ?? - Change dir to tool dir, run command, return to starting dir - JUST USE ENVVARS LATER??
rtt:{[cmd;dir]
 pwd:cwd[];
 cd dir;
 scmd cmd;
 cd pwd;
 }
//####################################MODULES######################################//
/Remove global variable from root namespace if it exists, run garbage collection
rmglobal:{if[not x in key`.;'"No such global";]; delete x from`.; .Q.gc[];}
/Save vepdata to disk, show table path
savevep:{show s2d[select from y;hsym`$x;y];}
/Save vcf data to disk, show table path
savevcf:{show s2d[select from y;hsym`$x;y];}
/Hook to convert 23andme txt to a vcf file using perl script
txt2vcf:{rtt[x;y];}
/Hook to annotate vcf file(dependecy on `txt2vcf)using emsembl-vep command line tool
vep:{rtt[x;y];}
/Read the vcf file generated from `txt2vcf and store globally as a q table `vcfdata
vcf2kdb:{
 data:read0 hsym`$first x;
 dstart:first where not"#"~/:data[;0];
 data:(dstart-1)_data;
 data:`ID xcols .Q.id("SJSSS*****";enlist"\t")0:data;
 `vcfdata set data;
 }
/Read the annotated vcf file generated from `vep and store globally as a q table `vepdata
vep2kdb:{
 data:read0 hsym`$first x;
 /define index where the data values start
 dstart:first where not"#"~/:data[;0];
 /extract vep header info (beginning with #)
 head:dstart#data;
 /extract the data (first record not  beginning with #)
 data:dstart _data;
 /extract the default column names
 defkols:`$"\t"vs 1_last head;
 //can simplify but below functionality could be used more later over more splits
 extrakols:head{(1+x)+til(y-x)-1}. where max head like\:/:("## Extra column keys*";"#Uploaded_variation*");
 extrakols:`$trim{(first where":"=x)#x}each 3_'extrakols;
 /convert data to kdb table
 data:flip defkols!("S****SSJJJSSS*";"\t")0:data;
 /parse the extra columns
 extradata:flip extrakols!flip{d:(!).("S*";"=")0:";"vs y; d@/:x}[extrakols;]each exec Extra from data;
 /convert any AlleleFrequency(AF) cols to float
 tofloat:extrakols where extrakols like\:"*AF";
 extradata:![extradata;();0b;tofloat!($;"F"),/:tofloat];
 /split out the SIFT and PHEN scores
 extradata:(delete SIFT from extradata),'flip`SIFTpred`SIFTscore!exec("SF";"(")0:-1_'SIFT from extradata;
 extradata:(delete PolyPhen from extradata),'flip`PHENpred`PHENscore!exec("SF";"(")0:-1_'PolyPhen from extradata;
 extradata:update `$IMPACT,`$CLIN_SIG,`$NEAREST,`$ZYG from extradata;
 data:`Uploaded_variation`ZYG`NEAREST`Consequence`AF`SIFTpred`PHENpred`SIFTscore`PHENscore`CLIN_SIG xcols delete Extra from data,'extradata;
 /parse the Location values to generate chromosome and position
 data:update chr:`$Location[;0],chrpos:"J"$Location[;1]from update Location:":"vs'Location from data;
 `vepdata set `phenScore xdesc`alleF xasc distinct select rsid:Uploaded_variation,gene:NEAREST,chr,chrpos,zyg:ZYG,conseq:Consequence,alleF:AF,maxAlleF:MAX_AF,siftPred:SIFTpred,siftScore:SIFTscore,phenPred:PHENpred,phenScore:PHENscore,clinvar:CLIN_SIG,alle:Allele,cdnaPos:cDNA_position,cdsPos:CDS_position,protPos:Protein_position,aminoAcid:Amino_acids,codon:Codons,imp:IMPACT,dist:DISTANCE,orien:STRAND,biotype:BIOTYPE,pheno:PHENO,pubm:PUBMED,motScore:MOTIF_SCORE_CHANGE,motName:MOTIF_NAME,motPos:MOTIF_POS,highInfPos:HIGH_INF_POS from data;
 }
//####################################HOOKS#######################################//
runpl:{
 st:.z.T;
 0N!(`start;x;st);
 /get required params
 params:PARAMS[x];
 /choose k func to apply based on param count
 kfn:(.;@)2>count params;
 /execute
 kfn[x;params];
 0N!(`finish;x;.z.T-st);
 }each /<----runpl is ran on each module in the pipeline successively

//KICKSTART
runpl[`txt2vcf`vep`vep2kdb`savevep`vcf2kdb`savevcf]
/runpl[`vep2kdb]
