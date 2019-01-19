//GLOBALS
\c 20 140
/project root dir
.info.PROJ_ROOT:"/Users/username/q/projects/snpdive/tools/DataDive"
/database root directory
.info.DB_DIR:"/Users/username/q/projects/snpdive/demodb"
/html directory and .h.HOME location
.h.HOME:.info.HTML_DIR:.info.PROJ_ROOT,"/html"
.info.PORT_NUM:"50664"
/month 2-digit number to month name
.info.MONTH_MAP:("0"^-2$string 1+til 12)!string`Jan`Feb`Mar`Apr`May`Jun`Jul`Aug`Sept`Oct`Nov`Dec
/schema to hold info re connected clients
.info.clients:(flip(enlist`handle)!enlist`int$())!flip`connectionTime`ip!(`timestamp$();())
/if devmode, don't error trap
.info.DEV_MODE:0b
/last received remote query
.info.lastQuery:()
/number of records to return to the browser
.info.NUM_RECORDS:200
/datatables standard options
.info.DT_OPTS:`destroy`bSort`bFilter`bLengthChange!1000b
/chars allowed in search
.info.ALLOWED:.Q.A,.Q.n," .-_"
/map types for display
.info.TYPE_MAP:"jifehcspmdznuvt"!`Number`Number`Number`Number`Number`String`String`Time`Time`Time`Time`Time`Time`Time`Time
/all operation options
.info.OPS:`Number`String`Time!{(x;2_x;x)}{.h.htac[`option;(enlist`value)!enlist x;y]}./:flip((enlist">";enlist"<";enlist"=";"x*";"*x";"*x*");("Greater Than";"Less Than";"Equals";"Begins With";"Ends With";"Contains"))
//UTILS
.util.fmtNum:{reverse csv sv 3 cut reverse string[x]}
.util.logm:{-1("@"sv string(x;y))," - ",string[.z.T]," - ",z;}[.z.u;.z.h;]
.util.za2ip:{"."sv string"h"$0x00 vs .z.a}
.util.prettyMonth:{"-"sv'reverse each flip @[flip "."vs'string x;1;.info.MONTH_MAP]}
.util.stringify:{?[x;();0b;(!). flip{(y;$[x in "Cc";y;(string;y)])}./:flip exec (t;c) from (meta x)]}
.util.dataTable:{r:`data`columns!(flip value flip y;flip(enlist `title)!enlist cols y); r,.info.DT_OPTS}
.util.tablefmt:{((1b;0b;0)!("Partitioned";"Splayed";"Binary")).Q.qp value x}
lf:{system"l ",.info.PROJ_ROOT,"/q/",string[.z.f];}
//MAIN CODE
getTableInfo:{
 tname:tables[];
 tabs:value each tname;
 partitions:{$[x in .Q.pt;.util.prettyMonth month;0N]}each tname;
 counts:.util.fmtNum each count each tabs;
 kols:cols each tname;
 types: .info.OPS .info.TYPE_MAP lower(0!'meta each value each tname)@\:`t;
 numcols:count each kols;
 tablefmt:.util.tablefmt each tname;
 :(`tableInfo;`tableName`partitions`count`numCols`columns`types`format!(tname;partitions;counts;numcols;kols;types;tablefmt));
 } 

getTable:{[numr;tname;part]
 part:$[all null part;part;"M"$"."sv @[reverse "-"vs part;1;.info.MONTH_MAP?]];
 tab:$[(t:`$tname)in .Q.pt;select from t where month=part;select from t];
 if[numr<cn:count tab;tab:numr#tab;];
 tab:`Row_Num xcols update Row_Num:i from tab;
 :(`tabledata;`data`numRows`totalRows!(.util.dataTable[t;tab];.util.fmtNum count tab;.util.fmtNum cn));
 }[.info.NUM_RECORDS;;]

searchTable:{[tab;kol;op;val]
 if[all null op;'"No filters passed.";];
 func:$[b:"*"in op;like;value op];
 data:tab[`$kol];
 val:$[b;ssr[op;"x";val];$[-20h~t:type first data;-11h$val;t$val]];
 :$[b or any -10 10h in dt:type first data;
    [d:$[any -11 -20h in dt;upper data;data inter\:.info.ALLOWED]; where d like\:upper[val]];
    where(value op).(data;val)];
 }

filterTable:{[numr;tname;part;const]
 part:$[all null part;part;"M"$"."sv @[reverse "-"vs part;1;.info.MONTH_MAP?]];
 tab:$[(t:`$tname)in .Q.pt;select from t where month=part;select from t];
 idxs:searchTable[tab;]./:flip value flip const;
 tab:tab inter/[idxs];
 if[numr<cn:count tab;tab:numr#tab;];
 tab:`Row_Num xcols update Row_Num:i from tab;
 :(`tabledata;`data`numRows`totalRows!(.util.dataTable[t;tab];.util.fmtNum count tab;.util.fmtNum cn));
 }[.info.NUM_RECORDS;;;]

//HANDLERS
.z.wo:{
 .util.logm"Websocket connection established";
 `.info.clients upsert 1!flip select handle:.z.w,connectionTime:.z.P,ip:enlist .util.za2ip .z.a from (0#`)!();
 }
.z.wc:{
 .util.logm"Websocket connection closed";
 .info.clients _:.z.w;
 }
.z.ws:{
 .util.logm"Message recieved from client at handle ",sh:string[.z.w];
 st:.z.T;
 op:.j.k -9!x;
 func:`$op`qFunc;
 apply:(.;@)op[`qParams]~();
 params:op[`qParams];
 err:{(`Error;"Error in function: ",string[x],". ERROR==>'",y)}[func;];
 .info.lastQuery:(apply;func;params);
 res:$[.info.DEV_MODE;apply[func;params];.[apply;(func;params);err]];
 tm:string[.z.T-st];
 neg[.z.w][-8!.j.j res,enlist tm];
 .util.logm"Response sent back through handle ",sh,". Time taken: ",tm;
 }
//INITIALISATION
init:{
 if[.info.DEV_MODE:`dev in key .Q.opt .z.x;system["e 1"];.util.logm"Process is in DEVMODE";];
 @[system;"l ",.info.DB_DIR;{.util.logm"Failed to load database: ",.info.DB_DIR;.util.logm"Error: '",x;}];
 @[system;"p ",.info.PORT_NUM;{.util.logm"Failed to open port: ",.info.PORT_NUM;.util.logm"Error: '",x;}];
 .util.logm"Database loaded and port opened successfully";
 .util.logm"Initialisation complete. Access: http://",string[.z.h],":",.info.PORT_NUM,"/index.html";
 }

init[]
