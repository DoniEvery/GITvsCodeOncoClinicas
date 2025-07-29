import { LightningElement } from 'lwc';
import pacienteIcon from '@salesforce/resourceUrl/APP_PacienteLogin';
import acompanhanteIcon from '@salesforce/resourceUrl/APP_AcompanhanteLogin';
import logoOnco from '@salesforce/resourceUrl/APP_LogoOncoclinicas';

export default class AppPreLoginForm extends LightningElement {
    pacienteIcon = pacienteIcon;
    acompanhanteIcon = acompanhanteIcon;
    logoOnco = logoOnco;

    opcoes = [
        { label: 'Paciente', value: 'Paciente', checked: true, icon: pacienteIcon },
        { label: 'Acompanhante', value: 'Acompanhante', checked: false, icon: acompanhanteIcon }
    ];

    selectedValue = 'Paciente';

    handleChange(event) {
        this.selectedValue = event.target.value;
        this.opcoes = this.opcoes.map(opcao => ({
            ...opcao,
            checked: opcao.value === this.selectedValue
        }));
    }

    handleSubmit() {
        const selected = this.opcoes.find(opcao => opcao.checked);
        if (selected) {
            this.dispatchEvent(new CustomEvent('next', {
                detail: selected.value
            }));
        }
    }

    get computedOpcoes() {
        return this.opcoes.map(opcao => ({
            ...opcao,
            customClass: opcao.checked ? 'custom-radio checked' : 'custom-radio'
        }));
    }
    
}