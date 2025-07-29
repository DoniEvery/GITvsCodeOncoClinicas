global without sharing class LeadBatch implements Database.Batchable<SObject> {
	
	List<String> errors = new List<String>();
	private static Id LEAD_MEDICO_RTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

	global Database.QueryLocator start(Database.BatchableContext context) {
		
		return Database.getQueryLocator([
            SELECT Id, CRM__c, UF_do_CRM__c, Lead_Novo__c, Nome_da_Campanha__c, Termo_de_Consentimento__c ,RecordTypeId
            FROM Lead
            WHERE Lead_Novo__c = true AND CRM__c != null AND UF_do_CRM__c != null AND 
			RecordTypeId =: LEAD_MEDICO_RTYPE
            ORDER BY CreatedDate ASC
			LIMIT 750
        ]);

	}

	global void execute(Database.BatchableContext context, List<SObject> scope) {

        try {
			new LeadTriggerHandler().verificaCrmValido(scope);
		} catch (Exception ex) {
			errors.add('BatchUnidadeMaisRecorrente :: batch execute :: EXCEPTION : ' + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(scope));
		}

	} 

	global void finish(Database.BatchableContext context) {
		
        sendEmail(errors);
		
	}

    /* -------------------------------------------------------------------------- */
    /*                              METHODS PRIVATES                              */
    /* -------------------------------------------------------------------------- */

    private void sendEmail(List<String> errors) {
		Messaging.SingleEmailMessage sEM = new Messaging.SingleEmailMessage();
		String body = '';

		for (String error : errors) {
			body += error + '\n';
		}

		sEM.setToAddresses(new List<String>{ 'admincrm@wingsit.com.br' });
		sEM.setSubject('OC - BatchConvertLead Result : ' + Datetime.now());
		sEM.setPlainTextBody(body);

		//Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ sEM });
	}

}