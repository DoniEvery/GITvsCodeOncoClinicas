@isTest
public class LwcCustomLookupControllerTest {
    @testSetup
    static void makeData(){
        Account paciente = DataFactory.gerarPaciente();
        insert paciente;
    }
	@isTest
    static void searchDefaultRecord(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        LwcCustomLookupController.searchDefaultRecord(acc.Id, 'Account');
    }
    @isTest
    static void searchLookupData(){
        LwcCustomLookupController.searchLookupData('Jose', 'Account', null, new List<String>{'CPF_Origem__c'}, new List<String>(), null, false, null, null);
    }
}