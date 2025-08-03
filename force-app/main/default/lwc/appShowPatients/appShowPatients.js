import { LightningElement, track, api } from 'lwc';

import iconsZip from '@salesforce/resourceUrl/APP_IconsPatientRecord';
import imagesZip from '@salesforce/resourceUrl/APP_imagesAPPRecordMedical';
import buscarProntuarioPacientePorId from '@salesforce/apex/APP_PatientController.buscarProntuarioPacientePorId';

// Nao vou usar mais
import getPatientInfo from '@salesforce/apex/APP_PatientController.getPatientInfo';
import getPatientCount from '@salesforce/apex/APP_PatientController.getPatientCount';


import searchPatients from '@salesforce/apex/APP_PatientController.searchPatients';




export default class AppShowPatients extends LightningElement {
    search = `${iconsZip}/APP_IconsPatientRecord/search.png`;
    details = `${iconsZip}/APP_IconsPatientRecord/docs_add_on.svg`;




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

    intOffset = 0;
    firstMaxVisibleResults;
    totalResults = 0;
    maxVisibleResults;
    currentTerm = '';

    @track allPlans = [];

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
        console.log(1);

        json.treatments = (json.treatments || []).map((treatment, treatmentIndex) => {
            const addIndex = (arr) =>
                Array.isArray(arr) && arr.length > 0
                    ? arr.map((item, index) => ({ ...item, index }))
                    : arr;

            const updatedPlans = (treatment.plans || []).map(plan => {
                const updatedSessions = (plan.sessions || []).map(session => {
                    const firstState = Array.isArray(session.state) ? session.state[0] : session.state;

                    const stateClass = firstState === 'pending-prescription'
                        ? 'stateClasspending'
                        : 'stateClassCompleted';

                    const translatedState = firstState === 'pending-prescription'
                        ? 'Pendente'
                        : firstState;

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


        this.patient = {
            ...this.patient,
            observations: json.observations || [],
            allergies: json.allergies || [],
            medications: json.medications || [],
            treatments: json.treatments || [],
        };

        // console.log("doni ", JSON.stringify(this.patient));

    }


    renderedCallback() {

        // a pagina estava sempre sendo carregada na metade, e nao me permitua dar o scroll, ai fui no avo e dei o scroll
        const scrollEvent = new CustomEvent('scrolltoprequest', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(scrollEvent);

    }


    updateResults() {
        this.intOffset = 0; // Sempre reinicia na primeira busca

        searchPatients({
            identificacao: this.currentTerm,
            intOffset: this.intOffset,
            intLimit: this.firstMaxVisibleResults
        })
            .then(result => {
                console.log(result);
                console.log(JSON.stringify(result))
                
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





    // updateResults() {
    //     const filtered = this.people.filter(person =>
    //         person.nome.toLowerCase().includes(this.currentTerm)
    //     );

    //     this.totalResults = filtered.length;
    //     this.listOfResults = filtered.slice(0, this.maxVisibleResults);
    //     this.results = this.totalResults > 0;
    // }

    handleViewMore() {
        this.intOffset += this.firstMaxVisibleResults;

        searchPatients({
            identificacao: this.currentTerm,
            intOffset: this.intOffset,
            intLimit: this.firstMaxVisibleResults
        })
            .then(result => {
                // Em vez de substituir, vamos concatenar os novos resultados
                this.listOfResults = [...this.listOfResults, ...result.patients];
                this.totalResults = result.total;
                this.results = this.listOfResults.length > 0;
            })
            .catch(error => {
                console.error('Erro ao buscar mais pacientes:', error);
            });
    }


    openPatient(event) {

        const cpf = event.currentTarget.dataset.id;

        this.patient = this.people.find(person =>
            person.cpf === cpf
        )
        this.loadPatientData(this.apiData);

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
    // APAGAR DEPOIS DE INTEGRAR, DADOS SOMENTE DE TESTE




    people = [
        {
            nome: 'Gustavo Mioto',
            photo: `${imagesZip}/APP_imagesAPPRecordMedical/` + 'mioto.png',
            cpf: '123.456.789-01',
            dataNascimento: '1990-05-12',
            sexo: 'Masculino',
            filiacao1: 'Jose',
            filiacao2: 'Maria',
            telefone: '32187861',
            email: 'mioto@msn.com',
            // altura: 1.81, dentro do observation
            // peso: 81,
            prontuario: 'Informação',
            observations: [],
            allergies: [],
            medications: []

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
        "observations": [
            {
                "id": 4573597,
                "type": "BodyWeight",
                "date": "2025-06-10T11:14:49",
                "encounter": 4856865,
                "patient": 4856865,
                "unit": "Kg",
                "value": 80
            },
            {
                "id": 4573597,
                "type": "BodyHeight",
                "date": "2025-06-10T11:14:49",
                "encounter": 4856865,
                "patient": 4856865,
                "unit": "cm",
                "value": 180
            }
        ],
        "allergies": [
            {
                "id": 439264,
                "date": "2025-05-29T14:03:53",
                "encounter": 4856587,
                "patient": 4856587,
                "substance": "Látex",
                "reaction": "N/A"
            }
        ],
        "medications": [
            {
                "id": 382059,
                "date": "2025-07-23T10:31:39",
                "patient": "1852708",
                "description": "Atenolol",
                "dosageQuantity": null,
                "dosageUnit": null
            }
        ],
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
                        "startDate": "1987-05-07T16:00:00",
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
            },
            {
                "id": "2437949.790627",
                "diagnosis": {
                    "id": 790627,
                    "date": "2025-07-02T16:09:39",
                    "disease": {
                        "code": "Neoplasia Maligna de Outras Glândulas Endócrinas e de Estruturas Relacionadas",
                        "description": "Neoplasia Maligna de Outras Glândulas Endócrinas e de Estruturas Relacionadas"
                    },
                    "topografy": {
                        "code": "C75.0",
                        "description": "Neoplasia Maligna da Glândula Paratireóide"
                    },
                    "morfology": {
                        "code": "8000/0",
                        "description": "Neoplasia Benigna"
                    },
                    "physician": {
                        "code": "849545",
                        "name": "Bianca Pinna Pascual"
                    },
                    "unitCare": {
                        "code": 4,
                        "description": "QAS_200525 | CPO Faria Lima"
                    }
                },
                "anamnesis": [
                    {
                        "complaint": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "hpma": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "isda": "N",
                        "date": "2025-05-30T09:16:14"
                    }
                ],
                "evolution": [],
                "conducts": [
                    {
                        "description": "AETEESSATE",
                        "date": "2025-05-30T09:17:03"
                    }
                ],
                "diagnosticImpression": [],
                "plans": null
            },
            {
                "id": "2437949.790613",
                "diagnosis": {
                    "id": 790613,
                    "date": "2025-05-30T09:17:53",
                    "disease": {
                        "code": "Imunodeficiência Com Predominância de Defeitos de Anticorpos",
                        "description": "Imunodeficiência Com Predominância de Defeitos de Anticorpos"
                    },
                    "topografy": {
                        "code": "D80.6",
                        "description": "Deficiência de Anticorpos Com Imunoglobulinas Próximas do Normal ou Com Hiperimunoglobulinemia"
                    },
                    "morfology": {
                        "code": null,
                        "description": null
                    },
                    "physician": {
                        "code": "849545",
                        "name": "Bianca Pinna Pascual"
                    },
                    "unitCare": {
                        "code": 4,
                        "description": "QAS_200525 | CPO Faria Lima"
                    }
                },
                "anamnesis": [
                    {
                        "complaint": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "hpma": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "isda": "N",
                        "date": "2025-05-30T09:16:14"
                    }
                ],
                "evolution": [],
                "conducts": [
                    {
                        "description": "AETEESSATE",
                        "date": "2025-05-30T09:17:03"
                    }
                ],
                "diagnosticImpression": [],
                "plans": [
                    {
                        "physician": "849545",
                        "summary": "Imunomediados/Imunoglobulina (Endobulin e Gamunex) 400mg/kg a 800mg/kg SC  - a cada 28 dias",
                        "protocolKey": "208.167",
                        "startDate": "2025-05-30T15:00:00",
                        "lastSessionDate": "2025-06-27T08:30:00",
                        "sessions": [
                            {
                                "id": 5689261,
                                "cycle": 1,
                                "day": "D1",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-05-30T15:00:00",
                                "realDate": "2025-05-30T11:00:00"
                            },
                            {
                                "id": 5689262,
                                "cycle": 2,
                                "day": "D2",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-06-27T15:00:00",
                                "realDate": "2025-06-27T08:30:00"
                            },
                            {
                                "id": 5689263,
                                "cycle": 3,
                                "day": "D3",
                                "state": [
                                    "Completed"
                                ],
                                "expectedDate": "2025-07-25T15:00:00",
                                "realDate": "2025-07-25T10:00:00"
                            },
                            {
                                "id": 5689264,
                                "cycle": 4,
                                "day": "D4",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-08-22T15:00:00",
                                "realDate": "2025-08-22T14:00:00"
                            },
                            {
                                "id": 5689265,
                                "cycle": 5,
                                "day": "D5",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-09-19T15:00:00",
                                "realDate": "2025-09-19T15:00:00"
                            },
                            {
                                "id": 5689266,
                                "cycle": 6,
                                "day": "D6",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-10-17T15:00:00",
                                "realDate": "2025-10-17T15:00:00"
                            },
                            {
                                "id": 5689267,
                                "cycle": 7,
                                "day": "D7",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-11-14T15:00:00",
                                "realDate": "2025-11-14T15:00:00"
                            },
                            {
                                "id": 5689268,
                                "cycle": 8,
                                "day": "D8",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2025-12-12T15:00:00",
                                "realDate": "2025-12-12T15:00:00"
                            },
                            {
                                "id": 5689269,
                                "cycle": 9,
                                "day": "D9",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2026-01-09T15:00:00",
                                "realDate": "2026-01-09T15:00:00"
                            },
                            {
                                "id": 5689270,
                                "cycle": 10,
                                "day": "D10",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2026-02-06T15:00:00",
                                "realDate": "2026-02-06T15:00:00"
                            },
                            {
                                "id": 5689271,
                                "cycle": 11,
                                "day": "D11",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2026-03-06T15:00:00",
                                "realDate": "2026-03-06T15:00:00"
                            },
                            {
                                "id": 5689272,
                                "cycle": 12,
                                "day": "D12",
                                "state": [
                                    "pending-prescription"
                                ],
                                "expectedDate": "2026-04-03T15:00:00",
                                "realDate": "2026-04-03T15:00:00"
                            }
                        ]
                    }
                ]
            }
        ]
    }
}