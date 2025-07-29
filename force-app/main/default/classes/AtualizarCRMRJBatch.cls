global without sharing class AtualizarCRMRJBatch implements Database.Batchable<SObject> {

    List<String> errors = new List<String>();
    private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext context) {

        return Database.getQueryLocator(
            [
                SELECT Id, CRM__c, UF_do_CRM__c, CRM_MKT_RJ__c, CRM_UF__c, RecordTypeId
                FROM Contact
                WHERE UF_do_CRM__c = 'RJ' AND RecordTypeId =: CONTATO_MEDICO_RTYPE
            ]
        );
    }

    global void execute(Database.BatchableContext context, List<SObject> scope) {

        List<Contact> medicoList = new List<Contact>();

        for(SObject s : scope) {
            try {
                Contact medico = (Contact) s;
                if(medico.CRM_UF__c.length() >= 9) {
                    if(medico.CRM_UF__c.substring(0, 2) == '52') {
                        medico.CRM_MKT_RJ__c = medico.CRM_UF__c.substring(2);
                        medicoList.add(medico);
                    } else {
                        medico.CRM_MKT_RJ__c = medico.CRM_UF__c;
                        medicoList.add(medico);
                    }
                } else {
                    medico.CRM_MKT_RJ__c = medico.CRM_UF__c;
                    medicoList.add(medico);
                } 
                

            } catch(Exception ex) {
                errors.add('AtualizarCRMRJBatch :: batch execute :: EXCEPTION : ' + ex.getMessage() + ', ' + ex.getSTackTraceString() + ', scope : \n' + JSON.serializePretty(scope));
            }
        }

        update medicoList;

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
		sEM.setSubject('BatchAtualizadoresPaciente Result : ' + Datetime.now());
		sEM.setPlainTextBody(body);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ sEM });
    }
    
}