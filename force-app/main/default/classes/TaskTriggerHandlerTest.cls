@IsTest
private class TaskTriggerHandlerTest {  
    
    @IsTest
    private static void testeTask(){
        
        ConfiguracoesOC__c configOC = new ConfiguracoesOC__c();
        configOC.PodeExcluirDataComemorativa__c = true;
        insert configOC;
        
        Task objTask = new Task();
        objTask.Subject = 'DiadoMedicoTeste001';
        objTask.ActivityDate = System.today();
        objTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DatasComemorativas').getRecordTypeId();
        insert objTask;

        Task t2 = new Task();
        t2.Subject = 'Tarefa';
        t2.ActivityDate = System.today();
        t2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FollowUp').getRecordTypeId();
        t2.NotificaMedico__c = false;
        insert t2;       
        
        configOC.PodeExcluirDataComemorativa__c = false;
        update configOC;        
        
        Test.startTest();
        
        try {
            t2.NotificaMedico__c = true;
            update t2;  
        	delete objTask;
        } 
        catch (Exception e) {
       		 Boolean expectedExceptionThrown =  e.getMessage().contains('Você não tem permissão para excluir a tarefa!') ? true : false;
             System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }

        Test.stopTest();        

    }
}