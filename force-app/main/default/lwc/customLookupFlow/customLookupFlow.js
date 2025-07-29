import { LightningElement,api,track,wire} from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import findRecordsFlow from "@salesforce/apex/LwcLookupController.findRecordsFlow";
import findRecordsFlowChild from "@salesforce/apex/LwcLookupController.findRecordsFlowChild";
import findRecordsFlowCache from "@salesforce/apex/LwcLookupController.findRecordsFlowCache";
import findRecordsFlowChildCache from "@salesforce/apex/LwcLookupController.findRecordsFlowChildCache";
export default class CustomLookupFlow extends LightningElement {
    @api RecordTypeIdParent;
    @api RecordTypeIdChild;
    @api Field1ResultChild;
    @api Field2ResultChild;
    @api Field3ResultChild;
    @api Field1ResultParent;
    @api Field2ResultParent;
    @api Field3ResultParent;
    @api IdResultParent;
    @api IdResultChild;
    @track isChild = false;
    @track parentChild = '';
    @track recordsListParent;  
    @track searchKeyParent = "";  
    @api selectedValueParent;  
    @api selectedRecordIdParent; 
    @track recordsListChild;  
    @track searchKeyChild = "";  
    @api selectedValueChild;  
    @api selectedRecordIdChild;       
    @track message;
    @track typingTimer;
    @track doneTypingInterval = 300;

    connectedCallback(){
     // console.log('parentid ',this.IdResultParent2);
      if(typeof this.IdResultParent != 'undefined'){
        this.getLookupResultCache();
        if(typeof this.IdResultChild != 'undefined'){
          this.getLookupResultChildCache()
        }

      }
    }


  @api
  validate() {
  if((this.IdResultParent && this.isChild == true)) { 
      return { isValid: true }; 
  } 
  else { 
      // If the component is invalid, return the isValid parameter 
      // as false and return an error message. 
      return { 
          isValid: false, 
          errorMessage: 'Por favor escolha uma opção!' 
       }; 
   }
  }
    
  onLeaveParent(event) {  
   setTimeout(() => {  
    this.searchKeyParent = "";  
    this.recordsListParent = null; 
   }, 400);  
  }  
    
  onRecordSelectionParent(event) {
   // console.log('aoba',JSON.parse(JSON.stringify(event.target.dataset)));
    this.selectedRecordIdParent = event.target.dataset.key;  
    this.selectedValueParent = event.target.dataset.name;
    const found = this.recordsListParent.find((element) => element.Id == this.selectedRecordIdParent);
   // console.log(found);
    this.IdResultParent = this.selectedRecordIdParent;
    this.Field1ResultParent = this.selectedValueParent;
    this.Field2ResultParent = found.UF_Endereco__c;
    this.searchKeyParent = "";
    this.isChild = true;
   // console.log(this.isChild)
   // console.log(this.Field2ResultParent)
    const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultParent', this.IdResultParent);   
    const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultParent', this.Field1ResultParent);
    const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultParent', this.Field2ResultParent);
    this.dispatchEvent(attributeChangeEvent);
    this.dispatchEvent(attributeChangeEvent2);
    this.dispatchEvent(attributeChangeEvent3);
    this.onSeletedRecordUpdateParent();  
  }  

  handleKeyChangeParent(event) {   
   const searchKeyParent = event.target.value;
   this.searchKeyParent = searchKeyParent;
   clearTimeout(this.typingTimer);
   if (this.searchKeyParent.length > 2) {
    this.typingTimer = setTimeout(() => this.getLookupResult(), this.doneTypingInterval);  
    }
  }
  handleKeyChangeParentDown(){
    clearTimeout(this.typingTimer);
  }
   
