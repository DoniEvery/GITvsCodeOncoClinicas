public with sharing class ResFilterController {
	@AuraEnabled
	public static List<HealthCloudGA__EhrEncounter__c> getRes(String recordId) {
		return [
			SELECT
				HealthCloudGA__PeriodStart__c,
				Name,
				Resumo_Procedimento_II__c,
				Receita_Bruta__c,
				Sequencia_Atendimento__c,
				Identificador_Medico_Ref_Contact__r.FirstName,
				Identificador_Corpo_Clinico_Contact__r.FirstName,
				Identificador_Medico_Ref_Contact__r.LastName,
				Identificador_Corpo_Clinico_Contact__r.LastName,
				Descricao_CID__c,
				HealthCloudGA__HospitalAdmitSourceLabel__c,
				Identificador_Convenio_Account__r.Name,
				Identificador_Unidade_Account__r.Name
			FROM HealthCloudGA__EhrEncounter__c
			WHERE
				HealthCloudGA__Account__c = :recordId
				AND (Resumo_Procedimento_II__c = 'primeiro_atendimento'
				OR Resumo_Procedimento_II__c = 'primeira_QT'
				OR Resumo_Procedimento_II__c = 'primeira_RT')
			ORDER BY HealthCloudGA__PeriodStart__c DESC NULLS LAST
			LIMIT 50000
		];
	}
}