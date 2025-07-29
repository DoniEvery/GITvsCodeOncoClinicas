public with sharing class LeadTriggerHandler extends TriggerHelper {
	private static Id LEAD_MEDICO_RTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
	private static Id ACCOUNT_EMPRESARIAL_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AccountRT').getRecordTypeId();
	private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

	public void verificaCrmValido(List<Lead> leads) {
		System.enqueueJob(new LeadQueue(getLeadsMedicos(leads)));
	}

	private List<Lead> getLeadsMedicos(List<Lead> triggerLead) {
		List<Lead> result = new List<Lead>();

		for (Lead lead : triggerLead) {
			if(lead.RecordTypeId == LEAD_MEDICO_RTYPE) {
				if (Trigger.isExecuting && Trigger.isUpdate) {} else {
					if (lead.CRM__c != null && lead.UF_do_CRM__c != null && lead.Lead_Novo__c == true) {
						result.add(lead);
					}
				}
			}
			
		} 

		return result;
	}

	/* -------------------------------------------------------------------------- */
	/*                                  SUB CLASS                                 */
	/* -------------------------------------------------------------------------- */

	public class LeadQueue implements Queueable, Database.AllowsCallouts {
		private List<Lead> leads;
		private Integer index;

		public LeadQueue(List<Lead> leads) {
			this(leads, 0);
		}

		public LeadQueue(List<Lead> leads, Integer index) {
			this.leads = leads;
			this.index = index;
		}

		public void execute(QueueableContext qc) {
			try {
				Lead lead = this.leads[this.index];
				Map<String, Consulta_Medicos__mdt> consultasMedicoMdt = getConsultaMedicosMap();

				String chave = consultasMedicoMdt.get('Chave').Chave__c;
				String crmUf = lead.CRM__c + lead.UF_do_CRM__c;
				Long crmTamanho = null;
				Integer crm = null;
				Boolean crmValido = true;

				System.debug('CRM + UF: ' + crmUf);
				if(lead.CRM__c.contains('.')) {
					System.debug('tem.');
					crmValido = false;
				}

				if(lead.UF_do_CRM__c.toUpperCase() == 'RJ' && crmValido) {
					if(crmUf.length() >= 9) {
						if(crmUf.substring(0, 2) == '52') {
							lead.CRM_MKT_RJ__c = crmUf.substring(2);
							crmTamanho = lead.CRM__c != null ? Long.valueOf(lead.CRM__c) : null;
							if(crmTamanho > 2147483647) {
								crm = 2147483646;
							} else {
								crm = Integer.valueOf(lead.CRM__c.substring(2));
							}
							lead.CRM__c = lead.CRM__c.substring(2);	
							System.debug('com 52: ' + crmUf);	
						} else {
							lead.CRM_MKT_RJ__c = crmUf;
							crmTamanho = lead.CRM__c != null ? Long.valueOf(lead.CRM__c) : null;
							if(crmTamanho > 2147483647) {
								crm = 2147483646;
							} else {
								crm = Integer.valueOf(lead.CRM__c);
							}
							System.debug('sem 52: ' + crmUf);
						}
					} else {
						lead.CRM_MKT_RJ__c = crmUf;
						crmTamanho = lead.CRM__c != null ? Long.valueOf(lead.CRM__c) : null;
						if(crmTamanho > 2147483647) {
							crm = 2147483646;
						} else {
							crm = lead.CRM__c != null ? Integer.valueOf(lead.CRM__c) : null;
						}
						System.debug('CRM menor que 9: ' + crmUf);
					}		
				} else {
					if(crmValido) {
						crmTamanho = lead.CRM__c != null ? Long.valueOf(lead.CRM__c) : null;
						if(crmTamanho > 2147483647) {
							crm = 2147483646;
						} else {
							crm = lead.CRM__c != null ? Integer.valueOf(lead.CRM__c) : null;
						}
					} else {
						crm = 2147483646;
					}
					
				}
                
				cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
				cfmService.medicoVO medico = response.Consultar(crm, lead.UF_do_CRM__c, chave);

				if (medico != null) {
					if (medico.codigoErro == null && !String.isBlank(medico.nome)) {
						System.debug(JSON.serializePretty(medico));

						List<String> nome = medico.nome.contains(' ') ? medico.nome.split(' ') : new List<String>{ medico.nome };

						lead.FirstName = nome.remove(0);
						lead.LastName = String.join(nome, ' ');

						if (medico.especialidade != null && medico.especialidade.size() > 0) {
							String especialidadeTamanho = String.join(medico.especialidade, ', ');
							if(especialidadeTamanho.length() <= 255) {
								lead.Especialidade_CRM__c = String.join(medico.especialidade, ', ');
							} else {
								lead.Especialidade_CRM__c = 'Especialidade CRM: valor de dados grande demais';
							}
						}

						lead.CRM__c = medico.crm;
						lead.UF_do_CRM__c = medico.uf;
						lead.CRM_Valido__c = 'Sim';
						//lead.CRM_UF__c = medico.crm + medico.uf;
						lead.Tipo_Inscricao_CRM__c = consultasMedicoMdt.get('T' + medico.tipoInscricao).Tipo_de_Inscricao__c;
						lead.Situacao_do_CRM__c = consultasMedicoMdt.get('S' + medico.situacao).Situacao__c;
						lead.Lead_Novo__c = false;

						update lead;

						/* -------------------------------------------------------------------------- */
						/*                              LEAD PARA CONTATO                             */
						/* -------------------------------------------------------------------------- */

						if (lead.Situacao_do_CRM__c != 'Falecido' && lead.Situacao_do_CRM__c != 'Cassado') {
							if (lead.CRM_Valido__c != null && lead.Situacao_do_CRM__c != null) {
								convertLeadToContact(lead);
							}
						} else {
							lead.Error__c = 'Falha ao tentar converter. Situação do CRM inadequado.';
							lead.Status = 'Unqualified';
							lead.Lead_Novo__c = false;
							update lead;
						}
					}
				} else {
					lead.CRM_Valido__c = 'Não';
					lead.CRM_UF__c = lead.CRM__c + lead.UF_do_CRM__c;
					lead.Tipo_Inscricao_CRM__c = null;
					lead.Situacao_do_CRM__c = null;
					lead.Especialidade_CRM__c = null;
					lead.Error__c = 'CRM não encontrado.';
					lead.Lead_Novo__c = false;

					update lead;
				}
			} catch (Exception ex) {
				System.debug('Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
			} finally {
				this.index++;

				if (this.index < this.leads.size() && !Test.isRunningTest()) {
					{
						System.enqueueJob(new LeadQueue(this.leads, this.index));
					}
				}
			}
		}

		/* -------------------------------------------------------------------------- */
		/*                               METHODS PRIVATE                              */
		/* -------------------------------------------------------------------------- */
		

		private void convertLeadToContact(Lead lead) {
			Id conta;

			List<Database.LeadConvert> lcs = new List<Database.LeadConvert>();
			final String convertedLeadStatus = LeadUtils.convertedLeadStatus;

			try {
				if (conta == null) {
					List<Account> contaParaContato = [
						SELECT Id 
						FROM Account 
						WHERE RecordTypeId =:ACCOUNT_EMPRESARIAL_RTYPE AND Name = 'Conta Oc' LIMIT 1
					];
					conta = contaParaContato.get(0).Id;
				}
			} catch (Exception ex) {
				lead.Error__c = ex.getMessage();
			}
			

			System.debug('Converting lead: ' + lead.Id);
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(lead.Id);
			lc.setDoNotCreateOpportunity(true);
			lc.setConvertedStatus(convertedLeadStatus);
			lc.setAccountId(conta);

			List<Contact> listContact = new List<Contact>();

			try {
				List<Contact> medicoExistente = [
					SELECT Id, Nome_da_Campanha__c, Termo_de_Consentimento__c
					FROM Contact 
					WHERE CRM__c =: lead.CRM__c AND UF_do_CRM__c =: lead.UF_do_CRM__c AND 
					RecordTypeId =: CONTATO_MEDICO_RTYPE LIMIT 1
				];
				
				if(medicoExistente.size() > 0) {
					lc.setContactId(medicoExistente.get(0).Id);
					listContact.add(medicoExistente.get(0));
				} 
				

			} catch (Exception ex) {
				System.debug('error contact ' +ex);
				lead.Error__c = ex.getMessage();
			}
			

			lcs.add(lc);
			try {
				
				if(listContact.size() > 0) {
					if(lead.Nome_da_Campanha__c != listContact.get(0).Nome_da_Campanha__c) {
                        listContact.get(0).Nome_da_Campanha__c = lead.Nome_da_Campanha__c;
                        listContact.get(0).Termo_de_Consentimento__c = 'Sim';

						update listContact;
                    }
				}

				Database.convertLead(lcs);

			} catch (Exception e) {

				if(e.getMessage() != null) lead.Lead_Novo__c = true;
				lead.Error__c = e.getMessage();	
				
				update lead;
			}

		}

		private Map<String, Consulta_Medicos__mdt> getConsultaMedicosMap() {
			Map<String, Consulta_Medicos__mdt> result = new Map<String, Consulta_Medicos__mdt>();

			List<Consulta_Medicos__mdt> consultasMedicos = [
				SELECT Id, DeveloperName, Mensagem__c, Chave__c, Situacao__c, Tipo_de_Inscricao__c
				FROM Consulta_Medicos__mdt
				ORDER BY DeveloperName ASC
				LIMIT 2000
			];

			for (Consulta_Medicos__mdt consulta : consultasMedicos) {
				result.put(consulta.DeveloperName, consulta);
			}

			return result;
		}
	}

	public class LeadServiceException extends Exception {
	}
}