  removeRecordOnLookupParent(event) {  
   this.searchKeyParent = "";  
   this.selectedValueParent = null;  
   this.selectedRecordIdParent = null;  
   this.recordsListParent = null;
   this.isChild = false;   
   this.searchKeyChild = "";  
   this.selectedValueChild = null;  
   this.selectedRecordIdChild = null;  
   this.recordsListChild = null;
   // zerar os valores dos outputs flow
   this.Field3ResultParent = '';
   this.IdResultParent = '';
   this.Field1ResultParent = '';
   this.Field2ResultParent = '';
   this.Field3ResultParent = '';
   this.IdResultChild = '';
   this.Field1ResultChild = '';
   this.Field2ResultChild = '';
   const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultParent', this.IdResultParent);   
   const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultParent', this.Field1ResultParent);
   const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultParent', this.Field2ResultParent);
   this.dispatchEvent(attributeChangeEvent);
   this.dispatchEvent(attributeChangeEvent2);
   this.dispatchEvent(attributeChangeEvent3);
   const attributeChangeEvent4 = new FlowAttributeChangeEvent('IdResultChild', this.IdResultChild);   
   const attributeChangeEvent5 = new FlowAttributeChangeEvent('Field1ResultChild', this.Field1ResultChild);
   const attributeChangeEvent6 = new FlowAttributeChangeEvent('Field2ResultChild', this.Field2ResultChild); 
   this.dispatchEvent(attributeChangeEvent4);
   this.dispatchEvent(attributeChangeEvent5);
   this.dispatchEvent(attributeChangeEvent6);
   this.onSeletedRecordUpdateParent(); 
 }    
  getLookupResult() {  
    findRecordsFlow({ searchKey: this.searchKeyParent,recordTypeId: this.RecordTypeIdParent})  
    .then((result) => {  
     if (result.length===0) {  
       this.recordsListParent = [];  
       this.message = "Nenhum registro encontrado";  
      } else {  
       this.recordsListParent = result; 
      // console.log('this.recordsListParent: ',JSON.parse(JSON.stringify(this.recordsListParent)));
       this.message = "";  
      }  
      this.error = undefined;  
    })  
    .catch((error) => {  
     this.error = error;  
     this.recordsListParent = undefined;  
    });  
  }  
   
  onSeletedRecordUpdateParent(){  
   const passEventr = new CustomEvent('recordselection', {  
     detail: { selectedRecordIdParent: this.selectedRecordIdParent, selectedValueParent: this.selectedValueParent }  
    });  
    this.dispatchEvent(passEventr);  
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
   // console.log(found);
    this.IdResultChild = this.selectedRecordIdChild;
    this.Field1ResultChild = this.selectedValueChild;
    this.Field2ResultChild = found.UF_do_CRM__c;
    const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultChild', this.IdResultChild);   
    const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultChild', this.Field1ResultChild);
    const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultChild', this.Field2ResultChild); 
    this.dispatchEvent(attributeChangeEvent);
    this.dispatchEvent(attributeChangeEvent2);
    this.dispatchEvent(attributeChangeEvent3);
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
    this.IdResultChild = '';
    this.Field1ResultChild = '';
    this.Field2ResultChild = ''; 
    const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultChild', this.IdResultChild);   
    const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultChild', this.Field1ResultChild);
    const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultChild', this.Field2ResultChild); 
    this.dispatchEvent(attributeChangeEvent);
    this.dispatchEvent(attributeChangeEvent2);
    this.dispatchEvent(attributeChangeEvent3);
    this.onSeletedRecordUpdateChild();  
  }    
   getLookupResultChild() {  
     findRecordsFlowChild({ searchKey: this.searchKeyChild,ufDoCrm: this.Field2ResultParent})  
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

   getLookupResultCache() {  
    findRecordsFlowCache({ recordId:this.IdResultParent})  
    .then((result) => {  
     if (result) {
      this.IdResultParent = result.Id;
      this.Field1ResultParent = result.Name;
      this.Field2ResultParent = result.UF_Endereco__c;
      this.selectedRecordIdParent = this.IdResultParent;  
      this.selectedValueParent = result.Name;
      this.searchKeyParent = "";
      this.isChild = true;
      this.message = "";
      const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultParent', this.IdResultParent);  
      const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultParent', this.Field1ResultParent);
      const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultParent', this.Field2ResultParent); 
      this.dispatchEvent(attributeChangeEvent);
      this.dispatchEvent(attributeChangeEvent2);
      this.dispatchEvent(attributeChangeEvent3); 
      
     } else {  
      this.message = "No Records Found";  
     }  
      this.error = undefined;  
    })  
    .catch((error) => {  
     this.error = error;  
    });  
  }
  getLookupResultChildCache() {  
    findRecordsFlowChildCache({ recordId:this.IdResultChild})  
    .then((result) => {  
     if (result) {  
      this.selectedRecordIdChild = result.Id;  
      this.selectedValueChild = result.Nome_completo__c;   
      this.searchKeyChild = "";
      this.isChild = true;
      this.IdResultChild = result.Id;
      this.Field1ResultChild = result.Nome_completo__c;
      this.Field2ResultChild = result.UF_do_CRM__c;
      const attributeChangeEvent = new FlowAttributeChangeEvent('IdResultChild', this.IdResultChild);  
      const attributeChangeEvent2 = new FlowAttributeChangeEvent('Field1ResultChild', this.Field1ResultChild);
      const attributeChangeEvent3 = new FlowAttributeChangeEvent('Field2ResultChild', this.Field2ResultChild);
      this.dispatchEvent(attributeChangeEvent);
      this.dispatchEvent(attributeChangeEvent2);
      this.dispatchEvent(attributeChangeEvent3);
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