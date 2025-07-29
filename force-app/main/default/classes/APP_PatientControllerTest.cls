@isTest
private class APP_PatientControllerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '12345678900');
        insert acc;
    
        Contact contPaciente = new Contact(
            FirstName = 'Paciente', 
            LastName = 'Teste', 
            AccountId = acc.Id, 
            CPF__c = '12345678900'
        );
        insert contPaciente;
        
        Contact contMedico = new Contact(
            FirstName = 'Médico', 
            LastName = 'Teste', 
            AccountId = acc.Id, 
            CPF__c = '12345678905'
        );
        insert contMedico;
    }


    @isTest
    static void testGetCpfDoPacienteLogado() {
        Contact contact = [SELECT Id FROM Contact WHERE CPF__c = '12345678900' LIMIT 1];

        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        User u = new User(
            Username = 'testuser@app.com',
            LastName = 'Teste',
            Alias = 'tuser',
            Email = 'testuser@app.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = stdProfile.Id,
            ContactId = contact.Id
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            String cpf = APP_PatientController.getCpfDoPacienteLogado();
            Test.stopTest();
            
            System.assertEquals('12345678900', cpf, 'O CPF retornado deve ser igual ao configurado no setup');
        }
    }

    @isTest
    static void testRegistrarErroLog() {
        Test.startTest();
        APP_PatientController.registrarErroLog('endpoint', 500, 'erro', 'corpo');
        Test.stopTest();
        
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assert(!logs.isEmpty(), 'Deveria ter criado um registro de log');
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            String body = '[{"name": "Paciente Teste", "document": "12345678900", "dateValue": "2025-07-01"}]';
			res.setBody(body.replace('"dateValue"', '"date"').replace('"numberValue"', '"number"').replace('"typeValue"', '"type"'));
            return res;
            
        }
    }
    
    private class MockBuscarPorProntuarioComCPF implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String body = '[{"cpf": "12345678900"}]';
            res.setBody(body);
            return res;
        }
    }
    
    private class MockAgendamentoComActorComReferencia implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
   
            String body = '[{ ' +
                '"actor": [{ "reference": "abc123" }], ' +
                '"otherField": "valor qualquer" ' +
            '}]';
    
            res.setBody(body);
            return res;
        }
    }


    private class MockProntuarioResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
    
            String json = '{"records": [{"dateTm": "2025-07-01T10:00:00", "description": "Exame de Sangue"}]}';
            res.setBody(json.replace('"dateTm"', '"date"'));
            return res;
        }
	}
    
    private class MockHttpResponseMedico implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
    
            String body = '[{"name": "Dr. Teste", "cpf": "12345678900", "date": "2025-07-01"}]';
            res.setBody(body);
            return res;
        }
	}
    
    private class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String body = '[{"startDate": "2025-07-28T10:00:00", "endDate": "2025-07-28T11:00:00", "appointmentType": {"display": "Consulta"}}]';
            res.setBody(body.replace('"endDate"', '"end"').replace('"systemValue"', '"system"')); // Reverso do replace feito no método real
            return res;
        }
    }

    
    @isTest
    static void testGetPacientesPorCpf() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<APP_PatientResponseDTO> pacientes = APP_PatientController.getPacientesPorCpf('12345678900');
        Test.stopTest();
       
        System.assertNotEquals(null, pacientes);
        System.assertEquals(1, pacientes.size());
    }
    
    @isTest
    static void testGetPacientesPorCpfError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<APP_PatientResponseDTO> pacientes = APP_PatientController.getPacientesPorCpf('42345678944');
        Test.stopTest();
       
        System.assertNotEquals(null, pacientes);
        System.assertEquals(1, pacientes.size());
    }
  
    @isTest
    static void testListarAgendamentosFiltrados() {
        Contact contact = [SELECT Id FROM Contact WHERE CPF__c = '12345678900' LIMIT 1];
        
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        User u = new User(
            Username = 'paciente@app.com',
            LastName = 'Paciente',
            Alias = 'pac',
            Email = 'paciente@app.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = stdProfile.Id,
            ContactId = contact.Id
        );
        insert u;
    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200()); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse()); 
    
        System.runAs(u) {
            Test.startTest();
            List<APP_ProfissionalListResponseDTO> lista = APP_PatientController.listarAgendaPacienteLogado('2025-07-28T10:00:00', '2025-07-28T11:00:00');
            Test.stopTest();
    
            System.assertNotEquals(null, lista, 'A lista de agendamentos deve ser retornada');
            System.assertEquals(1, lista.size(), 'Deve conter um agendamento');
        }
   }
    
   @isTest
   static void testBuscarPorProntuario() {
        Test.setMock(HttpCalloutMock.class, new MockBuscarPorProntuarioComCPF());
    
        Contact cont = [SELECT Id, Name FROM Contact WHERE CPF__c = '12345678900'];
    
        User u = new User(
            Username = 'medico.teste@example.com',
            LastName = 'Teste Médico',
            Alias = 'medtest',
            Email = 'medico.teste@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            APP_ContatoId__c = cont.Id
        );
        insert u;
    
        Test.startTest();
       	User insertedUser = [SELECT Id, Name, APP_ContatoId__c FROM User WHERE Id = :u.Id];
        Map<String, String> dadosMedico = APP_PatientController.getDadosMedicoPorProntuario('abc123');
        Test.stopTest();
    
        System.assertNotEquals(null, dadosMedico, 'Deveria ter entrado no bloco final e retornado o mapa');
    }  
    
     @isTest
   static void testBuscarPorProntuarioSemUsuarioIgualAoContato() {
        Test.setMock(HttpCalloutMock.class, new MockBuscarPorProntuarioComCPF());
    
        Contact cont = new Contact(
            FirstName = 'Teste', 
            LastName = 'Teste', 
            CPF__c = '12345678903'
        );
        insert cont;
    
        User u = new User(
            Username = 'medico.teste@example.com',
            LastName = 'Teste Médico',
            Alias = 'medtest',
            Email = 'medico.teste@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            APP_ContatoId__c = cont.Id
        );
        insert u;
    
        Test.startTest();
       	User insertedUser = [SELECT Id, Name, APP_ContatoId__c FROM User WHERE Id = :u.Id];
        Map<String, String> dadosMedico = APP_PatientController.getDadosMedicoPorProntuario('abc123');
        Test.stopTest();
    
        System.assertEquals(null, dadosMedico, 'Não deve ter retorno');
    }  
    
    @isTest
    static void testListarAgendamentos_ComDadosMedico() {
        Contact contact = [SELECT Id FROM Contact WHERE CPF__c = '12345678900' LIMIT 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        User u = new User(
            Username = 'paciente.dadosmedico@app.com',
            LastName = 'Paciente Dados',
            Alias = 'pacdado',
            Email = 'paciente.dados@app.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = profile.Id,
            ContactId = contact.Id
        );
        insert u;
    
        Test.setMock(HttpCalloutMock.class, new MockAgendamentoComActorComReferencia());
    
        System.runAs(u) {
            Test.startTest();
            List<APP_ProfissionalListResponseDTO> lista = APP_PatientController.listarAgendaPacienteLogado('2025-07-28T10:00:00', '2025-07-28T11:00:00');
            Test.stopTest();
    
            System.assertNotEquals(null, lista, 'Deveria retornar uma lista de agendamentos');
            System.assertEquals(1, lista.size(), 'Deveria haver 1 agendamento');
        }
    }

}