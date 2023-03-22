import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class StructureComponent extends LightningElement {
    @api disabledClick = false;
    @api structure;
    
    handleSelectStructure(){
        if(this.disabledClick) return;

		this.dispatchEvent(new CustomEvent(
			'handlestructure',
			{
				detail: { structure: this.structure }
			}
		));

    }
}