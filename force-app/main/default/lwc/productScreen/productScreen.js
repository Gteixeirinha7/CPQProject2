import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getStructures from '@salesforce/apex/ProductScreenController.getStructures';
import getResources from '@salesforce/apex/ProductScreenController.getResources';
import getProducts from '@salesforce/apex/ProductScreenController.getProducts';
import saveQuoteLineItems from '@salesforce/apex/ProductScreenController.saveQuoteLineItems';
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
	currentProductConfig = {};

	structureMap = {};
	delayProductCode = {};

	quoteId = '';
	productCode = '';
	grouper = '';
	structureName = '';
	currentStackTraceCode = '';

	isLoading = true;
	isLoadingModal = false;
	isShowStructures = true;
	isShowProducts = false;
	isShowResources = false;
	isShowCheckout = false;
	isShowSearchProduct = false;
	isOpenConfigKit = false;

	currentPageReference;
	discountTypeOptionList = [
		{
			label: 'Moeda (R$)',
			value: 'currency'
		},
		{
			label: 'Porcentagem (%)',
			value: 'percent'
		}
	];

	get structures() {
		if (!this.grouper && !this.structureName) return Object.values(this.structureMap);

		return Object.values(this.structureMap).filter(item => (
			this.grouper ? item.Agrupador__c.toLocaleLowerCase().includes(this.grouper.toLocaleLowerCase()) : true ||
			this.structureName ? item.Name.toLocaleLowerCase().includes(this.structureName.toLocaleLowerCase()) : true
		));
	}

	get products() {
		return Object.values(this.productMap);
	}

	get checkoutProducts() {
		return Object.values(this.checkoutProductMap);
	}

	@wire(CurrentPageReference)
	async setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		const { state } = currentPageReference;

		this.clearAll();
		this.checkoutProductMap = {};

		if (state) {
			this.quoteId = state.c__quoteId;
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
			.finally(() => this.isLoading = false);
	}

	async handleSelectStructure(event) {
		const id = event.target.dataset.id;

		this.isLoading = true;

		this.resourceList = await getResources({ structureId: id });

		let errorMessage = this.checkResources();
		if (errorMessage) {
			this.resourceList = [];

			this.handlerDispatchToast('Atenção!', 'Nenhum os recursos desta estrutura não estão completos.', 'warning');

			this.isLoading = false;
			return;
		}

		this.resourceList[0].isShowResource = true;
		this.resourceList[0].ComposicaoProduto__r.forEach(item => item.isShowType = true);

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

	async handleTypeResource(event) {
		this.isLoading = true;

		const checked = event.target.checked;
		const { id, index, resourceIndex } = event.target.dataset;
		const nextResourceIndex = Number(resourceIndex) + 1;

		this.clearAllNextTypes(Number(resourceIndex), id);

		this.resourceList[resourceIndex].ComposicaoProduto__r[index].isChecked = checked;

		this.fillStackTraceCode();

		if (nextResourceIndex < this.resourceList.length) {
			const externalIdList = await checkNextTypeResources({
				structureId: this.selectedStructure.Id,
				currentExternalId: this.currentStackTraceCode,
				index: nextResourceIndex
			});

			this.resourceList[nextResourceIndex].isShowResource = true;
			this.resourceList[nextResourceIndex].ComposicaoProduto__r.forEach(item => {
				if (externalIdList.includes(item.ExternalId__c)) {
					item.isShowType = true;
				}
			});
		}

		this.isLoading = false;
	}

	handleProductData(event) {
		const { name, value, dataset } = event.target;

		let productData = this.productMap[dataset.id];

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
			productData.discountPercent = Number((productData.discountCurrency / productData.listPrice).toFixed(2));
		}
		else if (name === 'discountCurrency') {
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
			productData.discountPercent = Number((productData.discountCurrency / productData.listPrice).toFixed(2));
		}
		else if (name === 'discountPercent') {
			productData.discountCurrency = Number(((productData.discountPercent / 100) * productData.listPrice).toFixed(2));
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
		}

		productData.totalPrice = Number((productData.price * productData.quantity).toFixed(2));
	}

	handleNewStructure() {
		this.clearAll();
	}

	handleFilter(event) {
		const { name, value } = event.target;
		this[name] = value;
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

				getProducts({ quoteId: this.quoteId, structureId: null, productCode: this.productCode })
					.then(resolve => {
						this.productMap = resolve;
					})
					.catch(error => {
						console.log('Error Search Product By Code =>', error);
						this.handlerDispatchToast('Falha!', ('Erro inesperado! ' + error), 'error');
					})
					.finally(() => this.isLoading = false);
			}, 1500);
		}
		else this.productCodeLoading = false;
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
						item.totalAmount = Number(Number(item.unitPrice * item.quantity).toFixed(2));
					}
				});
			}
		});
		product.isConfigured = true;
		product.isDisabledButtons = false;

		this.isLoadingModal = false;

		this.handleCloseConfigKit();
	}

	handleCloseConfigKit() {
		this.currentProductConfig = {};

		this.isOpenConfigKit = false;
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

	handleSelectProduct(event) {
		const id = event.target.dataset.id;
		let addProduct = this.productMap[id];

		if (!addProduct.quantity || addProduct.quantity <= 0) {
			this.handlerDispatchToast('Atenção!', 'Quantidade inválida', 'warning');
			return;
		}
		else if (!addProduct.price || addProduct.price <= 0) {
			this.handlerDispatchToast('Atenção!', 'Preço inválido', 'warning');
			return;
		}
		else if ((!addProduct.discountCurrency && addProduct.discountCurrency != 0) || addProduct.discountCurrency > addProduct.listPrice) {
			this.handlerDispatchToast('Atenção!', 'Desconto inválido', 'warning');
			return;
		}
		else if ((!addProduct.discountPercent && addProduct.discountPercent != 0) || addProduct.discountPercent > 100) {
			this.handlerDispatchToast('Atenção!', 'Porcetagem do desconto inválido', 'warning');
			return;
		}

		addProduct.isSelected = true;
		this.checkoutProductMap[id] = { ...addProduct };
	}

	handleRemoveProduct(event) {
		const id = event.target.dataset.id;
		let removeProduct = this.productMap[id];

		removeProduct.isSelected = false;
		removeProduct.quantity = 1;
		removeProduct.price = removeProduct.listPrice;

		delete this.checkoutProductMap[id];
	}

	handleCheckoutProductData(event) {
		const { name, value, dataset } = event.target;

		let productData = this.checkoutProductMap[dataset.id];

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
			productData.discountPercent = Number((productData.discountCurrency / productData.listPrice).toFixed(2));
		}
		else if (name === 'discountCurrency') {
			productData.price = Number((productData.listPrice - productData.discountCurrency).toFixed(2));
			productData.discountPercent = Number((productData.discountCurrency / productData.listPrice).toFixed(2));
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

	handleGroupValues(event) {
		const { name, value, dataset } = event.target;
		const { id, groupId, productId } = dataset;

		let currentGroup = this.checkoutProductMap[productId].groupAccessoryList.find(group => group.id === groupId);
		let currentAccessory = currentGroup.accessoryList.find(item => item.id === id);
		currentAccessory[name] = value;

		if (name === 'quantity') {
			currentAccessory.totalAmount = Number(Number(currentAccessory.quantity * currentAccessory.unitPrice).toFixed(2));
		}
	}

	handleCheckout() {
		this.clearAll(false);
		this.isShowCheckout = true;
	}

	async handleSearchProduct() {
		this.isLoading = true;

		if (!this.currentStackTraceCode) {
			this.handlerDispatchToast('Atenção!', 'Não é possível buscar produtos sem nenhuma estrutura.', 'warning');
			this.isLoading = false;
			return;
		}

		this.productMap = await getProducts({
			quoteId: this.quoteId,
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

	checkProducts() {
		let errorMessage = '';

		this.checkoutProducts.forEach(item => {
			if (item.quantity <= 0) {
				errorMessage = 'Quantidade inválida para o item ' + item.name;
			}
			else if (item.price <= 0 || item.price > item.listPrice) {
				errorMessage = 'Valor inválido para o item ' + item.name;
			}
		});

		return errorMessage;
	}

	handleSaveProducts() {
		this.isLoading = true;

		let errorMessage = this.checkProducts();
		if (errorMessage) {
			this.handlerDispatchToast('Atenção!', errorMessage, 'warning');
			this.isLoading = false;
			return;
		}

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

		saveQuoteLineItems({ quoteId: this.quoteId, quoteItemList: this.checkoutProducts })
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

	clearAllNextTypes(resourceIndex, id) {
		for (let i = resourceIndex + 1; i < this.resourceList.length; i++) {
			this.resourceList[i].ComposicaoProduto__r.forEach(item => {
				item.isChecked = false;
				item.isShowType = false;
			});
			this.resourceList[i].isShowResource = false;
		}

		this.resourceList[resourceIndex].ComposicaoProduto__r.forEach(item => {
			item.isChecked = false;

			if (item.isShowType && item.Id != id) {
				this.template.querySelector('[data-id="' + item.Id + '"]').checked = false;
			}
		});
	}

	fillStackTraceCode() {
		this.currentStackTraceCode = '';

		this.resourceList.forEach(resource => {
			resource.ComposicaoProduto__r.forEach(item => {
				if (item.isChecked) {
					this.currentStackTraceCode += item.ExternalId__c;
				}
			});
		});
	}

	clearAll(isShowStructures = true) {
		this.resourceList = [];
		this.productMap = {};
		this.selectedStructure = {};
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