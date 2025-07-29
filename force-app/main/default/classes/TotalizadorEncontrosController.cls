public with sharing class TotalizadorEncontrosController {
	@AuraEnabled
	public static DadosTotalizados getDadosEncontrosByPeriodo(String medicoId, Date dataInicial, Date dataFinal, List<String> blockedProfiles) {
        
		try {
			if (!String.isBlank(medicoId) && dataInicial != null && dataFinal != null) {
				List<HealthCloudGA__EhrEncounter__c> encontrosDoMedico = ([
					SELECT
						Id,
						HealthCloudGA__PeriodStart__c,
						Identificador_Unidade_Account__c,
						Identificador_Unidade_Account__r.Id,
						Identificador_Unidade_Account__r.Name,
						Resumo_Procedimento_II__c,
						Receita_Bruta__c,
						Identificador_Medico_Ref_Contact__c,
						Identificador_Corpo_Clinico_Contact__c,
						Identificador_Corpo_Clinico_Contact__r.Medico_Corpo_Clinico__c
					FROM HealthCloudGA__EhrEncounter__c
					WHERE
						HealthCloudGA__PeriodStart__c != NULL
						AND HealthCloudGA__PeriodStart__c >= :dataInicial
						AND HealthCloudGA__PeriodStart__c <= :dataFinal.addDays(1)
						AND (Identificador_Medico_Ref_Contact__c = :medicoId
						OR (Identificador_Corpo_Clinico_Contact__c = :medicoId
						AND Identificador_Corpo_Clinico_Contact__r.Medico_Corpo_Clinico__c = TRUE))
					WITH SECURITY_ENFORCED
					ORDER BY HealthCloudGA__PeriodStart__c DESC
					LIMIT 50000
				]);

				return new DadosTotalizados(medicoId, encontrosDoMedico, blockedProfiles);
			} else {
				throw new AuraHandledException('Parâmetros inválidos.');
			}
		} catch (Exception e) {
			System.debug(e.getMessage() + ', ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class DadosTotalizados {
		@AuraEnabled
		public Boolean viewAllData = true;

		@AuraEnabled
		public Account unidadePrincipal = null;

		@AuraEnabled
		public Decimal valorTotalCC = 0;
		@AuraEnabled
		public Decimal valorPrimeirasConsultasCC = 0;
		@AuraEnabled
		public Integer qtdPrimeirasConsultasCC = 0;
		@AuraEnabled
		public Decimal valorPrimeirasQuimioterapiasCC = 0;
		@AuraEnabled
		public Integer qtdPrimeirasQuimioterapiasCC = 0;
		@AuraEnabled
		public Decimal valorPrimeirasRadioterapiasCC = 0;
		@AuraEnabled
		public Integer qtdPrimeirasRadioterapiasCC = 0;
		@AuraEnabled
		public Decimal valorDemaisProcedimentosCC = 0;
		@AuraEnabled
		public Integer qtdDemaisProcedimentosCC = 0;

		@AuraEnabled
		public Decimal valorTotalRef = 0;
		@AuraEnabled
		public Decimal valorPrimeirasConsultasRef = 0;
		@AuraEnabled
		public Integer qtdPrimeirasConsultasRef = 0;
		@AuraEnabled
		public Decimal valorPrimeirasQuimioterapiasRef = 0;
		@AuraEnabled
		public Integer qtdPrimeirasQuimioterapiasRef = 0;
		@AuraEnabled
		public Decimal valorPrimeirasRadioterapiasRef = 0;
		@AuraEnabled
		public Integer qtdPrimeirasRadioterapiasRef = 0;
		@AuraEnabled
		public Decimal valorDemaisProcedimentosRef = 0;
		@AuraEnabled
		public Integer qtdDemaisProcedimentosRef = 0;

		public DadosTotalizados(String medicoId, List<HealthCloudGA__EhrEncounter__c> result, List<String> blockedProfiles) {
			if (result != null && result.size() > 0) {
				this.viewAllData = getUserHasViewAllAccess(blockedProfiles);

				totalizaCamposSegundoProcedimento(medicoId, result, this.viewAllData);
				setUnidadeMaisRecorrente(medicoId, result);
			}
		}

		private void totalizaCamposSegundoProcedimento(String medicoId, List<HealthCloudGA__EhrEncounter__c> encontros, Boolean viewAllData) {
			for (HealthCloudGA__EhrEncounter__c encontro : encontros) {
				//Totaliza Campos Segundo Procedimento
				if (medicoId == encontro.Identificador_Corpo_Clinico_Contact__c && encontro.Identificador_Corpo_Clinico_Contact__r.Medico_Corpo_Clinico__c == true) {
					this.valorTotalCC += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;

					if (encontro.Resumo_Procedimento_II__c == 'primeiro_atendimento') {
						this.qtdPrimeirasConsultasCC += 1;
						this.valorPrimeirasConsultasCC += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else if (encontro.Resumo_Procedimento_II__c == 'primeira_QT') {
						this.qtdPrimeirasQuimioterapiasCC += 1;
						this.valorPrimeirasQuimioterapiasCC += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else if (encontro.Resumo_Procedimento_II__c == 'primeira_RT') {
						this.qtdPrimeirasRadioterapiasCC += 1;
						this.valorPrimeirasRadioterapiasCC += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else {
						this.qtdDemaisProcedimentosCC += 1;
						this.valorDemaisProcedimentosCC += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					}
				} else if (medicoId == encontro.Identificador_Medico_Ref_Contact__c) {
					this.valorTotalRef += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;

					if (encontro.Resumo_Procedimento_II__c == 'primeiro_atendimento') {
						this.qtdPrimeirasConsultasRef += 1;
						this.valorPrimeirasConsultasRef += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else if (encontro.Resumo_Procedimento_II__c == 'primeira_QT') {
						this.qtdPrimeirasQuimioterapiasRef += 1;
						this.valorPrimeirasQuimioterapiasRef += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else if (encontro.Resumo_Procedimento_II__c == 'primeira_RT') {
						this.qtdPrimeirasRadioterapiasRef += 1;
						this.valorPrimeirasRadioterapiasRef += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					} else {
						this.qtdDemaisProcedimentosRef += 1;
						this.valorDemaisProcedimentosRef += viewAllData && encontro.Receita_Bruta__c != null ? encontro.Receita_Bruta__c : 0;
					}
				}
			}
		}

		private void setUnidadeMaisRecorrente(String medicoId, List<HealthCloudGA__EhrEncounter__c> encontros) {
			Id unidadeSelecionada = null;
			Map<Id, Integer> unidadeQuantidade = new Map<Id, Integer>();
			Map<Id, Account> unidadeAccount = new Map<Id, Account>();

			for (HealthCloudGA__EhrEncounter__c encontro : encontros) {
				if (
					encontro.Identificador_Unidade_Account__c != null && medicoId == encontro.Identificador_Corpo_Clinico_Contact__c ||
					medicoId == encontro.Identificador_Medico_Ref_Contact__c
				) {
					if (!unidadeQuantidade.containsKey(encontro.Identificador_Unidade_Account__c)) {
						unidadeSelecionada = encontro.Identificador_Unidade_Account__c;

						unidadeQuantidade.put(encontro.Identificador_Unidade_Account__c, 0);
						unidadeAccount.put(encontro.Identificador_Unidade_Account__c, encontro.Identificador_Unidade_Account__r);
					} else {
						unidadeQuantidade.put(encontro.Identificador_Unidade_Account__c, unidadeQuantidade.get(encontro.Identificador_Unidade_Account__c) + 1);
					}
				}
			}

			if (unidadeQuantidade.values().size() > 0) {
				for (Id unidadeId : unidadeQuantidade.keySet()) {
					if (unidadeQuantidade.get(unidadeId) > unidadeQuantidade.get(unidadeSelecionada)) {
						unidadeSelecionada = unidadeId;
					}
				}

				this.unidadePrincipal = unidadeAccount.get(unidadeSelecionada);
			}
		}

		private Boolean getUserHasViewAllAccess(List<String> blockedProfiles) {
			Boolean result = true;

			System.debug('blockedProfiles => ' + JSON.serializePretty(blockedProfiles));
            
			if (blockedProfiles.size() > 0) {
                User usuario = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
				result = !blockedProfiles.contains(usuario.Profile.Name);
			}
            
            System.debug('result => ' + result);
			return result;
		}
	}
}