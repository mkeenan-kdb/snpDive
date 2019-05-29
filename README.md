 ### Notes
 *This readme is... under construction...
 *Tested on linux and macOS only

 # SNPdive

Annotate 23andmedata with ensembl-vep, present resulting data in a queryable browser UI

![DataDive](https://i.imgur.com/QmTyGxn.png)

  ## Installing
 * Install kdb+; download [here](https://kx.com/connect-with-us/download/), instructions [here](https://code.kx.com/v2/learn/install/)
 * `$ git clone https://github.com/mkeenan-kdb/snpDive.git ~/snpDive`
 * `$ cd snpDive/tools`
 * `$ git clone https://github.com/Ensembl/ensembl-vep.git`
 * `$ git clone https://github.com/arrogantrobot/23andme2vcf.git`
 * `$ cd ensembl-vep`
 * follow [instructions](https://useast.ensembl.org/info/docs/tools/vep/script/vep_download.html) to install vep
 * After ensembl-vep is installed, edit `snppl.q` so that the `PROJ_ROOT` variable points to the location of snpDive e.g. 
 ```
 /##snppl.q##
 PROJ_ROOT:"/Users/username/snpDive"
 DATA_DIR:PROJ_ROOT,"/data"
 DB_ROOT:PROJ_ROOT,"/snpdb"
 VEP_DIR:PROJ_ROOT,"/tools/ensembl-vep"
 VCF_DIR:PROJ_ROOT,"/tools/23andme2vcf"
 GENOME_TXT:DATA_DIR,"/genome/myTXTgenome.txt"
 GENOME_VCF:DATA_DIR,"/output/myVCFgenome.vcf"
 GENOME_VEP:DATA_DIR,"/output/myVEPgenome.vep.vcf"
 ```
 * Do the same in ~/snpDive/tools/DataDive/datadive.q
 ```
 /##datadive.q##
 /project root dir
 .info.PROJ_ROOT:"/Users/username/snpDive/tools/DataDive"
 /database root directory
 .info.DB_DIR:"/Users/username/snpDive/snpdb"
 ```
 
 ## Running pipeline
 The `snppl.q` script is what hooks into vep. If you wanted to run vep on your 23andme data, you would start kdb+q;
 `$QHOME/m32/q ~/snpDive/snppl.q`
 After the `snppl.q` script is loaded, we can run the pipline like;
 ```q)runpl[`txt2vcf`vep`vep2kdb`savevep]```
 The above command runs each of the items left to right. In this case;
  * `txt2vcf` converts the raw 23andme text file to a vcf file using [this](https://github.com/arrogantrobot/23andme2vcf) (stored in snpDive/tools/23andme2vcf)
  * `vep` takes the newly created vcf file and runs ensembl-vep on it
  * `vep2kdb` takes the annotated vcf file and coverts it into a kdb+ table
  * `savevep` takes the newly created kdb+ table (called `vepdata`) and stores it to a kdb+ database
  
  After running the pipeline, you can exit the snppl.q session and start a fresh one with datadive.q loaded
  ```
  start snppl.q from command line   :  $ q snppl.q
  inside q, run your pipeline       :  q)runpl[`txt2vcf`vep`vep2kdb`savevep]
  after completion, exit q          :  q)\\
  now db can be accessed by datadive:  $ cd tools/DataDive
  start datadive.q                  :  $ q datadive.q
  In your browser go to http://localhost:50664/index.html to view your data 
  ```
QUICK START;
* clone this repo
* install kdb (free download [here](https://kx.com/download/))
* inside your local repo cd to tools/DataDive/q and open the datadive.q file; edit the params;
`info.PROJ_ROOT` and `.info.DB_DIR`; save the changes
* use kdb+ to run the datadive.q script - this will load the demodb, you can access the UI with http://localhost:50664/index.html in your browser

### Paste from terminal
```
IllyseMacBook:projects Arielle$ echo $QHOME;alias q
/Users/Arielle/q
alias q='rlwrap /Users/Arielle/q/m32/q'
IllyseMacBook:projects Arielle$ cd snpdive/
IllyseMacBook:snpdive Arielle$ q snppl.q 
KDB+ 3.6 2018.05.17 Copyright (C) 1993-2018 Kx Systems
m32/ 4()core 8192MB Arielle illysemacbook.local 10.0.0.34 NONEXPIRE  

Welcome to kdb+ 32bit edition
For support please see http://groups.google.com/d/forum/personal-kdbplus
Tutorials can be found at http://code.kx.com/wiki/Tutorials
To exit, type \\
To remove this startup msg, edit q.q


					http://localhost:50667
q)runpl
k){x'y}[{
 st:.z.T;
 0N!(`start;x;st);
 /get required params
 params:PARAMS[x];
 /choose k func to apply based on param count
 kfn:(.;@)2>count params;
 /execute
 kfn[x;params];
 0N!(`f..]
q)key PARAMS
`txt2vcf`vep`vep2kdb`vcf2kdb`savevep`savevcf
q)PARAMS
txt2vcf| ("perl 23andme2vcf.pl /Users/username/q/projects/snpdive/data/genome/demo23andmegenome.txt /Users/username/q/projects/snpdive/data/output/demo23andmegenome.vcf 5";"/Use..
vep    | ("./vep --sift b --polyphen b --protein --uniprot --nearest symbol --numbers --domains --gene_phenotype --af --af_1kg --max_af --pubmed --variant_class --biotype --regu..
vep2kdb| ,"/Users/username/q/projects/snpdive/data/output/demo23andmegenome.vep.vcf"
vcf2kdb| ,"/Users/username/q/projects/snpdive/data/output/demo23andmegenome.vcf"
savevep| ("/Users/username/q/projects/snpdive/demodb";`vepdata)
savevcf| ("/Users/username/q/projects/snpdive/demodb";`vcfdata)
q)\\
IllyseMacBook:snpdive Arielle$ cd tools/DataDive/
IllyseMacBook:DataDive Arielle$ cd q
IllyseMacBook:q Arielle$ q datadive.q 
KDB+ 3.6 2018.05.17 Copyright (C) 1993-2018 Kx Systems
m32/ 4()core 8192MB Arielle illysemacbook.local 10.0.0.34 NONEXPIRE  

Welcome to kdb+ 32bit edition
For support please see http://groups.google.com/d/forum/personal-kdbplus
Tutorials can be found at http://code.kx.com/wiki/Tutorials
To exit, type \\
To remove this startup msg, edit q.q
Arielle@illysemacbook.local - 12:37:21.202 - Database loaded and port opened successfully
Arielle@illysemacbook.local - 12:37:21.202 - Initialisation complete. Access: http://illysemacbook.local:50664/index.html
q)\pwd
"/Users/Arielle/q/projects/snpdive/demodb"
q)tables[]
,`vepdata
q)vepdata
rsid        gene       chr   chrpos    zyg conseq           alleF  maxAlleF siftPred                   siftScore phenPred          phenSc..
-----------------------------------------------------------------------------------------------------------------------------------------..
rs273259    IFI44L     chr1  79093818  HET missense_variant 0.4449 0.7554   tolerated                  0.35      benign            0.003 ..
rs1048201   NUDT6      chr4  123814308 HET missense_variant 0.2288 0.4707   deleterious                0         probably_damaging 0.999 ..
rs12952242  AC000003.2 chr17 10049293  HOM missense_variant 0.0968 0.5                                           possibly_damaging 0.856 ..
rs11722476  SMARCAD1   chr4  95170839  HET missense_variant 0.4615 0.7087   tolerated                  0.49      benign            0     ..
rs1133657   KIAA1430   chr4  186111639 HET missense_variant 0.4305 0.5823   deleterious_low_confidence 0.02      benign            0.023 ..
rs150003957 NOX5       chr15 69325606  HET missense_variant 0.0168 0.0286   deleterious                0.01      possibly_damaging 0.472 ..
rs2617170   KLRC4      chr12 10560957  HET missense_variant 0.5567 0.6805   deleterious                0.05      benign            0.062 ..
rs1510765   PARD3B     chr2  205912403 HOM missense_variant 0.5447 0.6925   tolerated                  1         benign            0     ..
rs12963653  TAF4B      chr18 23872235  HET missense_variant 0.1216 0.3291   tolerated                  0.21      benign            0     ..
rs2229207   IFNAR2     chr21 34614250  HET missense_variant 0.1186 0.1747   tolerated                  0.44      benign            0     ..
rs62641705  UGT2A3     chr4  69811110  HET missense_variant 0.007  0.03749  deleterious                0         probably_damaging 0.977 ..
rs2071307   ELN        chr7  73470714  HOM missense_variant 0.2204 0.4604   deleterious_low_confidence 0.02      benign            0.001 ..
rs628031    SLC22A1    chr6  160560845 HET missense_variant        0.7986   tolerated                  1         benign            0     ..
rs1541185   RNF186     chr1  20141528  HET missense_variant 0.2885 0.4618   tolerated                  0.18      benign            0.024 ..
rs61750816  PTPN13     chr4  87724970  HET missense_variant 0.0102 0.0368   tolerated                  0.46      benign            0.005 ..
..
q)\\
IllyseMacBook:q Arielle$ 
```
