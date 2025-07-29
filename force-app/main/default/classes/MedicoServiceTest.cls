@isTest
private with sharing class MedicoServiceTest {
	@isTest
	static void consultaMedicoTestSucesso() {
		MedicoService medicoService = new MedicoService();

		Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosPort());
		Contact contato = medicoService.consultaMedico(12345, 'SP'); 

        System.assertEquals(true, contato.CRM__c == '12345');
	}

	@isTest
	static void consultaMedicoTestErroServico() {
		MedicoService medicoService = new MedicoService();

		Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosErro());

		// Nenhum Medico Test -> throws exception
		try {
			medicoService.consultaMedico(123456, 'SP');
		} catch (Exception ex) {
			System.assertEquals(true, ex.getMessage().contains('Nenhum médico foi localizado!'));
		}
	}

	@isTest
	static void consultaMedicoTestNaoEncontrado() {
		MedicoService medicoService = new MedicoService();

		Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosNaoEncontrado());

		// Nenhum Medico Test -> throws exception
		try {
			medicoService.consultaMedico(123456, 'SP');
		} catch (Exception ex) {
            System.debug(ex.getMessage() + ', ' + ex.getStackTraceString());
			System.assertEquals(true, ex.getMessage().contains('Médico não encontrado.'));
		}
	}
}