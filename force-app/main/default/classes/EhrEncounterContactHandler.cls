public with sharing class EhrEncounterContactHandler extends TriggerHelper {

	// String dataHoje;

	// public EhrEncounterContactHandler() {
	// 	this.dataHoje = date.today().format();
	// }	
    public static Set<Id> setEncontrosIdentificadorCCC = new Set <Id>();
    public static Set<Id> setEncontrosIdentificadorMRC = new Set <Id>();

	public void atualizaTotalizadoresContatoMed(Set<Id> medToUpda, Set<Id> encontrosMRC, Set<Id> encontrosCCC) {
    setEncontrosIdentificadorMRC = encontrosMRC;
	setEncontrosIdentificadorCCC = encontrosCCC;

        updateMedicos(medToUpda); 
	}

	private static void updateMedicos(Set<Id> medicosToUpdateIds) {
		if (medicosToUpdateIds.size() > 0) {

			updateUnidadePrincipalMedico(medicosToUpdateIds);

		}
	}

	private static void updateUnidadePrincipalMedico(Set<Id> medicosIds) {

		// System.debug('Data hoje -> ' + dataHoje);

		/* -------------------------------------------------------------------------- */
		/*                              AggregateResult CC                            */
		/* -------------------------------------------------------------------------- */

		Map<String, Integer> mapAggregate = new Map<String, Integer>();

		AggregateResult[] groupedResultsCC = [
			SELECT 
				Identificador_Unidade_Account__c unidade, 
				Identificador_Corpo_Clinico_Contact__c cc,
				count(id) soma 
			FROM HealthCloudGA__EhrEncounter__c 
			WHERE Id NOT IN : setEncontrosIdentificadorCCC AND Identificador_Corpo_Clinico_Contact__c IN :medicosIds
			// (Identificador_Corpo_Clinico_Contact__r.Data_Batch__c = null OR Identificador_Corpo_Clinico_Contact__r.Data_Batch__c !=:dataHoje) 
			GROUP BY Identificador_Unidade_Account__c, Identificador_Corpo_Clinico_Contact__c ORDER BY MAX(HealthCloudGA__PeriodStart__c) DESC
		];

		for(AggregateResult ar : groupedResultsCC) {
            
			mapAggregate.put((String)ar.get('cc')+'-'+(String)ar.get('unidade'), (Integer)ar.get('soma'));
		}	

		/* -------------------------------------------------------------------------- */
		/*                             AggregateResult REF                            */
		/* -------------------------------------------------------------------------- */

		AggregateResult[] groupedResultsREF = [
			SELECT 
				Identificador_Unidade_Account__c unidade, 
				Identificador_Medico_Ref_Contact__c ref,
				count(id) soma 
			FROM HealthCloudGA__EhrEncounter__c 
			WHERE Id NOT IN : setEncontrosIdentificadorMRC AND Identificador_Medico_Ref_Contact__c IN :medicosIds
			//(Identificador_Medico_Ref_Contact__r.Data_Batch__c = null OR Identificador_Medico_Ref_Contact__r.Data_Batch__c !=:dataHoje)
			GROUP BY Identificador_Unidade_Account__c, Identificador_Medico_Ref_Contact__c ORDER BY MAX(HealthCloudGA__PeriodStart__c) DESC
			
		];
		for(AggregateResult ar : groupedResultsREF) {
			if(mapAggregate.containsKey((String)ar.get('ref')+'-'+(String)ar.get('unidade'))) {

				mapAggregate.put((String)ar.get('ref')+'-'+(String)ar.get('unidade'), 
				mapAggregate.get((String)ar.get('ref')+'-'+(String)ar.get('unidade'))
				+(Integer)ar.get('soma'));

			} else {
				mapAggregate.put((String)ar.get('ref')+'-'+(String)ar.get('unidade'), (Integer)ar.get('soma'));
			}

		}
        
		Map<String, unidadeSoma> unidadeSomaByMedico = new Map<String, unidadeSoma>();

		for(String idContaEMedico : mapAggregate.keySet()) {
		if(String.isBlank(idContaEMedico)) continue;
            
			if(unidadeSomaByMedico.containsKey(idContaEMedico.split('-')[0])) {                
				if(mapAggregate.get(idContaEMedico) > unidadeSomaByMedico.get(idContaEMedico.split('-')[0]).somaOcorrencias) {
					unidadeSomaByMedico.get(idContaEMedico.split('-')[0]).unidadeId = idContaEMedico.split('-')[1];
					unidadeSomaByMedico.get(idContaEMedico.split('-')[0]).somaOcorrencias = mapAggregate.get(idContaEMedico);
				}
			} else {
				unidadeSoma us = new unidadeSoma();
				us.unidadeId = idContaEMedico.split('-')[1];
				us.somaOcorrencias = mapAggregate.get(idContaEMedico);
				unidadeSomaByMedico.put(idContaEMedico.split('-')[0], us);
			}
		}
		List<Contact> listMedicoUpdate = new List<Contact>();

		for(String idMedico : unidadeSomaByMedico.keySet()) {
         if(String.isBlank(idMedico)) continue;
         if(String.isBlank(unidadeSomaByMedico.get(idMedico)?.unidadeId)) continue;
            
			Contact medico = new Contact();
			medico.id = idMedico;
			medico.Unidade_Principal__c = unidadeSomaByMedico.get(idMedico).unidadeId;
            listMedicoUpdate.add(medico);                
       }
        
		List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
		if(listMedicoUpdate.size() > 0) updateResults = database.update(listMedicoUpdate,false);
        
         List<String> errors = new List<String>();
        
        for(Integer i=0;i<updateResults.size();i++){
          if (!updateResults.get(i).isSuccess()){
             
        	Database.Error error = updateResults.get(i).getErrors().get(0);
        	String failedDML = error.getMessage();
        	listMedicoUpdate.get(i);
            errors.add('BatchUnidadeMaisRecorrente :: batch execute :: EXCEPTION : ' + error.getMessage() + ', ' + 'Failed ID ' + listMedicoUpdate.get(i).Id);
       	  }          
        }
        if(errors.size() > 0 ) sendEmail(errors);
	}
    
   public static void sendEmail(List<String> errors) {
		Messaging.SingleEmailMessage sEM = new Messaging.SingleEmailMessage();
		String body = '';
		Integer totalErros = errors.size() > 10 ? 10 : errors.size();
		for(Integer i=0; i < totalErros ; i++) {
			body += errors[i] + '\n';
		}

		sEM.setToAddresses(new List<String>{ 'admincrm@wingsit.com.br' });
		sEM.setSubject('BatchUnidadeMaisRecorrente Result : ' + Datetime.now());
		sEM.setPlainTextBody(body);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ sEM });
	}

	public class unidadeSoma {
		public String unidadeId;
		public Integer somaOcorrencias;
		
	}

}