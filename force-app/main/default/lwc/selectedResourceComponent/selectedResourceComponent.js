import { LightningElement, api } from 'lwc';

export default class SelectedResourceComponent extends LightningElement {
    @api title;
    @api subs;
    @api key;
}