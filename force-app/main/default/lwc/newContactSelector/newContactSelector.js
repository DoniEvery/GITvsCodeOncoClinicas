import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CONTACT_OBJ from '@salesforce/schema/Contact';
import getMedico from '@salesforce/apex/NewContactSelectorController.getMedico';
import getNewMedicoCfm from '@salesforce/apex/NewContactSelectorController.getNewMedicoCfm';
import saveMedico from '@salesforce/apex/NewContactSelectorController.saveMedico';

export default class NewContactSelector extends NavigationMixin(LightningElement) {
	/* -------------------------------------------------------------------------- */
	/*                                WIRED METHODS                               */
	/* -------------------------------------------------------------------------- */

	@wire(getObjectInfo, { objectApiName: CONTACT_OBJ })
	getRtypeBeneficiarios({ error, data }) {
		this.tiposRegistrosContato = [];

		if (data && data.recordTypeInfos) { 
			let rtypesArr = this.toArray(data.recordTypeInfos).filter((rtype) => rtype.available === true);

			if (rtypesArr.length > 1) {
				rtypesArr = rtypesArr.filter((rtype) => rtype.master === false);
			}

			this.tiposRegistrosContato = rtypesArr.map((rtype) => {
				return { label: rtype.name, value: rtype.recordTypeId };
			}); 
		} else if (error) {
			console.error(error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao buscar os tipos de registro.',
                    variant: 'error',
                    mode: 'pester'
                })
            );
		}
	}

	toArray(obj_obj) {
		return Object.keys(obj_obj).map((i) => obj_obj[i]);
	}

	/* -------------------------------------------------------------------------- */
	/*                             PRIVATE ATTRIBUTES                             */
	/* -------------------------------------------------------------------------- */

	@track tiposRegistrosContato = [];
	@track tipoRegistroSelecionado;
	@track disablebtn = false;
	@track showConsultaCRMForm = false;
	@track novoMedicoEncontrado;
	@track isLoadingBuscaMedico = false;
	@track isSavingMedico = false;
	@track crmMedico;
	@track ufCrmMedico;

	handleTipoRegistroChange(event) {
		this.tipoRegistroSelecionado = event.target.value;
	}

	handleAvancar() {
		let tipoRegistroSelecionadoFull = this.tiposRegistrosContato.find((tipoReg) => tipoReg.value === this.tipoRegistroSelecionado); 
        
		if (tipoRegistroSelecionadoFull.label === 'Medico') {
			// continua
			this.showConsultaCRMForm = true;
		} else {
			//abre record page
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'Contact',
					actionName: 'new'
				},
				state: {
					nooverride: '1',
					recordTypeId: tipoRegistroSelecionadoFull.value
				}
			});
		}
	}

	async handleSearchMedico() {
		this.novoMedicoEncontrado = null;

		if (this.isFormValid()) {
			this.isLoadingBuscaMedico = true;

			try {
				let medicoEncontrado = await getMedico({ crm: this.crmMedico, ufCrm: this.ufCrmMedico });

				if (!medicoEncontrado) {
					this.novoMedicoEncontrado = await getNewMedicoCfm({ crm: this.crmMedico, ufCrm: this.ufCrmMedico });
				} else {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: medicoEncontrado.Id,
							actionName: 'view'
						}
					});

					this.reset();
				}
			} catch (error) {
				let errorMessage = error?.body?.message || 'Erro ao processar a requisição.';

				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Erro',
						message: errorMessage,
						variant: 'error',
						mode: 'pester'
					})
				);

				console.error(error);
			} finally {
				this.isLoadingBuscaMedico = false;
			}
		}
	}

	handleSalvarMedico() {
		if (this.novoMedicoEncontrado) {
			this.isSavingMedico = true;
			saveMedico({ medico: this.novoMedicoEncontrado })
				.then((medicoId) => {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: medicoId,
							actionName: 'view'
						}
					});
				})
				.catch((error) => {
					let errorMessage = error?.body?.message || 'Erro ao processar a requisição.';

					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Erro',
							message: errorMessage,
							variant: 'error',
							mode: 'pester'
						})
					);

					console.error(error);
				})
				.finally(() => {
					this.isSavingMedico = false;
				});
		}
	}

	isFormValid() {
		let isLightningInputsOK = true;
		let isLightningInputFieldsOK = true;

		if (!this.getAndReportValidityFrom('lightning-input, lightning-combobox, lightning-radio-group')) {
			isLightningInputsOK = false;
		}

		this.template.querySelectorAll('lightning-input-field').forEach((inputField) => {
			if (inputField.required && !inputField.value) {
				inputField.reportValidity();
				isLightningInputFieldsOK = false;
			}
		});

		return isLightningInputsOK && isLightningInputFieldsOK;
	}

	getAndReportValidityFrom(selector) {
		return [...this.template.querySelectorAll(selector)].reduce((validSoFar, inputField) => {
			inputField.reportValidity();
			return validSoFar && inputField.checkValidity();
		}, true);
	}

	handleCancelar() {

        this.dispatchEvent(new CustomEvent('close'));
        
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'Contact',
				actionName: 'list'
			},
			state: {
				filterName: 'Recent'
			}
		});
	}

	handleInputChange(event) {
		this.novoMedicoEncontrado = null;

		switch (event.target.name) {
			case 'crmMedico':
				this.crmMedico = event.target.value;
				break;
			case 'ufCrmMedico':
				this.ufCrmMedico = event.target.value;
				break;
			default:
				break;
		}
	}

	connectedCallback() {
		this.reset();
	}

	@api
	reset() {
		this.tipoRegistroSelecionado = null;
		this.showConsultaCRMForm = false;
		this.isLoadingBuscaMedico = true;
		this.novoMedicoEncontrado = null;
		this.crmMedico = null;
		this.ufCrmMedico = null;
	}

	onloadCrmForm() {
		this.isLoadingBuscaMedico = false;
	}
}