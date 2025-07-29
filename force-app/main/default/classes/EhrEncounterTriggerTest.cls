@IsTest
public with sharing class EhrEncounterTriggerTest {

	private static Id ACCOUNT_UNIDADE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
	private static Id CONTACT_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();


	@IsTest
	static void testNovoEncontroConta() {
		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);
		Datetime myDateTime_2 = Datetime.newInstance(2022, 6, 15);

		Test.startTest();

		Account conta2 = new Account();
		conta2.LastName = 'testeValor2';
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

		//System.assertEquals(10, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);
		Test.stopTest();
	}

	@IsTest
	static void testAlteraEncontroConta() {
		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);

		Test.startTest();

		Account conta2 = new Account();
		conta2.LastName = 'testeValor2';
		insert conta2;

		Account conta3 = new Account();
		conta3.LastName = 'testeValor3';
		insert conta3;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.HealthCloudGA__Account__c = conta2.Id;
		encounters.Receita_Bruta__c = 5;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		insert encounters;

		//System.assertEquals(encounters.Receita_Bruta__c, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);

		encounters.HealthCloudGA__Account__c = conta3.Id;
		encounters.Receita_Bruta__c = 15;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		update encounters;

		//System.assertEquals(0, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta2.Id].Valor_Total__c);
		//System.assertEquals(15, [SELECT Valor_Total__c FROM ACCOUNT WHERE ID = :conta3.Id].Valor_Total__c);

		Test.stopTest();
	}

	@IsTest
	static void testNovoEncontroMedicoReferenciador() {
		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);

		Test.startTest();

		Account conta2 = new Account();
		conta2.Name = 'testeUnidade';
		conta2.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
		insert conta2;

		Account conta3 = new Account();
		conta3.Name = 'testeUnidade2';
		conta3.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
		insert conta3;

		Contact medico = new Contact();
		medico.FirstName = 'teste';
		medico.LastName = 'Trigger';
		medico.Especialidade_que_Atua__c = 'ONCOLOGIA CLÍNICA';
		medico.Situacao_do_CRM__c = 'Ativo';
		medico.RecordTypeId = CONTACT_MEDICO_RTYPE;
		insert medico;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.HealthCloudGA__Account__c = conta2.Id;
		encounters.Receita_Bruta__c = 5;
		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters.Resumo_Procedimento_II__c = 'primeiro_atendimento';
		encounters.Identificador_Unidade_Account__c = conta2.Id;
		insert encounters;

		HealthCloudGA__EhrEncounter__c encounters2 = new HealthCloudGA__EhrEncounter__c();
		encounters2.HealthCloudGA__Account__c = conta2.Id;
		encounters2.Receita_Bruta__c = 5;
		encounters2.HealthCloudGA__PeriodStart__c = myDateTime;
		encounters2.Identificador_Corpo_Clinico_Contact__c = medico.Id;
		encounters2.Resumo_Procedimento_II__c = 'primeiro_atendimento';
		encounters2.Identificador_Unidade_Account__c = conta3.Id;
		insert encounters2;

		HealthCloudGA__EhrEncounter__c encounters3 = new HealthCloudGA__EhrEncounter__c();
		encounters3.HealthCloudGA__Account__c = conta2.Id;
		encounters3.Receita_Bruta__c = 5;
		encounters3.HealthCloudGA__PeriodStart__c = myDateTime;
		encounters3.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters3.Identificador_Corpo_Clinico_Contact__c = medico.Id;
		encounters3.Resumo_Procedimento_II__c = 'primeiro_atendimento';
		encounters3.Identificador_Unidade_Account__c = conta3.Id;
		insert encounters3;

		List<Contact> result = [SELECT Unidade_Principal__c FROM Contact WHERE ID = :medico.Id];

		//System.assertEquals(true, result.size() > 0);

		Test.stopTest();
	}

// 	@IsTest
// 	static void testNovoEncontroMedicoCorpoClinico() {
// 		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);

// 		Test.startTest();

// 		Account conta2 = new Account();
// 		conta2.LastName = 'testeValor2';
// 		insert conta2;

// 		Contact medico = new Contact();
// 		medico.FirstName = 'Durotan';
// 		medico.LastName = 'Frostwolf';
// 		medico.Medico_Corpo_Clinico__c = true;

// 		insert medico;

// 		Contact medico2 = new Contact();
// 		medico2.FirstName = 'Varyan';
// 		medico2.LastName = 'Wrynn';
// 		medico.Medico_Corpo_Clinico__c = true;
// 		insert medico2;

// 		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
// 		encounters.HealthCloudGA__Account__c = conta2.Id;
// 		encounters.Receita_Bruta__c = 5;
// 		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters.Resumo_Procedimento_II__c = 'primeiro_atendimento';
// 		insert encounters;

// 		HealthCloudGA__EhrEncounter__c encounters2 = new HealthCloudGA__EhrEncounter__c();
// 		encounters2.HealthCloudGA__Account__c = conta2.Id;
// 		encounters2.Receita_Bruta__c = 5;
// 		encounters2.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters2.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters2.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters2.Resumo_Procedimento_II__c = 'primeira_QT';
// 		insert encounters2;

