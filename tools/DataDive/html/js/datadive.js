//==========================Globals==============================//
var tableInfo
var chosenInfo = {tableName:"",partition:"",columns:[]}
var resetInfo = chosenInfo
var dataTable = null
var filterTemplate
//==========================Utils================================//
function makeOpts(optionArray){
	var res = [];
	for(opt in optionArray){ 
		res.push("<option value="+opt+">"+optionArray[opt]+"</option>");
	}
	return res;
}
//=========================Initialisation========================//
$(document).ready(function(){
	//we aren't waiting for a server resp
	$(".spinner").hide();
	filterTemplate = $("#filtering-0").html();
	$("#filterCont").hide();
	//connect to the server
	connect();
	//attatch listener to the table selection
	var tabSelect = document.getElementById("tables");
	tabSelect.onchange = function(e){
		buildTableInfo(e);
	};
});
//=========================Logic================================//
function buildTableInfo(e){
	//when a new table is selected, reset 'chosenInfo'
	chosenInfo = resetInfo;
	var tableNum = e.target.value;
	//populate chosen info
	chosenInfo.tableName = tableInfo.tableName[tableNum];
	chosenInfo.columns = tableInfo.columns[tableNum];
	chosenInfo.partition = tableInfo.partitions[tableNum];
	var deferSend = populatePartitions();
	var nameHTML = "<li>Table Name: <b>"+chosenInfo.tableName+"</b></li>";
	var countHTML = "<li>Record Count: <b>"+tableInfo.count[tableNum]+"</b></li>";
	var colsHTML = "<li>Num Columns: <b>"+tableInfo.numCols[tableNum]+"</b></li>";
	var tabFmtHTML = "<li>Table Format: <b>"+tableInfo.format[tableNum]+"</b></li>";
	$("#selectedTab").html(nameHTML+countHTML+colsHTML+tabFmtHTML);
	if(!deferSend){getTable();};
}

function getTable(){
	sendCmd("getTable",[chosenInfo.tableName,chosenInfo.partition]);
}

function choosePart(e){
	window.lala = e;
  	chosenInfo.partition = $($($("#partitions > option"))[1+parseInt(e.target.value)]).text();
	getTable();
}

function populatePartitions(){
	$("#filters > li").eq(1).remove();
	var partArray = chosenInfo.partition;
	if(null == partArray){
		console.log("No partitions");
		return false;
	}
	var opts = makeOpts(partArray);
	var partSelect = "<li><select id='partitions' onchange='choosePart(event);' class='form-control selections'><option value='' selected disabled>Partition</option></select></li>";
	$("#filters").append(partSelect);
	$("#partitions").append(opts);
	return true;
}

function fillTableInfo(data){
	//adding table names to table selection
	$("#tables").append(makeOpts(data.tableName));
}

function renderTable(data, timeTaken){
        console.log("Rendering table");
	$(".chart-cont > p").hide();
	$("#filterCont").show();
	$(".column-selection").append(makeOpts(chosenInfo.columns));
	$("#tinfo").text("Showing a sample of "+data.numRows+" records from the '"+chosenInfo.tableName+"' \
		              table (total of "+data.totalRows+" records returned from your selections). Time taken: "+timeTaken);
	$("#tableContainer").html("");
	$("#tableContainer").append("<table id='tableView' class='display compact cell-border'></table>");
	dataTable = $('#tableView').DataTable(data.data);
}

function addFiltering(){
	var filterid = "filtering-"+$("#additional-filters > ul").length;
	var newFilter = "<ul class='list-inline' id='"+filterid+"'>"+filterTemplate+"</ul>";
	$("#additional-filters").append(newFilter);
	$(".column-selection").append(makeOpts(chosenInfo.columns));
}

function removeFiltering(){
	$("#additional-filters > ul").last().remove();
}

function submitQuery(){
	var numFilters = $("#additional-filters > ul").length;
	var constraints = [];
	var query = [chosenInfo.tableName,chosenInfo.partition];
	for(i=0;i<numFilters;i++){
		var inp = {};
		var thisFilter = $("#filtering-"+i).children();
		inp["column"] = thisFilter[0].firstElementChild.selectedOptions[0].innerHTML;
		inp["op"] = thisFilter[1].firstElementChild.selectedOptions[0].value;
		inp["val"] = thisFilter[2].firstElementChild.value;
		console.log(inp);
		constraints.push(inp);
	}
	sendCmd("filterTable",[chosenInfo.tableName,chosenInfo.partition,constraints]);
}
//===============Websocket connection and handlers===============//
function connect(){
	ws = new WebSocket("ws://localhost:50664");
	ws.binaryType="arraybuffer";
	
	sendCmd = function(func, params){
		$(".spinner").show();
		var msg = {qFunc:func, qParams:params};
		ws.send(serialize(JSON.stringify(msg)));
	}

	ws.onopen = function(){
		sendCmd("getTableInfo",[]);
	}

	ws.onmessage = function(msg){
		$(".spinner").hide();
		var raw = JSON.parse(deserialize(msg.data));
		console.log(raw);
		var responseClass = raw[0];
		var data = raw[1];
		switch(responseClass){
			case "tableInfo":
				tableInfo = data;
				fillTableInfo(data);
				break;
			case "tabledata":
				renderTable(data,raw[2]);
				break;
			case "Error":
				alert(data);
				break;
			default:
				alert("Unexplained exception in websocket");
		}
	}
}
