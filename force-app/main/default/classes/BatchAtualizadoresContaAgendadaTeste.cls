@IsTest
public with sharing class BatchAtualizadoresContaAgendadaTeste {
	
    public static String CRON_EXP = '0 0 20 * * ? *';
	private static Id CONTA_PACIENTE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
	private static Id CONTA_CONVENIO_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Convenio_OC_Care').getRecordTypeId();
	private static Id CONTA_LOCAL_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Local_OC_Care').getRecordTypeId();
	@IsTest
	static void testNovoEncontroConta() {
		
		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);
		Datetime myDateTime_2 = Datetime.newInstance(2022, 6, 15);
		Date nascimento = Date.newInstance(2001, 10, 15);

		Test.startTest();

		Account origem = new Account();
		origem.Name = 'LocalTest';
		origem.Praca__c = 'SÃO PAULO';
		origem.Situacao_da_Local__c = 'Dentro da rede';
		origem.RecordTypeId = CONTA_LOCAL_RTYPE;
		insert origem;

		Account convenio = new Account();
		convenio.Name = 'ConvenioTest';
		convenio.RecordTypeId = CONTA_CONVENIO_RTYPE;
		insert convenio;

		Account conta2 = new Account();
		conta2.FirstName = 'teste';
		conta2.LastName = 'testeValor2';
		conta2.CNPJ__c = '79455624427';
		conta2.PersonBirthdate = nascimento;
		conta2.HealthCloudGA__Gender__pc = 'Outro';
		conta2.PersonMobilePhone = '11765489765';
		//conta2.Situacao_do_Paciente__c = 'Acompanhamento OC Care';
		conta2.Origem__c = origem.Id;
		conta2.Convenio_do_paciente__c = convenio.Id;
		conta2.RecordTypeId = CONTA_PACIENTE_RTYPE;
		insert conta2;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.HealthCloudGA__Account__c = conta2.Id;
		encounters.Receita_Bruta__c = 5;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		insert encounters;

		HealthCloudGA__EhrEncounter__c encounters2 = new HealthCloudGA__EhrEncounter__c();
		encounters2.HealthCloudGA__Account__c = conta2.Id;
		encounters2.Receita_Bruta__c = 5;
		encounters2.HealthCloudGA__PeriodStart__c = myDateTime_2;
		insert encounters2;

		// System.assertEquals(10, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);
		Test.stopTest();
	}

	@IsTest
	static void testAlteraEncontroConta() {

		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);
		Datetime myDateTime_2 = Datetime.newInstance(2022, 6, 15);
		Date nascimento = Date.newInstance(2001, 10, 15);

		Test.startTest();

		Account origem = new Account();
		origem.Name = 'LocalTest';
		origem.Praca__c = 'SÃO PAULO';
		origem.Situacao_da_Local__c = 'Dentro da rede';
		origem.RecordTypeId = CONTA_LOCAL_RTYPE;
		insert origem;

		Account convenio = new Account();
		convenio.Name = 'ConvenioTest';
		convenio.RecordTypeId = CONTA_CONVENIO_RTYPE;
		insert convenio;

		Account conta2 = new Account();
		conta2.FirstName = 'teste';
		conta2.LastName = 'testeValor2';
		conta2.CNPJ__c = '79455624427';
		conta2.PersonBirthdate = nascimento;
		conta2.HealthCloudGA__Gender__pc = 'Outro';
		conta2.PersonMobilePhone = '11765489765';
		//conta2.Situacao_do_Paciente__c = 'Acompanhamento OC Care';
		conta2.Origem__c = origem.Id;
		conta2.Convenio_do_paciente__c = convenio.Id;
		conta2.RecordTypeId = CONTA_PACIENTE_RTYPE;
		insert conta2;

		// Account conta3 = new Account();
		// conta3.FirstName = 'teste';
		// conta3.LastName = 'testeValor3';
		// conta3.CNPJ__c = '79455624427';
		// conta3.PersonBirthdate = nascimento;
		// conta3.HealthCloudGA__Gender__pc = 'Outro';
		// conta3.PersonMobilePhone = '11765489765';
		// conta3.Situacao_do_Paciente__c = 'Acompanhamento OC Care';
		// conta3.Origem__c = origem.Id;
		// conta3.Convenio_do_paciente__c = convenio.Id;
		// conta3.RecordTypeId = CONTA_PACIENTE_RTYPE;
		// insert conta3;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.HealthCloudGA__Account__c = conta2.Id;
		encounters.Receita_Bruta__c = 5;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		insert encounters;

		// System.assertEquals(encounters.Receita_Bruta__c, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);

		// encounters.HealthCloudGA__Account__c = conta3.Id;
		// encounters.Receita_Bruta__c = 15;
		// encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		// update encounters;

		// System.assertEquals(0, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);
		// System.assertEquals(15, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta3.Id].Valor_Total__c);

        String jobId = System.schedule('SchedulePacienteApexClassTest', CRON_EXP, new BatchAtualizadoresContaAgendada());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
	}
}