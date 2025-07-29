import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDadosEncontrosByPeriodo from '@salesforce/apex/TotalizadorEncontrosController.getDadosEncontrosByPeriodo';

export default class TotalizadorEncontros extends NavigationMixin(LightningElement) {
	/* -------------------------------------------------------------------------- */
	/*                              PUBLIC ATTRIBUTES                             */
	/* -------------------------------------------------------------------------- */
	@api prop1;
	@api recordId;
	@api perfisBloqueadosValor = '';

	/* -------------------------------------------------------------------------- */
	/*                             PRIVATE ATTRIBUTES                             */
	/* -------------------------------------------------------------------------- */
	@track isLoading = false;
	@track hasTooManyRows = false;
	@track dataInicial;
	@track dataFinal;
	@track dados = {};
	@track setDateMin;
	@track setDateMax;

	/* -------------------------------------------------------------------------- */
	/*                              LIFECYCLE METHODS                             */
	/* -------------------------------------------------------------------------- */

	connectedCallback() {
		this.setDate();
		this.getDadosEncontrosByPeriodo();
	}

	/* -------------------------------------------------------------------------- */
	/*                                   ACTIONS                                  */
	/* -------------------------------------------------------------------------- */
	setDate() {
		let hoje = new Date();
		this.dataInicial = new Date(hoje.getFullYear() - 1, hoje.getMonth(), hoje.getDate()).toISOString();
		this.dataFinal = hoje.toISOString();

		this.setDateMin = new Date(hoje.getFullYear() -2, hoje.getMonth(), hoje.getDate()).toISOString();
		this.setDateMax = new Date(hoje.getFullYear() +3, hoje.getMonth(), hoje.getDate()).toISOString();
	}

	toggleSectionClass(event) {
		event.target.closest('.slds-section').classList.toggle('slds-is-open');
	}

	getBeginMonthDate() {
		let data = new Date();
		return new Date(data.getFullYear(), data.getMonth(), 1).toISOString();
	}

	handleDataInicialChange(event) {
		this.dataInicial = event.target.value;

		this.getDadosEncontrosByPeriodo();
	}

	handleDataFinalChange(event) {
		this.dataFinal = event.target.value;

		this.getDadosEncontrosByPeriodo();
	}

	getDadosEncontrosByPeriodo() {
		this.isLoading = true;
		this.dados = {};

		getDadosEncontrosByPeriodo({
			medicoId: this.recordId,
			dataInicial: this.dataInicial,
			dataFinal: this.dataFinal,
			blockedProfiles: [...this.perfisBloqueadosValor.split(',')]?.map((item) => item.trim())
		})
			.then((result) => {
				this.dados = result;

                this.hasTooManyRows = this.dados.nEncontros >=49999;
			})
			.catch((error) => {
				if (error?.body?.message) {
					this.showToast('Erro!', error.body.message, 'error', 'pester');
				}

				console.error(error);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	getFormattedDate(data) {
		return new Date(data).toLocaleDateString('pt-BR', { timeZone: 'UTC' });
	}

	goToUnidade() {
		// View a custom object record.
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.dados.unidadePrincipal.Id,
				actionName: 'view'
			}
		});
	}

	showToast(title, message, type, mode) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: type,
				mode: mode
			})
		);
	}

	/* -------------------------------------------------------------------------- */
	/*                                   GETTERS                                  */
	/* -------------------------------------------------------------------------- */

	get secaoRefPeriodo() {
		return this.dataInicial && this.dataFinal
			? `Grandes Números - Referenciador (${this.getFormattedDate(this.dataInicial)} - ${this.getFormattedDate(this.dataFinal)})`
			: 'Grandes Números - Referenciador';
	}

	get secaoCCPeriodo() {
		return this.dataInicial && this.dataFinal
			? `Grandes Números - Corpo Clínico (${this.getFormattedDate(this.dataInicial)} - ${this.getFormattedDate(this.dataFinal)})`
			: 'Grandes Números - Corpo Clínico';
	}

	get secaoUnidadePrincipal() {
		return this.dataInicial && this.dataFinal
			? `Unidade Principal (${this.getFormattedDate(this.dataInicial)} - ${this.getFormattedDate(this.dataFinal)})`
			: 'Unidade Principal';
	}

	get maxDate() {
		return new Date().toISOString();
	}
}