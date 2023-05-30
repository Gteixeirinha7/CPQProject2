import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class GlobalSearchProductScreen extends LightningElement {
    @api filterList;
    @track showOptions = false;
    @track filterValue;

    get selectedFilter(){
        return this.filterList.find(item => item.selected).value;
    }

    showOptionsCheck(){
        this.showOptions = !this.showOptions;
    }
    selectFilter(event){
        this.showOptionsCheck();
		this.dispatchEvents('selectfilter', {value: event.target.value, filter: this.filterValue});
    }
    handleFilter(event){
        this.filterValue = event.target.value;
		this.dispatchEvents('handlefilter', {filter: this.filterValue});
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