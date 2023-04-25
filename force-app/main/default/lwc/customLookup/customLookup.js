import { LightningElement, api, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/ProductScreenController.getRecords';

export default class CustomLookup extends LightningElement {
  @api standardId;
  @api standardName;
  @api objectApiName;
  @api fieldApiName = '';
  @api objectIconName = '';
  @api inputLabel = '';
  @api recordId;
  @api filter;
  @api customLookupName = '';
  @api searchTerm;
  @api byWhat;
  @api statusOrder;
  @api fieldApiNames;
  @api recordType;
  @api disabledCustomLookup;
  @track changeColorSelectedRecord = 'slds-var-p-vertical_xx-small slds-var-p-horizontal_small selected-record slds-list_horizontal slds-media_center slds-grid_align-spread';

  @api byFocus;
  @track blurTimeout;


  @track searchValue = null;
  @track recordsList = null;
  @track isLoading = false;
  @api selectedRecord;
  @api keys;
  @api orderAttribute;
  @api selectedFamily = false;
  @track recordsPropList = null;
  @track showCustomLookup = true;


  handleOnFocus(event) {
    this.byFocus = true;
    this.isLoading = true
    this.searchValue = '';
    this.handleGetRecords();
  }

  handleOnFocusOut(event) {
    this.blurTimeout = setTimeout(() => { this.recordsList = false }, 300);
  }

  handleTyping(event) {
    const { value } = event.target;
    this.byFocus = false;
    this.searchValue = value;
    this.isLoading = true;

    this.byWhat = false;
    this.handleGetRecords();
  }

  handleGetRecords() {
    getRecords({
      objectApiName: this.objectApiName,
      fieldApiName: this.fieldApiName,
      searchTerm: this.searchValue,
      filter: this.filter, 
      recordId: this.recordId,
      fieldApiNames: this.fieldApiNames,
      byFocus: this.byFocus
    }).then(data => {
        this.recordsList = this.handleData(JSON.parse(JSON.stringify(data)));
        this.isLoading = false;
      })
      .catch(error => {
        console.log('error: ' + JSON.stringify(error));
      });
  }
  handleData(data){
    for(var i=0; i< data.length; i++){
      if(this.objectApiName == 'AccountContactRelation'){
        data[i].Name = data[i].Contact.Name;
        data[i].Email = data[i].Contact.Email;
        data[i].Phone = data[i].Contact.Phone;
        data[i].Id = data[i].ContactId;
      }
      if(this.objectApiName == 'TabelaVendedor__c'){
        data[i].Name = data[i].TabelaPreco__r.Name;
      }
    }
    if(this.objectApiName == 'TabelaVendedor__c' && this.standardId && this.standardName){
      data.push({Id: this.standardId, Name: this.standardName});
    }
    return data;
  }
  handleSelectRecord(event) {
    const { value } = event.target.dataset;
    const record = this.recordsList.find(item => item.Id === value);
    console.log('RECORD:' + JSON.stringify(record));
    this.familyName = record.Name;
    this.selectedRecord = record;

    this.dispatchEvent(new CustomEvent('selectrecord', {detail: {record: this.selectedRecord, attributes: this.orderAttribute, keys: this.keys, name: this.customLookupName}}));
  }

  handleClearSelected() {
    this.selectedRecord = null;
      this.dispatchEvent(
        new CustomEvent('selectrecord', {detail: {
          record: this.selectedRecord, 
          attributes: this.orderAttribute, 
          keys: this.keys,
          name: this.customLookupName}
        }));
  }

  @api
  initialSetup(recordIdInput) {
    this.handleGetRecords();
  }

  @api
  initialSetupOrderEmpty() {
    this.selectedRecord = null;
    this.recordId = null;
    this.initialSetupOrder();
  }
  @api
  initialSetupOrderShipEmpty() {
    this.selectedRecord = null;
  }
}