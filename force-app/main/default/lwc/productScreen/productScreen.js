import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

import getCheckoutData from '@salesforce/apex/ProductScreenController.getCheckoutData';
import getStructures from '@salesforce/apex/ProductScreenController.getStructures';
import getResources from '@salesforce/apex/ProductScreenController.getResources';
import getProducts from '@salesforce/apex/ProductScreenController.getProducts';
import saveLineItems from '@salesforce/apex/ProductScreenController.saveLineItems';
import getBaseObject from '@salesforce/apex/ProductScreenController.getBaseObject';
import checkNextTypeResources from '@salesforce/apex/ProductScreenController.checkNextTypeResources';

export default class ProductScreen extends NavigationMixin(LightningElement) {
	defaultQuantitySearch = 50;
	defaultTrue = true;
	currentTab = 'Estrutura';
	@track
	selectedStructure = {};
	@track
	resourceList = [];
	@track
	productMap = {};
	@track
	exceptionProducts= {};
	@track
	currentProductConfig = {};
	@track
	currentResourceActiveted = {};
	@track
	baseObject = {
		"Name":"Nova Cotação",
		"CurrencyIsoCode":"USD",
		"Account":{"Name":"Cliente", "Id": ""},
		"CreatedBy":{"Name":"Vendedor"},
		"Pricebook2":{"Name":"Catalogo de Preço"}};

	@track
	filterListProducts = [
		{
			selected : true,
			label : "Produto",			
			filter : "",
			value : "name"
		},
		{
			selected : false,
			label : "Código do Produto",			
			filter : "",
			value : "internalProdCode"
		}
	]
	@track
	filterList = [
		{
			selected : true,
			label : "Estrutura",			
			filter : "",
			value : "Name"
		},
		{
			selected : false,
			label : "Agrupador",			
			filter : "",
			value : "Agrupador__c"
		}
	]

	@track 
	structureException = {
		Id : "",
		showIcon : true,
		Name : "Estrutura Manual",
		Agrupador__c : "Cadastro Produto fora da Estrutura",
	}

	@track currentExceptionEdit = {};

	structureMap = {};
	delayProductCode = {};
	addNewAccessory = {};
	checkoutExceptionProductMap = {};

	quoteId = '';
	productCode = '';
	grouper = '';
	structureName = '';
	@track currentStackTraceCode = [];
	activatedResourceIndex = '0';

	pricebookFilter = ' AND id IN (SELECT CatalogoDePreco__c FROM ContaXCatalogoDePreco__c where Conta__c = {accountId})';

	isWireConnectedLoading = true;
	isConnectedLoading = true;
	isLoading = true;
	isLoadingModal = false;
	isShowSeeMoreButton = false;
	isShowStructures = false;
	isShowProducts = false;
	isShowResources = false;
	isShowSearchProduct = false;
	isOpenConfigKit = false;
	isOpenNewAccessoryModal = false;
	isOpenEditAccessoryModal = false;
	isDesktop = false;
	isMobile = false;
	isTablet = false;

	currentPageReference;

	get showCarrinho(){
		return this.currentTab == 'Carrinho';
	}
	get showEstrutura(){
		return this.currentTab == 'Estrutura';
	}
	get showProduto(){
		return this.currentTab == 'Pronta';
	}
	get showExcecao(){
		return this.currentTab == 'Excecao';
	}
	get showSingleProduct(){
		return this.currentTab == 'SingleProduct';
	}
	get getClassEstrutura(){
		return this.getClassTabItem('Estrutura');
	}
	get getClassProduto(){
		return this.getClassTabItem('Pronta');
	}
	get getClassExcecao(){
		return this.getClassTabItem('Excecao');
	}
	get getClassCarrinho(){
		return this.getClassTabItem('Carrinho');
	}
	get getClassSingleProduct(){
		return this.getClassTabItem('SingleProduct');
	}

	getClassTabItem(item){
		return 'slds-vertical-tabs__nav-item '+(this.currentTab == item ? 'slds-is-active' : '');
	}

	get currentGroupShowId(){
		return this.currentGroupShow('id');
	}
	get currentGroupShowName(){
		return this.currentGroupShow('nameCompleted');
	}
	currentGroupShow(field){
		if(this.currentProductConfig && this.currentProductConfig.groupAccessoryList){
			var allShow = this.currentProductConfig.groupAccessoryList.filter(item => item.isShowGroup);
			return allShow[allShow.length-1][field];
		}
	}

	get selectedResourceList() {
		let selectedResourceList = [];

		this.resourceList.forEach(resource => {
			resource.ComposicaoProduto__r.forEach(item => {
				if (item.isSelected) {
					selectedResourceList.push(item);
				}
			});
		});

		return selectedResourceList;
	}
	get structures() {		
		return Object.values(this.structureMap).filter(function(item){
			var filter = this.filterList.find(filters => filters.selected);
			return item[filter.value].toLocaleLowerCase().includes(filter.filter.toLocaleLowerCase());
		}.bind(this));
	}

