trigger EhrEncounterContact on HealthCloudGA__EhrEncounter__c (after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        new EhrEncounterContactHandler().atualizaTotalizadoresContatoMed(Trigger.isDelete ? Trigger.old : Trigger.new); 
    } 
    
}