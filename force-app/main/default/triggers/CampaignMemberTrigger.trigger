trigger CampaignMemberTrigger on CampaignMember (after insert,after update) {

    Boolean afterInsert = trigger.isAfter && trigger.isInsert;
    //Boolean afterUpdate = trigger.isAfter && trigger.isUpdate;
    
    if(afterInsert )
    {        
        CampaignMemberTriggerHandler.validarTelefone(trigger.newMap);
        System.debug('CampaignMemberTrigger');
    }
    
}