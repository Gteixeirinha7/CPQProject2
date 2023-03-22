import { LightningElement, api } from 'lwc';

export default class SelectedStructureComponent extends LightningElement {
    @api selectedStructure;
    @api selectedResourceList;

    get hasSelectedResourceList(){
        return this.selectedResourceList.length > 0;
    }
}