var app = angular.module('app', ['infinite-scroll']);

app.controller('ItemController', ['$scope', '$http', '$sce', function ($scope, $http, $sce) {
	var c = this;

	c.loading = false;

	this.tableAcessorysRecordList = [];
	this.tableProductsRecordList = [];
	this.tableGroupsRecordList = [];
	this.tableKitsRecordList = [];
	this.tableAcessorysRecordListError = [];
	this.tableGroupsRecordListError = [];
	this.tableKitsRecordListError = [];

	this.showAcessorySuccess = true;
	this.showGroupSuccess = false;
	this.showKitsSuccess = false;
	this.showKitsError = false;
	this.showAcessoryError = false;
	this.showGroupError = false;

	this.productCodeSet = [];

	this.columnAcessoryList = [
		{title: '#', field: 'internalId'},
		{title: 'Codigo Produto', field: 'productCode'},
		{title: 'Quantidade Sugerida', field: 'quantity'},
		{title: 'Padrão', field: 'standards'},
		{title: 'Nome do Grupo', field: 'groupName'},
		{title: 'Nome do Kit', field: 'structureName'}
	];
	this.columnAcessoryListError = [
		...this.columnAcessoryList,
		{title: 'Erro na linha', field: 'errorMessage'}
	];

	this.columnGroupList = [
		{title: '#', field: 'internalId'},
		{title: 'Nome', field: 'names'},
		{title: 'Tipo', field: 'types'},
		{title: 'Ordem Exibicao', field: 'orderShow'},
		{title: 'Numero minimo', field: 'minimumQuantity'},
		{title: 'Ação do Grupo', field: 'actions'},
		{title: 'Nome Kit', field: 'kitName'}
	];
	this.columnGroupListError = [
		...this.columnGroupList,
		{title: 'Erro na linha', field: 'errorMessage'}
	];

	this.columnKitList = [
		{title: '#', field: 'internalId'},
		{title: 'Nome Kit', field: 'names'}
	];
	this.columnKitListError = [
		...this.columnKitList,
		{title: 'Erro na linha', field: 'errorMessage'}
	];

	this.initPage = function() {
		c.loading = false;
		$scope.$apply();
	}

	this.newFile = function() {
		c.tableAcessorysRecordList = [];
		c.tableProductsRecordList = [];
		c.tableGroupsRecordList = [];
		c.tableKitsRecordList = [];
		c.tableAcessorysRecordListError = [];
		c.tableGroupsRecordListError = [];
		c.tableKitsRecordListError = [];
		document.getElementById('error-01').innerHTML = 'Selecione o Arquivo';
		document.getElementById('file-upload-input-01').files = (new DataTransfer()).files;
	}

	this.removeRecord = function(record) {
		c.loading = true;

		if (c.tableAcessorysRecordList.length <= 1) {
			c.tableAcessorysRecordList = [];
			c.tableProductsRecordList = [];
			c.tableGroupsRecordList = [];
			c.tableKitsRecordList = [];
			c.tableAcessorysRecordListError = [];
			c.tableGroupsRecordListError = [];
			c.tableKitsRecordListError = [];
			document.getElementById('error-01').innerHTML = 'Selecione o Arquivo';
			document.getElementById('file-upload-input-01').files = (new DataTransfer()).files;
		} else {
			var count = 1;
			c.tableAcessorysRecordList = c.tableAcessorysRecordList.filter(item => {
				if (item.internalId == record.internalId) return;

				item.internalId = count;
				count++;

				return item;
			});
			count = 1;
			c.tableGroupsRecordList = c.tableGroupsRecordList.filter(item => {
				if (item.internalId == record.internalId) return;

				item.internalId = count;
				count++;

				return item;
			});
			count = 1;
			c.tableKitsRecordList = c.tableKitsRecordList.filter(item => {
				if (item.internalId == record.internalId) return;

				item.internalId = count;
				count++;

				return item;
			});
		}

		c.loading = false;
	}

	this.changeInputFile = function() {
		c.loading = true;

		var fileXCL = document.getElementById('file-upload-input-01').files[0];
		document.getElementById('error-01').innerHTML = fileXCL.name != undefined ? fileXCL.name : 'Selecione o Arquivo';

		if (c.tableAcessorysRecordList && c.tableAcessorysRecordList.length > 0)
			c.insertAllRecords({acessoryDatas : c.tableAcessorysRecordList,
								groupDatas : c.tableGroupsRecordList,
								kitDatas : c.tableKitsRecordList, 
								productDatas : c.tableProductsRecordList});
		else if (fileXCL && typeof(FileReader) != "undefined" && fileXCL.name.split('.').pop().toLowerCase() == 'xlsx') {
			var reader = new FileReader();
			//For Browsers other than IE.
			if (reader.readAsBinaryString) {
				reader.onload = function(e) {
					var data = e.target.result;
					var workbook = XLSX.read(data, { type: "binary" });

					//Read all rows from First Sheet into an JSON array.
					var acessoryRows = XLSX.utils.sheet_to_row_object_array( workbook.Sheets[workbook.SheetNames[0]] );
					var groupsRows = XLSX.utils.sheet_to_row_object_array( workbook.Sheets[workbook.SheetNames[1]] );
					var kitsRows = XLSX.utils.sheet_to_row_object_array( workbook.Sheets[workbook.SheetNames[2]] );
					var productsRows = XLSX.utils.sheet_to_row_object_array( workbook.Sheets[workbook.SheetNames[3]] );
					c.getRecordExternalId(acessoryRows, groupsRows, kitsRows, productsRows);
					c.loading = false;

					$scope.$apply();
				};

				reader.readAsBinaryString(fileXCL);
			}
		}
		else {
			dispatchSwalError('Favor importar um arquivo válido!');
			c.tableRecordList = [];
			c.tableRecordListError = [];
			c.loading = false;
		}
	};

	$scope.checkRecords = function() {
		c.changeInputFile();
	}

	this.checkInvalidRowAcessory = function(item){
		if(!item.productCode || !item.quantity || !item.standards || !item.groupName || !item.structureName){
			item.errorMessage = 'Preencha todos os campos obrigatorios: '+item.internalKey;
			item.isInvalid = true;
		}
		return item;
	}
	this.checkInvalidRowGroup = function(item){
		if(!item.names || !item.types || !item.orderShow || !item.minimumQuantity || !item.actions || !item.kitName ){
			item.errorMessage = 'Preencha todos os campos obrigatorios: '+item.internalKey;
			item.isInvalid = true;
		}
		return item;
	}
	this.checkInvalidRowKit = function(item){
		if(!item.names){
			item.errorMessage = 'Preencha o nome do Kit de Acessorios: '+item.internalKey;
			item.isInvalid = true;
		}
		return item;
	}

	var fillRecordList = function(excelRows, filterInvalid) {
		if(filterInvalid)
			return excelRows.filter( item => !item.isInvalid);
		else
			return excelRows.filter( item => item.isInvalid);
	}
	
	this.getRecordList = function(acessoryRows, groupsRows, kitsRows, productsRows) {
		var recordList = {acessoryDatas : [], groupDatas : [], kitDatas : [], productDatas: []};
		var count = 0;
		productsRows.forEach(
			function(item) {
				var newObjItem = {
						productCode : item['Codigo Produto'],
						kitName : item['Codigo Kit'],
						internalId : count,
						internalKey : item['Codigo Produto']
					}
				count++;
					
				recordList.productDatas.push(newObjItem);
			},
			{ recordList, count }
		);
		count = 0;
		acessoryRows.forEach(
			function(item) {
				var newObjItem = {
						productCode : item['Codigo Produto'],
						quantity : item['Quantidade Sugerida'],
						standards : item['Padrao'],
						groupName : item['Nome do Grupo'],
						structureName : item['Nome do Kit'],
						internalId : count,
						internalKey : item['Nome do Kit']+' - '+item['Nome do Grupo']+' - '+item['Codigo Produto']
					}
				count++;
					
				recordList.acessoryDatas.push(c.checkInvalidRowAcessory(newObjItem));
			},
			{ recordList, count }
		);
		count = 0;
		groupsRows.forEach(
			function(item) {
				var newObjItem = {
						names : item['Nome'],
						types : item['Tipo'],
						orderShow : item['Ordem Exibicao'],
						minimumQuantity : item['Numero minimo'],
						actions : item['Ação do Grupo'],
						kitName : item['Nome Kit'],
						internalId : count,
						internalKey : item['Nome Kit']+' - '+item['Nome']
					}
				count++;
					
				recordList.groupDatas.push(c.checkInvalidRowGroup(newObjItem));
			},
			{ recordList, count }
		);
		count = 0;
		kitsRows.forEach(
			function(item) {
				var newObjItem = {
						names : item['Nome'],
						internalId : count,
						internalKey : item['Nome']
					}
				count++;
					
				recordList.kitDatas.push(c.checkInvalidRowKit(newObjItem));
			},
			{ recordList, count }
		);

		return recordList;
	}

	var insertRecordList = function(recordList) {
		var allLists = [];
		if (recordList.length > 1000) {
			allLists = result = new Array(
				Math.ceil(recordList.length / 1000)
			)
			.fill()
			.map((_) => recordList.splice(0, 1000));
		}
		else allLists.push(recordList);

		c.reCallRemote(allLists, allLists.length - 1, 0);
	}

	var dispatchSwalError = function(errorMessage) {
		Swal.fire({
			title: "Erro!",
			text: errorMessage,
			type: "error",
			confirmButtonColor: "#3085d6",
			confirmButtonText: "Ok!"
		}).then((result) => {});
	}

	this.insertAllRecords = function (allData) {
		Utils.createRecords(JSON.stringify(allData)).then((result) => {
			console.log(result);
			c.loading = false;

				$scope.$apply();
				toastr.success("Registros inseridos/atualizados com sucesso!");
		})
		.catch(error => {
			console.log('error =>', error);

			c.loading = false;
			$scope.$apply();

			var errorMessage = '';
			if (String(error).includes('DUPLICATE_VALUE') && String(error).includes('ExternalIdIndex__c'))
				errorMessage = 'Existem itens duplicados, por favor verifique os registros inseridos!';
			else
				errorMessage = error + '\nContate um administrador!';

			dispatchSwalError(errorMessage);
		})
	}
	this.reCallRemote = function (objectsList, endIndex, currentIndex) {
		Utils.createRecords(JSON.stringify(objectsList[currentIndex])).then((result) => {
			console.log(result);
			c.loading = false;

			if (currentIndex == endIndex){
				$scope.$apply();
				toastr.success("Registros inseridos/atualizados com sucesso!");
			}
			else {
				c.loading = true;
				currentIndex++;
				c.reCallRemote(objectsList, endIndex, currentIndex);
			}
		})
		.catch(error => {
			console.log('error =>', error);

			c.loading = false;
			$scope.$apply();

			var errorMessage = '';
			if (String(error).includes('DUPLICATE_VALUE') && String(error).includes('ExternalIdIndex__c'))
				errorMessage = 'Existem itens duplicados, por favor verifique os registros inseridos!';
			else
				errorMessage = error + '\nContate um administrador!';

			dispatchSwalError(errorMessage);
		})
	};

	this.getRecordExternalId = function (acessoryRows, groupsRows, kitsRows, productsRows) {
		var getRecordList = c.getRecordList(acessoryRows, groupsRows, kitsRows, productsRows);
		Utils.getRecords(getRecordList).then((result) => {
			console.log(result);			
			c.productCodeSet = result.productList;

			var recordList = c.getRecordList(acessoryRows, groupsRows, kitsRows, productsRows);
			c.tableProductsRecordList = fillRecordList(recordList.acessoryDatas, true);
			c.tableAcessorysRecordList = fillRecordList(recordList.acessoryDatas, true);
			c.tableGroupsRecordList = fillRecordList(recordList.groupDatas, true);
			c.tableKitsRecordList = fillRecordList(recordList.kitDatas, true);
			c.tableAcessorysRecordListError = fillRecordList(recordList.acessoryDatas, false);
			c.tableGroupsRecordListError = fillRecordList(recordList.groupDatas, false);
			c.tableKitsRecordListError = fillRecordList(recordList.kitDatas, false);
			$scope.$apply();
		})
		.catch(error => { })
	};

	window.onload = function () {
		debugger;
		c.initPage();
	}
}]);

var CURRENCY_REGEX  = new RegExp('R\\$\\s');
function checkNull(v) {
	return v ? v : ' - ';
}

function checkNullDecimal(v) {
	return v ? v : '0';
}

function formatMonetary(v, d) {
	if (v){
		let valueParsed = (typeof v == 'string' ? parseFloat(v) : v);

		return valueParsed.toLocaleString('pt-BR', {
			style: 'currency',
			currency: 'BRL',
			minimumFractionDigits: d,
			maximumFractionDigits: d,
		}).replace(CURRENCY_REGEX, '');
	}
	else {
		return v;
	}
}

function sSize(VAR_text) {
	return (VAR_text < 10 ? '0' + VAR_text : VAR_text)
}

function formatDate(date) {
	if (date){
		if (typeof date == 'string' || typeof date == 'number') {
			date = new Date(date);
		}

		return sSize(date.getUTCDate()) + '/' + sSize(date.getUTCMonth() + 1) + '/' + date.getFullYear();
	}
	else{
		return date;
	}
}
