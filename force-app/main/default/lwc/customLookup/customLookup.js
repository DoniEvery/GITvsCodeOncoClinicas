/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */
import { LightningElement,api,wire,track} from 'lwc';
import searchLookupData from '@salesforce/apex/CustomLookupController.searchLookupData';
 
export default class CustomLookup extends LightningElement {
    /* -------------------------------------------------------------------------- */
    /*                               PUBLIC METHODS                               */
    /* -------------------------------------------------------------------------- */
    @api label = '';
    @api fields = [];
    @api required;
    @api strObj = '';
    @api placeholder = ''; 
    @api iconName = '';
    @api sObjectApiName = '';
    @api defaultRecordId = ''
    @api templateDocumentoId = null;
    @api selectedRecord = {};
    @api isSearch;
    @api recordId = '';
    @api parentChild = '';

    /* -------------------------------------------------------------------------- */
    /*                               PRIVATE METHODS                              */
    /* -------------------------------------------------------------------------- */
    @track lstResult = [];
    @track hasRecords = true; 
    @track searchKey=''; 
    @track isSearchLoading = false;
    @track delayTimeout;
    @track isValueSelected;
    @track templateByQuadro = false;
    @track titleHasRecords = '';

    /* -------------------------------------------------------------------------- */
    /*                              LIFECYCLE METHODS                             */
    /* -------------------------------------------------------------------------- */
    connectedCallback(){
    }
    /* -------------------------------------------------------------------------- */
    /*                                WIRE METHODS                                */
    /* -------------------------------------------------------------------------- */
    @wire(searchLookupData, { searchKey: '$searchKey' , strObj : '$strObj'})
     searchResult(value) {
        try{
            //console.log('--wire--');
           // console.log('recordId => ',this.recordId);
           // console.log('isSearch => ',this.isSearch);
            const { data, error } = value;
            this.isSearchLoading = false;
            //console.log('data: ',JSON.parse(JSON.stringify(data)));
            if ((data && this.searchKey.length >= 3 && this.parentChild == 'Child') || (data &&this.parentChild == 'Parent')) {
                this.hasRecords = (data.length == 0 || this.isSearch == false) ? false : true;
                this.titleHasRecords = 'Nenhum registro encontrado....';
                this.lstResult = (this.isSearch == false) ? [] : JSON.parse(JSON.stringify(data)); 

                if(this.recordId && this.isSearch == true){
                    this.selectedRecord = this.lstResult.find(data => data.Id === this.recordId);
                    this.lookupUpdateParenthandler(this.selectedRecord);
                    this.handelSelectRecordHelper();
                }
            }
            else if (error) {
                this.hasRecords = false;
                this.titleHasRecords = 'Erro! ' + error.body.message;
                console.log('error---> ' + JSON.stringify(error.body.message));
            }
        }catch(error){
            console.log(error)
        }
    };
    /* -------------------------------------------------------------------------- */
    /*                                   METHODS                                  */
    /* -------------------------------------------------------------------------- */
        
    handleKeyChange(event) {
        if(event.target.value.length >= 3){
            this.isSearchLoading = true;
            window.clearTimeout(this.delayTimeout);
            const searchKey = event.target.value;
            this.delayTimeout = setTimeout(() => {this.searchKey = searchKey;}, 300);
        }

    }
    handleRemove(){
        this.searchKey = '';    
        this.selectedRecord = {};
        this.lookupUpdateParenthandler(undefined);
        this.isValueSelected = false; 
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
        const oEvent = new CustomEvent('lookupupdate',{'detail': {value}});
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
    
    /* -------------------------------------------------------------------------- */
    /*                                 GET METHODS                                */
    /* -------------------------------------------------------------------------- */
    get isTemplateByQuadro() {
        return this.templateByQuadro
    }
}