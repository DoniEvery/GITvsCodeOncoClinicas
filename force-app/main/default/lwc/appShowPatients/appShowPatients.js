import { LightningElement, track, api } from 'lwc';

import iconsZip from '@salesforce/resourceUrl/APP_IconsPatientRecord';
import imagesZip from '@salesforce/resourceUrl/APP_imagesAPPRecordMedical';
import buscarProntuarioPacientePorId from '@salesforce/apex/APP_PatientController.buscarProntuarioPacientePorId';
import searchPatients from '@salesforce/apex/APP_PatientController.searchPatients';

export default class AppShowPatients extends LightningElement {
    search = `${iconsZip}/APP_IconsPatientRecord/search.png`;
    details = `${iconsZip}/APP_IconsPatientRecord/docs_add_on.svg`;

    @track isLoading = false;
    @track patient;

    @track listOfResults = [];
    @track results = false;

    @api altura;

    intOffset = 0;
    firstMaxVisibleResults;
    totalResults = 0;
    maxVisibleResults;
    currentTerm = '';


    connectedCallback() {
        this.calcularAltura();

    }

    handleInputChange(event) {
        this.currentTerm = event.target.value.trim().toLowerCase();
        this.intOffset = 0;

        if (this.currentTerm.length > 2) {
            this.updateResults();
        } else {
            this.listOfResults = [];
            this.totalResults = 0;
            this.results = false;
            this.maxVisibleResults = this.firstMaxVisibleResults;
        }
    }


    calcularAltura() {

        // Aqui calcula quantos cards cabem na pagina
        // Eu busquei a altura do avo, e peguei os tamanho do card para calcular
        const alturaDisponivel = (this.altura - 56) || window.innerHeight - 106;
        const alturaCard = 82 + 24;
        this.maxVisibleResults = Math.floor(alturaDisponivel / alturaCard);
        this.firstMaxVisibleResults = Math.floor(alturaDisponivel / alturaCard);



    }

    loadPatientData(json) {
        let weight = null;
        let height = null;

        if (Array.isArray(json.observations)) {
            for (let obs of json.observations) {
                if (obs.type === 'BodyWeight' && weight === null) {
                    weight = obs.value + obs.unit;
                } else if (obs.type === 'BodyHeight' && height === null) {
                    height = obs.value + obs.unit;
                }
            }
        }
        json.treatments = (json.treatments || []).map((treatment, treatmentIndex) => {
            const addIndex = (arr) =>
                Array.isArray(arr) && arr.length > 0
                    ? arr.map((item, index) => ({ ...item, index }))
                    : arr;

            const updatedPlans = (treatment.plans || []).map(plan => {
                const updatedSessions = (plan.sessions || []).map(session => {
                    const firstState = Array.isArray(session.state) ? session.state[0] : session.state;

                    const stateTranslations = {
                        'released-prescription': 'Prescrição liberada',
                        'pending-prescription': 'Prescrição pendente',
                        'suspended-prescription': 'Prescrição suspensa',
                        'pending-prescription-signature': 'Assinatura da prescrição pendente',
                        'authorized-cycle': 'Ciclo autorizado',
                        'attended-day': 'Concluído',
                        'release-required': 'Liberação necessária',
                        'suspended-day': 'Dia suspenso'
                    };

                    const pendingStates = new Set([
                        'attended-day', 'released-prescription'
                    ]);

                    const stateClass = pendingStates.has(firstState)
                        ? 'stateClassCompleted'
                        : 'stateClasspending';

                    const translatedState = stateTranslations[firstState] || firstState;


                    return {
                        ...session,
                        stateClass,
                        state: translatedState
                    };
                });

                return {
                    ...plan,
                    sessions: updatedSessions,
                    className: 'details-wrapper closed',
                    isModalOpen: false,
                };
            });

            return {
                ...treatment,
                className: 'details-wrapper closed',
                isOpen: false,
                plans: updatedPlans,
                anamnesis: addIndex(treatment.anamnesis),
                evolution: addIndex(treatment.evolution),
                conducts: addIndex(treatment.conducts),
                diagnosticImpression: addIndex(treatment.diagnosticImpression),
                diagnosis: treatment.diagnosis || {
                    physician: {
                        code: '',
                        name: ''
                    },
                    date: ''
                }
            };
        });

        if (!this.patient.Account.PersonBirthdate) {
            this.patient.Account.PersonBirthdate = '';
        }

        this.patient = {
            ...this.patient,
            weight: weight,
            height: height,
            observations: json.observations || [],
            allergies: json.allergies || [],
            medications: json.medications || [],
            treatments: json.treatments || [],
        };

    }


    renderedCallback() {

        // a pagina estava sempre sendo carregada na metade, e nao me permitia dar o scroll, ai fui no avo e dei o scroll
        const scrollEvent = new CustomEvent('scrolltoprequest', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(scrollEvent);

    }


    updateResults() {
        this.intOffset = 0;

        searchPatients({
            identificacao: this.currentTerm,
            intOffset: this.intOffset,
            intLimit: this.firstMaxVisibleResults
        })
            .then(result => {

                this.listOfResults = result.patients;
                this.totalResults = result.total;
                this.results = result.patients.length > 0;
            })
            .catch(error => {
                console.error('Erro ao buscar pacientes:', error);
                this.listOfResults = [];
                this.totalResults = 0;
                this.results = false;
            });
    }


    handleViewMore() {
        this.intOffset += this.firstMaxVisibleResults;

        searchPatients({
            identificacao: this.currentTerm,
            intOffset: this.intOffset,
            intLimit: this.firstMaxVisibleResults
        })
            .then(result => {
                this.listOfResults = [...this.listOfResults, ...result.patients];
                this.totalResults = result.total;
                this.results = this.listOfResults.length > 0;
            })
            .catch(error => {
                console.error('Erro ao buscar mais pacientes:', error);
            });
    }


    openPatient(event) {
        this.isLoading = true;
        const id = event.currentTarget.dataset.id;
        this.patient = this.listOfResults.find(person =>
            person.Account.Id === id
        )


        if (this.patient.Account.APP_NumeroProntuario__c) {

            buscarProntuarioPacientePorId({ idProntuario: String(this.patient.Account.APP_NumeroProntuario__c) })
                .then(result => {
                    if (result) {
                        this.loadPatientData(result);
                        this.dispatchEvent(new CustomEvent('patientselected', {
                            detail: {
                                patient: this.patient,
                                pageName: 'Paciente',
                                fromPage: 'Meus pacientes'
                            },
                            bubbles: true,
                            composed: true
                        }));
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('Erro ao buscar prontuário:', error);
                    this.isLoading = false;

                });

        }


        else {
            this.dispatchEvent(new CustomEvent('patientselected', {
                detail: {
                    patient: this.patient,
                    pageName: 'Paciente',
                    fromPage: 'Meus pacientes'
                },
                bubbles: true,
                composed: true
            }));
            this.isLoading = false;

        }




    }

    handleClickDetails(event) {

        this.detailsClick = !this.detailsClick;
        this.showDetails = !this.showDetails;
    }

    get showDetailsWrapperClass() {
        return this.showDetails ? 'details-wrapper open' : 'details-wrapper closed';
    }
    get showViewMoreButton() {
        return this.totalResults > this.listOfResults.length;
    }
    get maxContentStyle() {
        return this.altura ? `min-height: ${this.altura}px;` : '';
    }
    get detailsClass() {
        return this.detailsClick ? 'details selected' : 'details';
    }
    get hasPlans() {
        return this.allPlans && this.allPlans.length > 0;
    }

}