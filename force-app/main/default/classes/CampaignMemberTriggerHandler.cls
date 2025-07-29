public class CampaignMemberTriggerHandler {
    
    public static void validarTelefone(Map<Id,CampaignMember> CampaignMemberMap){
        Map<Id,Account> accountMap = new Map<Id,Account>();
	    Set<Id> setIdContact = new Set<Id>();
	    Set<Id> setIdCampaign = new Set<Id>();
        
        for(CampaignMember cm : CampaignMemberMap.values()){
            if(String.isNotBlank(cm.CampaignId)){
                setIdCampaign.add(cm.CampaignId);
            }
        }
        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([Select id from Campaign WHERE Status = 'In Progress' AND IsActive = True AND IntegraBlip__c = True and id in :setIdCampaign
                                                             and TipoQuestionario__c = null]);

        for(CampaignMember cm : CampaignMemberMap.values()){
		    if(String.isNotBlank(cm.ContactId) && campaignMap.containsKey(cm.CampaignId)){
                setIdContact.add(cm.ContactId);
            }
            
        }

        for(Contact ct : [SELECT Id,AccountId,Account.PersonAssistantPhone,Account.StatusVerificacaoWhatsApp__c,Account.logIntegracaoVerificacaoWhatsApp__c,Account.UltimaIntegracaoBlip__c FROM Contact WHERE Id IN: setIdContact]){
            System.debug('1');
            if(string.isNotBlank(ct.Account.PersonAssistantPhone)){
                System.debug('2');
                accountMap.put(ct.AccountId,new Account(
                    Id = ct.AccountId,
                    PersonAssistantPhone = ct.Account.PersonAssistantPhone,
                	StatusVerificacaoWhatsApp__c = ct.Account.StatusVerificacaoWhatsApp__c,
                	logIntegracaoVerificacaoWhatsApp__c = ct.Account.logIntegracaoVerificacaoWhatsApp__c,
                	UltimaIntegracaoBlip__c = ct.Account.UltimaIntegracaoBlip__c));
            }
        }
        if(accountMap.size() > 0){
           System.enqueueJob(new VerificarTelefoneQueueable(accountMap));
        }
    }
}