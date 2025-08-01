import { LightningElement, track } from 'lwc';
import fotoPaciente from '@salesforce/resourceUrl/APP_Paciente';
import iconeDados from '@salesforce/resourceUrl/APP_DadosPessoais';
import iconeFiliacao from '@salesforce/resourceUrl/APP_Filiacao';

export default class appDadosCadastrais extends LightningElement {
    fotoPaciente = fotoPaciente;
    iconeDados = iconeDados;
    iconeFiliacao = iconeFiliacao;

    nomePaciente = 'Ana Martha Galvão';
    dataNascimento = '17/09/1992';
    cpf = '025.021.224-89';

    @track nacionalidade;
    @track estadoCivil;
    @track sexo;
    @track grauInstrucao;
    @track celular;
    @track profissao;
    @track religiao;
    @track usaNomeSocial = 'nao';
    @track nomeSocial;
    @track nomeMae;
    @track nomePai;

    mostrarCampoNomeSocial = false;

    @track isFormInvalid = true;


    opcoesNacionalidade = [
        { label: 'Brasileira', value: 'brasileira' },
        { label: 'Estrangeira', value: 'estrangeira' }
    ];
    opcoesEstadoCivil = [
        { label: 'Solteiro(a)', value: 'solteiro' },
        { label: 'Casado(a)', value: 'casado' },
        { label: 'Divorciado(a)', value: 'divorciado' },
        { label: 'Viúvo(a)', value: 'viuvo' }
    ];
    opcoesSexo = [
        { label: 'Masculino', value: 'masculino' },
        { label: 'Feminino', value: 'feminino' },
        { label: 'Outro', value: 'outro' }
    ];
    opcoesGrauInstrucao = [
        { label: 'Fundamental', value: 'fundamental' },
        { label: 'Médio', value: 'medio' },
        { label: 'Superior', value: 'superior' },
        { label: 'Pós-graduação', value: 'pos' }
    ];
    opcoesProfissao = [
        { label: 'Médico', value: 'medico' },
        { label: 'Enfermeiro', value: 'enfermeiro' },
        { label: 'Professor', value: 'professor' }
    ];
    opcoesReligiao = [
        { label: 'Católica', value: 'catolica' },
        { label: 'Evangélica', value: 'evangelica' },
        { label: 'Espírita', value: 'espirita' },
        { label: 'Ateu', value: 'ateu' }
    ];
    opcoesNomeSocial = [
        { label: 'Sim', value: 'sim' },
        { label: 'Não', value: 'nao' }
    ];

    handleNomeSocialChange(event) {
        this.usaNomeSocial = event.detail.value;
        this.mostrarCampoNomeSocial = (this.usaNomeSocial === 'sim');
        this.checkFormValidity();
    }

    handleInputChange(event) {
    this[event.target.name] = event.detail.value;
    this.checkFormValidity();
    }

    checkFormValidity() {
        const requiredFields = [
            this.nacionalidade,
            this.estadoCivil,
            this.sexo,
            this.grauInstrucao,
            this.celular,
            this.profissao,
            this.religiao,
            this.usaNomeSocial,
            this.nomeMae,
            this.nomePai
        ];

        if (this.mostrarCampoNomeSocial) {
            requiredFields.push(this.nomeSocial);
        }

        this.isFormInvalid = requiredFields.some(field => {
            if (field === undefined || field === null) return true;
            if (typeof field === 'string' && field.trim() === '') return true;
            return false;
        });
    }


    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
        console.log('Voltando...');
    }
    handleContinuar() {
        this.dispatchEvent(new CustomEvent('continuar'));
        console.log('Continuando...');
    }
}