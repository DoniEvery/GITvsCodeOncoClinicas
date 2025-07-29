global without sharing class BatchUnidadeMaisRecorrente implements Database.Batchable<SObject>, Database.Stateful  {
    
    List<String> errors = new List<String>();
    global Map<Id, DateTime> mapaEncontroMedRef = new Map<Id, DateTime>();
    global Map<Id, DateTime> mapaEncontroCorCli = new Map<Id, DateTime>();
    global Set<Id> setEncontrosIdentificadorCCC = new Set <Id>();
    global Set<Id> setEncontrosIdentificadorMRC = new Set <Id>();
    global Set<Id> medicosToUpdateIds = new Set<Id>();
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(
			[
				SELECT
					Id,
					HealthCloudGA__PeriodStart__c,
					Identificador_Unidade_Account__c,
					Identificador_Medico_Ref_Contact__c,
					Identificador_Corpo_Clinico_Contact__c
				FROM HealthCloudGA__EhrEncounter__c WHERE HealthCloudGA__PeriodStart__c >= LAST_N_MONTHS:24 
                AND Unidade_nova_alterada__c = true AND HealthCloudGA__PeriodStart__c != null  
                AND(Identificador_Medico_Ref_Contact__c != null OR Identificador_Corpo_Clinico_Contact__c != null)
                AND Identificador_Unidade_Account__c != NULL
				WITH SECURITY_ENFORCED
				ORDER BY HealthCloudGA__PeriodStart__c DESC
			]
		);

	} 

	global void execute(Database.BatchableContext context, List<HealthCloudGA__EhrEncounter__c> encontros) {
        
		for(HealthCloudGA__EhrEncounter__c encontro : encontros)           
        {
            if(encontro.Identificador_Unidade_Account__c == null) continue;
            if(encontro.Identificador_Medico_Ref_Contact__c != null && encontro.Identificador_Unidade_Account__c != null)
            {
                medicosToUpdateIds.add(encontro.Identificador_Medico_Ref_Contact__c);
                if(!mapaEncontroMedRef.containsKey(encontro.Identificador_Medico_Ref_Contact__c))
                mapaEncontroMedRef.put(encontro.Identificador_Medico_Ref_Contact__c, encontro.HealthCloudGA__PeriodStart__c);
 			}

            if(encontro.Identificador_Corpo_Clinico_Contact__c != null && encontro.Identificador_Unidade_Account__c != null)
            {
                medicosToUpdateIds.add(encontro.Identificador_Corpo_Clinico_Contact__c);
                if(!mapaEncontroCorCli.containsKey(encontro.Identificador_Corpo_Clinico_Contact__c))
                mapaEncontroCorCli.put(encontro.Identificador_Corpo_Clinico_Contact__c, encontro.HealthCloudGA__PeriodStart__c);
            }     
		}
        
        for(HealthCloudGA__EhrEncounter__c enc : encontros)
        {
            if(enc.Identificador_Medico_Ref_Contact__c != null && mapaEncontroMedRef.ContainsKey(enc.Identificador_Medico_Ref_Contact__c))
            {
             if(enc.HealthCloudGA__PeriodStart__c < mapaEncontroMedRef.get(enc.Identificador_Medico_Ref_Contact__c).addMonths(-6))
                 setEncontrosIdentificadorMRC.add(enc.Id);                
            }
			if(enc.Identificador_Corpo_Clinico_Contact__c != null && mapaEncontroCorCli.ContainsKey(enc.Identificador_Corpo_Clinico_Contact__c))
            {
             if(enc.HealthCloudGA__PeriodStart__c < mapaEncontroCorCli.get(enc.Identificador_Corpo_Clinico_Contact__c).addMonths(-6))
                 setEncontrosIdentificadorCCC.add(enc.Id);                
            }
        }

		/*try {
			new EhrEncounterContactHandler().atualizaTotalizadoresContatoMed(medicosToUpdateIds, setEncontrosIdentificadorMRC, setEncontrosIdentificadorCCC);
		} catch (Exception ex) {
			errors.add('BatchUnidadeMaisRecorrente :: batch execute :: EXCEPTION : ' + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(encontros));
		}*/			

	} 
    
	global void finish(Database.BatchableContext context) {

			new EhrEncounterContactHandler().atualizaTotalizadoresContatoMed(medicosToUpdateIds, setEncontrosIdentificadorMRC, setEncontrosIdentificadorCCC);
	}
}