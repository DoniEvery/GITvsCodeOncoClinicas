@IsTest
public with sharing class NewContactSelectorControllerTest {
	@IsTest
	public static void getMedicoTest() {
		Contact contato = new Contact(
			FirstName = 'Medico',
			LastName = 'Mock',
			Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483',
			CRM__c = '194528',
			UF_do_CRM__c = 'SP',
			Tipo_Inscricao_CRM__c = 'Principal',
			Situacao_do_Medico__c = 'Regular',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId()
		); 
		insert contato;

		Contact resultMedico = NewContactSelectorController.getMedico(Integer.valueOf(contato.CRM__c), contato.UF_do_CRM__c);
		System.debug('result Medico => ' + resultMedico);
		System.assertEquals(true, contato.Id == resultMedico.Id);
	}

	@IsTest
	public static void getNewMedicoCfmTest() {
		Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosPort());
		Contact contato = NewContactSelectorController.getNewMedicoCfm(12345, 'SP');

		System.assertEquals(true, contato.CRM__c == '12345');
	}

	@IsTest
	public static void getNewMedicoCfmTestErro() {
		Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosNaoEncontrado());

		// Nenhum Medico Test -> throws exception
		try {
			Contact contato = NewContactSelectorController.getNewMedicoCfm(12345, 'SP');
		} catch (Exception ex) {
			System.debug(ex.getMessage() + ', ' + ex.getStackTraceString());
			System.assertEquals(true, ex.getMessage().contains('Médico não encontrado.'));
		}
	}

    @IsTest
	public static void saveMedicoTest() { 
        Test.setMock(WebServiceMock.class, new MedicoServiceMock.MockServicoConsultaMedicosPort()); 
        Id contactId = NewContactSelectorController.saveMedico(NewContactSelectorController.getNewMedicoCfm(12345, 'SP'));

		System.assertEquals(true, contactId != null); 

        //cover try catch block -> explicit exception
        try {
            NewContactSelectorController.saveMedico(null); 
        } catch (Exception ex) {
            System.assertEquals(true, !String.isBlank(ex.getMessage()));
        }
	}
}