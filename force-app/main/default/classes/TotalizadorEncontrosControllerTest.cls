@IsTest
public class TotalizadorEncontrosControllerTest {
	@IsTest
	static void testGetEncontrosMedico() {
		Account conta2 = new Account();
		conta2.LastName = 'testeValor2';
		insert conta2;

		Contact medico = new Contact();
		medico.FirstName = 'Durotan';
		medico.LastName = 'Frostwolf';
        medico.Medico_Corpo_Clinico__c = true;
		insert medico;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
		encounters.HealthCloudGA__Account__c = conta2.Id;
		encounters.Receita_Bruta__c = 5;
        encounters.Identificador_Unidade_Account__c = conta2.Id;
		encounters.HealthCloudGA__PeriodStart__c = System.now();
		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters.Identificador_Corpo_Clinico_Contact__c = medico.Id;
		encounters.Resumo_Procedimento_II__c = 'primeiro_atendimento';
		insert encounters;

		HealthCloudGA__EhrEncounter__c encounters2 = new HealthCloudGA__EhrEncounter__c();
		encounters2.HealthCloudGA__Account__c = conta2.Id;
		encounters2.Receita_Bruta__c = 5;
		encounters2.HealthCloudGA__PeriodStart__c = System.now();
		encounters2.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters2.Identificador_Corpo_Clinico_Contact__c = medico.Id;
		encounters2.Resumo_Procedimento_II__c = 'primeira_QT';
		insert encounters2;

        HealthCloudGA__EhrEncounter__c encounters3 = new HealthCloudGA__EhrEncounter__c();
		encounters3.HealthCloudGA__Account__c = conta2.Id;
		encounters3.Receita_Bruta__c = 5;
		encounters3.HealthCloudGA__PeriodStart__c = System.now();
		encounters3.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters3.Identificador_Corpo_Clinico_Contact__c = medico.Id;
		encounters3.Resumo_Procedimento_II__c = 'primeira_RT';
		insert encounters3;

        HealthCloudGA__EhrEncounter__c encounters4 = new HealthCloudGA__EhrEncounter__c();
		encounters4.HealthCloudGA__Account__c = conta2.Id;
		encounters4.Receita_Bruta__c = 5;
		encounters4.HealthCloudGA__PeriodStart__c = System.now();
		encounters4.Identificador_Medico_Ref_Contact__c = medico.Id;
		encounters4.Identificador_Corpo_Clinico_Contact__c = medico.Id; 
		insert encounters4;

        

		HealthCloudGA__EhrEncounter__c refencounters = new HealthCloudGA__EhrEncounter__c();
		refencounters.HealthCloudGA__Account__c = conta2.Id;
		refencounters.Receita_Bruta__c = 5;
		refencounters.HealthCloudGA__PeriodStart__c = System.now();
		refencounters.Identificador_Medico_Ref_Contact__c = medico.Id; 
		refencounters.Resumo_Procedimento_II__c = 'primeiro_atendimento';
		insert refencounters;

		HealthCloudGA__EhrEncounter__c refencounters2 = new HealthCloudGA__EhrEncounter__c();
		refencounters2.HealthCloudGA__Account__c = conta2.Id;
		refencounters2.Receita_Bruta__c = 5;
		refencounters2.HealthCloudGA__PeriodStart__c = System.now();
		refencounters2.Identificador_Medico_Ref_Contact__c = medico.Id; 
		refencounters2.Resumo_Procedimento_II__c = 'primeira_QT';
		insert refencounters2;

        HealthCloudGA__EhrEncounter__c refencounters3 = new HealthCloudGA__EhrEncounter__c();
		refencounters3.HealthCloudGA__Account__c = conta2.Id;
		refencounters3.Receita_Bruta__c = 5;
		refencounters3.HealthCloudGA__PeriodStart__c = System.now();
		refencounters3.Identificador_Medico_Ref_Contact__c = medico.Id; 
		refencounters3.Resumo_Procedimento_II__c = 'primeira_RT';
		insert refencounters3;

        HealthCloudGA__EhrEncounter__c refencounters4 = new HealthCloudGA__EhrEncounter__c();
		refencounters4.HealthCloudGA__Account__c = conta2.Id;
		refencounters4.Receita_Bruta__c = 5;
		refencounters4.HealthCloudGA__PeriodStart__c = System.now();
		refencounters4.Identificador_Medico_Ref_Contact__c = medico.Id; 
		insert refencounters4;

		Test.startTest();

		TotalizadorEncontrosController.DadosTotalizados dados = TotalizadorEncontrosController.getDadosEncontrosByPeriodo(
			medico.Id,
			System.today(),
			System.today(),
			new List<String>{ 'Consultor RM' }
		);

		TotalizadorEncontrosController.DadosTotalizados dados2 = TotalizadorEncontrosController.getDadosEncontrosByPeriodo(
			medico.Id,
			System.today(),
			System.today(),
			new List<String>{ 'Consultor RM', 'Administrador do sistema' }
		);

		System.assertEquals(true, dados.valorTotalRef > 0);
		System.assertEquals(true, dados.valorTotalCC > 0);
		Test.stopTest();
	}
}