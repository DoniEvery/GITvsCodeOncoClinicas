trigger userCommunityInsert on User (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        for (User u : Trigger.new) {
            if (u.ProfileIdAux__c != null) {
                u.ProfileId = u.ProfileIdAux__c;
                u.ProfileIdAux__c = null;
            }
        }
    }
}