public without sharing class LeadUtils {

    public static final String convertedLeadStatus = [SELECT ApiName FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].ApiName;
    
}