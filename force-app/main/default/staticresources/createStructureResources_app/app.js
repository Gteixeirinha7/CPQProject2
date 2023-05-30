var app = angular.module('app', ['infinite-scroll']);

app.controller('ItemController', ['$scope', '$http', '$sce', function ($scope, $http, $sce) {
	var c = this;

	c.loading = false;

	this.showError = false;
	this.showSuccess = true;
	this.tableRecordList = [];
	this.tableRecordListError = [];

	this.structureNameSet = [];
	this.productCodeSet = [];
	this.internalKeySet = [];

	this.columnList = [
		{title: '#', field: 'internalId'},
		{title: 'Nome da Estrutura', field: 'structureName'},
		{title: 'Codigo do Produto', field: 'productCode'},
		{title: 'Chave do Registro', field: 'internalKey'}
	];
	this.columnListError = [
		...this.columnList,
		{title: 'Erro na linha', field: 'errorMessage'}
	];

	this.initPage = function() {
		c.loading = false;
		$scope.$apply();
	}

	this.newFile = function() {
		c.tableRecordList = [];
		c.tableRecordListError = [];
		document.getElementById('error-01').innerHTML = 'Selecione o Arquivo';
		document.getElementById('file-upload-input-01').files = (new DataTransfer()).files;
	}

	this.removeRecord = function(record) {
		c.loading = true;

		if (c.tableRecordList.length <= 1) {
			c.tableRecordList = [];
			c.tableRecordListError = [];
			document.getElementById('error-01').innerHTML = 'Selecione o Arquivo';
			document.getElementById('file-upload-input-01').files = (new DataTransfer()).files;
		} else {
			var count = 1;
			c.tableRecordList = c.tableRecordList.filter(item => {
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

		if (c.tableRecordList && c.tableRecordList.length > 0)
			insertRecordList(c.tableRecordList);
		else if (fileXCL && typeof(FileReader) != "undefined" && fileXCL.name.split('.').pop().toLowerCase() == 'xlsx') {
			var reader = new FileReader();
			//For Browsers other than IE.
			if (reader.readAsBinaryString) {
				reader.onload = function(e) {
					var data = e.target.result;
					var workbook = XLSX.read(data, { type: "binary" });

					//Read all rows from First Sheet into an JSON array.
					var excelRows = XLSX.utils.sheet_to_row_object_array( workbook.Sheets[workbook.SheetNames[0]] );
					c.getRecordExternalId(excelRows);
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

	this.checkInvalidRow = function(item){
		if(!item.productCode || !item.structureName || !item.internalKey){
			item.errorMessage = 'Preencha os parametros Obrigatorios: Nome da Estrutura, Codigo do produto, Tipo de Recurso e Valor';
			item.isInvalid = true;
		}
		if(item.structureName && c.structureNameSet && !c.structureNameSet.includes(item.structureName)){
			item.errorMessage = 'Não existe estrutrura com este nome cadastrado no Salesforce: '+item.structureName ;
			item.isInvalid = true;
		}
		if(item.productCode && c.productCodeSet && !c.productCodeSet.includes(item.productCode)){
			item.errorMessage = 'Não existe produto com este código cadastrado no Salesforce: '+item.productCode;
			item.isInvalid = true;
		}
		if(item.internalKey && c.internalKeySet && !c.internalKeySet.includes(item.internalKey.replace(/[^a-zA-Z0-9]+/g, ''))){
			item.errorMessage = 'Preencha o tipo de recurso e o valor corretamente: '+item.internalKey;
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
	
	this.getRecordList = function(excelRows) {
		var recordList = [];
		var count = 0;
		excelRows.forEach(
			function(item) {
				Object.keys(item).forEach(
					function(keyProp) {
						if(keyProp == 'Nome Estrutura' || keyProp == 'Codigo do Produto') return;

						var newObjItem = {structureName : item['Nome Estrutura'], productCode : item['Codigo do Produto'], internalId : count}
						newObjItem.internalKey = item['Nome Estrutura']+' - '+keyProp+' - '+item[keyProp];
						count++;

						recordList.push(c.checkInvalidRow(newObjItem));
					},
					{ item, count }
				);
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

	this.getRecordExternalId = function (excelRows) {
		var getRecordList = c.getRecordList(excelRows);
		Utils.getRecords(getRecordList).then((result) => {
			console.log(result);			
			c.structureNameSet = result.structureList;
			c.productCodeSet = result.productList;
			c.internalKeySet = result.internalList;

			var recordList = c.getRecordList(excelRows);
			c.tableRecordListError = fillRecordList(recordList, false);
			c.tableRecordList = fillRecordList(recordList, true);
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
