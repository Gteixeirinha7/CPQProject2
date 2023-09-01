import { LightningElement, api } from 'lwc';

export default class ProductComponentAccessoryCombo extends LightningElement {
    @api combo;
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
		var groupId;
		this.combo.accessoryList.forEach(item => {
			groupId = item.groupId;
			this.onAddExceptionSingle(item.id, item.groupId);
		});
		this.dispatchEvents('showcombo', {id : this.combo.id, groupId: groupId});
	}
	onRemoveException(){
		var groupId;
		this.combo.accessoryList.forEach(item => {
			groupId = item.groupId;
			this.onRemoveExceptionSingle(item.id, item.groupId, item.Product2Id);
		});
		this.dispatchEvents('showcombo', {id : this.combo.id, groupId: groupId});
	}
	onAddExceptionSingle(prodId, groupId){
		if(!this.isconfig)
			this.dispatchEvents('clickselectexceptionaccessoryevent', {id : prodId});
		else
			this.dispatchEvents('selectconfig', {id : prodId, groupId: groupId});
	}
	onRemoveExceptionSingle(prodId, groupId, prodsId){
		if(!this.isconfig)
			this.dispatchEvents('removeexception', {id: prodId, groupId: groupId, Product2Id : prodsId});
		else
			this.dispatchEvents('selectconfig', {id : prodId, groupId: groupId});
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