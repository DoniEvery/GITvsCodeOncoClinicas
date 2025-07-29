global class BlipIntegrationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
     
    global Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator('SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE Campaign.Status = \'In Progress\' AND Campaign.IsActive = True AND Campaign.IntegraBlip__c = True');   }
    
    global void execute(Database.BatchableContext bc, List<CampaignMember> lstCm){
        Map<Id,CampaignMember> CampaignMemberMap = new Map<Id,CampaignMember>();
        for(CampaignMember cm : lstCm){
            CampaignMemberMap.put(cm.id,cm);
        }
        CampaignMemberTriggerHandler.validarTelefone(CampaignMemberMap);
    }
    
    global void finish(Database.BatchableContext bc){

    }
}