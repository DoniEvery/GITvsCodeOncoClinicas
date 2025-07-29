public with sharing class EhrEncounterAccountHandler extends TriggerHelper {
	public void atualizaTotalizadoresConta(List<HealthCloudGA__EhrEncounter__c> encontros) {

		Set<Id> accountsToUpdateSet = new Set<Id>();

		for (HealthCloudGA__EhrEncounter__c encontro : encontros) {
			if (encontro.HealthCloudGA__Account__c != null && encontro.HealthCloudGA__Account__c != null)
				accountsToUpdateSet.add(encontro.HealthCloudGA__Account__c);
		}

		if (accountsToUpdateSet.size() > 0) {
			//get contas
			Map<Id, Account> contasToUpdate = new Map<Id, Account>();

			//get encontros das contas
			Map<Id, List<HealthCloudGA__EhrEncounter__c>> encontrosByConta = getEncontrosByContas(accountsToUpdateSet);

			for (Id contaId : accountsToUpdateSet) {
				Account conta = new Account(Id = contaId);

				totalizaDadosContaEncontro(conta, encontrosByConta);
				setUltimoEncontro(conta, encontrosByConta);

				contasToUpdate.put(conta.Id, conta);
			}
			Database.update(contasToUpdate.values(), false);
			//update contasToUpdate.values();
		}
	}

	private Map<Id, List<HealthCloudGA__EhrEncounter__c>> getEncontrosByContas(Set<Id> contasIds) {
		Map<Id, List<HealthCloudGA__EhrEncounter__c>> result = new Map<Id, List<HealthCloudGA__EhrEncounter__c>>();

		List<HealthCloudGA__EhrEncounter__c> encontros = [
			SELECT Id, HealthCloudGA__Account__c, Receita_Bruta__c, HealthCloudGA__PeriodStart__c
			FROM HealthCloudGA__EhrEncounter__c
			WHERE HealthCloudGA__Account__c IN :contasIds AND HealthCloudGA__PeriodStart__c >= LAST_N_MONTHS:36
			WITH SECURITY_ENFORCED
			ORDER BY CREATEDDATE DESC
			LIMIT 49999
		];

		for (HealthCloudGA__EhrEncounter__c encontro : encontros) {
			if (!result.containsKey(encontro.HealthCloudGA__Account__c)) {
				result.put(encontro.HealthCloudGA__Account__c, new List<HealthCloudGA__EhrEncounter__c>{ encontro });
			} else {
				List<HealthCloudGA__EhrEncounter__c> encontrosDaConta = result.get(encontro.HealthCloudGA__Account__c);
				encontrosDaConta.add(encontro);

				result.put(encontro.HealthCloudGA__Account__c, encontrosDaConta);
			}
		}

		return result;
	}

	private void totalizaDadosContaEncontro(Account conta, Map<Id, List<HealthCloudGA__EhrEncounter__c>> encontrosByConta) {
		conta.Valor_Total__c = 0;

		if (encontrosByConta.containsKey(conta.Id)) {
			for (HealthCloudGA__EhrEncounter__c encontroDaConta : encontrosByConta.get(conta.Id)) {
				//totaliza valor bruto
				conta.Valor_Total__c += encontroDaConta.Receita_Bruta__c != null ? encontroDaConta.Receita_Bruta__c : 0;
			}
		}
	}

	private void setUltimoEncontro(Account conta, Map<Id, List<HealthCloudGA__EhrEncounter__c>> encontrosByConta) {
		conta.Ultimo_Encontro__c = null;

		if (encontrosByConta.containsKey(conta.Id)) {
			HealthCloudGA__EhrEncounter__c ultimoEncontro = null;

			for (HealthCloudGA__EhrEncounter__c encontroDaConta : encontrosByConta.get(conta.Id)) {
				if (ultimoEncontro == null && encontrodaConta.HealthCloudGA__PeriodStart__c != null) {
					ultimoEncontro = encontrodaConta;
				} else if (ultimoEncontro != null && encontrodaConta.HealthCloudGA__PeriodStart__c > ultimoEncontro.HealthCloudGA__PeriodStart__c) {
					ultimoEncontro = encontrodaConta;
				}
			}

			if (ultimoEncontro != null) {
				conta.Ultimo_Encontro__c = ultimoEncontro.Id;
			}
		}
	}
}