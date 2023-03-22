import { LightningElement, api } from 'lwc';

export default class SelectedResourceComponent extends LightningElement {
    @api item;
    @api key;
}