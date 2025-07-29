import { LightningElement, api, wire, track } from 'lwc';
import getPickListLabels from '@salesforce/apex/VisitRecordFormController.getPickListLabels';
import getDependentPickListLabels from '@salesforce/apex/VisitRecordFormController.getDependentPickListLabels';
import getMultiPickListContacts from '@salesforce/apex/VisitRecordFormController.getMultiPickListContacts';
import save from '@salesforce/apex/VisitRecordFormController.save';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




export default class VisitRecordForm extends LightningElement {

    @track accountName;  
    @track accountRecordId;  
    @track subject;
    @track description;
    @track startDate;
    @track subjectValue;
    @track communicationChannelValue;
    @track endDate;
    @track requiredType = false;
    @track disableButton = true;
   
   @track labelItems = [];

    clickedButtonLabel;
    isLoading = false;
    meetingStatusValues = '';
    typeValue = '';
    communicationChannelValue = '';
    recurrenceValue = '';
    actionValue = '';
    medicTypeValue = '';
    advisorPanelValue = '';
    @api objectApiName;
    meetingStatus = [];
    types = [];
    recurrence = [];
    communicationChannels = [];
    subjects = [];
    actions = [];
    medicTypes = [];
    advisorPanels = [];
    products = [];
    selected = [];
    pills = [];
    contactIds = [];
    contactGroupId = [];
    meetingStatusOptions ;
    GroupContactOption = [];
    typeOptions;
    communicationChannelOptions ;
    subjectValue;
    recurrenceOptions;
    actionOptions;
    medicTypeOptions;
    advisorPanelOptions;
    productOptions  ;
    selectedRecordId; //store the record id of the selected 

    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Status_Reuniao__c' })
    wiredPickListStatus({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.meetingStatus.push(option);
            });
            this.meetingStatusOptions = this.meetingStatus;
        } else if (error) {
            console.error(error);
        }
        
    }

    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Tipo_Convite__c' })
    wiredPickListType({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.types.push(option);
            });
            this.typeOptions = this.types;
        } else if (error) {
            console.error(error);
        }
        
    }


    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Tipo_Assunto__c' })
    wiredPickListSubject({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.subjects.push(option);
            });
            this.subjectOptions = this.subjects;
        } else if (error) {
            console.error(error);
        }
        
    }
    
    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Retorno__c' })
    wiredPickListRecurrence({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.recurrence.push(option);
            });
            this.recurrenceOptions = this.recurrence;
        } else if (error) {
            console.error(error);
        }
        
    }
    
    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Acao__c' })
    wiredPickListAction({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.actions.push(option);
            });
            this.actionOptions = this.actions;
        } else if (error) {
            console.error(error);
        }
        
    }
    
    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Tipo_de_Medico__c' })
    wiredPickListMedicType({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.medicTypes.push(option);
            });
            this.medicTypeOptions = this.medicTypes;
        } else if (error) {
            console.error(error);
        }
        
    }
    
    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Painel_do_Consultor__c' })
    wiredPickListAdvisorPanel({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.advisorPanels.push(option);
            });
            this.advisorPanelOptions = this.advisorPanels;
        } else if (error) {
            console.error(error);
        }
        
    }
    
    @wire(getPickListLabels, { objectApiName: 'Event', fieldApiName: 'Produto__c' })
    wiredPickListProducts({ error, data }) {
        let option = {};

        if (data) {
            data.map(it => {
                option = {};
                option.label = it;
                option.value = it;
                this.products.push(option);
            });
            this.productOptions = this.products;
        } else if (error) {
            console.error(error);
        }
        
    }
    @wire(getMultiPickListContacts)
    getMultiPickListContacts({ error, data }) {
        if (data) {
            this.GroupContactOption = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleChangeMeetingValue(event) {
        this.meetingStatusValues = event.detail.value;
    }

    handleChangeType(event) {
        this.typeValue = event.detail.value;
    }
    
    handleChangeCommunicationChannel(event) {
        this.communicationChannelValue = event.detail.value;
    }

    handleChangeSubject(event) {
        this.subjectValue = event.detail.value;
        this.disableButton = false;
            getDependentPickListLabels({ objectApiName: 'Event', fieldApiName: 'Canal_de_comunicacao__c', parentFieldValue: this.subjectValue })
            .then(data => {
                console.log('data '  + data);
                this.communicationChannels = [];
                let option = {};

                    data.map(it => {
                        option = {};
                        option.label = it;
                        option.value = it;
                        
                        this.communicationChannels.push(option);
                    });
                    
                    this.communicationChannelOptions = this.communicationChannels;

            })
            .catch(error => {
                console.log('Error: ', error);
            });
        
    }
    
    handleChangeRecurrence(event) {
        this.recurrenceValue = event.detail.value;

    }
    
    handleChangeAction(event) {
        this.actionValue = event.detail.value;
    }
    
    handleChangeMedicType(event) {
        this.medicTypeValue = event.detail.value;
    }
    
    handleChangeAdvisorPanel(event) {
        this.advisorPanelValue = event.detail.value;
    }

    handleChange(e) {
        this.selected = e.detail.value;
    }

    handleValueSelected(event) {
        this.selectedRecordId = event.detail;
    }
    handleChangeContacts(event){
        this.contactGroupId = [];
        event.target.value.forEach(element =>{         
            this.contactGroupId.push(... this.GroupContactOption.find((id)=>id.value == element).contactIds);
        })
        console.log('this.contactGroupId',this.contactGroupId);
    }

    selectedRecords(event) {
    }

    onAccountSelection(event){

        if (event.detail.selectedValue == '' || event.detail.selectedValue == undefined) return;
        if (this.contactIds.includes(event.detail.selectedRecordId)) return;

        this.accountName = event.detail.selectedValue;  
        this.accountRecordId = event.detail.selectedRecordId;  
        let item = {};
        item.type = 'avatar';
        item.label = event.detail.selectedValue;
        item.fallbackIconName = 'standard:user';
        item.variant = 'circle';
        item.alternativeText = 'User avatar';
        item.id = event.detail.selectedRecordId;
        this.labelItems.push(item);
        this.labelItems.forEach(it => {
            console.log('it ', it); 
        })
        this.contactIds.push(event.detail.selectedRecordId);

    }  

    removePillItem(event) {

        console.log('this.contactIds remove ', this.contactIds);
        
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        
        const itempill = this.labelItems;
        itempill.splice(pillIndex, 1);  
        let removeId = itempill.splice(pillIndex, 1);
        this.labelItems = [...itempill];
        this.contactIds = [];
        this.labelItems.map(it => {
            this.contactIds.push(it.id);
        })
    }

    descriptionOnChange(event) {
        this.description = event.target.value;
    }

    handleClick(event) {
        console.log('handleClick');

        this.isLoading = !this.isLoading;
        try{
            if( (this.startDate == '' || this.startDate == undefined) || (this.endDate == '' || this.endDate == undefined) 
            || (this.contactIds.length == 0 && this.contactGroupId.length == 0) || (this.communicationChannelValue == '' || this.communicationChannelValue == undefined)) {
                this.showToast('Erro', 'Campos obrigatórios não preenchidos', 'error');
                this.isLoading = !this.isLoading;
    
            } else {
                this.clickedButtonLabel = event.target.label;
                var evContactsId = [];
                console.log('this.contactIds.length '+ this.contactIds.length);
                console.log('this.contactGroupId.length '+ this.contactGroupId.length);

                if(this.contactIds.length > 0 && this.contactGroupId.length > 0){
                    console.log('entrou');
                   // evContactsId.push.apply(this.contactIds,this.contactGroupId);
                    evContactsId.push(...this.contactIds);
                    evContactsId.push(...this.contactGroupId);
                    console.log('evContactsId', JSON.stringify(evContactsId));
                }else{
                    console.log('else')
                    console.log(JSON.stringify(this.contactIds));
                    console.log(JSON.stringify(this.contactGroupId));

                    if(this.contactIds.length > 0){
                        evContactsId = this.contactIds;
                    }else{
                        evContactsId = this.contactGroupId;
                    }

                    //evContactsId.push((this.contactIds.length > 0) ? this.contactIds : this.contactGroupId);
                }

                let eventVO = {};
                eventVO.meetingStatusValues = this.meetingStatusValues;
                eventVO.startDate = this.startDate;
                eventVO.startDate = this.startDate;
                eventVO.endDate = this.endDate;
                
                eventVO.subjectValue = this.subjectValue;
                eventVO.typeValue = this.typeValue;
                eventVO.communicationChannelValue = this.communicationChannelValue;
                eventVO.recurrenceValue = this.recurrenceValue;
                eventVO.actionValue = this.actionValue;
                eventVO.medicTypeValue = this.medicTypeValue;
                eventVO.advisorPanelValue = this.advisorPanelValue;
                eventVO.contactIds = evContactsId;
                eventVO.description = this.description;
                
                eventVO.selected = this.selected;
                
                let eventVOJson = '';
                eventVOJson = JSON.stringify(eventVO);
                save({voJson: eventVOJson})
                .then(r => {
                    console.log('response ', r)
                    if(r == 'ok') {
                        this.showToast('Sucesso', 'Registro(s) criado(s) com sucesso', 'success');
                        window.location.reload();
                    } else {
                        this.isLoading = !this.isLoading;
                        this.showToast('Erro', 'Nenhum registro criado, confira os campos e tente novamente', 'error');
                    }
                    
                })
                .catch(error => {
                    console.log('Error: ', error);
                    let errorMessage = error.body.message;
                    this.showToast('Erro', errorMessage, 'error');
                    this.isLoading = !this.isLoading;
                });
            }
        }catch(err){
            console.log('ERRROOUUUU =>> ' + err)
        }

    }
        
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant});
        this.dispatchEvent(event);
    }

    changeStartDate(event) {
        this.startDate = event.target.value;
        console.log('start date ', this.startDate)
    }
    
    changeEndDate(event) {
        this.endDate = event.target.value;
        console.log('endDate date ', this.endDate)
    }
    

}