	get excpProducts(){
		return Object.values(this.exceptionProducts);
	}
	get products() {
		return this.filterProductList(Object.values(this.productMap).filter(item => !item.showCheckout));
	}
	get singleProduts() {
		return this.filterProductList(Object.values(this.productMap).filter(item => !item.isShowNewStructure && !item.showCheckout));
	}
	get newStructures() {
		return this.filterProductList(Object.values(this.productMap).filter(item => item.isShowNewStructure && !item.showCheckout));
	}
	get checkoutProducts() {	
		return Object.values(this.productMap).filter(item => item.showCheckout);
	}

	filterProductList(context){
		var objs = [];
		try{
		var filter = this.filterListProducts.find(filters => filters.selected);
		objs =  context.filter(function(item){
			if(filter.filter)
				return item[filter.value]?.toLocaleLowerCase().includes(filter.filter?.toLocaleLowerCase());
			else
				return true;
		}.bind(this), {filter});
	}catch(ex){
		debugger;
	}
		return objs;
	}

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		const { state } = currentPageReference;

		this.clearAll();

		if (state) {
			this.quoteId = state.c__quoteId;
			this.getBaseObjectData();
		}
	}

	connectedCallback() {
		this.isDesktop = FORM_FACTOR == 'Large';
		this.isMobile = FORM_FACTOR == 'Small';
		this.isTablet = FORM_FACTOR == 'Medium';
	}

	getBaseObjectData() {
		this.isLoading = true;
		getBaseObject({objId : this.quoteId})
			.then(resolve => {
				this.baseObject = resolve;
				if(this.baseObject?.Pricebook2?.Name && this.baseObject?.Pricebook2?.Name != 'Catalogo de Preço'){
					this.isShowStructures = true;
				}else{
					this.pricebookFilter = this.pricebookFilter.replace('{accountId}', '\"'+this.baseObject.AccountId+'\"');
					this.isPricebookSelection = true;
					this.isShowStructures = false;
				}
				this.isLoading = false;
				return getStructures({});
			})
			.then(resolve => {
				this.structureMap = resolve;
				return getCheckoutData({ objId: this.quoteId });
			})
			.then(resolve => {
				this.updateProductsMap(resolve);
				this.isLoading = false;
			})
			.catch(error => {
				this.isLoading = false;
				console.log('Error =>', error);
				this.handlerDispatchToast('Erro!', 'Contate um administrador!!\n' + error, 'error');
			})
	}

	updateProductsMap(resolve){		
		Object.keys(resolve).forEach(function(key){
			if(!this.productMap[key]?.showCheckout)
				this.productMap[key] = resolve[key];
		}.bind(this), {resolve});
	}

	selectFilterProductomponent(event){
		const { value } = event.detail;
		this.filterListProducts.forEach(function(item){
			item.selected = (item.value == value);
		});
		this.handlefilterProductComponent(event);
	}
	handlefilterProductComponent(event){
		const { value, filter } = event.detail;
		this.filterListProducts.forEach(function(item){
			if(item.selected) item.filter = filter;
		}, {value, filter});
		this.getFilterProducts();
	}

	selectFilterComponent(event){
		const { value } = event.detail;
		this.filterList.forEach(function(item){
			item.selected = (item.value == value);
		});
		this.handlefilterComponent(event);
	}
	handlefilterComponent(event){
		const { value, filter } = event.detail;
		this.filterList.forEach(function(item){
			if(item.selected) item.filter = filter;
		}, {value, filter});
	}

	getFilterValue(){
		return this.filterListProducts.find(item => item.selected).filter;
	}

	getFilterProducts(){		
		this.productMap = JSON.parse(JSON.stringify(this.productMap));
		this.structureMap = JSON.parse(JSON.stringify(this.structureMap));
		this.isLoading = true;
		getProducts({objId: this.quoteId, productCode: this.getFilterValue(), quantity: this.defaultQuantitySearch, structureId: this.currentTab}).then(resolve => {
			this.updateProductsMap(resolve);
			this.isLoading = false;
		});
	}

	showComponentTab(event){
		this.currentTab = event.currentTarget.dataset.component;
		this.productMap = JSON.parse(JSON.stringify(this.productMap));
		this.structureMap = JSON.parse(JSON.stringify(this.structureMap));
		this.isLoading = true;
		getProducts({objId: this.quoteId, quantity: this.defaultQuantitySearch, structureId: this.currentTab}).then(resolve => {
			this.updateProductsMap(resolve);
			this.isLoading = false;
		});
	}
	async handleSelectStructure(id) {

		this.isLoading = true;

		this.resourceList = await getResources({ structureId: id });

		let errorMessage = this.checkResources();
		if (errorMessage) {
			this.resourceList = [];

			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');

			this.isLoading = false;
			return;
		}

		this.resourceList.forEach(item => {
			item.class = "menu__title";
			item.isResourceDisabled = true;
			item.isSelected = false;
		});

		this.resourceList[0].class = "menu__title-current";
		this.resourceList[0].isResourceDisabled = false;
		this.resourceList[0].ComposicaoProduto__r.forEach(item => {
			item.isShowType = true;
			item.isSelected = false;
			item.class = "slds-card";
		});

		this.currentResourceActiveted = this.resourceList[0];
		this.activatedResourceIndex = '0';

		// this.currentStackTraceCode = this.resourceList[0].EstruturaProduto__r.CodigoInterno__c;

		this.selectedStructure = this.structureMap[id];
		this.isShowStructures = false;
		this.isShowResources = true;

		this.isLoading = false;
	}

	checkResources() {
		let errorMessage = '';

		if (!this.resourceList || this.resourceList.length === 0) {
			this.resourceList = [];

			this.isLoading = false;
			return 'Os recursos desta estrutura não estão completos.';
		}

		this.resourceList.forEach(resource => {
			if (!resource.ComposicaoProduto__r || resource.ComposicaoProduto__r.length === 0) {
				errorMessage = 'Recurso ' + resource.Name + ' não tem tipos de recurso cadastrados.';
			}
		});

		return errorMessage;
	}

	handleChooseResource(event) {
		this.isLoading = true;

		const { resourceId, currentResourceId } = event.detail;

		let chooseIndex = 0;
		let chooseResource = this.resourceList.find((item, index) => {
			if (item.Id === resourceId) {
				chooseIndex = index;
				return true;
			}
		});

		if (currentResourceId) {
			let selectedResource = this.resourceList.find(item => item.Id === currentResourceId);
			selectedResource.class = selectedResource.isSelected ? "menu__title-selected" : "menu__title";
		}
		chooseResource.class = "menu__title-current";

		this.currentResourceActiveted = chooseResource;
		this.activatedResourceIndex = String(chooseIndex);

		this.isLoading = false;
	}

	async handleChooseTypeResource(event) {
		this.isLoading = true;

		const { resourceId, typeResourceId, hasResourceTypeSelected } = event.detail;

		let hasNext = false;
		let selectedResourceIndex = 0;
		let nextResourceIndex = 0;
		let selectedResource = this.resourceList.find((item, index) => {
			if (item.Id === resourceId) {
				selectedResourceIndex = index;
				nextResourceIndex = index + 1;
				return true;
			}
		});

		if (hasResourceTypeSelected) {
			selectedResource.ComposicaoProduto__r.forEach(item => {
				item.isSelected = false;
				item.class = "slds-card";
			});
		}

		for (let i = nextResourceIndex; i < this.resourceList.length; i++) {
			this.resourceList[i].ComposicaoProduto__r.forEach(item => {
				item.isShowType = false;
				item.isSelected = false;
				item.class = "slds-card";
			});
			this.resourceList[i].isResourceDisabled = true;
			this.resourceList[i].class = "menu__title";
			hasNext = true;
		}

		let chooseTypeResource = selectedResource.ComposicaoProduto__r.find(item => item.Id === typeResourceId);
		chooseTypeResource.isSelected = true;
		chooseTypeResource.class = "slds-card container__header-green";

		this.resourceList[selectedResourceIndex].isSelected = true;

		this.fillStackTraceCode();

		// if (nextResourceIndex < this.resourceList.length) {
		// 	const externalIdList = await checkNextTypeResources({
		// 		structureId: this.selectedStructure.Id,
		// 		currentExternalId: this.currentStackTraceCode,
		// 		index: nextResourceIndex
		// 	});

		// 	this.resourceList[nextResourceIndex].isResourceDisabled = false;
		// 	this.resourceList[nextResourceIndex].ComposicaoProduto__r.forEach(item => {
		// 		if (externalIdList.find(extId => extId.includes(item.Sequencial__c)) || !item.Sequencial__c) {
		// 			item.isShowType = true;
		// 		}
		// 	}, {externalIdList});
		// }

		if (nextResourceIndex < this.resourceList.length) {
			const externalIdList = await checkNextTypeResources({
				structureId: this.selectedStructure.Id,
				currentStackTraceCode : this.currentStackTraceCode,
				index: (nextResourceIndex +1)
			});

			this.resourceList[nextResourceIndex].isResourceDisabled = false;
			this.resourceList[nextResourceIndex].ComposicaoProduto__r.forEach(item => {
				if (externalIdList.includes(item.Id)) {
					item.isShowType = true;
				}
			}, {externalIdList});
		}

		if (hasNext) {
			this.handleChooseResource({
				detail: {
					resourceId: this.resourceList[nextResourceIndex].Id,
					currentResourceId: resourceId
				}
			});
		}

		this.isLoading = false;
	}

	async handleSearchProductStructure() {
		this.isLoading = true;

		this.fillStackTraceCode();

		if (!this.selectedStructure.Id) {
			this.handlerDispatchToast('Atenção!', 'Não é possível buscar produtos sem nenhuma estrutura.', 'warning');
			this.isLoading = false;
			return;
		}

		Object.values(this.productMap).forEach(item => item.showSelectedStructure = false);
		var resolve = await getProducts({
			objId: this.quoteId,
			structureId: this.selectedStructure.Id,
			currentStackTraceCode: this.currentStackTraceCode,
			quantity: this.defaultQuantitySearch
		});
		Object.values(resolve).forEach(item => item.showSelectedStructure = true);
		
		this.updateProductsMap(resolve);

		this.isShowProducts = true;
		this.isShowStructures = false;
		this.isShowResources = false;
		this.isShowSearchProduct = false;

		this.isLoading = false;
	}

	handleAcessoryData(event){
		this.handleAcessory(event.detail);
	}
	handleAcessoryDataConfig(event){
		const { id, groupId } = event.detail;
		
		let groupAccessory = this.currentProductConfig.groupAccessoryList.find(item => item.id === groupId);
		let productData = groupAccessory.accessoryList.find(item => item.id === id);

		this.handleAcessoryProductData({ name:event.detail.name, value:event.detail.value } , productData);
	}
	handleAcessory(event){
		const { name, value, id, Product2Id, groupId } = event;

		let productData = {};
		
		let checkoutProduct = this.productMap[Product2Id];
		let groupAccessory = checkoutProduct.groupAccessoryList.find(item => item.id === groupId);
		if(groupAccessory){
			groupAccessory.accessoryList.forEach(item => {
				if (item.id === id) {
					productData = item;
					return;
				}
			}, {productData});
		}else{
			productData = checkoutProduct.exceptionAccessoryList.find(item => item.id === id);
		}
		this.handleAcessoryProductData(event, productData);
	}

	handleAcessoryProductData(event, productData){
		const { name, value, id, Product2Id, groupId } = event;
		if(name !== 'changedQuantity'){
			productData[name] = (name === 'discountType' ? value : Number(value));
		}

		if (name === 'discountType') {
			if (value === 'percent') {
				productData.isDiscountPercent = true;
			}
			else {
				productData.isDiscountPercent = false;
			}
		}
		else if (name === 'price') {
			productData.discountCurrency = Number((productData.listPrice - productData.price).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountCurrency') {
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountPercent') {
			productData.discountCurrency = Number(((productData.discountPercent / 100) * productData.listPrice).toFixed(2));
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
		}

		if(name === 'quantity'){
			productData['changedQuantity'] = Number(value);
		}

		if(name === 'changedQuantity'){
			productData['quantity'] = Number(value);
		}

		if(productData.price && productData.quantity)
			productData.totalPrice = Number((productData.price * productData.quantity).toFixed(2));

	}

	handleNewAcessoryProductData(event) {
		const { name, value, id } = event.detail;
		this.handleProducts(event, this.exceptionProducts[id]);
	}

	handleProductData(event) {
		const { name, value, id } = event.detail;
		this.handleProducts(event, this.productMap[id]);
	}
	handleProducts(event, productData){
		const { name, value, id } = event.detail;
		if(name == 'quantityAccessory'){
			productData.exceptionAccessoryList.forEach(function(item){
				var newQuantity = value * item.changedQuantity;
				this.handleAcessory( { name : 'changedQuantity', value : newQuantity, id : item.id, Product2Id : productData.id, groupId: item.id });
			}.bind(this), {productData});
			productData.groupAccessoryList.forEach(function(item){
				item.accessoryList.forEach(function(acesss){
					var newQuantity = value * acesss.changedQuantity;
					this.handleAcessory( { name : 'changedQuantity', value : newQuantity, id : acesss.id, Product2Id : productData.id, groupId: item.id });
				}.bind(this), {productData});
			}.bind(this), {productData});
			productData[name] = Number(value);
			return;
		}
		if (!value || (name !== 'discountType' && value < 0)) {
			productData.price = 0;
			productData.discountCurrency = 0;
			productData.discountPercent = 0;
			productData.totalPrice = 0;
			productData[name] = undefined;
			return;
		}

		productData[name] = (name === 'discountType' ? value : Number(value));

		if (name === 'discountType') {
			productData.isDiscountPercent = value === 'percent';
		}
		else if (name === 'price') {
			productData.discountCurrency = Number((productData.listPrice - productData.price).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountCurrency') {
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountPercent') {
			productData.discountCurrency = Number(((productData.discountPercent / 100) * productData.listPrice).toFixed(2));
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
		}

		productData.totalPrice = Number((productData.price * productData.quantity).toFixed(2));
	}

	handleConfigureKit(event) {
		const id = event.detail.id;

		this.productMap[id].groupAccessoryList.forEach(item => item.isShowGroup = false);
		this.productMap[id].groupAccessoryList[0].isShowGroup = true;
		this.productMap[id].groupAccessoryList[0].isCurrentGroup = true;

		this.currentProductConfig = JSON.parse(JSON.stringify(this.productMap[id]));

		this.isOpenConfigKit = true;
	}

	handleClearKitConfiguration(event) {
		this.clearConfig(this.productMap[event.detail.id]);
	}

	handleSelectProduct(event) {
		let addProduct = this.productMap[event.detail.id];

		if (!this.checkProductIsValid(addProduct)) return;

		addProduct.isSelected = true;
		addProduct.showCheckout = true;
		addProduct.isSingleItem = this.currentTab == 'SingleProduct';

		this.currentTab = 'Carrinho';
		this.handleNewStructure();
	}

	handleRemoveProduct(event) {
		let removeProduct = this.productMap[ event.detail.id];

		removeProduct.isSelected = false;
		removeProduct.showCheckout = false;
		removeProduct.quantity = 1;
		removeProduct.price = removeProduct.listPrice;
	}

	checkProductIsValid(addProduct) {
		if (!addProduct.quantity || addProduct.quantity <= 0) {
			this.handlerDispatchToast('Atenção!', 'Quantidade inválida', 'warning');
			return false;
		}
		else if (!addProduct.price || addProduct.price <= 0) {
			this.handlerDispatchToast('Atenção!', 'Preço inválido', 'warning');
			return false;
		}
		else if ((!addProduct.discountCurrency && addProduct.discountCurrency != 0) || addProduct.discountCurrency > addProduct.listPrice) {
			this.handlerDispatchToast('Atenção!', 'Desconto inválido', 'warning');
			return false;
		}
		else if ((!addProduct.discountPercent && addProduct.discountPercent != 0) || addProduct.discountPercent > 100) {
			this.handlerDispatchToast('Atenção!', 'Porcetagem do desconto inválido', 'warning');
			return false;
		}
		return true;
	}






	handleStructure(event){
		// const structure = event.detail.structure;
		// if(structure.Name == "Estrutura Manual"){
		// 	this.onClickNewStructure();
		// }else{
		// 	this.handleSelectStructure(structure.Id);
		// }
		this.handleSelectStructure(event.detail.structure.Id);
	}
	handleNewStructure(event) {
		this.isShowStructures = true;
		this.isShowResources = false;
		this.isShowProducts = false;
		this.showComponentTab(event);
		// this.clearAll();
		// this.productMap.forEach(item => item.showSelectedStructure = false);
	}

	handleFilter(event) {
		const { name, value } = event.target;
		this[name] = value;
	}

	// onClickNewStructure() {
	// 	this.handleSearchProductCode();
	// }

	// handleSearchProductCode() {
	// 	this.clearAll(false);
	// 	this.isShowSearchProduct = true;
	// }

	onClickSeeMoreProduct(){
		this.isLoading = true;
		getProducts({objId: this.quoteId, quantity: Object.values(this.productMap).length + this.defaultQuantitySearch, structureId: this.currentTab})
		.then(resolve => {
			this.isLoading = false;
			this.updateProductsMap(resolve);
		});
	}

	handleProductCode(event) {
		this.productCodeLoading = true;

		this.productCode = event.target.value;

		clearTimeout(this.delayProductCode);

		if (this.productCode > ' ') {
			this.delayProductCode = setTimeout(() => {
				this.productCodeLoading = false;
				this.isLoading = true;
				this.isLoadingModal = true;

				getProducts({ objId: this.quoteId, productCode: this.productCode, quantity: this.defaultQuantitySearch, structureId: this.currentTab })
					.then(resolve => {				
						this.exceptionProducts = resolve;
					})
					.catch(error => {
						console.log('Error Search Product By Code =>', error);
						this.handlerDispatchToast('Falha!', ('Erro inesperado! ' + error), 'error');
					})
					.finally(() => {
						if (this.products.length > 0) this.isShowSeeMoreButton = true;
						this.isLoading = false;
						this.isLoadingModal = false;
					});
			}, 1500);
		}
		else {
			this.isShowSeeMoreButton = false;
			this.productCodeLoading = false;
		}
	}


	onClickAddExceptionAccessoryEvent(event) {
		if(!(this.addNewAccessory?.productId))
			this.addNewAccessory = {};
		this.addNewAccessory.productId = event.detail.id;
		this.isOpenNewAccessoryModal = true;
	}

	clickSelectExceptionAccessoryEvent(event) {
		const id = event.detail.id;
		let addProduct = this.exceptionProducts[id];

		if (!this.checkProductIsValid(addProduct)) return;

		addProduct.discountPercent = 0;
		addProduct.listPrice = addProduct.price;
		addProduct.discountCurrency = 0;
		addProduct.discountType = 'currency';
		addProduct.isSelected = true;
		addProduct.showCheckout = true;
		addProduct.showException = true;
	}

	onClickRemoveExceptionAccessory(event) {
		const { name, value, id, Product2Id, groupId } = event.detail;
		
		let removeProduct = {};
		let checkoutProduct = this.productMap[Product2Id];
		let groupAccessory = checkoutProduct.groupAccessoryList.find(item => item.id === groupId);
		if(groupAccessory){
			groupAccessory.accessoryList.forEach(item => {
				if (item.id === id) {
					removeProduct = item;
					return;
				}
			}, {removeProduct});
		}else{
			delete checkoutProduct.exceptionAccessoryList[id];
		}			
		removeProduct.isSelected = false;
		removeProduct.showCheckout = false;
		removeProduct.quantity = 1;
		removeProduct.price = removeProduct.listPrice;
	}

	onClickRemoveExceptionAccessoryCheckout(event) {
		const { id, productId } = event.target.dataset;

		let checkoutProduct = this.productMap[productId];
		checkoutProduct.exceptionAccessoryList = checkoutProduct.exceptionAccessoryList.filter(item => item.id !== id);

		if (checkoutProduct.exceptionAccessoryList.length <= 0) {
			checkoutProduct.hasExceptionAccessory = false;
		}
	}

	onClickCancelNewAccessory() {
		this.productCode = '';
		this.addNewAccessory = {};
		this.currentExceptionEdit = {};
		this.isOpenNewAccessoryModal = false;
		this.isOpenEditAccessoryModal = false;
	}

	onClickSaveNewAccessory() {
		if (Object.values(this.exceptionProducts).length <= 0) {
			this.handlerDispatchToast('Atenção!', 'Nenhum acessório selecionado!', 'warning');
			return;
		}

		Object.values(this.exceptionProducts).forEach(item => {
			let currentProductCheckout = this.productMap[this.addNewAccessory.productId];

			if (!currentProductCheckout.exceptionAccessoryList) currentProductCheckout.exceptionAccessoryList = [];

			if (currentProductCheckout.hasExceptionAccessory) {
				let hasProduct = false;
				currentProductCheckout.exceptionAccessoryList.forEach(accessory => {
					if (accessory.id === item.id) {
						accessory = item;
						hasProduct = true;
						accessory.isSelected = true;
						item.isSelected = true;
					}
				});

				if (!hasProduct) {
					currentProductCheckout.isConfigured = true;
					currentProductCheckout.exceptionAccessoryList.push({ ...item });
				}
			}
			else {
				currentProductCheckout.isConfigured = true;
				currentProductCheckout.hasExceptionAccessory = true;
				currentProductCheckout.exceptionAccessoryList.push({ ...item });
			}

		});

		this.onClickCancelNewAccessory();
	}

	onChangeExceptionAccessoryQuantity(event) {
		const { id, productId } = event.target.dataset;

		let checkoutProduct = this.productMap[productId];
		let accessory = checkoutProduct.exceptionAccessoryList.find(item => item.id === id);
		accessory.quantity = Number(event.target.value);
		accessory.totalAmount = Number(Number(accessory.quantity * accessory.price).toFixed(2));
	}

	handleClearConfigKit(event) {
		const id = event.target.dataset.id;
		this.clearConfig(this.productMap[id]);
	}

	handleConfigKit(event) {
		const id = event.target.dataset.id;

		this.currentProductConfig = JSON.parse(JSON.stringify(this.productMap[id]));

		this.isOpenConfigKit = true;
	}

	onClickBackAccessoryGroup(event) {
		const { groupId, index } = event.target.dataset;

		let groupAccessory = this.currentProductConfig.groupAccessoryList[index];
		let newGroupAccessory = this.currentProductConfig.groupAccessoryList[Number(index) - 1];

		if (!groupAccessory.isFirstGroup) {
			groupAccessory.isShowGroup = false;
			groupAccessory.isCurrentGroup = false;
			groupAccessory.isNotCurrentGroup = true;

			newGroupAccessory.isNotCurrentGroup = false;
			newGroupAccessory.isCurrentGroup = true;
		}
		else {
			this.handlerDispatchToast('Atenção!', 'Não há acessório anterior!', 'warning');
		}
	}

	onClickNextAccessoryGroup(event) {
		const { groupId, index } = event.target.dataset;

		let groupAccessory = this.currentProductConfig.groupAccessoryList[index];
		let newGroupAccessory = this.currentProductConfig.groupAccessoryList[Number(index) + 1];

		let errorMessage = '';
		let selectedLength = groupAccessory.accessoryList.filter(item => item.isSelected).length;

		if (groupAccessory.isRequired && groupAccessory.isListing && selectedLength < groupAccessory.minQuantity) {
			errorMessage = groupAccessory.name + ' precisa selecionar ' + groupAccessory.minQuantity + ' acessório(s).';

			if (selectedLength < groupAccessory.minQuantity) {
				errorMessage += ' Adicione mais ' + (groupAccessory.minQuantity - selectedLength) + ' acessório(s).';
			}
			else {
				errorMessage += ' Remova ' + (selectedLength - groupAccessory.minQuantity) + ' accessório(s).';
			}
		}

		if (errorMessage > ' ') {
			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');
			return;
		}

		if (!groupAccessory.isLastGroup && (groupAccessory.isSelected || !groupAccessory.isListing || !groupAccessory.isRequired)) {
			groupAccessory.isCurrentGroup = false;
			groupAccessory.isNotCurrentGroup = true;

			newGroupAccessory.isNotCurrentGroup = false;
			newGroupAccessory.isCurrentGroup = true;
			newGroupAccessory.isShowGroup = true;
		}
		else if (!groupAccessory.isSelected && groupAccessory.isListing) {
			this.handlerDispatchToast('Atenção!', 'Selecione um acessório para continuar!', 'warning');
		}
	}

	handlerShowCombo(event) {
		const { id, groupId } = event.detail;

		let groupAccessory = this.currentProductConfig.groupAccessoryList.find(group => group.id === groupId);

		if (groupAccessory.isNotCurrentGroup) return;

		groupAccessory.comboList.forEach(item => {
			if (item.id === id) {
				item.isSelected = !item.isSelected; 
			}

			if (item.isSelected) {
				groupAccessory.isSelected = true;
			}
		});
	}
	handlerSelectAccessory(event) {
		const { id, groupId } = event.detail;
		// const { id, groupId } = event.target.dataset;

		let groupAccessory = this.currentProductConfig.groupAccessoryList.find(group => group.id === groupId);

		if (groupAccessory.isNotCurrentGroup) return;

		groupAccessory.isSelected = false;
		groupAccessory.accessoryList.forEach(item => {
			if (item.id === id) {
				if (item.isSelected) {
					item.isSelected = false;
				}
				else {
					item.isSelected = true;
				}
			}

			if (item.isSelected) {
				groupAccessory.isSelected = true;
			}
		});
	}

	handleSaveConfigKit() {
		debugger;
		this.isLoadingModal = true;

		let errorMessage = this.checkAccessories(this.currentProductConfig.groupAccessoryList);
		if (errorMessage) {
			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');
			this.isLoadingModal = false;
			return;
		}

		let product = this.productMap[this.currentProductConfig.id];

		product.groupAccessoryList = JSON.parse(JSON.stringify(this.currentProductConfig.groupAccessoryList));
		product.groupAccessoryList.forEach(group => {
			if (group.isListing) {
				group.accessoryList.forEach(item => {
					if (item.isSelected) {
						item.totalAmount = Number(Number(item.price * item.quantity).toFixed(2));
						item.discountPercent = 0;
						item.listPrice = item.price;
						item.discountCurrency = 0;
						item.discountType = 'currency';
					}
				}, {product});
			}
		}, {product});
		product.isConfigured = true;
		product.isDisabledButtons = false;

		this.isLoadingModal = false;

		this.handleCloseConfigKit();
	}

	handleCloseConfigKit() {
		this.currentProductConfig = {};

		this.isOpenConfigKit = false;
		this.onClickCancelNewAccessory();
	}

	checkAccessories(groupList) {
		let hasError = false;
		let errorMessage = '';

		groupList.forEach(group => {
			if (!hasError) {
				let selectedLength = group.accessoryList.filter(item => item.isSelected).length;

				if (group.isRequired && group.isListing && selectedLength < group.minQuantity) {
					errorMessage = group.name + ' precisa selecionar ' + group.minQuantity + ' acessório(s).';

					if (selectedLength < group.minQuantity) {
						errorMessage += ' Adicione mais ' + (group.minQuantity - selectedLength) + ' acessório(s).';
					}
					else {
						errorMessage += ' Remova ' + (selectedLength - group.minQuantity) + ' accessório(s).';
					}

					hasError = true;
				}
			}
		});

		return errorMessage;
	}

	checkAccessoriesQuantities(groupList) {
		let hasError = false;
		let errorMessage = '';

		groupList.forEach(group => {
			if (!hasError) {
				if (group.isSelected) {
					group.accessoryList.forEach(item => {
						if (item.isSelected && item.quantity <= 0) {
							errorMessage = 'Quantidade invalida para o acessório ' + item.name + '!';
							hasError = true;
						}
					});
				}
			}
		});

		return errorMessage;
	}

	onClickRemoveAccessoryCheckout(event) {
		const { id, groupId, productId } = event.target.dataset;

		let checkoutProduct = this.productMap[productId];
		let groupAccessory = checkoutProduct.groupAccessoryList.find(item => item.id === groupId);
		groupAccessory.accessoryList.forEach(item => {
			if (!groupAccessory.isRequired && item.id === id) {
				item.quantity = 1;
				item.isSelected = false;
				// groupAccessory.isSelected = false;
			}
		});
	}

	handleCheckoutProductData(event) {
		const { name, value, dataset } = event.target;

		let productData = this.productMap[dataset.id];

		if (!value || (name !== 'discountType' && value < 0)) {
			productData.price = 0;
			productData.discountCurrency = 0;
			productData.discountPercent = 0;
			productData.listPrice = item.price;
			productData.totalPrice = 0;
			productData[name] = undefined;
			return;
		}

		productData[name] = (name === 'discountType' ? value : Number(value));

		if (name === 'discountType') {
			if (value === 'percent') {
				productData.isDiscountPercent = true;
			}
			else {
				productData.isDiscountPercent = false;
			}
		}
		else if (name === 'price') {
			productData.discountCurrency = Number((productData.listPrice - productData.price).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountCurrency') {
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
			productData.discountPercent = Number(((productData.discountCurrency / productData.listPrice) * 100).toFixed(2));
		}
		else if (name === 'discountPercent') {
			productData.discountCurrency = Number(((productData.discountPercent / 100) * productData.listPrice).toFixed(2));
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
		}

		productData.totalPrice = Number((productData.price * productData.quantity).toFixed(2));
	}

	handleRemoveCheckoutProduct(event) {
		const id = event.target.dataset.id;		
		let addProduct = this.productMap[id];
		addProduct.isSelected = false;
		addProduct.showCheckout = false;
	}

	handleremoveexception(event){
		const { id, groupId } = event.detail;
		
		let currentGroup = this.productMap[id].exceptionAccessoryList.find(group => group.id === groupId);
		currentGroup.isSelected = false;

	}

	handleeditexception(event){
		const { id, groupId } = event.detail;
		this.currentExceptionEdit = this.productMap[id].exceptionAccessoryList.find(group => group.id === groupId);
		this.currentExceptionEdit.Product2Id = id;
		this.currentExceptionEdit.groupId = groupId;
		this.isOpenEditAccessoryModal = true;
	}
	handleChangeAcessory(event){
		const {  name, value, id, groupId, productId } = event.detail;
		
		let checkoutProduct = this.productMap[productId];
		let currentGroup = checkoutProduct.groupAccessoryList.find(group => group.id === groupId);
		let currentAccessory = currentGroup ? currentGroup.accessoryList.find(item => item.id === id) : null;
		if(currentAccessory)
			currentAccessory[name] = value;

		if (name === 'quantity') {
			currentAccessory.totalAmount = Number(Number(currentAccessory.quantity * currentAccessory.price).toFixed(2));
		}
		if (name === 'isEdit') {
			this.currentExceptionEdit = currentAccessory ? currentAccessory : checkoutProduct.exceptionAccessoryList.find(group => group.id === groupId);
			this.isOpenEditAccessoryModal = true;
			this.currentExceptionEdit.Product2Id = productId;
			this.currentExceptionEdit.groupId = groupId;
			this.currentExceptionEdit.isShowProduct = true;
		}

	}

	handleSaveProducts() {
		this.isLoading = true;

		let errorMessage = this.checkProducts();
		if (errorMessage) {
			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');
			this.isLoading = false;
			return;
		}

		console.log(JSON.stringify(this.checkoutProducts));
		this.checkoutProducts.forEach(product => {
			if (product.isHasKit) {
				errorMessage = this.checkAccessories(product.groupAccessoryList);

				if (!errorMessage) {
					errorMessage = this.checkAccessoriesQuantities(product.groupAccessoryList);
				}
			}
		});
		if (errorMessage) {
			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');
			this.isLoading = false;
			return;
		}

		saveLineItems({ objId: this.quoteId, lineItemList: this.checkoutProducts })
			.then(resolve => {
				if (!resolve.hasError) {
					this.handlerDispatchToast('Sucesso!!', 'Itens salvo com exito!!!', 'success');

					this.getBaseObjectData();

					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: this.quoteId,
							actionName: 'view',
						}
					});
				}
				else {
					console.log('Error Save Quote Line Items =>', (resolve.errorMessage || resolve.exceptionMessage));
					this.handlerDispatchToast('Erro!', (resolve.errorMessage || ''), 'error');
				}
			})
			.catch(error => {
				console.log('Save Quote Line Items =>', error);
				this.handlerDispatchToast('Erro!', 'Falha na inserção dos itens da cotação! ' + error, 'error');
			})
			.finally(() => this.isLoading = false);
	}

	checkProducts() {
		let errorMessage = '';

		this.checkoutProducts.forEach(item => {
			if (item.quantity <= 0) {
				errorMessage = 'Quantidade inválida para o item ' + item.name;
			}
			else if (item.price <= 0 || item.price > item.listPrice) {
				errorMessage = 'Valor inválido para o item ' + item.name;
			}

			if (!errorMessage && item.hasExceptionAccessory) {
				item.exceptionAccessoryList.forEach(accessory => {
					if (accessory.quantity <= 0) {
						errorMessage = 'Quantidade inválida para o acessório ' + accessory.name;
					}
				});
			}
		});

		return errorMessage;
	}









	clearConfig(product) {
		product.isConfigured = false;

		product.groupAccessoryList.forEach(group => {
			if (group.isListing) group.value = '';

			group.isSelected = false;
			group.accessoryList.forEach(item => item.isSelected = false);
		});

		product.isDisabledButtons = true;
	}

	fillStackTraceCode() {
		// this.currentStackTraceCode = this.resourceList[0].EstruturaProduto__r.CodigoInterno__c;

		// this.resourceList.forEach(resource => {
		// 	resource.ComposicaoProduto__r.forEach(item => {
		// 		if (item.isSelected && item.Sequencial__c) {
		// 			this.currentStackTraceCode += item.Sequencial__c;
		// 		}
		// 	});
		// });
		this.currentStackTraceCode = [];
		this.resourceList.forEach(resource => {
			resource.ComposicaoProduto__r.forEach(item => {
				if (item.isSelected) {
					this.currentStackTraceCode.push(item.Id);
				}
			});
		});
	}

	clearAll(isShowStructures = true) {
		this.resourceList = [];
		this.productMap = {};
		this.selectedStructure = {};
		this.addNewAccessory = {};
		this.currentStackTraceCode = [];
		this.productCode = '';

		this.isShowStructures = isShowStructures;
		this.isShowProducts = false;
		this.isShowResources = false;
		this.isShowSearchProduct = false;
	}

	handlerDispatchToast(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}
}