import { LightningElement, api } from 'lwc';

export default class MultiModalTemplate extends LightningElement {
	/********************************************** 
            PROPRIEDADES PUBLICAS
    ***********************************************/
	@api title = '';
	@api isCard = false;
	@api backOnClose = false;
	@api disableOverflow = false;
	@api disableOverrideModal = false;
	@api notHasBody = false;
	@api heightBody = '';

	/********************************************** 
                 PROPRIEDADES INDEFINIDAS
    ***********************************************/
	get bodyModalClasses() {
		return 'slds-modal__content slds-p-around_medium ' + (this.disableOverflow ? 'disableOverflow' : '');
	}

	get modalClasses() {
		return 'slds-modal__container ' + (!this.disableOverrideModal ? 'allowOverrideModal' : '');
	}

	get getHeightBody() {
		return this.heightBody != '' ? 'height: ' + this.heightBody + ';' : '';
	}

	get getTitle(){
		return this.title != '';
	}

	connectedCallback() {  
	}

	/********************************************** 
                 EVENTOS
    ***********************************************/
	doClose() {
		console.log('=doClose=');
		this.dispatchEvent(new CustomEvent('close', {}));
		console.log(this.backOnClose);
		if (this.backOnClose === true) {
			window.history.go(-1);
		}
	}
}