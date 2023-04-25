import { LightningElement, api } from 'lwc';

export default class AccessoryListComponent extends LightningElement {
    @api product

    get showIncluded(){
        return this.product.groupAccessoryList?.find(item => !item.isListing) ? true : false;
    }
    get showRequired(){
        return this.product.groupAccessoryList?.filter(item => item.isRequired && item.isListing)?.find(item => item.isSelected) ? true : false;
    }
    get showOptional(){
        return this.product.groupAccessoryList?.filter(item => !item.isRequired && item.isListing)?.find(item => item.isSelected) ? true : false;
    }
    get showException(){
        return this.product.exceptionAccessoryList.length > 0;
    }

    handlechangeacessory(event){
        this.dispatchEvents('handlechangeacessory', event.detail);
    }
    onRemoveException(event){
        this.dispatchEvents('handleremoveexception', {id: this.product.id, groupId: event.target.dataset.id});
    }
    onEditException(event){
        this.dispatchEvents('handleeditexception', {id: this.product.id, groupId: event.target.dataset.id});
    }
	dispatchEvents(evt, details){
		this.dispatchEvent(new CustomEvent(
			evt, { 
                detail: details
            }
		));
	}
}