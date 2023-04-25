import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

import getCheckoutData from '@salesforce/apex/ProductScreenController.getCheckoutData';
import getStructures from '@salesforce/apex/ProductScreenController.getStructures';
import getResources from '@salesforce/apex/ProductScreenController.getResources';
import getProducts from '@salesforce/apex/ProductScreenController.getProducts';
import getExceptionProducts from '@salesforce/apex/ProductScreenController.getExceptionProducts';
import saveLineItems from '@salesforce/apex/ProductScreenController.saveLineItems';
import getBaseObject from '@salesforce/apex/ProductScreenController.getBaseObject';
import checkNextTypeResources from '@salesforce/apex/ProductScreenController.checkNextTypeResources';

export default class ProductScreen extends NavigationMixin(LightningElement) {
	@track
	selectedStructure = {};
	@track
	resourceList = [];
	@track
	checkoutProductMap = {};
	@track
	productMap = {};
	@track
	productMapException = {}
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
			value : "Name"
		},
		{
			selected : false,
			label : "Código do Produto",			
			filter : "",
			value : "ProductCode"
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
	currentStackTraceCode = '';
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
	isShowCheckout = false;
	isShowSearchProduct = false;
	isOpenConfigKit = false;
	isOpenNewAccessoryModal = false;
	isOpenEditAccessoryModal = false;
	isDesktop = false;
	isMobile = false;
	isTablet = false;

	currentPageReference;

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

	get products() {
		return Object.values(this.productMap);
	}

	get checkoutProducts() {
		return Object.values(this.checkoutProductMap);
	}

	get exceptionProducts() {
		return Object.values(this.productMapException);
	}

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		const { state } = currentPageReference;

		this.clearAll();
		this.checkoutProductMap = {};

		if (state) {
			this.quoteId = state.c__quoteId;

			getCheckoutData({ objId: this.quoteId })
				.then(resolve => {
					this.checkoutProductMap = resolve;
				})
				.catch(error => {
					console.log('Error =>', error);
					this.handlerDispatchToast('Erro!', 'Contate um administrador!!\n' + error, 'error');
				})
				.finally(() => {
					this.isWireConnectedLoading = false;
					this.handleLoadingConnected();
				});
		}
		else {
			this.isWireConnectedLoading = false;
			this.handleLoadingConnected();
		}
	}

	connectedCallback() {
		getStructures({})
			.then(resolve => {
				if (!resolve || Object.keys(resolve).length === 0) {
					this.handlerDispatchToast('Atenção!', 'Nenhuma estrutura de produto encontrada.', 'warning');
				}
				else this.structureMap = resolve;
			})
			.catch(error => {
				console.log('Error =>', error);
				this.handlerDispatchToast('Erro!', 'Contate um administrador!!\n' + error, 'error');
			})
			.finally(() => {
				this.isConnectedLoading = false;
				this.handleLoadingConnected();
			});

		this.isDesktop = FORM_FACTOR == 'Large';
		this.isMobile = FORM_FACTOR == 'Small';
		this.isTablet = FORM_FACTOR == 'Medium';
	}

	handleLoadingConnected() {
		if (!this.isConnectedLoading && !this.isWireConnectedLoading) {
			this.getBaseObjectData();
		}
	}

	getBaseObjectData() {
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
			})
			.catch(error => {
				console.log('Error =>', error);
				this.handlerDispatchToast('Erro!', 'Contate um administrador!!\n' + error, 'error');
			})
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
			if(item.selected){
				item.filter = filter;
			};
		}, {value, filter});
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

		this.currentStackTraceCode = this.resourceList[0].EstruturaProduto__r.CodigoInterno__c;

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

		if (nextResourceIndex < this.resourceList.length) {
			const externalIdList = await checkNextTypeResources({
				structureId: this.selectedStructure.Id,
				currentExternalId: this.currentStackTraceCode,
				index: nextResourceIndex
			});

			this.resourceList[nextResourceIndex].isResourceDisabled = false;
			this.resourceList[nextResourceIndex].ComposicaoProduto__r.forEach(item => {
				if (externalIdList.find(extId => extId.includes(item.Sequencial__c)) || !item.Sequencial__c) {
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

	async handleSearchProduct() {
		this.isLoading = true;

		if (!this.currentStackTraceCode) {
			this.handlerDispatchToast('Atenção!', 'Não é possível buscar produtos sem nenhuma estrutura.', 'warning');
			this.isLoading = false;
			return;
		}

		this.productMap = await getProducts({
			objId: this.quoteId,
			structureId: this.selectedStructure.Id,
			productCode: this.currentStackTraceCode
		});

		this.isShowProducts = true;
		this.isShowStructures = false;
		this.isShowResources = false;
		this.isShowCheckout = false;
		this.isShowSearchProduct = false;

		this.isLoading = false;
	}

	handleAcessoryData(event){
		const { name, value, id, Product2Id, groupId } = event.detail;

		let productData = {};
		
		let checkoutProduct = this.checkoutProductMap[Product2Id] ?  this.checkoutProductMap[Product2Id] : this.productMap[Product2Id];
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

	handleProductData(event) {
		const { name, value, id } = event.detail;

		if(this.productMap[id])
			this.handleProducts(event, this.productMap[id]);
		if(this.checkoutProductMap[id])
			this.handleProducts(event, this.checkoutProductMap[id]);
		if(this.productMapException[id])
			this.handleProducts(event, this.productMapException[id]);
	}
	handleProducts(event, productData){
		const { name, value, id } = event.detail;
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

	handleConfigureKit(event) {
		const id = event.detail.id;

		this.currentProductConfig = JSON.parse(JSON.stringify(this.productMap[id] ?  this.productMap[id] : this.productMapException[id]));
		this.currentProductConfig.groupAccessoryList.forEach(item => item.isShowGroup = false);
		this.currentProductConfig.groupAccessoryList[0].isShowGroup = true;
		this.currentProductConfig.groupAccessoryList[0].isCurrentGroup = true;
		console.log('this.currentProductConfig =>', JSON.parse(JSON.stringify(this.currentProductConfig)));

		this.isOpenConfigKit = true;
	}

	handleClearKitConfiguration(event) {
		const id = event.detail.id;

		this.clearConfig(this.productMap[id] ?  this.productMap[id] : this.productMapException[id]);
	}

	handleSelectProduct(event) {
		const id = event.detail.id; // target.database
		let addProduct = this.productMap[id] ?  this.productMap[id] : this.productMapException[id];

		if (!this.checkProductIsValid(addProduct)) return;

		addProduct.isSelected = true;
		this.checkoutProductMap[id] = { ...addProduct };
	}

	handleRemoveProduct(event) {
		const id = event.detail.id;

		let removeProduct = this.productMap[id] ?  this.productMap[id] : this.productMapException[id];

		if(removeProduct){
			removeProduct.isSelected = false;
			removeProduct.quantity = 1;
			removeProduct.price = removeProduct.listPrice;
		}

		delete this.checkoutProductMap[id];
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
		const structure = event.detail.structure;
		if(structure.Name == "Estrutura Manual"){
			this.onClickNewStructure();
		}else{
			this.handleSelectStructure(structure.Id);
		}

	}
	handleNewStructure() {
		this.clearAll();
	}

	handleFilter(event) {
		const { name, value } = event.target;
		this[name] = value;
	}

	onClickNewStructure() {
		this.handleSearchProductCode();
	}

	handleSearchProductCode() {
		this.clearAll(false);
		this.isShowSearchProduct = true;
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

				getExceptionProducts({ objId: this.quoteId, searchValue: this.productCode, quantity: 30 })
					.then(resolve => {
						this.productMapException = resolve;
						console.log('this.productMap =>', JSON.parse(JSON.stringify(this.productMap)));
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

	onClickSeeMoreExceptionProduct() {
		if (this.productCode > ' ') {
			this.isLoading = true;

			getExceptionProducts({ objId: this.quoteId, searchValue: this.productCode, quantity: (this.products.length + 30) })
				.then(resolve => {
					this.productMapException = resolve;
				})
				.catch(error => {
					console.log('Error Search Product By Code =>', error);
					this.handlerDispatchToast('Falha!', ('Erro inesperado! ' + error), 'error');
				})
				.finally(() => {
					if (this.products.length > 0) this.isShowSeeMoreButton = true;
					this.isLoading = false;
				});
		}
		else {
			this.isShowSeeMoreButton = false;
			this.handlerDispatchToast('Atenção!', 'Pesquise pelo nome do produto!', 'warning');
		}
	}

	onClickAddExceptionAccessoryEvent(event) {
		const id = event.detail.id;

		this.addNewAccessory.productId = id;

		this.isOpenNewAccessoryModal = true;
	}

	clickSelectExceptionAccessoryEvent(event) {
		const id = event.detail.id;
		let addProduct = this.productMapException[id];

		if (!this.checkProductIsValid(addProduct)) return;

		addProduct.discountPercent = 0;
		addProduct.listPrice = addProduct.price;
		addProduct.discountCurrency = 0;
		addProduct.discountType = 'currency';
		addProduct.isSelected = true;
		this.checkoutExceptionProductMap[id] = { ...addProduct };
	}

	onClickRemoveExceptionAccessory(event) {
		const { name, value, id, Product2Id, groupId } = event.detail;

		
		let removeProduct = {};
		let checkoutProduct = this.checkoutProductMap[Product2Id] ?  this.checkoutProductMap[Product2Id] : this.productMap[Product2Id];
		let groupAccessory = checkoutProduct.groupAccessoryList.find(item => item.id === groupId);
		if(groupAccessory){
			groupAccessory.accessoryList.forEach(item => {
				if (item.id === id) {
					removeProduct = item;
					return;
				}
			}, {removeProduct});
		}else{
			removeProduct = checkoutProduct.exceptionAccessoryList.find(item => item.id === id);
		}			
		removeProduct.isSelected = false;
		removeProduct.quantity = 1;
		removeProduct.price = removeProduct.listPrice;

		delete this.checkoutExceptionProductMap[id];
	}

	onClickRemoveExceptionAccessoryCheckout(event) {
		const { id, productId } = event.target.dataset;

		let checkoutProduct = this.checkoutProductMap[productId] ?  this.checkoutProductMap[productId] : this.productMap[productId];
		checkoutProduct.exceptionAccessoryList = checkoutProduct.exceptionAccessoryList.filter(item => item.id !== id);

		if (checkoutProduct.exceptionAccessoryList.length <= 0) {
			checkoutProduct.hasExceptionAccessory = false;
		}
	}

	onClickCancelNewAccessory() {
		this.productCode = '';
		this.addNewAccessory = {};
		this.checkoutExceptionProductMap = {};
		this.currentExceptionEdit = {};
		this.productMapException = {};
		this.isOpenNewAccessoryModal = false;
		this.isOpenEditAccessoryModal = false;
	}

	onClickSaveNewAccessory() {
		if (Object.values(this.checkoutExceptionProductMap).length <= 0) {
			this.handlerDispatchToast('Atenção!', 'Nenhum acessório selecionado!', 'warning');
			return;
		}

		Object.values(this.checkoutExceptionProductMap).forEach(item => {
			let currentProductCheckout = this.checkoutProductMap[this.addNewAccessory.productId];

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

		let checkoutProduct = this.checkoutProductMap[productId] ?  this.checkoutProductMap[productId] : this.productMap[productId];
		let accessory = checkoutProduct.exceptionAccessoryList.find(item => item.id === id);
		accessory.quantity = Number(event.target.value);
		accessory.totalAmount = Number(Number(accessory.quantity * accessory.price).toFixed(2));
	}

	handleClearConfigKit(event) {
		const id = event.target.dataset.id;
		this.clearConfig(this.productMap[id] ?  this.productMap[id] : this.productMapException[id]);
	}

	handleConfigKit(event) {
		const id = event.target.dataset.id;

		this.currentProductConfig = JSON.parse(JSON.stringify(this.productMap[id] ?  this.productMap[id] : this.productMapException[id]));

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

		if (groupAccessory.isRequired && groupAccessory.isListing && selectedLength != groupAccessory.minQuantity) {
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

	handlerSelectAccessory(event) {
		const { id, groupId } = event.target.dataset;

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

		let product = this.productMap[this.currentProductConfig.id] ? this.productMap[this.currentProductConfig.id] : this.productMapException[this.currentProductConfig.id];

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

				if (group.isRequired && group.isListing && selectedLength != group.minQuantity) {
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

		let checkoutProduct = this.checkoutProductMap[productId] ?  this.checkoutProductMap[productId] : this.productMap[productId];
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

		let productData = this.checkoutProductMap[dataset.id];

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
		delete this.checkoutProductMap[id];
	}

	handleremoveexception(event){
		const { id, groupId } = event.detail;
		
		let currentGroup = this.checkoutProductMap[id].exceptionAccessoryList.find(group => group.id === groupId);
		currentGroup.isSelected = false;

	}

	handleeditexception(event){
		const { id, groupId } = event.detail;
		this.currentExceptionEdit = this.checkoutProductMap[id].exceptionAccessoryList.find(group => group.id === groupId);
		this.currentExceptionEdit.Product2Id = id;
		this.currentExceptionEdit.groupId = groupId;
		this.isOpenEditAccessoryModal = true;
	}
	handleChangeAcessory(event){
		const {  name, value, id, groupId, productId } = event.detail;
		
		let checkoutProduct = this.checkoutProductMap[productId] ?  this.checkoutProductMap[productId] : this.productMap[productId];
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

	handleCheckout() {
		this.clearAll(false);
		this.isShowCheckout = true;
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

					this.clearAll();
					this.checkoutProductMap = {};

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
		this.currentStackTraceCode = this.resourceList[0].EstruturaProduto__r.CodigoInterno__c;

		this.resourceList.forEach(resource => {
			resource.ComposicaoProduto__r.forEach(item => {
				if (item.isSelected && item.Sequencial__c) {
					this.currentStackTraceCode += item.Sequencial__c;
				}
			});
		});
	}

	clearAll(isShowStructures = true) {
		this.resourceList = [];
		this.productMap = {};
		this.selectedStructure = {};
		this.addNewAccessory = {};
		this.currentStackTraceCode = '';
		this.productCode = '';

		this.isShowStructures = isShowStructures;
		this.isShowProducts = false;
		this.isShowResources = false;
		this.isShowCheckout = false;
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
