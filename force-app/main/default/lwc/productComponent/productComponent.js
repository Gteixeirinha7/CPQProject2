import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductComponent extends LightningElement {
	@api
	product = {};
	@api enableCreateAccessory;

	get sizeAcessory(){
		return this.product.isConfigured ? 8 : 0;
	}
	get sizeDescription(){
		return this.product.isConfigured ? 4 : 12;
	}

	get showNewAccessory(){
		return this.product.isSelected && this.enableCreateAccessory && !this.product.isSingleItem;
	}

	get subTotalProduct(){
		let val =  (this.product.price * this.product.quantity);
		this.product.groupAccessoryList.filter(item => item.isListing).forEach(function(item){
			item.accessoryList.filter(itemAcessory => itemAcessory.isSelected).forEach(function(ItemVal){
				val += (ItemVal.quantity * ItemVal.price);
			}, {val})
		}, {val});
		this.product.exceptionAccessoryList.filter(item => item.isSelected).forEach(function(item){
			val += (item.quantity * item.price);
		}, {val});
		return val;
	}

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

	handlechangeacessory(event) {
		this.dispatchEvents('handlechangeacessory', { ...event.detail});
	}
	handleeditexception(){
		this.dispatchEvents('handleeditexception', { ...event.detail});
	}
	handleremoveexception(){
		this.dispatchEvents('handleremoveexception', { ...event.detail});
	}
	onhandleremovecheckoutacessory(event){
		this.dispatchEvents('handleremovecheckoutacessory', {...event.detail});
	}
	onClickCreateAcessory(event){
		this.dispatchEvents('addexceptionaccessory', { id: this.product.id});
	}

	onChangeProductData(event) {
		const { name, value } = event.target;
		this.dispatchEvents('handleproductdata', { name: name, value: value, id: this.product.id});
	}

	onClickConfigureKit() {
		this.dispatchEvents('handleconfigkit', { id: this.product.id});
	}

	onClickClearKitConfiguration() {
		this.dispatchEvents('handleclearconfigkit', { id: this.product.id});
	}

	onClickSelectProduct() {
		this.handlerDispatchToast('Sucesso', 'Produto adicionado no carrinho com sucesso', 'success');
		this.dispatchEvents('handleselectproduct', { id: this.product.id});
	}

	onClickRemoveProduct() {
		this.dispatchEvents('handleremoveproduct', { id: this.product.id});
	}

	dispatchEvents(evt, details){
		this.dispatchEvent(new CustomEvent(
			evt, { detail: details }
		));
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