// 		HealthCloudGA__EhrEncounter__c encounters3 = new HealthCloudGA__EhrEncounter__c();
// 		encounters3.HealthCloudGA__Account__c = conta2.Id;
// 		encounters3.Receita_Bruta__c = 5;
// 		encounters3.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters3.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters3.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters3.Resumo_Procedimento_II__c = 'primeira_RT';
// 		insert encounters3;

// 		HealthCloudGA__EhrEncounter__c encounters4 = new HealthCloudGA__EhrEncounter__c();
// 		encounters4.HealthCloudGA__Account__c = conta2.Id;
// 		encounters4.Receita_Bruta__c = 5;
// 		encounters4.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters4.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters4.Identificador_Corpo_Clinico_Contact__c = medico2.Id;
// 		encounters4.Resumo_Procedimento_II__c = null;
// 		insert encounters4;

// 		System.assertEquals(15, [SELECT Valor_Total_Cli__c FROM Contact WHERE ID = :medico.Id].Valor_Total_Cli__c);

// 		Test.stopTest();
// 	}

// 	@IsTest
// 	static void testUpdateEncontroMudouMedico() {
// 		Datetime myDateTime = Datetime.newInstance(2021, 6, 17);

// 		Test.startTest();

// 		Account conta2 = new Account();
// 		conta2.LastName = 'testeValor2';
// 		insert conta2;

//         Account unidade = new Account();
// 		unidade.LastName = 'unidade';
// 		insert unidade;

// 		Contact medico = new Contact();
// 		medico.FirstName = 'Durotan';
// 		medico.LastName = 'Frostwolf';
// 		medico.Medico_Corpo_Clinico__c = true;

// 		insert medico;

// 		Contact medico2 = new Contact();
// 		medico2.FirstName = 'Varyan';
// 		medico2.LastName = 'Wrynn';
// 		medico2.Medico_Corpo_Clinico__c = true;
// 		insert medico2;

// 		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
//         encounters.Identificador_Unidade_Account__c = conta2.Id;
// 		encounters.HealthCloudGA__Account__c = conta2.Id;
// 		encounters.Receita_Bruta__c = 5;
// 		encounters.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters.Resumo_Procedimento_II__c = 'primeiro_atendimento';
// 		insert encounters;

// 		HealthCloudGA__EhrEncounter__c encounters2 = new HealthCloudGA__EhrEncounter__c();
//         encounters2.Identificador_Unidade_Account__c = unidade.Id;
// 		encounters2.HealthCloudGA__Account__c = conta2.Id;
// 		encounters2.Receita_Bruta__c = 5;
// 		encounters2.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters2.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters2.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters2.Resumo_Procedimento_II__c = 'primeira_QT';
// 		insert encounters2;

// 		HealthCloudGA__EhrEncounter__c encounters3 = new HealthCloudGA__EhrEncounter__c();
//         encounters3.Identificador_Unidade_Account__c = unidade.Id;
// 		encounters3.HealthCloudGA__Account__c = conta2.Id;
// 		encounters3.Receita_Bruta__c = 5;
// 		encounters3.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters3.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters3.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters3.Resumo_Procedimento_II__c = 'primeira_RT';
// 		insert encounters3;

// 		HealthCloudGA__EhrEncounter__c encounters4 = new HealthCloudGA__EhrEncounter__c();
//         encounters4.Identificador_Unidade_Account__c = unidade.Id;
// 		encounters4.HealthCloudGA__Account__c = conta2.Id;
// 		encounters4.Receita_Bruta__c = 5;
// 		encounters4.HealthCloudGA__PeriodStart__c = myDateTime;
// 		encounters4.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters4.Identificador_Corpo_Clinico_Contact__c = medico2.Id;
// 		encounters4.Resumo_Procedimento_II__c = null;
// 		insert encounters4;

//         System.assertEquals(15, [SELECT Valor_Total_Cli__c FROM Contact WHERE ID = :medico.Id].Valor_Total_Cli__c);
        
// 		encounters4.Identificador_Medico_Ref_Contact__c = medico2.Id;
// 		encounters4.Identificador_Corpo_Clinico_Contact__c = medico2.Id;
// 		encounters4.Resumo_Procedimento_II__c = 'primeiro_atendimento';
// 		update encounters4;

//         System.debug('medico 2 => ' + [SELECT ID, Receita_Bruta__c from HealthCloudGA__EhrEncounter__c where Identificador_Corpo_Clinico_Contact__c =:medico2.id]);
        
//         System.assertEquals(5, [SELECT Valor_Total_Cli__c FROM Contact WHERE ID = :medico2.Id].Valor_Total_Cli__c);
//         System.assertEquals(15, [SELECT Valor_Total_Cli__c FROM Contact WHERE ID = :medico.Id].Valor_Total_Cli__c);

//         encounters4.Identificador_Medico_Ref_Contact__c = medico.Id;
// 		encounters4.Identificador_Corpo_Clinico_Contact__c = medico.Id;
// 		encounters4.Resumo_Procedimento_II__c = 'primeiro_atendimento';
// 		update encounters4;

// 		System.assertEquals(20, [SELECT Valor_Total_Cli__c FROM Contact WHERE ID = :medico.Id].Valor_Total_Cli__c);

// 		Test.stopTest();
// 	}
}