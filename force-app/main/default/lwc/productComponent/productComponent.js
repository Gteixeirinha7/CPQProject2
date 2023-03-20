import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductComponent extends LightningElement {
	@api
	product = {};

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

	onChangeProductData(event) {
		const { name, value } = event.target;

		this.dispatchEvent(new CustomEvent(
			'handleproductdata',
			{
				detail: {
					name: name,
					value: value,
					id: this.product.id
				}
			}
		));
	}

	onClickConfigureKit() {
		this.dispatchEvent(new CustomEvent(
			'handleconfigkit',
			{
				detail: {
					id: this.product.id
				}
			}
		));
	}

	onClickClearKitConfiguration() {
		this.dispatchEvent(new CustomEvent(
			'handleclearconfigkit',
			{
				detail: {
					id: this.product.id
				}
			}
		));
	}

	onClickSelectProduct() {
		this.dispatchEvent(new CustomEvent(
			'handleselectproduct',
			{
				detail: {
					id: this.product.id
				}
			}
		));
	}

	onClickRemoveProduct() {
		this.dispatchEvent(new CustomEvent(
			'handleremoveproduct',
			{
				detail: {
					id: this.product.id
				}
			}
		));
	}

	handlerDispatchToast(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}
}
