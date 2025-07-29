@IsTest
public class EhrEncounterSelfHandlerTest {

    private static Id ACCOUNT_UNIDADE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
    private static Id CONTACT_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

    @IsTest
    static void testNovoEncontro() {

		Contact medico = new Contact();
		medico.FirstName = 'teste';
		medico.LastName = 'testeTrigger2';
		medico.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medico.CRM__c = '194528';
		medico.UF_do_CRM__c = 'SP';
		medico.Tipo_Inscricao_CRM__c = 'Principal';
		medico.RecordTypeId = CONTACT_MEDICO_RTYPE;
		medico.Situacao_do_CRM__c = 'Ativo';
		insert medico;

		Account contaUnidade = new Account();
		contaUnidade.Name = 'testeUnidade';
        contaUnidade.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
		insert contaUnidade;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
        encounters.Identificador_Unidade_Account__c = contaUnidade.Id;
		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
		insert encounters;

	}

	@IsTest
	static void testEditarEncontro() {

		Contact medico = new Contact();
		medico.FirstName = 'teste';
		medico.LastName = 'testeTrigger2';
		medico.Especialidade_CRM__c = 'DERMATOLOGIA - RQE Nº: 91483';
		medico.CRM__c = '194528';
		medico.UF_do_CRM__c = 'SP';
		medico.Tipo_Inscricao_CRM__c = 'Principal';
		medico.RecordTypeId = CONTACT_MEDICO_RTYPE;
		medico.Situacao_do_CRM__c = 'Ativo';
		insert medico;

		Account contaUnidade = new Account();
		contaUnidade.Name = 'testeUnidade';
        contaUnidade.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
		insert contaUnidade;

		HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
        encounters.Identificador_Unidade_Account__c = contaUnidade.Id;
		encounters.Identificador_Medico_Ref_Contact__c = medico.Id;
		insert encounters;

		/* -------------------------------------------------------------------------- */
		/*                  EDITAR CONTATO E MUDAR O REF DO ENCONTRO                  */
		/* -------------------------------------------------------------------------- */

		Contact medico2 = new Contact();
		medico2.FirstName = 'teste';
		medico2.LastName = 'testeTrigger2';
		medico2.Especialidade_CRM__c = 'teste';
		medico2.CRM__c = '12345';
		medico2.UF_do_CRM__c = 'SP';
		medico2.Tipo_Inscricao_CRM__c = 'Principal';
		medico2.RecordTypeId = CONTACT_MEDICO_RTYPE;
		medico2.Situacao_do_CRM__c = 'Ativo';
		insert medico2;

		encounters.Identificador_Medico_Ref_Contact__c = medico2.Id;
		update encounters;
	}
    
    // @IsTest
	// static void testAlteraEncontroConta() {

    //     Account contaUnidade = new Account();
	// 	contaUnidade.Name = 'testeUnidade';
    //     contaUnidade.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
	// 	insert contaUnidade;
        
    //     Account contaUnidade2 = new Account();
	// 	contaUnidade2.Name = 'testeUnidade2';
    //     contaUnidade2.RecordTypeId = ACCOUNT_UNIDADE_RTYPE;
	// 	insert contaUnidade2;
        
	// 	HealthCloudGA__EhrEncounter__c encounters = new HealthCloudGA__EhrEncounter__c();
	// 	encounters.HealthCloudGA__PeriodStart__c = myDateTime;
    //     encounters.Identificador_Unidade_Account__c = contaUnidade.Id;
	// 	insert encounters;

	// 	List<HealthCloudGA__EhrEncounter__c> result = [SELECT Identificador_Unidade_Texto__c FROM HealthCloudGA__EhrEncounter__c WHERE ID = :encounters.Id];        
	// 	System.assertEquals(true, result.size() > 0);

	// 	encounters.HealthCloudGA__PeriodStart__c = myDateTime;
    //     encounters.Identificador_Unidade_Account__c = contaUnidade2.Id;
	// 	update encounters;

	// 	List<HealthCloudGA__EhrEncounter__c> result2 = [SELECT Identificador_Unidade_Texto__c FROM HealthCloudGA__EhrEncounter__c WHERE ID = :encounters.Id];        
	// 	System.assertEquals(true, result2.size() > 0);
		
    //     encounters.HealthCloudGA__PeriodStart__c = myDateTime;
    //     encounters.Identificador_Unidade_Account__c = null;
	// 	update encounters;
        
    //     List<HealthCloudGA__EhrEncounter__c> result3 = [SELECT Identificador_Unidade_Texto__c FROM HealthCloudGA__EhrEncounter__c WHERE ID = :encounters.Id];        
	// 	System.assertEquals(true, result3.size() > 0);

	// }
    
}