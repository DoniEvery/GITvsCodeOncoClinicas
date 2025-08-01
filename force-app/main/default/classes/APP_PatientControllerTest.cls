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
            FirstName = 'Médico 2', 
            LastName = 'Teste', 
            AccountId = acc.Id, 
            CPF__c = '12345678905'
        );
        insert contMedico;
        

    }


    @isTest
    static void testGetCpfDoPacienteLogado() {
        Contact contact = [SELECT Id FROM Contact WHERE CPF__c = '12345678900' LIMIT 1];

        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Medico' LIMIT 1];
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
            APP_ContatoId__c = contact.Id
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            String cpf = APP_PatientController.getCpfDoMedicoLogado();
            Test.stopTest();
            
            System.assertEquals('12345678900', cpf, 'O CPF retornado deve ser igual ao configurado no setup');
        }
    }
    
    @isTest
    static void testGetCpfDoMedicoLogado() {
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
    static void testListarAgendamentosMedicosFiltrados() {
        Contact contact = [SELECT Id FROM Contact WHERE CPF__c = '12345678900' LIMIT 1];
        
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Medico' LIMIT 1];
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
            APP_ContatoId__c = contact.Id
        );
        insert u;
    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200()); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse()); 
    
        System.runAs(u) {
            Test.startTest();
            List<APP_ProfissionalListResponseDTO> lista = APP_PatientController.listarAgendaMedicoLogado('2025-07-28T10:00:00', '2025-07-28T11:00:00');
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
    static void testBuscarPorProntuarioPaciente() {
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
    
       Test.setMock(HttpCalloutMock.class, new MockBuscarPorProntuarioComCPF());
        
        Test.startTest();
        Map<String, String> dadosPaciente = APP_PatientController.getDadosPacientesPorProntuario('abc123');
        Test.stopTest();
        
        System.assertNotEquals(null, dadosPaciente, 'Deveria ter retornado os dados do paciente');
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
    
    @isTest 
    static void testBuscarParametros() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Agenda' LIMIT 1];

        APP_Parametro__c parametro = new APP_Parametro__c(
            RecordTypeId = rt.Id,
            MaximumRetroactivePeriodMonths__c = 6,
            MaximumFuturePeriodMonths__c = 12
        );
        insert parametro;

        Test.startTest();
        APP_Parametro__c resultado = APP_PatientController.buscarParametros();
        Test.stopTest();

        System.assertNotEquals(null, resultado, 'Deve retornar um registro');
        System.assertEquals(parametro.MaximumRetroactivePeriodMonths__c, resultado.MaximumRetroactivePeriodMonths__c, 'Valor do MaximumRetroactivePeriodMonths__c deve bater');
        System.assertEquals(parametro.MaximumFuturePeriodMonths__c, resultado.MaximumFuturePeriodMonths__c, 'Valor do MaximumFuturePeriodMonths__c deve bater');
    }
    
    @isTest
    static void testBuscarProntuarioPacientePorId() {
        Test.setMock(HttpCalloutMock.class, new MockProntuarioResponse200());
        
        Test.startTest();
        APP_PatientRecordsResponseDTO prontuario = APP_PatientController.buscarProntuarioPacientePorId('paciente123');
        Test.stopTest();
    
        System.assertNotEquals(null, prontuario, 'Deve retornar um DTO válido de prontuário');
    }
    
    @isTest
    static void testGetPatientInfo() {
        // Cria o RecordType para PersonAccount
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];

        // Paciente com nome
        Account pacienteNome = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'PacienteNome',
            CNPJ__c = '27426454037',
            RNE__c = 'RNE000001',
            APP_NumeroProntuario__c = 'PRONT001',
            APP_Filiacao1__c = 'Pai A',
            APP_Filiacao2__c = 'Mãe A',
            Phone = '11999999991',
            PersonEmail = 'nome@teste.com',
            PersonBirthdate = Date.newInstance(1991, 1, 1),
            HealthCloudGA__Gender__pc = 'Masculino'
        );

        // Paciente com CNPJ
        Account pacienteCNPJ = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'Outro',
            CNPJ__c = '50196621003',
            RNE__c = 'RNE000002',
            APP_NumeroProntuario__c = 'PRONT002',
            Phone = '11999999992',
            PersonEmail = 'cnpj@teste.com'
        );

        // Paciente com RNE
        Account pacienteRNE = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'Outro',
            CNPJ__c = '13350501087',
            RNE__c = 'RNESPECIFICO',
            APP_NumeroProntuario__c = 'PRONT003',
            Phone = '11999999993',
            PersonEmail = 'rne@teste.com'
        );

        // Paciente com número do prontuário
        Account pacientePront = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'Outro',
            CNPJ__c = '25962737059',
            RNE__c = 'RNE000004',
            APP_NumeroProntuario__c = 'PRONTBUSCA123',
            Phone = '11999999994',
            PersonEmail = 'prontuario@teste.com'
        );

        insert new List<Account>{ pacienteNome, pacienteCNPJ, pacienteRNE, pacientePront };

        Test.startTest();

        // Teste por nome
        List<Account> porNome = APP_PatientController.getPatientInfo('PacienteNome', 0, 10);
        System.assertEquals(1, porNome.size(), 'Deve retornar o paciente com nome correspondente');
        System.assertEquals(pacienteNome.Id, porNome[0].Id);

        // Teste por CNPJ
        List<Account> porCNPJ = APP_PatientController.getPatientInfo('50196621003', 0, 10);
        System.assertEquals(1, porCNPJ.size(), 'Deve retornar o paciente com CNPJ correspondente');
        System.assertEquals(pacienteCNPJ.Id, porCNPJ[0].Id);

        // Teste por RNE
        List<Account> porRNE = APP_PatientController.getPatientInfo('RNESPEC', 0, 10);
        System.assertEquals(1, porRNE.size(), 'Deve retornar o paciente com RNE correspondente');
        System.assertEquals(pacienteRNE.Id, porRNE[0].Id);

        // Teste por número de prontuário
        List<Account> porProntuario = APP_PatientController.getPatientInfo('PRONTBUSCA123', 0, 10);
        System.assertEquals(1, porProntuario.size(), 'Deve retornar o paciente com número de prontuário correspondente');
        System.assertEquals(pacientePront.Id, porProntuario[0].Id);

        Test.stopTest();
    }
}