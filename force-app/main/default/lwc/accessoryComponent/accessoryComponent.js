import { LightningElement, api } from 'lwc';

export default class AccessoryComponent extends LightningElement {
    @api accessory;
    @api product;
    @api group;

	get sizeText(){
		return this.group.isRequired ? 12 : 10;
	}
	get sizeButton(){
		return this.group.isRequired ? 0 : 2;
	}

	onRemoveAcessory(){
		this.dispatchEvents('handlechangeacessory', {name: 'isSelected', value: false});
	}
	onEditException(){
		this.dispatchEvents('handlechangeacessory', {name: 'isEdit', value: false});
	}
	dispatchEvents(evt, details){
		this.dispatchEvent(new CustomEvent(
			evt, { 
                detail: {
                    id : this.accessory.id, groupId : this.group.id, productId : this.product.id,
                    ...details
                }
            }
		));
	}

}