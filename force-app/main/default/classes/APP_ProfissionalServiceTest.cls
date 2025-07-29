@isTest
private class APP_ProfissionalServiceTest {
    
    private class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String body = '[{"startDate": "2025-07-28T10:00:00", "endDate": "2025-07-28T11:00:00", "appointmentType": {"display": "Consulta"}}]';
            res.setBody(body.replace('"endDate"', '"end"').replace('"systemValue"', '"system"')); // Reverso do replace feito no método real
            return res;
        }
    }

    private class MockPatientResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String body = '[{"name": "Paciente Teste", "document": "12345678900", "dateValue": "2025-07-01"}]';
            res.setBody(body.replace('"dateValue"', '"date"').replace('"numberValue"', '"number"').replace('"typeValue"', '"type"'));
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

    @isTest
    static void testListarAgendamentosFiltrados() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());

        Test.startTest();
        List<APP_ProfissionalListResponseDTO> lista = APP_ProfissionalService.listarAgendamentosFiltrados(1, 10, '2025-07-01', '2025-07-30', '123456');
        Test.stopTest();

        System.assertNotEquals(null, lista, 'A lista de agendamentos deve ser retornada');
        System.assertEquals(1, lista.size(), 'Deve conter um agendamento');
    }

    @isTest
    static void testBuscarPacientePorCpf() {
        Test.setMock(HttpCalloutMock.class, new MockPatientResponse200());

        Test.startTest();
        List<APP_PatientResponseDTO> pacientes = APP_ProfissionalService.buscarPacientePorCpf('12345678900', 1, 1);
        Test.stopTest();

        System.assertNotEquals(null, pacientes);
        System.assertEquals(1, pacientes.size());
    }

    @isTest
    static void testBuscarPorProntuario() {
        Test.setMock(HttpCalloutMock.class, new MockPatientResponse200());

        Test.startTest();
        List<APP_PatientResponseDTO> pacientes = APP_ProfissionalService.buscarPorPronturario('abc123', 1, 1);
        Test.stopTest();

        System.assertNotEquals(null, pacientes);
    }
    
 
    @isTest
    static void testBuscarProntuarioPacientePorId() {
        
        /*
        List<ServicePath__mdt> configs = [
            SELECT Service_Path__c 
            FROM ServicePath__mdt 
            WHERE DeveloperName = 'Prontuario_DEV_QA' 
            LIMIT 1
        ];
		*/
        
        Test.setMock(HttpCalloutMock.class, new MockProntuarioResponse200());
        
        Test.startTest();
        APP_PatientRecordsResponseDTO prontuario = APP_ProfissionalService.buscarProntuarioPacientePorId('paciente123', 1, 10, '2025-07-01', '2025-07-31');
        Test.stopTest();
    
        System.assertNotEquals(null, prontuario, 'Deve retornar um DTO válido de prontuário');
    }
        
}