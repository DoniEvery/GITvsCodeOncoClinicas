@IsTest
public with sharing class resFilterControllerTest {

    @IsTest
    public static void getResTest() {

        Test.startTest();
        Account conta = new Account(LastName='Santos');
        insert conta;

        HealthCloudGA__EhrEncounter__c encontro = new HealthCloudGA__EhrEncounter__c(HealthCloudGA__Account__c = conta.Id);
        encontro.Resumo_Procedimento_II__c = 'primeira_RT';
        insert encontro;

        List<HealthCloudGA__EhrEncounter__c> result = ResFilterController.getRes(conta.Id);

        System.assertEquals(true, result.size() > 0);

    }

}