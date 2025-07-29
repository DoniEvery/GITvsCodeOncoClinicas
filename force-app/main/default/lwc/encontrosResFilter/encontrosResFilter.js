import { api, LightningElement, track, wire } from 'lwc';
import getRes from '@salesforce/apex/ResFilterController.getRes';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = ['Account.Id'];

const COLUMNS = [
	{
		label: 'Início do período',
		fieldName: 'HealthCloudGA__PeriodStart__c',
		initialWidth: 130,
		type: 'date',
		typeAttributes: {
			day: 'numeric',
			month: 'numeric',
			year: 'numeric',
			hour: '2-digit',
			minute: '2-digit'
		}
	},
	{
		label: 'ID do encontro',
		fieldName: 'resUrl',
		type: 'url',
		initialWidth: 130,
		typeAttributes: {
			label: { fieldName: 'Name' },
			target: '_self'
		}
	},
	{ label: 'Sequência Atendimento', initialWidth: 200, fieldName: 'Sequencia_Atendimento__c', type: 'text' },
	{ label: 'Resumo Procedimento II', initialWidth: 200, fieldName: 'Resumo_Procedimento_II__c', type: 'text' },
	{ label: 'Tipo de Rótulo', initialWidth: 130, fieldName: 'HealthCloudGA__TypeLabel__c', type: 'text' },
	{
		label: 'Identificador da Unidade',
		fieldName: 'unidadeUrl',
		initialWidth: 200,
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'unidadeName' },
			target: '_self'
		}	
	},
	{
		label: 'Identificador Médico Referenciador',
		fieldName: 'medicoUrl',
		initialWidth: 200,
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'medicoName' },
			target: '_self'
		}	
	},
	{
		label: 'Identificador Corpo Clínico',
		fieldName: 'corpoClinicoUrl',
		initialWidth: 200,
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'corpoClinicoName' },
			target: '_self'
		}	
	},
	{ label: 'Rótulo de origem de admissão do hospital', initialWidth: 200, fieldName: 'HealthCloudGA__HospitalAdmitSourceLabel__c' },

	{
		label: 'Identificador Convênio',
		fieldName: 'convenioUrl',
		initialWidth: 200,
		type: 'url',
		typeAttributes: {
			label: { fieldName: 'convenioName' },
			target: '_self'
		}	
	},

	{ label: 'Receita Bruta', initialWidth: 130, fieldName: 'Receita_Bruta__c', type: 'currency', cellAttributes: { alignment: 'left' } }
];

export default class EncontrosResFilter extends NavigationMixin(LightningElement) {
	/* -------------------------------------------------------------------------- */
	/*                             PRIVATE ATTRIBUTES                             */
	/* -------------------------------------------------------------------------- */
	timeoutId;
	tableData;
	columns = COLUMNS;
	@track records = [];
	@track recordsOriginal = [];
	@track isLoading = false;

	/* -------------------------------------------------------------------------- */
	/*                              PUBLIC ATTRIBUTES                             */
	/* -------------------------------------------------------------------------- */
	@api recordId;
	@api tamanho = 6;

	/* -------------------------------------------------------------------------- */
	/*                              WIRED ATTRIBUTES                              */
	/* -------------------------------------------------------------------------- */

	@wire(getRecord, { recordId: '$recordId', fields: FIELDS }) 
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }

            console.error(message);
        } else if (data) {
            this.fetchControllerData();
        }
    }

	/* -------------------------------------------------------------------------- */
	/*                              LIFECYCLE METHODS                             */
	/* -------------------------------------------------------------------------- */

	connectedCallback() {
		this.fetchControllerData();
	}

	/* -------------------------------------------------------------------------- */
	/*                                  HANDLERS                                  */
	/* -------------------------------------------------------------------------- */

	fetchControllerData() {
		this.isLoading = true;
		getRes({ recordId: this.recordId })
			.then((result) => {
				if (result && result.length > 0) {
					this.recordsOriginal = result;
					let tableResult = [];
					let listSize = result.length > this.tamanho ? this.tamanho : result.length;
                    
					for (let i = 0; i < listSize; i++) {
                        
						tableResult.push({
							...result[i],
							resUrl: '/' + result[i].Id,
							medicoName: result[i].Identificador_Medico_Ref_Contact__r
								? `${result[i].Identificador_Medico_Ref_Contact__r.FirstName} ${result[i].Identificador_Medico_Ref_Contact__r.LastName}`
								: null,
							medicoUrl: result[i].Identificador_Medico_Ref_Contact__r ? '/' + result[i].Identificador_Medico_Ref_Contact__r.Id : null,

							corpoClinicoName: result[i].Identificador_Corpo_Clinico_Contact__r
								? `${result[i].Identificador_Corpo_Clinico_Contact__r.FirstName} ${result[i].Identificador_Corpo_Clinico_Contact__r.LastName}`
								: null,
							corpoClinicoUrl: result[i].Identificador_Corpo_Clinico_Contact__r ? '/' + result[i].Identificador_Corpo_Clinico_Contact__r.Id : null,

							convenioName: result[i].Identificador_Convenio_Account__r ? `${result[i].Identificador_Convenio_Account__r.Name}` : null,
							convenioUrl: result[i].Identificador_Convenio_Account__r ? '/' + result[i].Identificador_Convenio_Account__r.Id : null,

							unidadeName: result[i].Identificador_Unidade_Account__r ? `${result[i].Identificador_Unidade_Account__r.Name}` : null,
							unidadeUrl: result[i].Identificador_Unidade_Account__r ? '/' + result[i].Identificador_Unidade_Account__r.Id : null
						});
					}

					this.tableData = tableResult.filter((record) => {
						return JSON.stringify(record).toLocaleLowerCase();
					});
					this.records = tableResult.filter((record) => {
						return JSON.stringify(record).toLocaleLowerCase();
					});
				}
			})
			.catch((error) => {
				console.error(error);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;

		switch (actionName) {
			case 'excluir':
				this.deleteRow(row);
				break;
			default:
		}
	}

	// navigateToContactRelatedList() {
	// 	this[NavigationMixin.Navigate]({
	// 		type: 'standard__recordRelationshipPage',
	// 		attributes: {
	// 			recordId: this.recordId,
	// 			objectApiName: 'Account',
	// 			relationshipApiName: 'HealthCloudGA__Encounters__r',
	// 			actionName: 'view'
	// 		}
	// 	});
	// }

	get hasTooManyRows() {
		return this.records && this.records.length > 0 && this.recordsOriginal.length > this.tamanho;
	}
	get hasTooManyRowsHeight() {
		return this.records && this.records.length > 10;
	}
}