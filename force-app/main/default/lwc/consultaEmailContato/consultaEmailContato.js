import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

import buscaEmailsMkt from '@salesforce/apex/ConsultaEmailContatoController.buscaEmailsMkt';

const columns = [ 
    { label: 'Nome do e-mail', fieldName: 'Nome Email', type: 'text', sortable: false },
    { label: 'Assunto', fieldName: 'Assunto', type: 'text', sortable: false },
    { label: 'Campanha', fieldName: 'Nome Jornada', type: 'text', sortable: false },
    { label: 'Data envio', fieldName: 'Data Envio', type: 'text', sortable: false },
    { label: 'Se aberto', fieldName: 'Abertura', type: 'text', sortable: false },
    { label: 'Se clicou', fieldName: 'Clique', type: 'text', sortable: false }
];

export default class ConsultaEmailContato extends LightningElement {

    @api recordId;
    @track columns = columns; 
    @track infoTabela = [{ results: [], size: -1 }];
    filterDataInicial;
    filterDataFinal;
    isLoading = false;

    /* -------------------------------------------------------------------------- */
    /*                               LIFECYCLE HOOKS                              */
    /* -------------------------------------------------------------------------- */
    
    connectedCallback(){
        this.getStateParameters();   
    }

    /* -------------------------------------------------------------------------- */
    /*                               METHOD HANDLER                               */
    /* -------------------------------------------------------------------------- */
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            let dataInicial = new Date(new Date().getTime()-(90*24*60*60*1000)); // remove 90 dias do dia atual
            let dataFinal   = new Date();
            this.filterDataInicial = dataInicial.toISOString();
            this.filterDataFinal   = dataFinal.toISOString();
        }
    }

    async getDadosMkt(){
        if (!this.filterDataInicial) {
            this.showToast('Campo vazio!', 'Por favor, preencher o campo Data inicial', 'warning');
            return;
        }
        if (!this.filterDataFinal) {
            this.showToast('Campo vazio!', 'Por favor, preencher o campo Data final', 'warning');
            return;
        }

        this.isLoading = true;
        buscaEmailsMkt({
            recordId : this.recordId,
            dataInicial: this.filterDataInicial,
            dataFinal: this.filterDataFinal
        }).then((result) =>{
            this.infoTabela = result
            this.isLoading = false
        }).catch((error) =>{
            console.log("erro: " , error)
            this.showToast('Ocorreu um erro!', error, 'error')
            this.isLoading = false;
        })
    }

    handleChange(event){
        var value;
        if(event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle'){
            value = event.target.checked;
        }else{
            value = event.target.value;
        }

        if(event.target.name === 'dataInicial'){
            this.filterDataInicial = value;
        }
        if(event.target.name === 'dataFinal'){
            this.filterDataFinal = value;
        }
  }

    //Toast de mensagens de sucesso e erro.
    showToast(titulo, mensagem, variant){
        const event = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    
    /* -------------------------------------------------------------------------- */
    /*                               GETTERS SETTERS                              */
    /* -------------------------------------------------------------------------- */

    get alreadySearch(){
        return (this.infoTabela.size && this.infoTabela.size > 0) ? true : false;
    }
}