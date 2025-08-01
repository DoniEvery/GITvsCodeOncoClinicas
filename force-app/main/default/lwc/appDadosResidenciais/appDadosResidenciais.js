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

    cep = '';
    endereco = '';
    numero = '';
    complemento = '';
    bairro = '';
    municipio = '';
    estado = '';
    pais = '';
    email = '';
    telefoneAdicional = '';

    handleInputChange(event) {
        const campo = event.target.name;
        const valor = event.target.value;

        this[campo.toLowerCase()] = valor;
    }

    handleTelefoneInput(event) {
        let raw = event.target.value.replace(/\D/g, '');
        if (raw.length > 11) raw = raw.slice(0, 11);

        let formatted = '';
        if (raw.length > 0) {
            formatted = '(' + raw.substring(0, 2);
        }
        if (raw.length >= 3) {
            formatted += ') ' + raw.substring(2, 7);
        }
        if (raw.length >= 8) {
            formatted += '-' + raw.substring(7);
        }

        this.telefoneAdicional = formatted;
        event.target.value = formatted;
    }

    handleCepInput(event) {
        let raw = event.target.value.replace(/\D/g, '');
        if (raw.length > 8) raw = raw.slice(0, 8);

        let formatted = raw;
        if (raw.length > 5) {
            formatted = raw.substring(0, 5) + '-' + raw.substring(5);
        }

        this.cep = formatted;
        event.target.value = formatted;
    }

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
        console.log('Voltando...');
    }
    handleContinuar() {
        console.log('Continuando...');
    }
}