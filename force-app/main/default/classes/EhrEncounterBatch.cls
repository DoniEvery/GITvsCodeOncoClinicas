global without sharing class EhrEncounterBatch implements Database.Batchable<SObject>, Database.Stateful {
	List<String> errors = new List<String>();

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(
			[
				SELECT
					Id,
					HealthCloudGA__Account__c
				FROM HealthCloudGA__EhrEncounter__c 
				WHERE HealthCloudGA__PeriodStart__c >= LAST_N_MONTHS:36 AND HealthCloudGA__Account__c != ''
				WITH SECURITY_ENFORCED
				ORDER BY CREATEDDATE DESC
			]
		);
	}

	global void execute(Database.BatchableContext context, List<SObject> scope) {
		try {
			new EhrEncounterAccountHandler().atualizaTotalizadoresConta(scope);
		} catch (Exception ex) {
			errors.add('EhrEncounterBatch :: batch execute :: EXCEPTION : ' + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(scope));
		}
	}

	global void finish(Database.BatchableContext context) {
		 sendEmail(errors);
	}

	private void sendEmail(List<String> errors) {
		Messaging.SingleEmailMessage sEM = new Messaging.SingleEmailMessage();
		String body = '';

		for (String error : errors) {
			body += error + '\n';
		}

		sEM.setToAddresses(new List<String>{ 'admincrm@wingsit.com.br' });
		sEM.setSubject('EhrEncounterBatch Result : ' + Datetime.now());
		sEM.setPlainTextBody(body);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ sEM });
	}
}