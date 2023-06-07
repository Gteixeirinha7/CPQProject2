import { LightningElement, api } from 'lwc';

export default class ProductComponentAccessory extends LightningElement {
    @api product;
    @api isconfig;

	
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

	onAddException(){
		if(!this.isconfig)
			this.dispatchEvents('clickselectexceptionaccessoryevent', {id : this.product.id});
		else
			this.dispatchEvents('selectconfig', {id : this.product.id, groupId: this.product.groupId,});
	}
	onChangeProductData(event) {
		const { name, value } = event.target;
		if(!this.isconfig)
			this.dispatchEvents('handleproductdata', { name: name, value: value, id: this.product.id, groupId: this.product.groupId, Product2Id : this.product.Product2Id});
		else
			this.dispatchEvents('handleproductdataconfig', { name: name, value: value, id: this.product.id, groupId: this.product.groupId, Product2Id : this.product.Product2Id});
	}
	onRemoveException(){
		if(!this.isconfig)
			this.dispatchEvents('removeexception', {id: this.product.id, groupId: this.product.groupId, Product2Id : this.product.Product2Id});
		else
			this.dispatchEvents('selectconfig', {id : this.product.id, groupId: this.product.groupId,});
	}
	dispatchEvents(evt, details){
		this.dispatchEvent(new CustomEvent(
			evt, { 
                detail: {
                    ...details
                }
            }
		));
	}
}