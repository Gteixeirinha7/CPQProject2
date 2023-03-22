import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class ResourceComponent extends LightningElement {
	@api
	resourceList = [];
	@api
	currentResourceActiveted = {};
	@api
	activatedResourceIndex;

	@api
	selectedStructure;

	get selectedResourceList() {
		let selectedResourceList = [];

		this.resourceList.forEach(resource => {
			resource.ComposicaoProduto__r.forEach(item => {
				if (item.isSelected) {
					selectedResourceList.push(item);
				}
			});
		});

		return selectedResourceList;
	}
	
	onClickChooseResource(event) {
		const index = event.target.dataset.index;

		if (this.activatedResourceIndex == index) return;
		else if (this.resourceList[index].isResourceDisabled) {
			this.handlerDispatchToast('Atenção!', 'Preencha os recursos anteriores.', 'warning');
			return;
		}

		let oldSelectedResourceId = this.currentResourceActiveted.Id;

		this.activatedResourceIndex = String(index);
		this.currentResourceActiveted = this.resourceList[index];

		this.dispatchEvent(new CustomEvent(
			'chooseresource',
			{
				detail: {
					resourceId: this.resourceList[index].Id,
					currentResourceId: oldSelectedResourceId
				}
			}
		));
	}

	async onClickChooseResourceType(event) {
		const index = event.target.dataset.index;

		let hasResourceTypeSelected = this.currentResourceActiveted.ComposicaoProduto__r.filter(item => item.isSelected).length > 0;

		if (hasResourceTypeSelected) {
			const result = await LightningConfirm.open({
				message: 'Alterar o tipo de recurso irá remover todos posterior já selecionados, se houver.',
				label: 'Atenção!',
				theme: 'warning'
			});

			if (!result) return;
		}

		this.dispatchEvent(new CustomEvent(
			'choosetyperesource',
			{
				detail: {
					resourceId: this.currentResourceActiveted.Id,
					typeResourceId: this.currentResourceActiveted.ComposicaoProduto__r[index].Id,
					hasResourceTypeSelected: hasResourceTypeSelected
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