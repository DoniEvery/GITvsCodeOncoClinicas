@IsTest
global class cfmServiceTest {
	@IsTest
	static void teste() {
		Test.startTest();
		cfmService.ConsultaCompletaResponse ConsultaCompletaResponse = new cfmService.ConsultaCompletaResponse();
		cfmService.ConsultaCompleta ConsultaCompleta = new cfmService.ConsultaCompleta();
		cfmService.Consultar Consultar = new cfmService.Consultar();
		cfmService.buscarImagem buscarImagem = new cfmService.buscarImagem();
		cfmService.buscarImagemResponse buscarImagemResponse = new cfmService.buscarImagemResponse();
		cfmService.ValidarResponse ValidarResponse = new cfmService.ValidarResponse();
		cfmService.ConsultarResponse ConsultarResponse = new cfmService.ConsultarResponse();
		cfmService.Exception_x Exception_x = new cfmService.Exception_x();
		cfmService.medicoVO medicoVO = new cfmService.medicoVO();
		Test.stopTest();
	}

	@IsTest
	static void testConsultaCompleta() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockConsultaCompleta());

		cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
		response.ConsultaCompleta(1, '', '', '', '');
		Test.stopTest();
	}

	@IsTest
	static void testBuscarImagem() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockBuscarImagem());

		cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
		response.buscarImagem('', '');
		Test.stopTest();
	}

	@IsTest
	static void testValidar() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockValidar());

		cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
		response.Validar(1, '', '', '', '');
		Test.stopTest();
	}

	@IsTest
	static void testConsultar() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockConsultar());

		cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
		response.Consultar(1, '', '');
		Test.stopTest();
	}

	global class MockConsultaCompleta implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ConsultaCompletaResponse result = new cfmService.ConsultaCompletaResponse();
			response.put('response_x', result);
		}
	}

	global class MockBuscarImagem implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.buscarImagemResponse result = new cfmService.buscarImagemResponse();
			response.put('response_x', result);
		}
	}

	global class MockValidar implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ValidarResponse result = new cfmService.ValidarResponse();
			response.put('response_x', result);
		}
	}

	global class MockConsultar implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ConsultarResponse result = new cfmService.ConsultarResponse();
			response.put('response_x', result);
		}
	}
}