public with sharing class LeadTriggerConvertedToContact {

    public void leadsConvertidos(List<Lead> listLeads) {

        List<Contact> contactAtt = new List<Contact>();

        for(Lead lead : listLeads) {
            if(lead.IsConverted) {

                List<Contact> contactResult = [
                    SELECT Id, Termo_de_Consentimento__c, Nome_da_Campanha__c
                    FROM Contact
                    WHERE CRM__c =:lead.CRM__c AND UF_do_CRM__c =:lead.UF_do_CRM__c
                    LIMIT 1
                ];

                if(contactResult.size() > 0) {
                    if(lead.Nome_da_Campanha__c != contactResult.get(0).Nome_da_Campanha__c) {
                        contactResult.get(0).Nome_da_Campanha__c = lead.Nome_da_Campanha__c;
                        contactResult.get(0).Termo_de_Consentimento__c = 'Sim';
                    }

                    contactAtt.add(contactResult.get(0));
                }

            }
        }
        
        if(contactAtt.size() > 0) {
            update contactAtt;
        }

    }
}