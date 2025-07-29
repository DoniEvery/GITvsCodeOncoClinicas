public class cirurgioesController {
	 
    public static List<responseEncaminhamento> createCase(String portalData){
        list<dadosMedicoPaciente> dadosMedicoPacienteList = (list<dadosMedicoPaciente>) JSON.deserialize(portalData, list<dadosMedicoPaciente>.class);
        
        list<responseEncaminhamento> response = new list<responseEncaminhamento>();
        list<Account> contasParaInserir = new list<Account>();
        list<Contact> contatosEncontrados = new list<Contact>();
        list<Contact> medicoList = new list<Contact>();
        list<Case> casosParaInserir = new list<Case>();
        set<String> buscarCPF = new set<String>();
        set<String> buscarFilaPorPraca = new set<String>();
        Map<String, Id> contaIdMap = new Map<String, Id>();
        Map<String, Id> filaIdMap = new Map<String, Id>();
        Map<String, Contact> contatoMap = new Map<String, Contact>();
        Map<String, String> cpfUnidadeMap = new Map<String, String>();
        Map<String, String> cpfPracaMap = new Map<String, String>();

        for (dadosMedicoPaciente dados : dadosMedicoPacienteList) {
            buscarCPF.add(dados.CPFPaciente);
            buscarFilaPorPraca.add(dados.praca);
        }
        
        list<Account> pacientesEncontrados = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c IN: buscarCPF];
        for(Account paciente : [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c IN: buscarCPF]){
            contaIdMap.put(paciente.CNPJ__c, paciente.Id);
        }
        
        for(Group filas : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN: buscarFilaPorPraca]){
            filaIdMap.put(filas.Name, filas.Id);
        }
        
        for (dadosMedicoPaciente dados : dadosMedicoPacienteList) {
            	String validarCampos = validarCamposObrigatorios(dados);
                System.debug('dados '+ dados);
                if(validarCampos != ''){
                    String campoObrigatorio = 'O(s) Campo(s) são obrigatórios/inválidos: ' + validarCampos;
                    responseEncaminhamento resp = new responseEncaminhamento();
                    resp.status = 'Erro';
                    resp.codigoStatus = '002';
                    resp.mensagem = 'Erro de campos obrigatórios/inválidos. ' + campoObrigatorio;
                    response.add(resp);
                    continue;
                }else {
                    Account paciente = new Account();
                    paciente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    paciente.FirstName = String.isNotEmpty(dados.nomePaciente) ? dividirNome(dados.nomePaciente).get('firstName') : '';
                    paciente.LastName = String.isNotEmpty(dados.nomePaciente) ? dividirNome(dados.nomePaciente).get('lastName') : '';
                    paciente.PersonEmail = String.isNotEmpty(dados.email) ? dados.email : '';
                    paciente.CNPJ__c = String.isNotEmpty(dados.CPFPaciente) ? dados.CPFPaciente : '';
                    paciente.Numero_Documento_RG__c = String.isNotEmpty(dados.RGPaciente) ? dados.RGPaciente : '';
                    paciente.PersonMobilePhone = String.isNotEmpty(dados.celularPaciente) ? dados.celularPaciente : '';
                    paciente.Phone = String.isNotEmpty(dados.telefonePaciente) ? dados.telefonePaciente : '';
                    String dataAniversario = String.isNotEmpty(dados.dataNascimento) ? dados.dataNascimento : '';
                    paciente.PersonBirthdate = Date.valueOf(dataAniversario);
                    paciente.HealthCloudGA__Gender__pc = String.isNotEmpty(dados.genero ) ? dados.genero : '';
                    paciente.Codigo_CID__c = String.isNotEmpty(dados.CID) ? dados.CID : '';   
                    
                    if(!contaIdMap.containsKey(dados.CPFPaciente)){
                        contasParaInserir.add(paciente);
                    	contaIdMap.put(dados.CPFPaciente, null);
                    }
                    
                    if(String.isNotEmpty(dados.unidade)){
                        cpfUnidadeMap.put(dados.CPFPaciente, dados.unidade);    
                    }
                    
                    if(String.isNotEmpty(dados.praca)){
                        cpfPracaMap.put(dados.CPFPaciente, dados.praca);
                    }
                    
                    String campoChave = String.isNotEmpty(dados.CRMUF) != null ? dados.CRMUF : '';
                    if(String.isNotEmpty(campoChave)){
                        contatoMap.put(campoChave, null);
                    }   
                }           
        }

        list<Database.SaveResult> srList = new list<Database.SaveResult>();
        if (!contasParaInserir.isEmpty()) {
        	srList = Database.insert(contasParaInserir, false);
        }
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Paciente criado com sucesso >>> ' + sr);
            }
            else {
                for(Database.Error err : sr.getErrors()) {  
                    System.debug('Erro ao criar paciente');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Campo com erro: ' + err.getFields());
                }
            }
        }

        for (Account paciente : contasParaInserir) {
            if(String.isNotEmpty(paciente.Id)){
            	contaIdMap.put(paciente.CNPJ__c, paciente.Id);    
            }else{
                responseEncaminhamento resp = new responseEncaminhamento();
                resp.status = 'Erro';
                resp.codigoStatus = '003';
                resp.mensagem = 'Erro no Salesforce: O paciente ' + paciente.FirstName + ' '+ paciente.LastName + ' não foi criado.';
                response.add(resp);
            }
        }
		
        Set<String> chavesContato = contatoMap.keySet();
        medicoList = [SELECT Id, CRM_UF__c FROM Contact WHERE CRM_UF__c IN :chavesContato];
        
        if(!medicoList.isEmpty()){
        	for (Contact medico : medicoList) {
            	contatoMap.put(medico.CRM_UF__c, medico);
        	}
        }
        
        for (dadosMedicoPaciente dados : dadosMedicoPacienteList) {
            Id contaId = contaIdMap.get(dados.CPFPaciente);
            String campoChave = dados.CRMUF;
            Contact contato = contatoMap.get(campoChave);

            if (contaId != null) {
                Case caso = new Case();
                caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('EncaminhamentoCirurgioes').getRecordTypeId();
                caso.AccountId = contaId;
                caso.Status = 'New';
                caso.Subject = 'Encaminhamento Cirurgiões';
                caso.Origin = 'Portal - Médico externo';
                caso.UnidadeRecebePacienteEncaminhado__c = cpfUnidadeMap.get(dados.CPFPaciente);
                caso.PracaPicklist__c = cpfPracaMap.get(dados.CPFPaciente);
                caso.OwnerId = filaIdMap.get(caso.PracaPicklist__c);
                caso.ContactId = contato != null ? contato.Id : null;
                caso.CriadoIntegracao__c = true;
                
                if(contato == null){
                    caso.Medico__c = dados.nomeMedico;
                    caso.CRMUFMedico__c = dados.CRMUF;
                }
                
                casosParaInserir.add(caso);
            }
        }

        list<Database.SaveResult> srCaseList = new list<Database.SaveResult>();
        if (!casosParaInserir.isEmpty()) {
        	srCaseList = Database.insert(casosParaInserir, false);
        }
         
        for (Database.SaveResult sr : srCaseList) {
            if (sr.isSuccess()) {
                System.debug('Caso de encaminhamento criado com sucesso >>> ' + sr);
                responseEncaminhamento resp = new responseEncaminhamento();
                resp.status = 'Sucesso';
                resp.codigoStatus = '001';
                resp.caseId = sr.getId();
                resp.mensagem = 'Caso criado com sucesso';
                response.add(resp);
            }
            else {
                for(Database.Error err : sr.getErrors()) {  
                    System.debug('Erro ao criar caso de encaminhamento');  
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Campo com erro: ' + err.getFields());
                    responseEncaminhamento resp = new responseEncaminhamento();
                    resp.status = 'Erro';
                    resp.codigoStatus = '004';
                    resp.mensagem = 'Erro ao criar caso';
                    response.add(resp);
                    
                }
            }
        }
        
        return response;
    }
    
    public static String validarCamposObrigatorios(dadosMedicoPaciente dados){
        String campoObrigatorio = '';
        campoObrigatorio += String.isEmpty(dados.nomePaciente) ? ' - Nome Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.email) ? ' - Email Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.CPFPaciente) ? ' - CPF Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.RGPaciente) ? ' - RG Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.celularPaciente) ? ' - Celular Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.telefonePaciente) ? ' - Telefone Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.dataNascimento) ? ' - Data de nascimento Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.genero) ? ' - Gênero Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.CID) ? ' - CID Paciente' : '';
        campoObrigatorio += String.isEmpty(dados.Praca) ? ' - Praça' : '';
        Integer tamanhoCPF = dados.CPFPaciente.length();
        campoObrigatorio += tamanhoCPF != 11 ? ' - CPF com tamanho inválido' : '';
        campoObrigatorio += String.isEmpty(dados.Praca) ? ' - Praça' : '';
        if (dados.Praca != null) {
            campoObrigatorio += dados.Praca.toUpperCase().equals('TODOS') ? ' - Praça não pode ser Todos' : '';
            campoObrigatorio += dados.Praca.toUpperCase().equals('TODAS') ? ' - Praça não pode ser Todas' : '';
        }
        
        campoObrigatorio += String.isEmpty(dados.nomeMedico) ? ' - Nome Medico' : '';
        campoObrigatorio += String.isEmpty(dados.CRMUF) ? ' - CRM UF' : '';
        
        return campoObrigatorio;
    }
    
    public static Map<String, String> dividirNome(String nomeCompleto) {
            // Remove espaços extras no início e no fim
            nomeCompleto = nomeCompleto.trim();
            
            // Separa o nome por espaços
            List<String> partes = nomeCompleto.split('\\s+');
            
            String firstName;
            String lastName;
            
            if (partes.size() == 1) {
                firstName = partes[0];
                lastName = '';
            } else {
                firstName = partes[0];
                lastName = partes[partes.size() - 1];
            }
            
            Map<String, String> nomeDividido = new Map<String, String>();
            nomeDividido.put('firstName', firstName);
            nomeDividido.put('lastName', lastName);
            
            return nomeDividido;
        }
        
    public class dadosMedicoPaciente{
        //dados para criar o paciente (conta pessoal)
		String nomePaciente;
		String email;
		String CPFPaciente;
		String RGPaciente;
        String celularPaciente;
        String telefonePaciente;
        String dataNascimento;
        String genero;
        String CID;	
        String unidade;
        String praca;
        //dados para vincular o contato no caso
        String nomeMedico;
        String CRMUF;
    }

    public class responseEncaminhamento{
        String status;
        String caseId;
        String pacienteId;
        String codigoStatus;
        String mensagem;
    }
}