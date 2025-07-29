import { LightningElement,track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import salvarCaso from '@salesforce/apex/CadastroProtocoloAtendimentoController.salvarCaso';
import getPickListValuesOrigem from '@salesforce/apex/CadastroProtocoloAtendimentoController.getPickListValuesOrigem';
import getPickListValuesMotivo from '@salesforce/apex/CadastroProtocoloAtendimentoController.getPickListValuesMotivo';
import getPickListValuesMotivoNaoAgendamento from '@salesforce/apex/CadastroProtocoloAtendimentoController.getPickListValuesMotivoNaoAgendamento';

export default class CadastroProtocoloAtendimento extends NavigationMixin(LightningElement) {
    /* -------------------------------------------------------------------------- */
    /*                             PRIVATE ATTRIBUTES                             */
    /* -------------------------------------------------------------------------- */
    @track msgErrorSave = 'Campo obrigatório.'
    @track isLoading = false;

    @track protocoloAtendimentoObj = {
        caso : {},
        especialidadeMedica : {},
        convenio : {},
        isNaoPaciente : false,
        lead : {},
        account : {},
        unidade : {},
        medico:{},
        assuntoUnidade : {}
    }

    @track textAreaDescricaoObj = {
        errorMessage : '',
        class : '',
    }

    @track comboboxOrigemObj = {
        options : [],
        errorMessage : '',
        class : '',
    }
    @track comboboxMotivoObj = {
        options : [],
        errorMessage : '',
        class : '',
    }

    @track tipoDePessoaComboboxObj = {
        options : [
            { value: 'Paciente', label: 'Paciente'},
            { value: 'Não Paciente', label: 'Não Paciente'}
        ],
        value : 'Paciente'
    };

    @track naoAgendamentoObj = {
        errorMessage : '',
        class : '',
        isShow : false,
        options : [],
        isConvenioObrigatorio : false,
        isEspecialidadeObrigatorio : false
    }

    @track customLookUpUnidadeObj = {
        errorMessage : '',
        class : '',
        sObjectApiName : 'Account',
        fieldsReturnQuery : ['UF_Endereco__c'],
        condition : ' RecordType.DeveloperName = \'UnidadeAtendimento\''
    }
    @track customLookUpNomeDoMedicoObj = {
        errorMessage : '',
        class : '',
        required: false,
        sObjectApiName : 'Contact',
        fieldsReturnQuery : ['UF_do_CRM__c'],
        condition : ' UF_do_CRM__c = \'SP\''
    }

    @track customLookUpAssuntoObj = {
        value : {},
        errorMessage : '',
        class : '',
        fildFilterMap : 'NomeDetalhe__c',
        fieldsWhereQuery : ['NomeAssuntoUnid__c','NomeAssunto__c','MotivoCaso__c'],
        fieldsReturnQuery : ['DisponivelPaciente__c','DisponivelNaoPacientes__c','NomeAssuntoUnid__c','NomeAssunto__c','SLA__c','SLA__r.BusinessHoursId','FilaAtendimento__c','FilaAtendimento__r.FilaAtendimento__c','Nasce_fechado__c', 'Prioridade__c', 'MotivoCaso__c','AssuntoDetalhe__c','NomeDetalhe__c',' Assunto__c','MedicoObrigatorio__c'],
        sObjectApiName : 'AssuntoUnidade__c',
        fieldCustomNameToShow : 'NomeAssuntoUnid__c'
    }
    @track customLookUpAssuntoDetalheObj = {
        isShow : false,
        errorMessage : '',
        class : '',
        fieldsReturnQuery :['DisponivelPaciente__c','DisponivelNaoPacientes__c','NomeAssuntoUnid__c','NomeAssunto__c','SLA__c','SLA__r.BusinessHoursId','FilaAtendimento__c','FilaAtendimento__r.FilaAtendimento__c','Nasce_fechado__c', 'Prioridade__c', 'MotivoCaso__c','AssuntoDetalhe__c','NomeDetalhe__c',' Assunto__c'],
        sObjectApiName : 'AssuntoUnidade__c',
        fieldCustomNameToShow : 'NomeDetalhe__c'
    }
    @track customLookUpConvenioNaoAtendidoObj = {
        errorMessage : '',
        class : '',
        sObjectApiName : 'Lista_Plano_Convenios__c',
    }
    @track customLookUpEspecialidadeNaoAtendidaObj= {
        errorMessage : '',
        class : '',
        sObjectApiName : 'EspecialidadeMed__c',
    }
    @track customLookUpContatoObj = {
        errorMessage : '',
        class : '',
    }
    @track knowledgeArticleObj = {
        knowledgeRecordTypeName : 'ArtigoAberturaDeCaso'
    }

    /* -------------------------------------------------------------------------- */
    /*                                WIRE METHODS                                */
    /* -------------------------------------------------------------------------- */
    @wire(getPickListValuesOrigem, { recordTypeName: 'CasoAtendimentoPaciente' })
	wiredPickListValuesOrigem({ error, data }) {
		this.comboboxOrigemObj.options = [];
		if (data && data.length) {
			this.comboboxOrigemObj.options = data.map((field) => {
				return {
					label: field.label,
					value: field.value,
				};
			});
		} else if (error) {
			console.error(error);
            //this.showToast('Erro', reduceErrors(error).join(' / '), 'error');
		}
	}
    @wire(getPickListValuesMotivo)
	wiredPickListValuesMotivo({ error, data }) {
		this.comboboxMotivoObj.options = [];
		if (data && data.length) {
			this.comboboxMotivoObj.options = data.map((field) => {
				return {
					label: field.label,
					value: field.value
				};
			});
		} else if (error) {
			console.error(error);
            this.showToast('Erro', reduceErrors(error).join(' / '), 'error');
		}
	}
    @wire(getPickListValuesMotivoNaoAgendamento)
	wiredPickListValuesMotivoNaoAgendamento({ error, data }) {
		this.naoAgendamentoObj.options = [];
		if (data && data.length) {
			this.naoAgendamentoObj.options = data.map((field) => {
				return {
					label: field.label,
					value: field.value
				};
			});
		} else if (error) {
			console.error(error);
            this.showToast('Erro', reduceErrors(error).join(' / '), 'error');
		}
	}
     /* -------------------------------------------------------------------------- */
    /*                                   METHODS                                  */
    /* -------------------------------------------------------------------------- */
    handleInputChange(event){
        try{
            switch (event.target.name) {
                case 'origem':
                    this.protocoloAtendimentoObj.caso.Origem__c = event.target.value;
                    this.setComboboxOrigemError();
                    break;
                case 'motivo':
                    this.protocoloAtendimentoObj.caso.MotivoCaso__c = event.target.value;
                    this.naoAgendamentoObj.isShow = event.target.value === 'Não agendamento' ? true: false;
                    this.setClassToClear('Assuntos');
                    this.setComboboxMotivoError();
                    break;
                case 'customLookUpEspecialidadeNaoAtendida':
                    this.protocoloAtendimentoObj.especialidadeMedica = event.detail.selectedRecord;
                    this.setCustomLookUpEspecialidadeNaoAtendidaError(true);
                    break; 
                case 'customLookUpConvenioNaoAtendido':
                    this.protocoloAtendimentoObj.convenio = event.detail.selectedRecord;
                    this.setCustomLookUpConvenioNaoAtendidoObjError(true);
                    break;                                                                               
                case 'motivoNaoAgendamento':
                    this.protocoloAtendimentoObj.caso.MotivoNaoAgendamento__c = event.target.value;
                    this.naoAgendamentoObj.isConvenioObrigatorio = event.target.value ==='Convênio não abrange a especialidade solicitada' ? true : false;
                    this.naoAgendamentoObj.isEspecialidadeObrigatorio = event.target.value ==='Especialidade não encontrada na clínica' ? true : false;
                    this.setComboboxNaoAgendamentoError();
                    this.setCustomLookUpConvenioNaoAtendidoObjError(true);
                    this.setCustomLookUpEspecialidadeNaoAtendidaError(true);
                    break;
                case 'razaoNaoAgendamento':
                    this.protocoloAtendimentoObj.caso.RazaoNaoAgendamento__c = event.target.value;
                    break;                                                                            
                case 'paciente':
                    this.tipoDePessoaComboboxObj.value = event.target.value;
                    this.protocoloAtendimentoObj.isNaoPaciente = (this.tipoDePessoaComboboxObj.value == 'Não Paciente') ? true : false;
                    this.setClassToClear('Assuntos');
                    break;
                case 'customLookUpContatoNaoPaciente':
                    this.protocoloAtendimentoObj.lead = event.detail.selectedRecord;
                    if(event.detail.selectedRecord?.Id){
                        this.protocoloAtendimentoObj.caso.ContactEmail = (event.detail.selectedRecord.Email) ? event.detail.selectedRecord.Email :'';
                        this.protocoloAtendimentoObj.caso.EmailAlternativo__c = (event.detail.selectedRecord.Email) ? event.detail.selectedRecord.Email :'';
                        this.protocoloAtendimentoObj.caso.NumeroRetorno__c = (event.detail.selectedRecord.MobilePhone) ? this.getCelularMask(event.detail.selectedRecord.MobilePhone,event.detail.selectedRecord.MobilePhone.length == 11) :'';
                    }
                    break;
                case 'customLookUpContatoPaciente':
                    console.log('selectedRecord ==>>> ' + JSON.stringify(event.detail.selectedRecord));
                    this.protocoloAtendimentoObj.account = event.detail.selectedRecord;
                    if(event.detail.selectedRecord?.Id){
                        this.protocoloAtendimentoObj.caso.ContactEmail = (event.detail.selectedRecord.PersonEmail) ? event.detail.selectedRecord.PersonEmail :'';
                        this.protocoloAtendimentoObj.caso.EmailAlternativo__c = (event.detail.selectedRecord.PersonEmail) ? event.detail.selectedRecord.PersonEmail :'';
                        var PersonMobilePhone =  (event.detail.selectedRecord.PersonMobilePhone) ? this.getCelularMask(event.detail.selectedRecord.PersonMobilePhone,event.detail.selectedRecord.PersonMobilePhone.length==11) :'';
                        var PersonHomePhone =  (event.detail.selectedRecord.PersonHomePhone) ? this.getCelularMask(event.detail.selectedRecord.PersonHomePhone,event.detail.selectedRecord.PersonHomePhone.length == 11) :'';
                        this.protocoloAtendimentoObj.caso.NumeroRetorno__c = (PersonMobilePhone) ? PersonMobilePhone : PersonHomePhone;
                    }
                    this.setCustomLookUpContatoObjError(true);
                    break;
                case 'customLookUpUnidade':
                    this.protocoloAtendimentoObj.unidade = event.detail.selectedRecord;
                    if(!this.protocoloAtendimentoObj.unidade?.Id) this.setClassToClear('Unidade');
                    this.setCustomLookUpUnidadeObjError(true);
                    break;
                case 'customLookUpNomeDoMedico':
                    this.protocoloAtendimentoObj.medico = event.detail.selectedRecord;
                    this.setCustomLookUpNomeDoMedicoObjError(true);
                    break;
                case 'customLookUpAssunto':
                    this.customLookUpAssuntoObj.value = event.detail.selectedRecord;
                    console.log('-selectedRecord-' + JSON.stringify(event.detail.selectedRecord));
                    if(!this.customLookUpAssuntoObj.value?.Id) this.setClassToClear('Assunto');
                    this.setCustomLookUpAssuntoObjError(true);

                    this.customLookUpAssuntoDetalheObj.isShow = (event.detail.selectedRecord?.NomeDetalhe__c) ? true : false;
                    this.customLookUpNomeDoMedicoObj.required = (event.detail.selectedRecord?.MedicoObrigatorio__c == true) ? true : false;
                    this.protocoloAtendimentoObj.assuntoUnidade = (!event.detail.selectedRecord?.NomeDetalhe__c) ? event.detail.selectedRecord : {};

                    break;
                case 'customLookUpAssuntoDetalhe':
                    this.protocoloAtendimentoObj.assuntoUnidade = event.detail.selectedRecord; // aqui
                    this.setCustomLookUpAssuntoDetalheObjError(true);
                    break;
                case 'descricao':
                    this.protocoloAtendimentoObj.caso.Description = event.target.value;
                    this.setTextAreaDescricaoError();
                    break;
                case 'email':
                    this.protocoloAtendimentoObj.caso.EmailAlternativo__c = event.target.value;
                    break;
                case 'numeroRetorno':
                    if (event.target.value !== undefined && event.target.value.length <= 15) {
                        event.target.value = this.getCelularMask(event.target.value,event.target.value.length == 15);
                        this.protocoloAtendimentoObj.caso.NumeroRetorno__c = event.target.value;
                    }                         
                    break;
                case 'enviarProtocolo':
                    this.protocoloAtendimentoObj.caso.EnvioProtocolo__c = event.target.checked;                   
                    break;                     
                default:
                    break;
            }
        }catch(error){
            //console.log(error)
        }
    }

    handleSalvar(){
        if(this.validarCamposObrigatorios()){
            this.salvarCaso();
        }
    }
    handleClearFields(){
        this.protocoloAtendimentoObj = {
            caso : {},
            especialidadeMedica : {},
            convenio : {},
            isNaoPaciente : false,
            lead : {},
            account : {},
            unidade : {},
            medico:{},
            assuntoUnidade : {}
        };

        this.naoAgendamentoObj.errorMessage = '';
        this.naoAgendamentoObj.class = '';
        this.naoAgendamentoObj.isShow = false;
        this.naoAgendamentoObj.isConvenioObrigatorio = false;
        this.naoAgendamentoObj.isEspecialidadeObrigatorio = false;
        this.tipoDePessoaComboboxObj.value = 'Paciente';
        this.textAreaDescricaoObj.errorMessage = '';
        this.textAreaDescricaoObj.class = '';
        this.comboboxOrigemObj.errorMessage = '';
        this.comboboxOrigemObj.class = '';
        this.comboboxMotivoObj.errorMessage = '';
        this.comboboxMotivoObj.class = '';
        this.customLookUpUnidadeObj.errorMessage = '';
        this.customLookUpUnidadeObj.class = '';
        this.customLookUpNomeDoMedicoObj.errorMessage = '';
        this.customLookUpNomeDoMedicoObj.class = '';
        this.customLookUpAssuntoObj.errorMessage = '';
        this.customLookUpAssuntoObj.class = '';
        this.customLookUpAssuntoObj.value = {};
        this.customLookUpAssuntoDetalheObj.errorMessage = '';
        this.customLookUpAssuntoDetalheObj.class = '';
        this.customLookUpConvenioNaoAtendidoObj.errorMessage = '';
        this.customLookUpConvenioNaoAtendidoObj.class = '';
        this.customLookUpEspecialidadeNaoAtendidaObj.errorMessage = '';
        this.customLookUpEspecialidadeNaoAtendidaObj.class = '';
        this.customLookUpContatoObj.errorMessage = '';
        this.customLookUpContatoObj.class = '';

        this.template.querySelectorAll('c-lwc-custom-lookup').forEach(cmp => {
            cmp.clearInput();
        });
        this.template.querySelectorAll('c-cadastro-protocolo-atendimento-contato').forEach(cmp => {
            cmp.clearInputLookup();
        });
        this.onBlurEmail({target : {value : ''}});
        this.onBlurNumeroRetorno({target : {value : ''}});
    }

    async navigateToRecordPage(recId,objectApiName) {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objectApiName,
                actionName: 'view',
            }
        });
        window.open(url, '_self');
    }
    salvarCaso(){
        this.isLoading = true;
        if(this.protocoloAtendimentoObj.account?.PersonBirthdate){
            this.protocoloAtendimentoObj.account.PersonBirthdate = this.parseDateString(this.protocoloAtendimentoObj.account.PersonBirthdate);
        }
        if(this.protocoloAtendimentoObj.lead?.HealthCloudGA__BirthDate__c){
            this.protocoloAtendimentoObj.lead.HealthCloudGA__BirthDate__c = this.parseDateString(this.protocoloAtendimentoObj.lead.HealthCloudGA__BirthDate__c);
        }
        console.log('casoJson ' + JSON.stringify(this.protocoloAtendimentoObj).replaceAll(',"showItem":true','').replaceAll(',"showItem":false',''));
        salvarCaso({casoJson: JSON.stringify(this.protocoloAtendimentoObj).replaceAll(',"showItem":true','').replaceAll(',"showItem":false','')})
        .then(resp => {
            console.log(JSON.stringify(resp));
            this.showToast('Sucesso', 'Registro criado com sucesso!','success');
            setTimeout(() => {
                this.handleClearFields();                            
                this.navigateToRecordPage(resp.Id,'Case');
            }, 2000);  

        })
        .catch(error => {
            console.log('handleSalvar.salvarCaso.Error: ', error);
            if (error?.body?.message) {
                this.showToast('Erro', error.body.message, 'error','pester');
            }
        }).finally(() => {
            this.isLoading = false;
        });
    }
    /* -------------------------------------------------------------------------- */
    /*                                UTIL METHODS                                */
    /* -------------------------------------------------------------------------- */
    parseDateString(inputDate) {
        if(inputDate.includes('/')){
            var parts = inputDate.split('/');
            inputDate = parts[2] + '-' + parts[1] + '-' + parts[0];
        }
        return inputDate;
    }
    clearInput(className){
        this.template.querySelectorAll(className).forEach(cmp => {cmp.clearInput()});
    }
    getCelularMask(cel,isCel){
        cel = cel.replace(/\D/g, '');
        cel = cel.replace(/^(\d\d)(\d)/g, '($1) $2');
        cel = (isCel == true ) ? cel.replace(/(\d{5})(\d)/, '$1-$2') : cel.replace(/(\d{4})(\d)/, '$1-$2');
        return cel;
    }   
    validateEmail(email){
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }
    validatePhoneNumber(phoneNumber) {
        const phoneRegex = /^\(\d{2}\)\s\d{4,5}-\d{4}$/;
        return phoneRegex.test(phoneNumber);
    }
    validateMobilePhoneNumber(mobileNumber) {
        const mobileRegex = /^\(\d{2}\)\s9\d{4}-\d{4}$/;
        return mobileRegex.test(mobileNumber);
    }
    validarNumeroRetorno(value){
        var isValid = false;
        if(value.length == 14){
            isValid = this.validatePhoneNumber(value);
        }else if(value.length == 15){
            isValid = this.validateMobilePhoneNumber(value);
        }
        return isValid;
    }

    showFieldInputError(classname, msg){
		var inputCmp = this.template.querySelector('.'+classname.replace(' ','.').replace(' slds-has-error',''));
		inputCmp.setCustomValidity(msg);
		inputCmp.reportValidity(); 
	}
    onBlurEmail(event){
        this.showFieldInputError('email',(this.validateEmail(event.target.value) || event.target.value == '') ? '' : 'E-mail inválido');
    }
    onBlurNumeroRetorno(event){
        this.showFieldInputError('numeroRetorno',(this.validarNumeroRetorno(event.target.value) || event.target.value == '') ? '' : 'Número de retorno inválido');
    }
    validarCamposObrigatorios(){
        var isValid = false;
        var contemError = [];

        contemError.push(this.setComboboxOrigemError());
        contemError.push(this.setComboboxMotivoError());
        contemError.push(this.setCustomLookUpUnidadeObjError(false));
        if(this.customLookUpNomeDoMedicoObj.required == true) contemError.push(this.setCustomLookUpNomeDoMedicoObjError(false));
        contemError.push(this.setCustomLookUpAssuntoObjError(false));
        if(this.customLookUpAssuntoDetalheObj.isShow) contemError.push(this.setCustomLookUpAssuntoDetalheObjError(false));
        contemError.push(this.setTextAreaDescricaoError());
        contemError.push(this.setCustomLookUpContatoObjError(false));

        

        if(this.naoAgendamentoObj.isShow){
            contemError.push(this.setComboboxNaoAgendamentoError());
            if(this.naoAgendamentoObj.isConvenioObrigatorio) contemError.push(this.setCustomLookUpConvenioNaoAtendidoObjError(false));
            if(this.naoAgendamentoObj.isEspecialidadeObrigatorio) contemError.push(this.setCustomLookUpEspecialidadeNaoAtendidaError(false));
        }

        if((contemError.findIndex((x) => x == true)) >= 0){
            this.showToast('Erro!', 'Campos obrigatórios não preenchidos!', 'error', 'pester');
        }else{
            isValid = true;
        }
        return isValid;
    }
    showToast(title, message, type, mode) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: type,
				mode: mode
			})
		);
	}
    /* -------------------------------------------------------------------------- */
    /*                                 SET METHODS                                */
    /* -------------------------------------------------------------------------- */
    setClassToClear(type){
        var classesToClear = [];
        switch (type) {
            case 'Unidade':
                classesToClear = ['.lookupMedicoClass','.lookupAssuntoUnidadeClass','.lookupAssuntoDetalheClass'];
                break;
            case 'Assunto':
                classesToClear = ['.lookupAssuntoDetalheClass'];
                break;
            case 'Assuntos':
                classesToClear = ['.lookupAssuntoUnidadeClass','.lookupAssuntoDetalheClass'];
                break;
            
        }
        if(classesToClear.length) this.clearInput(classesToClear);
    }
    setComboboxOrigemError(){
        var isNotValid = (!this.protocoloAtendimentoObj.caso.Origem__c) ? true : false;
        this.comboboxOrigemObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.comboboxOrigemObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setComboboxMotivoError(){
        var isNotValid = (!this.protocoloAtendimentoObj.caso.MotivoCaso__c) ? true : false;
        this.comboboxMotivoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.comboboxMotivoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setTextAreaDescricaoError(){
        var isNotValid = (!this.protocoloAtendimentoObj.caso.Description) ? true : false;
        this.textAreaDescricaoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.textAreaDescricaoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setComboboxNaoAgendamentoError(){
        var isNotValid = (!this.protocoloAtendimentoObj.caso.MotivoNaoAgendamento__c) ? true : false;
        this.naoAgendamentoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.naoAgendamentoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpContatoObjError(){
        var motivos = ['Agendamento','Reclamação','Elogio','Solicitação'];
        var isNotValid = false;
        if(this.protocoloAtendimentoObj.isNaoPaciente == false){
            if((motivos.findIndex((x) => x == this.protocoloAtendimentoObj.caso.MotivoCaso__c)) >= 0 && !this.protocoloAtendimentoObj.account?.Id) isNotValid= true;
        }
        this.customLookUpContatoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpContatoObj.errorMessage = (isNotValid) ? 'Campo paciente obrigatório para o motivo selecionado.' : '';
        return isNotValid;
    }

    setCustomLookUpConvenioNaoAtendidoObjError(isInputChange){
        var isNotValid = (isInputChange == true) ? false : (!this.protocoloAtendimentoObj.convenio?.Id) ? true : false;
        this.customLookUpConvenioNaoAtendidoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpConvenioNaoAtendidoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpEspecialidadeNaoAtendidaError(isInputChange){
        var isNotValid = (isInputChange) ? false : (!this.protocoloAtendimentoObj.especialidadeMedica?.Id) ? true : false;
        this.customLookUpEspecialidadeNaoAtendidaObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpEspecialidadeNaoAtendidaObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpUnidadeObjError(isInputChange){
        var isNotValid = (isInputChange == true) ? false : (!this.protocoloAtendimentoObj.unidade?.Id) ? true : false;
        this.customLookUpUnidadeObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpUnidadeObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpNomeDoMedicoObjError(isInputChange){
        var isNotValid = (isInputChange == true) ? false : (!this.protocoloAtendimentoObj.medico?.Id) ? true : false;
        this.customLookUpNomeDoMedicoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpNomeDoMedicoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpAssuntoObjError(isInputChange){
        var isNotValid = (isInputChange == true) ? false : (!this.customLookUpAssuntoObj.value?.Id) ? true : false;
        this.customLookUpAssuntoObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpAssuntoObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }
    setCustomLookUpAssuntoDetalheObjError(isInputChange){
        var isNotValid = (isInputChange == true) ? false : (!this.protocoloAtendimentoObj.assuntoUnidade?.Id) ? true : false;
        this.customLookUpAssuntoDetalheObj.class = (isNotValid) ? 'slds-has-error' : '' ;
        this.customLookUpAssuntoDetalheObj.errorMessage = (isNotValid) ? this.msgErrorSave : '';
        return isNotValid;
    }


    /* -------------------------------------------------------------------------- */
    /*                                 GET METHODS                                */
    /* -------------------------------------------------------------------------- */
    get getIsDisabledLookUpNomeDoMedico(){
        return (!this.protocoloAtendimentoObj.unidade?.Id)
    }
    get getHelpTextLookUpNomeDoMedico(){
        return 'Para habilitar o campo Selecione (Unidade)'
    }
    get getLabelLookUpNomeDoMedico(){
        return (this.customLookUpNomeDoMedicoObj.required == true) ? '* Nome do Médico' : 'Nome do Médico';
    }
    get getIsDisabledLookUpAssunto(){
        return (!this.protocoloAtendimentoObj.caso?.MotivoCaso__c || !this.protocoloAtendimentoObj.unidade?.Id)
    }
    get getHelpTextLookUpAssunto(){
        var msg = 'Para habilitar o campo Selecione (';
        var campos = [];
        if(!this.protocoloAtendimentoObj.caso?.MotivoCaso__c) campos.push((campos.length > 0) ? ' e Motivo' : 'Motivo')
        if(!this.protocoloAtendimentoObj.unidade?.Id) campos.push((campos.length > 0) ? ' e Unidade' : 'Unidade')
        campos.forEach(element=>{msg += element});
        msg+=')'
        return msg;
    }
    get getIsDisabledLookUpAssuntoDetalhe(){
        return (!this.protocoloAtendimentoObj.caso?.MotivoCaso__c || !this.protocoloAtendimentoObj.unidade?.Id ||!this.customLookUpAssuntoObj.value?.Id)
    }
    get getHelpTextLookUpAssuntoDetalhe(){
        var msg = 'Para habilitar o campo Selecione (';
        var campos = [];
        if(!this.protocoloAtendimentoObj.caso?.MotivoCaso__c) campos.push((campos.length > 0) ? ' e Motivo' : 'Motivo')
        if(!this.protocoloAtendimentoObj.unidade?.Id) campos.push((campos.length > 0) ? ' e Unidade' : 'Unidade')
        if(!this.customLookUpAssuntoObj.value?.Id) campos.push((campos.length > 0) ? ' e Assunto' : 'Assunto')
        campos.forEach(element=>{msg += element});
        msg+=')'
        return msg;
    }
    get knowledgeArticleAssuntoUnidadeId(){
        return (this.customLookUpAssuntoObj.value?.Id) ? this.customLookUpAssuntoObj.value?.Id : '';
    }
    get knowledgeArticleAssuntoUnidadeSelected(){
        return (this.customLookUpAssuntoObj.value?.Id) ? true : false;
    }
    get knowledgeArticleMotivoAssuntoUnidade(){
        return (this.customLookUpAssuntoObj.value?.MotivoCaso__c) ? this.customLookUpAssuntoObj.value?.MotivoCaso__c : '';
    }
    /* -------------------------------------------------------------------------- */
    /*                            GET CONDITION METHODS                           */
    /* -------------------------------------------------------------------------- */
    get getCustomLookUpAssuntoObjCondition(){
        var MotivoEUnidadeCondition = (this.protocoloAtendimentoObj.caso?.MotivoCaso__c && this.protocoloAtendimentoObj.unidade?.Id) ? ' AND MotivoCaso__c = \'' + this.protocoloAtendimentoObj.caso.MotivoCaso__c + '\' AND Unidade__c = \'' + this.protocoloAtendimentoObj.unidade.Id +'\' ': ''; 
        var DisponivelPacienteCondition = (this.protocoloAtendimentoObj.isNaoPaciente) ? ' DisponivelNaoPacientes__c = true' : ' DisponivelPaciente__c = true'
        var condition = DisponivelPacienteCondition + MotivoEUnidadeCondition + ' AND Ativo__c = true';
        return condition;
    }
    get getCustomLookUpAssuntoDetalheObjCondition(){
        var MotivoEUnidadeCondition = (this.protocoloAtendimentoObj.caso?.MotivoCaso__c && this.protocoloAtendimentoObj.unidade?.Id) ? ' AND MotivoCaso__c = \'' + this.protocoloAtendimentoObj.caso.MotivoCaso__c + '\' AND Unidade__c = \'' + this.protocoloAtendimentoObj.unidade.Id +'\' ': ''; 
        var DisponivelPacienteCondition = (this.protocoloAtendimentoObj.isNaoPaciente) ? ' DisponivelNaoPacientes__c = true' : ' DisponivelPaciente__c = true'
        var condition = DisponivelPacienteCondition + MotivoEUnidadeCondition + ' AND AssuntoDetalhe__c != null AND Ativo__c = true AND NomeDetalhe__c = \'' + this.customLookUpAssuntoObj.value.NomeDetalhe__c + '\'';
        return condition;
    }
    get getCustomLookUpNomeDoMedicoObjCondition(){
        return (this.protocoloAtendimentoObj.unidade?.UF_Endereco__c) ? ' UF_do_CRM__c = \'' + this.protocoloAtendimentoObj.unidade.UF_Endereco__c + '\'' : '';
    }
}