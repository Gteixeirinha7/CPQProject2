import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import getURL from '@salesforce/apex/OpenQuotePDFController.getURL';

export default class OpenQuotePDF extends NavigationMixin(LightningElement) {
	@api
	recordId;

	@api
	invoke() {
		console.log('this.recordId =>', this.recordId);
		getURL({ quoteId: this.recordId })
			.then(resolve => {
				if (resolve) {
					this[NavigationMixin.GenerateUrl]({
						type: 'standard__webPage',
						attributes: {
							url: resolve
						}
					}).then(generatedUrl => {
						window.open(generatedUrl, '_blank');
					});
				}
				else {
					this.handleDispatchToast('Falha!', 'Falha ao gerar o PDF.', 'error');
				}
			})
			.catch(error => {
				console.log('Error Generate PDF Url =>', error);
				this.handleDispatchToast('Falha!', 'Falha ao gerar o PDF.', 'error');
			})
			.finally(() => {
				this.dispatchEvent(new CloseActionScreenEvent());
			});
	}

	handleDispatchToast(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}
}