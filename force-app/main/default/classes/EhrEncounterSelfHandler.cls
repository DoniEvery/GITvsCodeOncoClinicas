public class EhrEncounterSelfHandler extends TriggerHelper {
    
	public void atualizaUnidadeEncontros(List<HealthCloudGA__EhrEncounter__c> encontros) {
        
        Set<Id> encontroIds = new Set<Id>();
        
        if(Trigger.isExecuting && Trigger.isUpdate) {
            for(HealthCloudGA__EhrEncounter__c encontro : encontros) {
                if (isChanged(encontro, new Set<String>{'Identificador_Unidade_Account__c', 'Identificador_Medico_Ref_Contact__c'})) {
                    if (encontro.Identificador_Unidade_Account__c != null) {
                        encontroIds.add(encontro.Id);
                    }
                }
                
                if (isChanged(encontro, new Set<String>{ 'Identificador_Unidade_Account__c', 'Identificador_Medico_Ref_Contact__c'})) {
					HealthCloudGA__EhrEncounter__c encontroOld = (HealthCloudGA__EhrEncounter__c) Trigger.oldMap.get(encontro.Id);

					if (encontroOld != null && encontroOld.Identificador_Unidade_Account__c != null) {
						encontroIds.add(encontroOld.Id);
					}
				}
            }
        } 
        else {
            for(HealthCloudGA__EhrEncounter__c encontro : encontros) {
                if (encontro.Identificador_Unidade_Account__c != null) {
                    encontroIds.add(encontro.Id);
                }
            }  
        }
        
        List<HealthCloudGA__EhrEncounter__c> listEncontroResult = [
            SELECT 
                Id, 
                Name, 
                Identificador_Unidade_Account__r.Name,
                Identificador_Unidade_Texto__c,
                Tipo_de_Medico_Medico_Referenciador__c,
                Identificador_Medico_Ref_Contact__r.Tipo_de_Medico__c,
                Identificador_Medico_Ref_Contact__r.CRM_UF__c
            FROM HealthCloudGA__EhrEncounter__c WHERE Id IN :encontroIds
        ];
        
        for(HealthCloudGA__EhrEncounter__c newEncontro : listEncontroResult) {
            newEncontro.Identificador_Unidade_Texto__c = newEncontro.Identificador_Unidade_Account__r.Name;
            newEncontro.Tipo_de_Medico_Medico_Referenciador__c = newEncontro.Identificador_Medico_Ref_Contact__r.Tipo_de_Medico__c;
            newEncontro.CRM_UF_REF_Texto__c = newEncontro.Identificador_Medico_Ref_Contact__r.CRM_UF__c; 
        }
        
        if(listEncontroResult.size() > 0) {
            update listEncontroResult;
        }
        
	}  
    
}