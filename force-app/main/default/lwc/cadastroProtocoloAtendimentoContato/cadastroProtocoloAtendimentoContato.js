import { LightningElement,api,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import salvarContato from '@salesforce/apex/CadastroProtocoloAtendimentoController.salvarContato';
export default class CadastroProtocoloAtendimentoContato extends LightningElement {
    /* -------------------------------------------------------------------------- */
    /*                             PUBLIC ATTRIBUTES                              */
    /* -------------------------------------------------------------------------- */
    @api isNaoPaciente = false;

    @api
    clearInputLookup() {    
        this.template.querySelector("c-lwc-custom-lookup").clearInput();
    }    
    /* -------------------------------------------------------------------------- */
    /*                             PRIVATE ATTRIBUTES                             */
    /* -------------------------------------------------------------------------- */    
    @track isLoading = false;
    @track showModalCadastro = false;
    @track isContact = true;
    @track customLookUpObj = {
        sObjectApiName : 'Account',
        iconName : 'standard:account',
        placeholder : 'Pesquisa: por CPF; Nome; Telefone/Celular',
        recordTypeCondition : ' RecordType.DeveloperName = \'PersonAccount\' ',
        recordIdSelect : null,
        isShowFieldAccount:true,
        isShowFieldLead:false,
        fieldsWhereQuery:['CNPJ__c','PersonMobilePhone'],
        fieldsReturnQuery:['CNPJ__c','PersonMobilePhone','PersonBirthdate','PersonHomePhone','PersonEmail','PersonContactId','Convenio_Ultima_Consulta__c']
    };

    @track modalObj = {
        title : 'Novo Paciente'
    };

    validateMsg = '';

    @track nomeCompletoObj = {
        errorMessage : '',
        class : '',
    }
    @track dataNascimentoObj = {
        errorMessage : '',
        class : '',
    }
    @track celularObj = {
        errorMessage : '',
        class : '',
    }
    @track cpfObj = {
        errorMessage : '',
        class : '',
    }
    @track msgErrorSave = 'Campo obrigatório.'

    /* -------------------------------------------------------------------------- */
    /*                              LIFECYCLE METHODS                             */
    /* -------------------------------------------------------------------------- */
    connectedCallback(){
        console.log('CallBack');
        if(this.isNaoPaciente === true){
            this.customLookUpObj.sObjectApiName = 'Lead';
            this.customLookUpObj.iconName = 'standard:lead';
            this.customLookUpObj.recordTypeCondition = ' RecordType.DeveloperName = \'NaoPaciente\' ';
            this.customLookUpObj.isShowFieldAccount = false;
            this.customLookUpObj.isShowFieldLead = true;
            this.customLookUpObj.fieldsWhereQuery = ['MobilePhone'];
            this.customLookUpObj.fieldsReturnQuery = ['HealthCloudGA__BirthDate__c','MobilePhone','Email'];
            this.modalObj.title = 'Novo Não Paciente';
        }
    }
    /* -------------------------------------------------------------------------- */
    /*                                   METHODS                                  */
    /* -------------------------------------------------------------------------- */
    handleCloseModal(){
        try{
            this.customLookUpObj.recordIdSelect = null;
            this.showModalCadastro = false;
            this.nomeCompletoObj.errorMessage = '';
            this.nomeCompletoObj.class = '';
            this.dataNascimentoObj.errorMessage = '';
            this.dataNascimentoObj.class = '';
            this.celularObj.errorMessage = '';
            this.celularObj.class = '';
            this.cpfObj.errorMessage = '';
            this.cpfObj.class = '';
            this.modalObj = {
                title : 'Novo Paciente'
            };
        }catch(err){
            console.log(err)
        }
    }
    handleInputChange(event){
        try{
            console.log('Marcos : ' + event.target.name);
            switch (event.target.name) {
                case 'customLookUp':
                    var selectedRecord = event.detail.selectedRecord;
                    if(selectedRecord.Id == '0001'){
                        this.showModalCadastro = true;
                    }else{
                        this.customLookUpObj.recordIdSelect = selectedRecord.Id;
                        console.log('selectedRecord 1=> ' + JSON.stringify(selectedRecord));
                        this.dispatchEvent(new CustomEvent('lookupupdate',{'detail': {selectedRecord: selectedRecord}}));
                    }
                    break;
                case 'nomeCompleto':
                    this.modalObj.nomeCompleto = event.target.value;
                    this.setNomeCompletoError(true);
                    break
                case 'cpf':
                    if (event.target.value !== undefined && event.target.value.length <= 14) this.modalObj.CPF = this.getMaskCPF(event.target.value);
                    this.setCpfError(true);
                    break;
                case 'celular':
                    if (event.target.value !== undefined && event.target.value.length <= 15) {
                        event.target.value = this.getCelularMask(event.target.value,event.target.value.length == 15);
                        this.modalObj.celular = event.target.value;
                    }
                    this.setCelularError(true);
                    break;
                case 'email':
                    this.modalObj.email = event.target.value;                  
                    break
                case 'dataNascimento':
                    this.modalObj.dataNascimento = event.target.value;
                    this.setDataNascimentoError(true);
                    break
                default:
                    break;
            }
        }catch(err){
            console.log(err)
        }
    }
    
    handleSalvarRegistro(){
        if (this.isValidForm()){
            this.salvarContato();
        }
    }
    salvarContato(){
        this.isLoading = true;
        this.modalObj.integrarTasy = true;
        this.modalObj.celular = this.modalObj.celular.replace(/\D/g, '');
        salvarContato({contatoJson: JSON.stringify(this.modalObj), isNaoPaciente: this.isNaoPaciente})
        .then(resp => {
            this.showToast('Sucesso', 'Registro criado com sucesso', 'success');
            setTimeout(() => { 
                this.dispatchEvent(new CustomEvent('lookupupdate',{'detail': {selectedRecord: resp}}));
                this.handleCloseModal();
                this.customLookUpObj.recordIdSelect = resp.Id;
            }, 1000);
                    
        })
        .catch(error => {
            this.modalObj.celular = this.getCelularMask(this.modalObj.celular);
            console.log(JSON.stringify(error))
            if (error?.body?.message) {
				this.showToast('Erro!', error.body.message, 'error', 'pester');
			}
        }).finally(() => {
            this.isLoading = false;
        });
    }
    
  
    /* -------------------------------------------------------------------------- */
    /*                                 VALIDAÇÔES                                 */
    /* -------------------------------------------------------------------------- */
    showFieldInputError(classname, msg){
		var inputCmp = this.template.querySelector('.'+classname.replace(' ','.').replace(' slds-has-error',''));
		inputCmp.setCustomValidity(msg);
		inputCmp.reportValidity(); 
	}
    validarCelularOnBlur(event){
        this.setCelularError(false);
    }
    validarCelular(mobileNumber){
		const mobileRegex = /^\(\d{2}\)\s9\d{4}-\d{4}$/;
        return mobileRegex.test(mobileNumber);
	}
    validateEmail(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }
    onBlurEmail(event){
        this.showFieldInputError('email',(this.validateEmail(event.target.value) || event.target.value == '') ? '' : 'E-mail inválido');
    }
    isValidForm(){
        var isValid = false;
        var contemError = [];
        contemError.push(this.setNomeCompletoError(false));
        contemError.push(this.setCelularError(false));
        contemError.push(this.setDataNascimentoError(false));
        if(this.isNaoPaciente == false) contemError.push(this.setCpfError(false));

        if((contemError.findIndex((x) => x == true)) >= 0){
            this.showToast('Erro!', 'Campos obrigatórios não preenchidos!', 'error', 'pester');
        }else{
            isValid = true;
        }
        return isValid;
    }
    setNomeCompletoError(isInput){
        var isNotValid = false;
        var msg = this.msgErrorSave;
        if(isInput == false){
            if(this.modalObj.nomeCompleto){
                //var regex = /\b[A-Za-zÀ-ú][A-Za-zÀ-ú]+,?\s[A-Za-zÀ-ú][A-Za-zÀ-ú]{2,19}\b/gi;
                var regex = /^[A-Za-zÀ-ÖØ-öø-ÿ]+ [A-Za-zÀ-ÖØ-öø-ÿ]+.*$/;
                if(!(regex.test(this.modalObj.nomeCompleto))){
                    isNotValid = true;
                    msg = 'O nome deve conter sobrenome.'
                }
            }else{
                isNotValid = true;
            }
        }
        this.nomeCompletoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.nomeCompletoObj.errorMessage = (isNotValid) ? msg : '';
        return isNotValid;
    }
    setCelularError(isInput){
        var msg = this.msgErrorSave;
        var isNotValid = false;
        
        if(isInput == false){
            if(this.modalObj.celular){
                if(!this.validarCelular(this.modalObj.celular)){
                    isNotValid = true;
                    msg = 'Número de celular inválido.'
                }
            }else{
                isNotValid = true;
            }
        }
        //var isNotValid = (isInput == true) ? false : (!this.modalObj.celular ) ? true : false;
        this.celularObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.celularObj.errorMessage = (isNotValid) ? msg : '';
        return isNotValid;
    }
    setDataNascimentoError(isInput){
        var isNotValid = (isInput == true) ? false : (!this.modalObj.dataNascimento) ? true : false;
        this.dataNascimentoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.dataNascimentoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCpfError(isInput){
        var isNotValid = (isInput == true) ? false : (!this.modalObj.CPF || this.modalObj.CPF.length <14) ? true : false;
        this.cpfObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.cpfObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }

    /* -------------------------------------------------------------------------- */
    /*                                    UTILS                                   */
    /* -------------------------------------------------------------------------- */
    getCelularMask(cel){
        cel = cel.replace(/\D/g, '');
        cel = cel.replace(/^(\d\d)(\d)/g, '($1) $2');
        cel = cel.replace(/(\d{5})(\d)/, '$1-$2');
        return cel;
    }
    
    getMaskCPF(cpf){
        cpf = cpf.replace(/\D/g, '');
        cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
        cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
        cpf = cpf.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
        return cpf;
    }

    showFieldError(event, msg){
		var inputCmp = this.template.querySelector('.'+event.target.className.replace(' ','.').replace(' slds-has-error',''));
		inputCmp.setCustomValidity(msg);
		inputCmp.reportValidity(); 
	}
  
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant});
        this.dispatchEvent(event);
    } 
}