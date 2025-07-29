public class App_JuncEspMedicoHandler {
    public static void preventDuplicates(List<App_JuncEspMedico__c> newRecords) {
        Set<Id> medicoIds = new Set<Id>();
        Set<Id> especialidadeIds = new Set<Id>();

        for (App_JuncEspMedico__c rec : newRecords) {
            if (rec.APP_Medico__c != null) {
                medicoIds.add(rec.APP_Medico__c);
            }
            if (rec.APP_EspecialidadeMedico__c != null) {
                especialidadeIds.add(rec.APP_EspecialidadeMedico__c);
            }
        }

        List<App_JuncEspMedico__c> existingRecords = [
            SELECT Id, APP_Medico__c, APP_EspecialidadeMedico__c
            FROM App_JuncEspMedico__c
            WHERE APP_Medico__c IN :medicoIds
              AND APP_EspecialidadeMedico__c IN :especialidadeIds
        ];

        for (App_JuncEspMedico__c newRec : newRecords) {
            for (App_JuncEspMedico__c existing : existingRecords) {
                if (
                    newRec.APP_Medico__c == existing.APP_Medico__c &&
                    newRec.APP_EspecialidadeMedico__c == existing.APP_EspecialidadeMedico__c &&
                    (newRec.Id == null || newRec.Id != existing.Id)
                ) {
                    newRec.addError('Já existe um registro com esta combinação de Médico e Especialidade.');
                }
            }
        }
    }
}