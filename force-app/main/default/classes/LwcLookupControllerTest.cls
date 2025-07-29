@isTest
public class LwcLookupControllerTest {

    @isTest
    static void findRecords() {
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
        Account acc = DataFactory.gerarConvenio();
        acc.Ativo__c = 'Sim';
        insert acc;
		string recordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Convenio_OC_Care').getRecordTypeId();
        Account acc2 = new Account();
        List<Contact> cttos = new List<Contact>();
        List<Account> accs = new List<Account>();
        Contact ctto2 = new Contact();
        Test.startTest();
        cttos = LwcLookupController.findRecords('Mock', 'Contact');
        cttos = LwcLookupController.findRecordsFlowChild('Mock', 'SP');
        ctto2 = LwcLookupController.findRecordsFlowChildCache(ctto.id);
        acc2 = LwcLookupController.findRecordsFlowCache(acc.id);
        accs = LwcLookupController.findRecordsFlow(string.valueOf(acc.Name), recordType);
        
        Test.stopTest();

        System.assert(!cttos.isEmpty());
    }

}