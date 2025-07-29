trigger EhrEncounterSelf on HealthCloudGA__EhrEncounter__c (after insert, after update) {

    if (Trigger.isAfter) {
        new EhrEncounterSelfHandler().atualizaUnidadeEncontros(Trigger.isDelete ? Trigger.old : Trigger.new);
    } 
    
}