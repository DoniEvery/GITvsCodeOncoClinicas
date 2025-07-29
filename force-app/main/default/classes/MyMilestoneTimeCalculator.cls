global class MyMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
       Case c = [SELECT SlaStartDate,NovaDataSLA__c,businesshoursid FROM Case WHERE Id=:caseId];
       MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
       Integer tempo;
       if (c.NovaDataSLA__c != null && mt.Name == 'Total Repactuado'){
           Long timeMinutes = BusinessHours.diff(c.businesshoursid, c.SlaStartDate, c.NovaDataSLA__c);
           timeMinutes = (timeMinutes/1000)/60;
           tempo =  timeMinutes.intValue();     
       }   
       return tempo;          
    }
}