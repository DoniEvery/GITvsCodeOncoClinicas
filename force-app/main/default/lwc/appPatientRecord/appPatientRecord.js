import { LightningElement, track, api } from 'lwc';
import iconsZip from '@salesforce/resourceUrl/APP_IconsPatientRecord';

export default class AppPatientRecord extends LightningElement {

    details = `${iconsZip}/APP_IconsPatientRecord/docs_add_on.svg`;
    menuSessions = `${iconsZip}/APP_IconsPatientRecord/menuSessions.svg`;
    fechar = `${iconsZip}/APP_IconsPatientRecord/fechar.svg`;


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

    @track detailsClick = false;
    @track showDetails = false;
    @track openInfos = false;
    @track isModalOpen = false;

    connectedCallback() {

        this.menuProntuario = this.menuProntuario.map(item => ({
            ...item,
            selected: item.label === this.currentPage ? 'navMenuItem selected' : 'navMenuItem'
        }));


        this.menuPatient = this.menuPatient.map(item => {
            if (item.label === 'Prontuário') {
                const isInactive = !this.patient?.treatments || this.patient.treatments.length === 0;

                return {
                    ...item,
                    menuPatientClass: isInactive ? 'menuCardContainer inativo' : 'menuCardContainer',
                    helpText: isInactive ? 'Paciente sem número de protocolo' : ''
                };
            }
            return item;
        });

    }
    @track
    menuPatient = [
        {
            label: 'Prontuário',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'clinical_notes.svg',
            menuPatientClass: 'menuCardContainer'
        },
        {
            label: 'Enviar arquivos',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'attach_file.svg',
            menuPatientClass: 'menuCardContainer'

        },
        {
            label: 'Solicitar exames',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'conditions.svg',
            menuPatientClass: 'menuCardContainer'
        }
    ]


    menuProntuario = [
        {
            label: 'Tratamentos',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'vaccines.svg',
            selected: 'navMenuItem'


        },
        {
            label: 'Diagnóstico e estadiamento',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'diagnosis.svg',
            selected: 'navMenuItem'


        }
        ,
        {
            label: 'Histórico de consultas',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'lab_profile.svg',
            selected: 'navMenuItem'

        }
        ,
        {
            label: 'Histórico de saúde',
            icon: `${iconsZip}/APP_IconsPatientRecord/` + 'person_heart.svg',
            selected: 'navMenuItem'

        }
    ]

    tableSessions = {
        ciclo: 'Ciclo',
        dia: 'Dia do ciclo',
        data: 'Data e hora',
        session: 'Status'
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

        this.menuProntuario = this.menuProntuario.map(item => {
            return {
                ...item,
                selected: item.label === pageName
                    ? 'navMenuItem selected'
                    : 'navMenuItem'
            };
        });


        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: pageName,
                fromPage: 'Prontuário'
            },
            bubbles: true,
            composed: true
        }));
    }



    handleClickVewDetailTratamentos(event) {
        const id = event.currentTarget.dataset.id;
   

        const clonedPatient = JSON.parse(JSON.stringify(this.patient));
        clonedPatient.treatments = clonedPatient.treatments.map(treatment => {
            const updatedPlans = (treatment.plans || []).map(plan => {
                const isOpen = plan.protocolKey === id ? !plan.isOpen : false;

                return {
                    ...plan,
                    isOpen: isOpen,
                    className: `details-wrapper ${isOpen ? 'open' : 'closed'}`
                };
            });

            return {
                ...treatment,
                plans: updatedPlans
            };
        });

        this.patient = clonedPatient;
    }
    handleClickDiagnostico(event) {
        const id = event.currentTarget.dataset.id;
     

        const clonedPatient = JSON.parse(JSON.stringify(this.patient));
        clonedPatient.treatments = clonedPatient.treatments.map(treatment => {
            const isOpen = treatment.id === id ? !treatment.isOpen : false;

            return {
                ...treatment,
                isOpen: isOpen,
                className: `protocoloTextInfoSecondContainer ${isOpen ? 'open' : 'closed'}`
            };
        });

        this.patient = clonedPatient;
    }

    handleClickViewProgress(event) {
        event.stopPropagation();
        const id = event.currentTarget.dataset.id;



        const clonedPatient = JSON.parse(JSON.stringify(this.patient));
        clonedPatient.treatments = clonedPatient.treatments.map(treatment => {
            const updatedPlans = (treatment.plans || []).map(plan => {
                const isModalOpen = plan.protocolKey === id ? !plan.isModalOpen : false;


                plan.isModalOpen = isModalOpen

                return {
                    ...plan,
                    isModalOpen
                };
            });
            return {
                ...treatment,
                plans: updatedPlans
            };
        });

        this.patient = clonedPatient;

    }

    closeModal(event) {
        event.stopPropagation();
        this.isModalOpen = false;
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