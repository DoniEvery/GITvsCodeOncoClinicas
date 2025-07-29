import { LightningElement, track, api } from 'lwc';
import getPacientesPorAcompanhante from '@salesforce/apex/APP_LoginController.getPacientesPorAcompanhante';
import pacienteIcon from '@salesforce/resourceUrl/APP_Paciente';

export default class AppLoginAcompanhante extends LightningElement {
    @api loginUrl;
    @api acompanhanteId;

    pacienteIcon = pacienteIcon;
    @track selectedPacienteId = null;
    @track pacientesOriginais = [];
    @track isLoading = false;

    connectedCallback() {
        if (this.acompanhanteId) {
            this.carregarPacientes();
        }
    }

    async carregarPacientes() {
        this.isLoading = true;
        try {
            const pacientes = await getPacientesPorAcompanhante({ acompanhanteId: this.acompanhanteId });
            console.log('Pacientes recebidos:', JSON.stringify(pacientes)); // 👈 aqui!
            this.pacientesOriginais = pacientes;
        } catch (error) {
            console.error('Erro ao buscar pacientes:', error);
        } finally {
            this.isLoading = false;
        }
    }
    

    get pacientes() {
        return this.pacientesOriginais.map(p => {
            return {
                ...p,
                checked: this.selectedPacienteId === p.id,
                className:
                    'paciente-card slds-box slds-m-bottom_small' +
                    (this.selectedPacienteId === p.id ? ' selecionado' : '')
            };
        });
    }       

    get temPacientes() {
        return this.pacientes && this.pacientes.length > 0;
    }

    get botaoDesabilitado() {
        return this.selectedPacienteId === null;
    }

    get showLogin() {
        return true;
    }

    handleSelecionarPaciente(event) {
        this.selectedPacienteId = event.target.value;
    }

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
    }

    handleLogin() {
        if (this.selectedPacienteId) {
            if (this.loginUrl) {
                window.location.href = this.loginUrl;
            } else {
                console.error('loginUrl não foi definido.');
            }
        } else {
            console.error('Nenhum paciente selecionado.');
        }
    }
}