@isTest
public class ContactRepositoryTest {


    @isTest
    static void findByIds() {

        ContactRepository repository = new ContactRepository();
        Contact ctto = new Contact(
			FirstName = 'Medico',
			LastName = 'Mock',
			Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483',
			CRM__c = '194528',
			UF_do_CRM__c = 'SP',
			Tipo_Inscricao_CRM__c = 'Principal',
			Situacao_do_Medico__c = 'Regular',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId()
		); 
		insert ctto;

        List<String> contactId = new List<String>{ctto.Id};
        List<Contact> contacts = new List<Contact>();

        Test.startTest();
        contacts = repository.findByIds(contactId);
        Test.stopTest();

        System.assert(!contacts.isEmpty());


    }
}