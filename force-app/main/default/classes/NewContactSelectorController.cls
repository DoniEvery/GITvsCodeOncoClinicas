public with sharing class NewContactSelectorController {
	private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

	/* -------------------------------------------------------------------------- */
	/*                                AURA METHODS                                */
	/* -------------------------------------------------------------------------- */

	@AuraEnabled
	public static Contact getMedico(Integer crm, String ufCrm) {
		Contact result;

		List<Contact> contatos = [
			SELECT Id
			FROM Contact
			WHERE CRM__c = :String.valueOf(crm) AND UF_do_CRM__c = :ufCrm AND CRM__c != NULL AND UF_do_CRM__c != NULL AND RecordTypeId = :CONTATO_MEDICO_RTYPE
		];

		if (contatos.size() > 0) {
			result = contatos.get(0);
		}

		return result;
	}

	@AuraEnabled
	public static Contact getNewMedicoCfm(Integer crm, String ufCrm) {
		Contact result;

		try {
			result = new MedicoService().consultaMedico(crm, ufCrm);
		} catch (Exception ex) {
			System.debug('Exception => getNewMedicoCfm => ' + ex.getMessage() + ', ' + ex.getStackTraceString());
			throwAuraException(ex.getMessage());
		}

		return result;
	}

	@AuraEnabled
	public static Id saveMedico(Contact medico) {
		try {
			insert medico;
		} catch (Exception ex) {
			System.debug('Exception => saveMedico => ' + ex.getMessage() + ', ' + ex.getStackTraceString());
			throwDmlExceptionMessage(ex);
		}

		return medico.Id;
	}

	/* -------------------------------------------------------------------------- */
	/*                               PRIVATE METHODS                              */
	/* -------------------------------------------------------------------------- */

    private static void throwDmlExceptionMessage(Exception e) {
		System.debug('throwDmlExceptionMessage :: ' + e.getMessage() + ', ' + e.getStackTraceString());

		String msg = '';

		for (Integer i = 0; i < e.getNumDml(); i++) {
			msg = +e.getDmlMessage(i) + '\n';
		}

		throwAuraException(msg);
	}

	private static void throwAuraException(String message) {
		AuraHandledException auraException = new AuraHandledException(message);
		auraException.setMessage(message);
		throw auraException;
	}

	/* -------------------------------------------------------------------------- */
	/*                                INNER CLASSES                               */
	/* -------------------------------------------------------------------------- */

	public class NewContactSelectorControllerException extends Exception {
	}
}