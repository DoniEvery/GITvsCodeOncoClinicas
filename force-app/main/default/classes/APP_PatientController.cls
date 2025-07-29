public without sharing class APP_PatientController {
    
    public static String getCpfDoPacienteLogado() {
        User user = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Contact contato = [SELECT Account.CNPJ__c FROM Contact WHERE Id = :user.ContactId LIMIT 1];
        return contato.Account.CNPJ__c;
    }

    public static String getCpfDoMedicoLogado() {
        User user = [SELECT APP_ContatoId__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        if (user.APP_ContatoId__c == null) {
            throw new AuraHandledException('Usuário logado não possui um contato associado.');
        }
        Contact contato = [SELECT CPF__c FROM Contact WHERE Id = :user.APP_ContatoId__c LIMIT 1];
        return contato.CPF__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<APP_PatientResponseDTO> getPacientesPorCpf(String cpf) {
        try {
            return APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);

        } catch (AuraHandledException aex) {
            throw aex;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<APP_ProfissionalListResponseDTO> listarAgendaMedicoLogado(String dateStart, String dateEnd) {
        try {
            String cpf = getCpfDoMedicoLogado();
            System.debug('cpf >>' + cpf);
            
            List<APP_PatientResponseDTO> medicos = APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);
            if (medicos == null || medicos.isEmpty()) {
                System.debug('Médico não encontrado >>' + medicos);
                throw new AuraHandledException('Médico não encontrado com CPF fornecido.');
            }

            String prontuario = medicos[0].id;
            List<APP_ProfissionalListResponseDTO> agendamentos = APP_ProfissionalService.listarAgendamentosFiltrados(1, 10, dateStart, dateEnd, prontuario);
            
            if (agendamentos != null) {
                for (APP_ProfissionalListResponseDTO agendamento : agendamentos) {
                    if (agendamento.actor != null && !agendamento.actor.isEmpty() && String.isNotBlank(agendamento.actor[0].reference)) {
                        Map<String, String> dadosMedico = getDadosMedicoPorProntuario(agendamento.actor[0].reference);
                        if (dadosMedico != null) {
                            // Adiciona os dados do médico ao DTO
                            agendamento.actor[1].nomeMedico = dadosMedico.get('nome'); //nome paciente
                            agendamento.actor[1].fotoMedicoUrl = dadosMedico.get('fotoUrl'); //foto paciente
                        }
                    }
                }
            }
            return agendamentos;
        } catch (AuraHandledException aex) {
            // Já é uma exceção lançada no formato correto, repassa para o JS sem modificar
            throw aex;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getDadosMedicoPorProntuario(String prontuarioMedico) {
        try {
            List<APP_PatientResponseDTO> medicos = APP_ProfissionalService.buscarPorPronturario(prontuarioMedico, 1, 1);
            
            if (medicos == null || medicos.isEmpty() || String.isBlank(medicos[0].cpf)) {
                return null;
            }
            
            String cpfMedico = medicos[0].cpf;
            List<Contact> contatos = [SELECT Id FROM Contact WHERE CPF__c = :cpfMedico LIMIT 1];
            
            if (contatos.isEmpty()) {
                return null;
            }
            
            String contatoId = contatos[0].Id;
            Contact contatoName = [SELECT Id, Name FROM Contact WHERE Id = :contatoId];
            List<User> usuarios = [SELECT Id, Name, FullPhotoUrl, SmallPhotoUrl FROM User WHERE APP_ContatoId__c = :contatoId LIMIT 1];
            
            if (usuarios.isEmpty()) {
                return null;
            }
            
            Map<String, String> dadosMedico = new Map<String, String>();
            dadosMedico.put('nome', usuarios[0].Name);
            dadosMedico.put('fotoUrl', usuarios[0].SmallPhotoUrl); // Ou FullPhotoUrl para foto maior
            
            System.debug('Controller dadosMedico>> ' + dadosMedico);
            return dadosMedico;
            
        } catch (AuraHandledException aex) {
            // Já é uma exceção lançada no formato correto, repassa para o JS sem modificar
            throw aex;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<APP_ProfissionalListResponseDTO> listarAgendaPacienteLogado(String dateStart, String dateEnd) {
        try {
            String cpf = getCpfDoPacienteLogado();
            
            List<APP_PatientResponseDTO> pacientes = APP_ProfissionalService.buscarPacientePorCpf(cpf, 1, 3);
            if (pacientes == null || pacientes.isEmpty()) {
                throw new AuraHandledException('Paciente não encontrado com CPF fornecido.');
            }

            String prontuario = pacientes[0].id;
            List<APP_ProfissionalListResponseDTO> agendamentos = APP_ProfissionalService.listarAgendamentosFiltrados(1, 10, dateStart, dateEnd, prontuario);
            
            if (agendamentos != null) {
                for (APP_ProfissionalListResponseDTO agendamento : agendamentos) {
                    if (agendamento.actor != null && !agendamento.actor.isEmpty() && String.isNotBlank(agendamento.actor[0].reference)) {
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
            // Já é uma exceção lançada no formato correto, repassa para o JS sem modificar
            throw aex;
        }
    }

    @AuraEnabled
    public static void registrarErroLog(String endpoint, Integer statusCode, String mensagem, String body) {
        APP_Logger.logErro(endpoint, statusCode, mensagem, body);
    }
}