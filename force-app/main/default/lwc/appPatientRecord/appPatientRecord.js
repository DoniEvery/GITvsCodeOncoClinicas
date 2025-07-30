import { LightningElement, track, api } from 'lwc';

import iconsZip from '@salesforce/resourceUrl/APP_IconsPatientRecord';

export default class AppPatientRecord extends LightningElement {

    details = `${iconsZip}/APP_IconsPatientRecord/docs_add_on.svg`;

    @track detailsClick = false;
    @track showDetails = false;
    @track openInfos = false;


    menuPatient = [
        {
            label: 'Prontuário',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'clinical_notes.svg'


        },
        {
            label: 'Enviar arquivos',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'attach_file.svg'

        },
        {
            label: 'Solicitar exames',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'conditions.svg'
        }
    ]

    menuProntuario = [
        {
            label: 'Tratamentos',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'vaccines.svg'

        },
        {
            label: 'Diagnóstico e estadiamento',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'diagnosis.svg'

        }
        ,
        {
            label: 'Histórico de consultas',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'lab_profile.svg'
        }
        ,
        {
            label: 'Histórico de saúde',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'person_heart.svg'
        }
    ]

    _currentPage;
    _patient;
    @api
    set patient(value) {
        if (value) {
            this._patient = value;
        }
    }
    @api
    set currentPage(value) {
        if (value) {
            this._currentPage = value;
        }
    }
    get currentPage() {
        return this._currentPage;
    }
    get patient() {
        return this._patient;
    }

    handleClickDetails() {
        this.detailsClick = !this.detailsClick;
        this.showDetails = !this.showDetails;
    }
    handleClickPatientMenu(event) {

        const pageName = event.currentTarget.dataset.name;

        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: pageName,
                fromPage: 'Paciente'
            },
            bubbles: true,
            composed: true
        }));
    }

    handleClickProntuarioMenu(event) {

        const pageName = event.currentTarget.dataset.name;
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: pageName,
                fromPage: 'Prontuário'
            },
            bubbles: true,
            composed: true
        }));
    }

    // handleClickVewDetailTratamentos(event) {
    //     const id = event.currentTarget.dataset.id;
    //     console.log('ID clicado:', id);

    //     if (!id || !this.patient?.prontuarios) return;
    //     console.log('depois do return', id);

    //     const clonedPatient = { ...this.patient };

    //     clonedPatient.prontuarios = clonedPatient.prontuarios.map(p => {
    //         const isOpen = p.uniqueKey === id ? !p.isOpen : false;

    //         return {
    //             ...p,
    //             isOpen,
    //             className: `protocoloTextInfoSecondContainer ${isOpen ? 'open' : 'closed'}`
    //         };
    //     });

    //     console.log('depois do clonedPatient');
    //     console.log(clonedPatient.prontuarios[0].className);

    //     this.patient = clonedPatient;
    // }

    handleClickVewDetailTratamentos(event) {
        const id = event.currentTarget.dataset.id;
        console.log(
            'ID clicado:', id);

        const clonedPatient = JSON.parse(JSON.stringify(this.patient));
        clonedPatient.treatments = clonedPatient.treatments.map(treatment => {
            const updatedPlans = (treatment.plans || []).map(plan => {
                const isOpen = plan.protocolKey === id ? !plan.isOpen : false;

                return {
                    ...plan,
                    isOpen,
                    className: `protocoloTextInfoSecondContainer ${isOpen ? 'open' : 'closed'}`
                };
            });

            return {
                ...treatment,
                plans: updatedPlans
            };
        });

        this.patient = clonedPatient;
    }

    // pages

    get isPatientPage() {
        return this.currentPage === 'Paciente';
    }
    get isProntuario() {
        return this.currentPage === 'Prontuário';
    }
    get isEnviarArquivos() {
        return this.currentPage === 'Enviar arquivos';
    }
    get isSolicitarExames() {
        return this.currentPage === 'Solicitar exames';
    }
    get isTratamentos() {
        return this.currentPage === 'Tratamentos';
    }
    get isDiagnostico() {
        return this.currentPage === 'Diagnóstico e estadiamento';
    }
    get isHistoricoCconsultas() {
        return this.currentPage === 'Histórico de consultas';
    }
    get isHistoricoSaude() {
        return this.currentPage === 'Histórico de saúde';
    }


    // css 
 
    get detailsClass() {
        return this.detailsClick ? 'details selected' : 'details';
    }
    get showDetailsWrapperClass() {
        return this.showDetails ? 'details-wrapper open' : 'details-wrapper closed';
    }


}