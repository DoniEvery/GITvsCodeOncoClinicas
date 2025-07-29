import { LightningElement, track, api } from 'lwc';

import iconsZip from '@salesforce/resourceUrl/APP_IconsPatientRecord';
import imagesZip from '@salesforce/resourceUrl/APP_imagesAPPRecordMedical';

export default class AppShowPatients extends LightningElement {
    search = `${iconsZip}/APP_IconsPatientRecord/search.png`;
    details = `${iconsZip}/APP_IconsPatientRecord/docs_add_on.svg`;

    @track fistScreen = true;
    @track patient = {
        nome: '',
        photo: '',
        cpf: '',
        dataNascimento: '',
        altura: 0,
        peso: 0,
        sexo: '',
        filiacao1: '',
        filiacao2: '',
        telefone: '',
        email: '',
        prontuario: ''
    };



    @track listOfResults = [];
    @track results = false;

    @api altura;

    totalResults = 0;
    maxVisibleResults;
    firstMaxVisibleResults;
    currentTerm = '';

    @track allPlans = [];

    connectedCallback() {

        // Aqui calcula quantos cards cabem na pagina
        // Eu busquei a altura do avo, e peguei os tamanho do card para calcular
        const alturaDisponivel = (this.altura - 56) || window.innerHeight - 106;
        const alturaCard = 82 + 24;
        this.maxVisibleResults = Math.floor(alturaDisponivel / alturaCard);
        this.firstMaxVisibleResults = Math.floor(alturaDisponivel / alturaCard);
        console.log('Máximo de resultados visíveis:', this.maxVisibleResults);


        this.allPlans = this.apiData.treatments?.flatMap((t) => {
            return (t.plans || []).map((p, index) => {
                return {
                    ...p,
                    uniqueKey: `${p.protocolKey}-${index}` // ou `${t.id}-${index}`
                };
            });
        });

        console.log('Lista de planos', JSON.stringify(this.allPlans));
        console.log('Lista de planos1', JSON.stringify(this.allPlans[0].startDate));


    }

