import { LightningElement, api, track, wire} from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex methods
import getArticlesKnowledge from '@salesforce/apex/CadastroProtocoloAtendimentoController.getArticlesKnowledge';

export default class CadastroProtocoloAtendimentoArtigos extends LightningElement {
    /* -------------------------------------------------------------------------- */
    /*                               PUBLIC METHODS                               */
    /* -------------------------------------------------------------------------- */
    @api assuntoUnidadeId = '';
    @api motivoAssuntoUnidade = '';
    @api isVisibleInCsp = false;
    @api isAssuntoUnidadeSelected = false;
    @api recordTypeDevelopername = 'ArtigoAberturaDeCaso';
    @api recordId = ''; 
    /* -------------------------------------------------------------------------- */
    /*                               PRIVATE METHODS                              */
    /* -------------------------------------------------------------------------- */    
    @track metaObj = {};
    @track assuntoUnidade = '';
    @track status = ''; 
    @track reportTypesOptions;   
    @track eventReportTypesOptions;

    @track pageSize = 1;//default value we are assigning
    @track recordLimit = 100; //initialize 1st page
    @track page = 1; //initialize 1st page
    @track items = []; //contains all the records.
    @track data; //data  displayed in the table

    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @track isLoading = false;
    @track sortDirection = 'asc';
    @track showModal = false;
    @track modalFieldInfo;
    @track sortedBy;
    @track mydata;
    @track currentPageSize = 0;  

    showResults = false;
    
    connectedCallback() {
        //console.log('Artigos.connectedCallback');
        //console.log('Artigos.connectedCallback.searchArticles');
        //this.searchArticles();        
    }
  
    @wire(getArticlesKnowledge, { assunto: '$assuntoUnidadeId', motivo: '$motivoAssuntoUnidade', recordId: '$recordId'})
        searchResult(value) {
        try{
            const { data, error } = value; 
            if (data) {
                console.log('==getArticlesKnowledge');
                console.log(this.searchParms);
                console.log(data);
                this.mydata = this.items = data.lstArticles;
                this.showResults = false;
                const parseData = data.lstArticles;
                if (parseData.length > this.recordLimit){
                    this.data = undefined;
                    this.spinner = false;
                    this.showToast('error', 'Limite de Registros encontrados superior ao limite estabelecido! (' + this.recordLimit + ')', 'warning');
                }else{
                    console.log(data.lstArticles.length );
                    if (data.lstArticles.length == 0){
                        this.data = undefined;
                        this.spinner = false;      
                        //this.showToast('Erro', 'Nenhum artigo encontrado!','warning');                 
                    }else{
                        this.items = parseData;
                        this.page = 1;
                        this.sortDirection = 'asc';
                        this.sortBy = '';
                        this.totalRecountCount = data.lstArticles.length;
                        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                        //here we slice the data according page size
                        this.data = this.items.slice(0, this.pageSize); 
                        this.endingRecord = this.data.length;
                        this.error = undefined;
                        this.spinner = false;
                        this.currentPageSize = this.endingRecord - this.startingRecord + 1;
                        this.showResults = true;
                    }
                }                    
            } else if (error) {
                console.log('(getArticlesKnowledge.error---> ' + JSON.stringify(error));
            }  
        }catch(er){
            console.log(er)
        }
    };

    /*
    searchArticles(){
        console.log('==searchArticles');
        const searchParms = {
            'assuntoUnidade' : this.assuntoUnidadeId,
            'recordTypeId'  : this.recordTypeDevelopername,
            'motivoAssuntoUnidade' : this.motivoAssuntoUnidade,
            'isVisibleInCsp' : this.isVisibleInCsp,
            'status' : this.status
            }            
        
        getArticles({searchParms : searchParms})
        .then(data=>{
            console.log('==getArticles');
            console.log(searchParms);
            console.log(data);
            this.mydata = this.items = data.lstArticles;
            this.showResults = false;
            const parseData = data.lstArticles;
            if (parseData.length > this.recordLimit){
                this.data = undefined;
                this.spinner = false;
                this.showToast('error', 'Limite de Registros encontrados superior ao limite estabelecido! (' + this.recordLimit + ')');
            }else{
                console.log(data.lstArticles.length );
                if (data.lstArticles.length == 0){
                    this.data = undefined;
                    this.spinner = false;      
                    this.showToast('Erro', 'Nenhum artigo encontrado!','warning');                 
                }else{
                    parseData.forEach(record=>{  
                        record.linkName = '/'+record.id;
                    });
                    this.items = parseData;
                    this.page = 1;
                    this.sortDirection = 'asc';
                    this.sortBy = '';
                    this.totalRecountCount = data.lstArticles.length;
                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                    //here we slice the data according page size
                    this.data = this.items.slice(0, this.pageSize); 
                    this.endingRecord = this.data.length;
                    this.error = undefined;
                    this.spinner = false;
                    this.currentPageSize = this.endingRecord - this.startingRecord + 1;
                    this.showResults = true;
                }
            }
            
        }) .catch(error=>{
            console.log(error);
            this.error = error;
            this.data = undefined;
            this.spinner = false;
            this.showToast('Erro', reduceErrors(error).join(' / '), 'error');
        })
    
    }    
    */

    handleSectionToggle(event){
        //console.log(event.detail.openSections);
    }
    
    //press on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }
 
    //press on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);            
        }             
    }
 
    get isPreviousDisable(){
        return (this.page == 1 ? true : false);
    }
 
    get isNextDisable(){
        return (this.page === this.totalPage || (this.page > this.totalPage)) ? true : false;
    }
 
    //this method displays records page by page
    displayRecordPerPage(page){
         
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
 
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
 
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
 
        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
        this.currentPageSize = this.endingRecord - this.startingRecord + 1;
    } 

    mapOptions = {
        draggable: false,
        disableDefaultUI: false,
    };

    //Shows Toast
    showToast(variant, message){
        this.dispatchEvent(
            new ShowToastEvent({"title" : (variant === 'error' ? 'Erro'  : 'Sucesso'), 
                                "message" : message, "variant" : variant})
        );
    }     

}