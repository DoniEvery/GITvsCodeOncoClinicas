import { LightningElement,api,track,wire} from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import findRecordsFlowChild from "@salesforce/apex/LwcLookupController.findRecordsFlowChild";
import findRecordsFlowChildCache from "@salesforce/apex/LwcLookupController.findRecordsFlowChildCache";
 
export default class CustomLookupFlowMedico extends LightningElement {
    @api EstadoMedico;
    @api IdResult; 
    @track recordsListChild;  
    @track searchKeyChild = "";  
    @api selectedValueChild;  
    @api selectedRecordIdChild; 
    @api IdMedico;      
    @track message;
    @track typingTimer;
    @track doneTypingInterval = 300;
    ConnectedCallback(){
        if(typeof this.IdResultChild != 'undefined'){
            this.getLookupResultChildCache();
        }

    }  
     onLeaveChild(event) {  
       setTimeout(() => {  
        this.searchKeyChild = "";  
        this.recordsListChild = null;  
       }, 400);  
      }  
        
      onRecordSelectionChild(event) {
        this.selectedRecordIdChild = event.target.dataset.key;  
        this.selectedValueChild = event.target.dataset.name;   
        this.searchKeyChild = "";
        this.isChild = true;
        const found = this.recordsListChild.find((element) => element.Id == this.selectedRecordIdChild);
        this.IdResult = this.selectedRecordIdChild;

        const attributeChangeEvent = new FlowAttributeChangeEvent('IdResult', this.IdResult);   
        this.dispatchEvent(attributeChangeEvent);
        this.onSeletedRecordUpdateChild();
      }  
       
      handleKeyChangeChild(event) {
       const searchKeyChild = event.target.value;
       this.searchKeyChild = searchKeyChild;
       clearTimeout(this.typingTimer);
       if (searchKeyChild.length > 2 ) {
        this.typingTimer = setTimeout(() => this.getLookupResultChild(), this.doneTypingInterval);  
        }
      }
      handleKeyChangeChildDown(){
       clearTimeout(this.typingTimer);
      }  
       
      removeRecordOnLookupChild(event) {  
       this.searchKeyChild = "";  
       this.selectedValueChild = null;  
       this.selectedRecordIdChild = null;  
       this.recordsListChild = null;
       this.IdResult = '';
       const attributeChangeEvent = new FlowAttributeChangeEvent('IdResult', this.IdResult);   
       this.dispatchEvent(attributeChangeEvent);
       this.onSeletedRecordUpdateChild();  
     }    
      getLookupResultChild() {  
        findRecordsFlowChild({ searchKey: this.searchKeyChild,ufDoCrm: this.EstadoMedico})  
        .then((result) => {  
         if (result.length===0) {  
           this.recordsListChild = [];  
           this.message = "Nenhum registro encontrado";  
          } else {  
           this.recordsListChild = result;  
          // console.log('this.recordsListChild: ',JSON.parse(JSON.stringify(this.recordsListChild)));
           this.message = "";  
          }  
          this.error = undefined;  
        })  
        .catch((error) => {  
         this.error = error;  
         this.recordsListChild = undefined;  
        });  
      }  
       
      onSeletedRecordUpdateChild(){  
       const passEventr = new CustomEvent('recordselection', {  
         detail: { selectedRecordIdChild: this.selectedRecordIdChild, selectedValueChild: this.selectedValueChild }  
        });  
        this.dispatchEvent(passEventr);  
      }
   
     getLookupResultChildCache() {  
       findRecordsFlowChildCache({recordId:this.IdResultChild})  
       .then((result) => {  
        if (result) {  
         this.selectedRecordIdChild = result.Id;  
         this.selectedValueChild = result.Nome_completo__c;   
         this.searchKeyChild = "";
         this.isChild = true;
         this.IdResult = result.Id;
         const attributeChangeEvent = new FlowAttributeChangeEvent('IdResult', this.IdResult);  

         this.dispatchEvent(attributeChangeEvent);
         } else {  
          this.message = "";  
         }  
         this.error = undefined;  
       })  
       .catch((error) => {  
        this.error = error;  
        this.recordsListChild = undefined;  
       });  
     } 
        
   }