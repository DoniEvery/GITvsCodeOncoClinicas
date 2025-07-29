@IsTest
public with sharing class BatchUnidadeMaisRecorrenteAgendadaTest {

    private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
    private static Id CONTA_UNIDADE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
    public static String CRON_EXP = '0 0 20 * * ? *';
//IndustriesBusiness

    @IsTest
    public static void BatchAgendadaTest() {

        Datetime myDateTime = Datetime.newInstance(2022, 1, 14);

        Test.startTest();
        
        Account conta = new Account();
		conta.Name = 'testeBatch';
        conta.RecordTypeId = CONTA_UNIDADE_RTYPE;

		insert conta;

        Contact medico = new Contact();
        medico.FirstName = 'Medico';
        medico.LastName = 'Batch';
        medico.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
        medico.CRM__c = '194528';
        medico.UF_do_CRM__c = 'SP';
        medico.Tipo_Inscricao_CRM__c = 'Principal';
        medico.Situacao_do_Medico__c = 'Regular';
        medico.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

        insert medico;

        HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.Receita_Bruta__c = 5;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
        encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
        encounters.Identificador_Unidade_Account__c = conta.Id;

        insert encounters;

        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new BatchUnidadeMaisRecorrenteAgendada());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // System.assertEquals(CRON_EXP, ct.CronExpression);
        // System.assertEquals(0, ct.TimesTriggered);
        // System.assertEquals('2021-07-15 20:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

    }
     @IsTest 
      public static void sendEmailTest(){
       List<String> errors = new List<String>{'Erros'};
       Test.startTest();
       EhrEncounterContactHandler.sendEmail(errors);
       Test.stopTest();
    } 
}