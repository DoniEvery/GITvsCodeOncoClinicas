@isTest
private class APP_ParametroTriggerTest {
    
    @testSetup
    static void setupData() {
        if ([SELECT COUNT() FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Chat'] == 0) {
            System.debug('⚠️ Crie o RecordType "Chat" manualmente no objeto APP_Parametro__c.');
        }
        if ([SELECT COUNT() FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Agenda'] == 0) {
            System.debug('⚠️ Crie o RecordType "Agenda" manualmente no objeto APP_Parametro__c.');
        }
    }

    @isTest
    static void testInsereUnicoParametroChat() {
        RecordType chatRT = [SELECT Id FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Chat' LIMIT 1];

        APP_Parametro__c p1 = new APP_Parametro__c(ExpirationTime__c = 10, GroupSize__c = 10, RecordTypeId = chatRT.Id);
        insert p1;

        APP_Parametro__c p2 = new APP_Parametro__c(ExpirationTime__c = 20, GroupSize__c = 20, RecordTypeId = chatRT.Id);

        Test.startTest();
        try {
            insert p2;
            System.assert(false, 'Deveria lançar erro por duplicidade de tipo Chat.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Já existe um registro do tipo Chat'), 'Mensagem de erro esperada.');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsereUnicoParametroAgenda() {
        RecordType agendaRT = [SELECT Id FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Agenda' LIMIT 1];

        APP_Parametro__c p1 = new APP_Parametro__c(ExpirationTime__c = 15, GroupSize__c = 15, RecordTypeId = agendaRT.Id);
        insert p1;

        APP_Parametro__c p2 = new APP_Parametro__c(ExpirationTime__c = 25, GroupSize__c = 25, RecordTypeId = agendaRT.Id);

        Test.startTest();
        try {
            insert p2;
            System.assert(false, 'Deveria lançar erro por duplicidade de tipo Agenda.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Já existe um registro do tipo Agenda'), 'Mensagem de erro esperada.');
        }
        Test.stopTest();
    }
}