    renderedCallback() {

        // a pagina estava sempre sendo carregada na metade, e nao me permitua dar o scroll, ai fui no avo e dei o scroll
        const scrollEvent = new CustomEvent('scrolltoprequest', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(scrollEvent);

    }

    handleInputChange(event) {
        this.currentTerm = event.target.value.trim().toLowerCase();

        if (this.currentTerm.length > 2) {
            this.updateResults();
        } else {
            this.listOfResults = [];
            this.totalResults = 0;
            this.results = false;
            this.maxVisibleResults = this.firstMaxVisibleResults;
        }
    }

    updateResults() {
        const filtered = this.people.filter(person =>
            person.nome.toLowerCase().includes(this.currentTerm)
        );

        this.totalResults = filtered.length;
        this.listOfResults = filtered.slice(0, this.maxVisibleResults);
        this.results = this.totalResults > 0;
    }

    handleViewMore() {
        this.maxVisibleResults += this.firstMaxVisibleResults;
        this.updateResults();
    }

    openPatient(event) {

        const cpf = event.currentTarget.dataset.id;

        this.patient = this.people.find(person =>
            person.cpf === cpf
        )
        this.patient.prontuarios = this.allPlans;
        if (this.patient?.prontuarios?.length) {
            this.patient.prontuarios = this.patient.prontuarios.map(p => ({
                ...p,
                isOpen: false,
                className: 'protocoloTextInfoSecondContainer closed'

            }));
        }
        console.log(JSON.stringify(this.patient));

        this.fistScreen = false
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






























































    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    // APAGAR DEPOIS DE INTEGRARM, DADOS SOMENTE DE TESTE



    people = [
        {
            nome: 'Gustavo Mioto',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'mioto.png',
            cpf: '123.456.789-01',
            dataNascimento: '1990-05-12',
            altura: 1.81,
            peso: 81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação',
            prontuarios: this.allPlans


        },
        {
            nome: 'Gustavo Bertoni',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'bertoni.png',
            cpf: '123.456.789-02',
            dataNascimento: '1990-05-12',
            altura: 1.81,
            peso: 81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },
        {
            nome: 'Gustavo Gaitero',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'gaitero.jpg',
            cpf: '123.456.789-03',
            dataNascimento: '1990-05-12',
            peso: 81,
            altura: 1.81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação',
            prontuarios: this.prontuarios,
            diagnosticos: this.diagnosticos
        },
        {
            nome: 'Gustavo Gomes',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'gomes.png',
            cpf: '123.456.789-04',
            dataNascimento: '1990-05-12',
            peso: 81,
            altura: 1.81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },
        {
            nome: 'Gustavo Kuerten',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'kuerten.jpg',
            cpf: '123.456.789-05',
            peso: 81,
            dataNascimento: '1990-05-12',
            altura: 1.81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },
        {
            nome: 'Gustavo Liberato',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'liberato.jpg',
            cpf: '123.456.789-06',
            dataNascimento: '1990-05-12',
            peso: 81,
            altura: 1.81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },
        {
            nome: 'Gustavo Lima',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'lima.png',
            cpf: '123.456.789-07',
            dataNascimento: '1990-05-12',
            altura: 1.81,
            peso: 81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },
        {
            nome: 'Gustavo scarpa',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'scarpa.png',
            cpf: '123.456.789-08',
            dataNascimento: '1990-05-12',
            peso: 81,
            altura: 1.81,
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            prontuario: 'Informação'
        },

    ];

    apiData = {

        "treatments": [
            {
                "id": "2438019.790633",
                "diagnosis": {
                    "id": 790633,
                    "date": "2025-07-23T11:28:27",
                    "disease": {
                        "code": "Anemia Por Deficiência de Ferro",
                        "description": "Anemia Por Deficiência de Ferro"
                    },
                    "topografy": {
                        "code": "D50.9",
                        "description": "Anemia Por Deficiência de Ferro Não Especificada"
                    },
                    "morfology": {
                        "code": "9980/1",
                        "description": "Anemia refrataria, SOE"
                    },
                    "physician": {
                        "code": "100",
                        "name": "Mariana Tosello Laloni"
                    },
                    "unitCare": {
                        "code": 4,
                        "description": "QAS_200525 | CPO Faria Lima"
                    }
                },
                "anamnesis": [],
                "evolution": [
                    {
                        "description": "EVOLUÇÃO PACIENTE GABRIELA",
                        "complement": "RESUMO PACIENTE GABRIELA",
                        "date": "2025-07-23T11:26:39",
                        "conduct": null
                    }
                ],
                "conducts": [
                    {
                        "description": "CONDUTA PACIENTE GABRIELA",
                        "date": "2025-07-23T11:31:57"
                    }
                ],
                "diagnosticImpression": [],
                "plans": [
                    {
                        "physician": "849545",
                        "summary": "Preferencial/Acido Zoledrônico 4mg IV D1 a cada 1 ano",
                        "protocolKey": "209.293",
                        "startDate": "2025-07-25T16:00:00",
                        "lastSessionDate": null,
                        "sessions": [
                            {
                                "id": 5689562,
                                "cycle": 1,
                                "day": "D1",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-07-25T16:00:00",
                                "realDate": "2025-07-25T09:00:00"
                            }
                        ]
                    },
                    {
                        "physician": "849545",
                        "summary": "Preferencial/Acido Zoledrônico 4mg IV D1 a cada 1 ano",
                        "protocolKey": "209.293",
                        "startDate": "2025-07-25T16:00:00",
                        "lastSessionDate": null,
                        "sessions": [
                            {
                                "id": 5689562,
                                "cycle": 1,
                                "day": "D1",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-07-25T16:00:00",
                                "realDate": "2025-07-25T09:00:00"
                            }
                        ]
                    },
                    {
                        "physician": "849545",
                        "summary": "Preferencial/Acido Zoledrônico 4mg IV D1 a cada 1 ano",
                        "protocolKey": "209.293",
                        "startDate": "2025-07-25T16:00:00",
                        "lastSessionDate": null,
                        "sessions": [
                            {
                                "id": 5689562,
                                "cycle": 1,
                                "day": "D1",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-07-25T16:00:00",
                                "realDate": "2025-07-25T09:00:00"
                            }
                        ]
                    }
                ]
            }
        ]
    }
}