import { LightningElement, api } from 'lwc';

export default class ProductComponentAccessory extends LightningElement {
    @api product;

	
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
		this.dispatchEvents('clickselectexceptionaccessoryevent', {id : this.product.id});
	}
	onChangeProductData(event) {
		const { name, value } = event.target;
		this.dispatchEvents('handleproductdata', { name: name, value: value, id: this.product.id, groupId: this.product.groupId, Product2Id : this.product.Product2Id});
	}
	onRemoveException(){
		this.dispatchEvents('removeexception', {id: this.product.id, groupId: this.product.groupId, Product2Id : this.product.Product2Id});
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