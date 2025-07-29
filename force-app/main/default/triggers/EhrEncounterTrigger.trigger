trigger EhrEncounterTrigger on HealthCloudGA__EhrEncounter__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter) {
        new EhrEncounterAccountHandler().atualizaTotalizadoresConta(Trigger.isDelete ? Trigger.old : Trigger.new); 
    }   
}