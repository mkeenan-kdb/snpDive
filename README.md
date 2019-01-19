 ### Notes
 *This readme is... under construction...
 *Tested on linux and macOS only

 # SNPdive

Annotate 23andmedata with ensembl-vep, present resulting data in a queryable browser UI

## Getting Started
 * `$ git clone https://github.com/mkeenan-kdb/snpDive.git ~/snpDive`
 * `$ cd snpDive/tools`
 * `$ git clone https://github.com/Ensembl/ensembl-vep.git`
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
 
QUICK START;
* clone this repo
* install kdb (free download [here](https://kx.com/download/))
* inside your local repo cd to tools/DataDive/q and open the datadive.q file; edit the params;
`info.PROJ_ROOT` and `.info.DB_DIR`; save the changes
* use kdb+ to run the datadive.q script - this will load the demodb, you can access the UI with http://localhost:50664/index.html in your browser

