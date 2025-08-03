public without sharing class APP_PatientController {
    public static String getCpfDoPacienteLogado() {
        User user = [SELECT ContactId
                     FROM User
                     WHERE Id = :UserInfo.getUserId()
                     LIMIT 1];
        Contact contato = [SELECT Account.CNPJ__c
                           FROM Contact
                           WHERE Id = :user.ContactId
                           LIMIT 1];
        return contato.Account.CNPJ__c;
    }

    public static String getCpfDoMedicoLogado() {
        User user = [SELECT APP_ContatoId__c
                     FROM User
                     WHERE Id = :UserInfo.getUserId()
                     LIMIT 1];

        if (user.APP_ContatoId__c == null) {
            throw new AuraHandledException('Usuário logado não possui um contato associado.');
        }
        Contact contato = [SELECT CPF__c
                           FROM Contact
                           WHERE Id = :user.APP_ContatoId__c
                           LIMIT 1];
        return contato.CPF__c;
    }

    @AuraEnabled(cacheable = true)
    public static List<APP_PatientResponseDTO> getPacientesPorCpf(String cpf) {
        try {
            return APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);

        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<APP_ProfissionalListResponseDTO> listarAgendaMedicoLogado(String dateStart, String dateEnd, Integer page, Integer count) {
        try {
            String cpf = getCpfDoMedicoLogado();

            List<APP_PatientResponseDTO> medicos = APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);
            if (medicos == null
                || medicos.isEmpty()) {
                throw new AuraHandledException('Médico não encontrado com CPF fornecido.');
            }

            String prontuario = medicos[0].id;
            page = (page != null) ? page : 1;
            count = (count != null) ? count : 20;            
            List<APP_ProfissionalListResponseDTO> agendamentos = APP_ProfissionalService.listarAgendamentosFiltradosMedicos(page, count, dateStart, dateEnd, prontuario);

            if (agendamentos != null) {
                for (APP_ProfissionalListResponseDTO agendamento : agendamentos) {
                    if (agendamento.actor != null
                        && !agendamento.actor.isEmpty()
                        && String.isNotBlank(agendamento.actor[1].reference)) {
                        Map<String, String> dadosPaciente = getDadosPacientesPorProntuario(agendamento.actor[1].reference);
                        if (dadosPaciente != null) {
                            // Adiciona os dados do médico ao DTO
                            agendamento.actor[0].nomeMedico = dadosPaciente.get('nome'); //nome paciente
                            agendamento.actor[0].fotoMedicoUrl = dadosPaciente.get('fotoUrl'); //foto paciente
                        }
                    }
                }
            }
            return agendamentos;
        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> getDadosMedicoPorProntuario(String prontuarioMedico) {
        try {
            List<APP_PatientResponseDTO> medicos = APP_ProfissionalService.buscarPorPronturario(prontuarioMedico, 1, 1);

            if (medicos == null
                || medicos.isEmpty()
                || String.isBlank(medicos[0].cpf)) {
                return null;
            }

            String cpfMedico = medicos[0].cpf;
            List<Contact> contatos = [SELECT Id
                                      FROM Contact
                                      WHERE CPF__c = :cpfMedico
                                      LIMIT 1];

            if (contatos.isEmpty()) {
                return null;
            }

            String contatoId = contatos[0].Id;
            Contact contatoName = [SELECT Id, 
                                          Name
                                   FROM Contact
                                   WHERE Id = :contatoId];
            List<User> usuarios = [SELECT Id, 
                                          Name, 
                                          FullPhotoUrl, 
                                          SmallPhotoUrl
                                   FROM User
                                   WHERE APP_ContatoId__c = :contatoId
                                   LIMIT 1];

            if (usuarios.isEmpty()) {
                return null;
            }

            Map<String, String> dadosMedico = new Map<String, String>();
            dadosMedico.put('nome', usuarios[0].Name);
            dadosMedico.put('fotoUrl', usuarios[0].SmallPhotoUrl); // Ou FullPhotoUrl para foto maior
            return dadosMedico;

        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> getDadosPacientesPorProntuario(String prontuarioPaciente) {
        try {
            List<APP_PatientResponseDTO> pacientes = APP_ProfissionalService.buscarPorPronturario(prontuarioPaciente, 1, 1);

            if (pacientes == null
                || pacientes.isEmpty()
                || String.isBlank(pacientes[0].cpf)) {
                return null;
            }

            String cpfPaciente = pacientes[0].cpf;
            List<Contact> contatos = [SELECT Id, 
                                             Account.CNPJ__c
                                      FROM Contact
                                      WHERE Account.CNPJ__c = :cpfPaciente
                                      LIMIT 1];

            if (contatos.isEmpty()) {
                return null;
            }

            String contatoId = contatos[0].Id;
            Contact contatoName = [SELECT Id, 
                                          Name
                                   FROM Contact
                                   WHERE Id = :contatoId];
            List<User> usuarios = [SELECT Id, 
                                          Name, 
                                          FullPhotoUrl, 
                                          SmallPhotoUrl
                                   FROM User
                                   WHERE ContactId = :contatoId
                                   LIMIT 1];

            if (usuarios.isEmpty()) {
                return null;
            }

            Map<String, String> dadosPaciente = new Map<String, String>();
            dadosPaciente.put('nome', usuarios[0].Name);
            dadosPaciente.put('fotoUrl', usuarios[0].SmallPhotoUrl); // Ou FullPhotoUrl para foto maior
            return dadosPaciente;

        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<APP_ProfissionalListResponseDTO> listarAgendaPacienteLogado(String dateStart, String dateEnd) {
        try {
            String cpf = getCpfDoPacienteLogado();

            List<APP_PatientResponseDTO> pacientes = APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);
            if (pacientes == null
                || pacientes.isEmpty()) {
                throw new AuraHandledException('Paciente não encontrado com CPF fornecido.');
            }

            String prontuario = pacientes[0].id;
            List<APP_ProfissionalListResponseDTO> agendamentos = APP_ProfissionalService.listarAgendamentosFiltrados(1, 10, dateStart, dateEnd, prontuario);

            if (agendamentos != null) {
                for (APP_ProfissionalListResponseDTO agendamento : agendamentos) {
                    if (agendamento.actor != null
                        && !agendamento.actor.isEmpty()
                        && String.isNotBlank(agendamento.actor[0].reference)) {
                        Map<String, String> dadosMedico = getDadosMedicoPorProntuario(agendamento.actor[0].reference);
                        if (dadosMedico != null) {
                            // Adiciona os dados do médico ao DTO
                            agendamento.actor[0].nomeMedico = dadosMedico.get('nome');
                            agendamento.actor[0].fotoMedicoUrl = dadosMedico.get('fotoUrl');
                        }
                    }
                }
            }
            return agendamentos;
        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled
    public static void registrarErroLog(String endpoint, Integer statusCode, String mensagem, String body) {
        APP_Logger.logErro(endpoint, statusCode, mensagem, body);
    }

    @AuraEnabled(cacheable = true)
    public static APP_Parametro__c buscarParametros() {
        return [SELECT MaximumRetroactivePeriodMonths__c, 
                       MaximumFuturePeriodMonths__c
                FROM APP_Parametro__c
                WHERE RecordType.DeveloperName = 'Agenda'
                LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Account> getPatientInfo(String identificacao, Integer intOffset, Integer intLimit) {
        String searchKey = '%' + identificacao + '%';
        return [SELECT Id, 
                       Name, 
                       CNPJ__c, 
                       RNE__c, 
                       PersonBirthdate, 
                       HealthCloudGA__Gender__pc, 
                       APP_NumeroProntuario__c, 
                       APP_Filiacao1__c, 
                       APP_Filiacao2__c, 
                       Phone, 
                       PersonEmail
                FROM Account
                WHERE RecordType.DeveloperName = 'PersonAccount' AND (Name LIKE:searchKey OR CNPJ__c LIKE:searchKey OR RNE__c LIKE:searchKey OR APP_NumeroProntuario__c LIKE:searchKey)
                LIMIT :intLimit
                OFFSET :intOffset];
    }

    @AuraEnabled(cacheable = true)
    public static Integer getPatientCount(String identificacao) {
        String searchKey = '%' + identificacao + '%';
        return [SELECT COUNT()
                FROM Account 
                WHERE RecordType.DeveloperName = 'PersonAccount' AND (Name LIKE:searchKey OR CNPJ__c LIKE:searchKey OR RNE__c LIKE:searchKey OR APP_NumeroProntuario__c LIKE:searchKey)];
    }

    // Retorna os dados do prontuário por id
    @AuraEnabled(cacheable = false)
    public static APP_PatientRecordsResponseDTO buscarProntuarioPacientePorId(String idProntuario) {
        return APP_ProfissionalService.buscarProntuarioPacientePorId(idProntuario);
    }






    // Busco os resultados que preciso e tb o numero total de registros em uma única chamada
    public class PatientSearchResponse {
        @AuraEnabled
        public List<Account> patients;
        @AuraEnabled
        public Integer total;
    }
    @AuraEnabled
    public static PatientSearchResponse searchPatients(String identificacao, Integer intOffset, Integer intLimit) {
        String searchKey = '%' + identificacao + '%';

        PatientSearchResponse result = new PatientSearchResponse();

        result.patients = [SELECT Id, 
                                  Name, 
                                  CNPJ__c, 
                                  RNE__c, 
                                  PersonBirthdate, 
                                  HealthCloudGA__Gender__pc, 
                                  APP_NumeroProntuario__c, 
                                  APP_Filiacao1__c, 
                                  APP_Filiacao2__c, 
                                  Phone, 
                                  PersonEmail,
                                  PhotoUrl
                           FROM Account
                           WHERE RecordType.DeveloperName = 'PersonAccount' AND (Name LIKE:searchKey OR CNPJ__c LIKE:searchKey OR RNE__c LIKE:searchKey OR APP_NumeroProntuario__c LIKE:searchKey)
                           LIMIT :intLimit
                           OFFSET :intOffset];

        result.total = [SELECT COUNT()
                        FROM Account 
                        WHERE RecordType.DeveloperName = 'PersonAccount' AND (Name LIKE:searchKey OR CNPJ__c LIKE:searchKey OR RNE__c LIKE:searchKey OR APP_NumeroProntuario__c LIKE:searchKey)];

        return result;
    }
}