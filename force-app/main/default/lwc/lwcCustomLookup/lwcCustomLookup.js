/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */
import { LightningElement,api,wire,track} from 'lwc';
import searchLookupData from '@salesforce/apex/LwcCustomLookupController.searchLookupData';
import searchDefaultRecord from '@salesforce/apex/LwcCustomLookupController.searchDefaultRecord';
 
export default class LwcCustomLookup extends LightningElement {
    /* -------------------------------------------------------------------------- */
    /*                               PUBLIC METHODS                               */
    /* -------------------------------------------------------------------------- */
    @api fildFilterMap = '';
    @api isMap = false;
    @api helptext = '';
    @api label = '';
    @api condition = '';
    @api fieldsWhereQuery = [];
    @api fieldsReturnQuery = [];
    @api placeholder = ''; 
    @api iconName = '';
    @api sObjectApiName = '';
    @api recordTypeDeveloperName = '';
    @api defaultRecordId = ''
    @api templateDocumentoId = null;
    @api selectedRecord = {};
    @api isContact = false;
    @api isShowFieldAccount = false;
    @api isShowFieldLead = false;
    @api isShowFieldCustomObject = false;
    @api fieldCustomNameToShow = '';
    @api disabled = false;
    @api
    clearInput() {
        console.log('=clearInput');       
        this.handleRemove();
    }

    /* -------------------------------------------------------------------------- */
    /*                               PRIVATE METHODS                              */
    /* -------------------------------------------------------------------------- */
    @track lstResult = [];
    @track hasRecords = true; 
    @track searchKey=''; 
    @track isSearchLoading = false;
    @track isRecordTypeSearch = false;
    @track delayTimeout;
    @track isValueSelected;

    /* -------------------------------------------------------------------------- */
    /*                              LIFECYCLE METHODS                             */
    /* -------------------------------------------------------------------------- */
    connectedCallback(){

        this.setCssIcon();
        try{
         if(this.defaultRecordId != ''){
            searchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper();
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }
        }catch(er){
            console.log(er)
        }
    }
    /* -------------------------------------------------------------------------- */
    /*                                WIRE METHODS                                */
    /* -------------------------------------------------------------------------- */
    @wire(searchLookupData, { 
        searchKey: '$searchKey' , 
        sObjectApiName : '$sObjectApiName', 
        recordId: '$templateDocumentoId',
        fieldsWhereQuery : '$fieldsWhereQuery',
        fieldsReturnQuery : '$fieldsReturnQuery',
        condition : '$condition',
        isMap : '$isMap',
        fieldCustomNameToShow : '$fieldCustomNameToShow',
        fildFilterMap : '$fildFilterMap'
    })
     searchResult(value) {
        try{
            const { data, error } = value;
            this.isSearchLoading = false;
            if (data) {
                this.hasRecords = data.length == 0 ? false : true; 
                this.lstResult = JSON.parse(JSON.stringify(data));
                this.lstResult.forEach(item => {
                    if (item.HealthCloudGA__BirthDate__c != undefined) {
                        const originalDate = new Date(item.HealthCloudGA__BirthDate__c);
                        // Format the date using the "dd/MM/YYYY" pattern
                        const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
                        item.HealthCloudGA__BirthDate__c = originalDate.toLocaleDateString('en-GB', options);                      
                    }
                    if (item.PersonBirthdate != undefined) {
                        const originalDate = item.PersonBirthdate.substring(8,10) + '/' + item.PersonBirthdate.substring(5,7)+ '/' + item.PersonBirthdate.substring(0,4);
                        // Format the date using the "dd/MM/YYYY" pattern
                        const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
                        item.PersonBirthdate =originalDate;                      
                        
                    }
                    item.showItem = true; 
                });               

                if(this.isContact == true){ 
                    this.criar = '+ Criar novo' + ( this.sObjectApiName.includes('Lead') ? ' não ' : '') + ' paciente';
                    this.lstResult.push({Id : '0001', Name : this.criar, showItem : false });
                }
                if (this.fieldCustomNameToShow != ''){     
                    const attributeNameToCheck = this.fieldCustomNameToShow; // Replace with the attribute name you want to check
                    const targetAttributeName = 'Name'; // Replace with the target attribute name                   
                    this.lstResult.forEach(item => {
                        if (attributeNameToCheck in item) {
                            item[targetAttributeName] = item[attributeNameToCheck];
                        }
                    });

                }            
                //console.log('lwcCustomLookup.return:');
                //console.log(this.lstResult);                 
            }
            else if (error) {
                console.log('(lwcCustomLookup.error---> ' + JSON.stringify(error));
            }
        }catch(er){
        console.log(er)
        }
    };
    /* -------------------------------------------------------------------------- */
    /*                                 CSS METHOD                                 */
    /* -------------------------------------------------------------------------- */
    setCssIcon(){
        const inputAligncenter = document.createElement('style');
        inputAligncenter.innerText = `.icon-help .slds-form-element__icon {padding-top: 0px !important;}`;
        document.body.appendChild(inputAligncenter);
     }
    /* -------------------------------------------------------------------------- */
    /*                                   METHODS                                  */
    /* -------------------------------------------------------------------------- */
        
    handleKeyChange(event) {
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {this.searchKey = searchKey;}, 300);
    }
    handleRemove(){
        this.searchKey = '';    
        this.selectedRecord = {};
        this.lookupUpdateParenthandler({Id : ''});
        this.isValueSelected = false; 
        console.log('=handleRemove');  
    }
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid');
        this.selectedRecord = this.lstResult.find(data => data.Id === objId);
        
        this.lookupUpdateParenthandler(this.selectedRecord);
        this.handelSelectRecordHelper(); 
    }
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        this.isValueSelected = true; 
    }
    lookupUpdateParenthandler(value){
        const oEvent = new CustomEvent('lookupupdate',{'detail': {selectedRecord: value}});
        this.dispatchEvent(oEvent);
    }
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
        }
    }
}