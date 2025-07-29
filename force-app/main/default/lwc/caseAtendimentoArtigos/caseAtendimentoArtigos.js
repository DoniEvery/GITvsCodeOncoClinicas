import { LightningElement,api ,wire, track} from 'lwc';
import getCaseData from '@salesforce/apex/CadastroProtocoloAtendimentoController.getCaseData';

export default class CaseAtendimentoArtigos extends LightningElement {

    @api recordId;
    @track assuntoUnidadeSelecionada = '';
    @track motivoAssuntoUnidade = '';
    @track knowledgeRecordTypeName = 'ArtigoAberturaDeCaso';

    connectedCallback() {
       getCaseData({idCase: this.recordId})
       .then(resp => {
           this.assuntoUnidadeSelecionada = resp.AssuntoUnidade__c;
           this.motivoAssuntoUnidade = resp.MotivoCaso__c;
       })
       .catch(error => {
           console.log('getCaseData.Error: ', error);                    
       });
    }
    

}