import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import integrarCart from "@salesforce/apex/IntegracaoPdfCartController.integrarCart"; 
import integrarDocumento from "@salesforce/apex/IntegracaoPdfCartController.integrarDocumento"; 
import generatePDF from "@salesforce/apex/IntegracaoPdfCartController.generatePDF"; 
 
export default class IntegracaoPdfCart extends LightningElement {
    @api recordId;
    dadosPacienteMedico = {};
    voltarBotao = false;
    previewCamposPdf = true;
    fileUrlBotao = '';
    url = '';
    urlCampos = '';
    fileList = [];
    filepreview = false;
    spinner = false;

    async connectedCallback(){ 
        this.spinner = true;
        await Promise.resolve();

        integrarCart({"recordId" : this.recordId})
        .then((result) => { 
            if(result.errorFlag){
                let erro = result.error;
                console.error('Erro integrarCart 1: ', result.error);
                
                if(JSON.stringify(result.error).includes('message')) erro = JSON.parse(result.error).message;
                
                this.showToast('Erro', erro, 'error');
                this.dispatchEvent(new CloseActionScreenEvent());
            }else{
                this.dadosPacienteMedico = result;

                this.dadosPacienteMedico.patientAttachments.forEach(element => {
                    element.fileName = element.fileName.split('-')[1];
                    this.fileList.push({"label" : element.fileName, "urlcriptografa" : element.encryptedFileKey});             
                });

                this.gerarLinkPdf();
            }    
	    })
        .catch(error=>{
            console.error('Erro integrarCart 2: ', JSON.stringify(error.message));
		    this.showToast('Erro!', error.message, 'error');
	    });
    }

    showToast(title, message, type) {

        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(toast);
    
    }

    previewHandler(event){
        this.fileUrlBotao = event.currentTarget.dataset.link;
        
        integrarDocumento({"doc" : this.fileUrlBotao})
        .then((result) => {
            if(result.errorFlag){
                console.error('Erro integrarDocumento: ', erros.message);
                this.showToast('Erro', erros.message, 'error');
            }
            else{
                this.url = result.data.replace(/["']/g, "").replace(' ','');
                window.open(this.url, "_blank");
            }    
        })
        .catch(error=>{
            console.error('Erro integrarDocumento: ', JSON.stringify(error.message));
            this.showToast('Erro!', error.message, 'error');
        });
    }

    previewHandlerPdfSalesforce(){
        this.previewCamposPdf = !this.previewCamposPdf;
        this.filepreview = !this.filepreview;
        this.voltarBotao = !this.voltarBotao;
    }

    closeHandler(){       
        this.refreshPage();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    refreshPage(){
        setTimeout(()=>{
            this.closeQuickAction();
            window.location.reload();  
    }
    ,1000);}

    gerarLinkPdf() {  
        generatePDF({"jsonData" : JSON.stringify(this.dadosPacienteMedico)})  
         .then((result) => {
            this.urlCampos = result;
         });
         this.spinner = false;
    }
}