import { LightningElement, api, track, wire } from 'lwc';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ALIAS_FIELD from '@salesforce/schema/User.Alias';

export default class AppScheduleDetails extends LightningElement {
    @api consulta;
    detalhesConsulta = detalhesConsultaIcon;
    @track showConfirmModal = false;
    isMedico = false;

    fecharModal() {
        const fecharEvent = new CustomEvent('fechar');
        this.dispatchEvent(fecharEvent);
    }

    abrirModalConfirmacao() {
        this.dispatchEvent(new CustomEvent('confirmar', {
            detail: {
                imagem: this.detalhesConsulta 
            },
            bubbles: true,
            composed: true
        }));
    } 

    fecharConfirmModal() {
        this.showConfirmModal = false;
    }

    confirmarConsultaSelecionada() {
        this.showConfirmModal = false;
        const confirmEvent = new CustomEvent('confirmar', { detail: this.consulta });
        this.dispatchEvent(confirmEvent);
    }

    get dataHoraFormatada() {
        if (this.consulta?.start) {
            const data = new Date(this.consulta.start);
            const dia = String(data.getDate()).padStart(2, '0');
            const mes = String(data.getMonth() + 1).padStart(2, '0');
            const ano = data.getFullYear();
            const horas = String(data.getHours()).padStart(2, '0');
            const minutos = String(data.getMinutes()).padStart(2, '0');
            
            return `${dia}/${mes}/${ano} ${horas}:${minutos}`;
        }
        return 'Data não informada';
    }

    get nomeMedico() {
        if (this.isMedico) {
            return this.consulta?.actor?.[0]?.nomeMedico || this.consulta?.actor?.[1]?.display;
        }
        return this.consulta?.actor?.[0]?.nomeMedico || 'Nome não informado';
    }

    get nomeUnidade() {
        return this.consulta?.actor?.[2]?.display || 'Local não informado';
    }

    get especialidade() {
        return this.consulta?.specialty?.[0]?.display || 'Especialidade não informada';
    }

    get enderecoCompleto() {
        const atorComEndereco = this.consulta?.actor?.find(a => a.address);
        
        if (atorComEndereco?.address) {
            const addr = atorComEndereco.address;
            const parts = [
                addr.street,
                addr.complement,  
                addr.district,
                `${addr.city} - ${addr.state}`,
                addr.zipcode
            ].filter(part => part && part.trim() !== '');
            
            return parts.join(', ');
        }
        return 'Endereço não informado';
    }

    get tipoConsulta() {
        return this.consulta?.appointmentType?.display || 'Tipo não informado';
    }

    get statusFormatado() {
        return this.consulta?.status || 'Status não informado';
    }

    get possuiObservacoes() {
        return this.consulta?.description || this.consulta?.comment;
    }

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD, ALIAS_FIELD] })
    userProfileHandler({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            const alias = data.fields.Alias.value;

            if (profileName === 'APP_Medico') {
                this.isMedico = true;
            } else {
                this.isMedico = false;
            }
        } else if (error) {
            console.error('Erro ao buscar perfil:', error);
        }
    }
}