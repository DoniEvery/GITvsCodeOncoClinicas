import { LightningElement,api,track,wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import searchListAssunto from '@salesforce/apex/AssuntoFlowController.searchListAssunto';
import searchListDetalhe from '@salesforce/apex/AssuntoFlowController.searchListDetalhe';
import searchIdAssunto from '@salesforce/apex/AssuntoFlowController.searchIdAssunto';
export default class AssuntoDetalheFlow extends LightningElement {
    @api Unidade;
    @api recategorizado;
    @api IdassuntoExistente;
    @api MotivoCaso;
    @api DisponivelPaciente;
    @api ValueAssunto;
    @api ValueDetalhe;
    @api IdAssunto;
    @api IdDetalhe;
    @api objName;
    @api ValueAssuntoInput;
    @api ValueDetalheInput;
    @api IdAssuntoInput;
    @api IdDetalheInput;
    @track listAcc;
    @track listCont;
    @track showContact = false;
    @track disabled = true;
    connectedCallback(){
        this.ValueAssunto = undefined;
        this.IdassuntoExistente = (typeof this.IdassuntoExistente === 'undefined') ? '': this.IdassuntoExistente;
        if((typeof this.IdAssunto != 'undefined')){
            console.log('this.IdAssunto',this.IdAssunto);
            console.log('this.IdDetalhe',this.IdDetalhe);
            console.log('this.ValueDetalhe',this.ValueDetalhe);
            console.log('this.IdDetalhe',this.IdDetalhe);
            this.getLookupResult();
            this.ValueDetalhe = this.ValueDetalhe;
        }

    }
    @api
    validate() {
    if((this.ValueAssunto && this.showContact == false) || (this.ValueAssunto && this.ValueDetalhe)) { 
        return { isValid: true }; 
    } 
    else { 
        // If the component is invalid, return the isValid parameter 
        // as false and return an error message. 
        return { 
            isValid: false, 
            errorMessage: '' 
         }; 
     }
    }
    get showContact(){
        return this.showContact;
    }
    @wire(searchListAssunto,{objName : '$objName',disponivelPaciente : '$DisponivelPaciente',motivoCaso : '$MotivoCaso',unidade : '$Unidade',recategorizado : '$recategorizado',IdassuntoExistente : '$IdassuntoExistente'})
    searchResult({error,data}){
        console.log(data);
        console.log(this.MotivoCaso)
        if(data){
        this.listAcc = data.map((item)=>{
            return {
                label: item,
                value: item
            }
        });
        
    }else if (error) {
        console.log('error---> ' + JSON.stringify(error.body.message));
    }
    }
   onSelectedListAcc(event){
        console.log(event.target.value);
        this.ValueAssunto = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('ValueAssunto', this.ValueAssunto);
        this.dispatchEvent(attributeChangeEvent);
        if(this.ValueAssunto){
            this.showContact = false;
            this.disabled = true;
            this.getLookupResult();
        }
    }
    getLookupResult(){
        searchListDetalhe({objName : this.objName,disponivelPaciente : this.DisponivelPaciente,motivoCaso : this.MotivoCaso,unidade : this.Unidade,assuntoName: this.ValueAssunto,recategorizado : this.recategorizado,IdassuntoExistente : this.IdassuntoExistente}).then((result) =>{
            console.log('result',result);
            if(result.length){
                this.showContact = true;
                this.disabled = false;
                this.listCont = result.map((item)=>{
                return {
                    label: item,
                    value: item
                }
                });
            }else{
                this.showContact = false;
                this.disabled = true;
                this.ValueDetalhe = '';
                this.getLookupResultId();
            }
        })
    }
    onSelectedListCont(event){
        this.ValueDetalhe = event.target.value;
        if(this.ValueDetalhe){
            this.getLookupResultId();
            const attributeChangeEvent = new FlowAttributeChangeEvent('ValueDetalhe', this.ValueDetalhe);
            this.dispatchEvent(attributeChangeEvent);
        }
    }
    getLookupResultId(){
        searchIdAssunto({objName : this.objName,nomeAssunto : this.ValueAssunto,nomeDetalhe: this.ValueDetalhe,unidade: this.Unidade,motivoCaso:this.MotivoCaso}).then((result) =>{
            console.log('resultado',result);
            if(result){
                this.IdAssunto = result.IdAssunto;
                this.IdDetalhe = result.IdDetalhe;
                const attributeChangeEvent = new FlowAttributeChangeEvent('IdAssunto', this.IdAssunto);
                this.dispatchEvent(attributeChangeEvent);
                if(this.IdDetalhe){
                    const attributeChangeEvent2 = new FlowAttributeChangeEvent('IdDetalhe', this.IdDetalhe);
                    this.dispatchEvent(attributeChangeEvent2);
                }
            }else{
                this.IdAssunto = '';
                this.IdDetalhe = '';
            }
        })
    }
}