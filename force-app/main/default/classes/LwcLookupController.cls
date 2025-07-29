public class LwcLookupController {  
    @AuraEnabled(cacheable=true)  
    public static List<Contact> findRecords(String searchKey, String objectName) 
    {
        List<Id> medicTypeIdList = new List<Id>();
        medicTypeIdList.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Medico').getRecordTypeId());
        medicTypeIdList.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Medico Corpo Clinico').getRecordTypeId());

        List<Contact> contacts = new List<Contact>();
        try {
            String searchString = '%' + searchKey + '%';
            contacts = [SELECT Id, Name, CRM_UF__c FROM Contact WHERE (Nome_completo__c LIKE :searchString OR CRM__c LIKE :searchString OR CRM_UF__c LIKE :searchString) AND RecordTypeId IN :medicTypeIdList LIMIT 49000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contacts;

    }
    @AuraEnabled(cacheable=true)  
    public static List<Account> findRecordsFlow(String searchKey,String recordTypeId) {
        List<Account> accounts = new List<Account>();
        try {
            if(searchKey.length() > 2){
                String searchString = '%' + searchKey + '%';
                accounts = [SELECT Id, Name, UF_Endereco__c FROM Account WHERE (Name LIKE : searchString) AND recordTypeId =: recordTypeId AND Ativo__c = 'Sim' LIMIT 49000];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accounts;

    }
    @AuraEnabled(cacheable=true)  
    public static List<Contact> findRecordsFlowChild(String searchKey, String ufDoCrm) {
        List<Contact> contacts = new List<Contact>();
        try {
            if(searchKey.length() > 2 ){
                String searchString = '%' + searchKey + '%';
                contacts = [SELECT Id,Nome_completo__c, UF_do_CRM__c FROM Contact WHERE (Nome_completo__c LIKE :searchString) AND UF_do_CRM__c =:ufDoCrm LIMIT 49000];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contacts;

    }
    @AuraEnabled(cacheable=true)  
    public static Account findRecordsFlowCache(String recordId) {
        Account account = new Account();
        account = [SELECT Id, Name, UF_Endereco__c FROM Account WHERE id =:recordId];
        return account;
    }
    @AuraEnabled(cacheable=true)  
    public static Contact findRecordsFlowChildCache(String recordId) {
        Contact contact = new Contact();
        contact = [SELECT Id,Nome_completo__c, UF_do_CRM__c FROM Contact WHERE id =:recordId];
        return contact;
    }   
}