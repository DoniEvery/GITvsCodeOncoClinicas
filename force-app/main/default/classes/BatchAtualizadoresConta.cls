global without sharing  class BatchAtualizadoresConta implements Database.Batchable<SObject> {

	List<String> errors = new List<String>();

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(
			[
				SELECT
					Id,
					HealthCloudGA__Account__c
				FROM HealthCloudGA__EhrEncounter__c 
				WHERE HealthCloudGA__PeriodStart__c >= LAST_N_MONTHS:36 AND
				Unidade_nova_alterada__c = true AND HealthCloudGA__Account__c != ''
				WITH SECURITY_ENFORCED
				ORDER BY CREATEDDATE DESC
			]
		);

	}

	global void execute(Database.BatchableContext context, List<SObject> scope) {

		List<HealthCloudGA__EhrEncounter__c> listEncounter = new List<HealthCloudGA__EhrEncounter__c>();

		try {
			new EhrEncounterAccountHandler().atualizaTotalizadoresConta(scope);
		} catch (Exception ex) {
			errors.add('BatchAtualizadoresPaciente :: batch execute :: EXCEPTION : ' + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(scope));
		}	

		for(SObject s : scope) {

			HealthCloudGA__EhrEncounter__c encontro = (HealthCloudGA__EhrEncounter__c) s;
			encontro.Unidade_nova_alterada__c = false;
			listEncounter.add(encontro);
		}

		update listEncounter;

	} 
    
	global void finish(Database.BatchableContext context) {

		if(errors.size() == 0) {
			errors.add('Batch executada com sucesso!');
		}
		sendEmail(errors);
	}

	private void sendEmail(List<String> errors) {
		Messaging.SingleEmailMessage sEM = new Messaging.SingleEmailMessage();
		String body = '';

		for (String error : errors) {
			body += error + '\n';
		}

		sEM.setToAddresses(new List<String>{ 'admincrm@wingsit.com.br' });
		sEM.setSubject('BatchAtualizadoresPaciente Result : ' + Datetime.now());
		sEM.setPlainTextBody(body);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ sEM });
	}
}