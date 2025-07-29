public class APP_JuncUnidadeHandler {
    public static void preventDuplicates(List<APP_JuncUnidade__c> newRecords) {
        Set<Id> pacienteIds = new Set<Id>();
        Set<Id> medicoIds = new Set<Id>();
        Set<Id> equipeIds = new Set<Id>();
        Set<Id> unidadeIds = new Set<Id>();

        for (APP_JuncUnidade__c rec : newRecords) {
            if (rec.APP_Paciente__c != null) pacienteIds.add(rec.APP_Paciente__c);
            if (rec.APP_Medico__c != null) medicoIds.add(rec.APP_Medico__c);
            if (rec.APP_EquipeMulti__c != null) equipeIds.add(rec.APP_EquipeMulti__c);
            if (rec.APP_Unidade__c != null) unidadeIds.add(rec.APP_Unidade__c);
        }

        List<APP_JuncUnidade__c> existing = [
            SELECT Id, APP_Paciente__c, APP_Medico__c, APP_EquipeMulti__c, APP_Unidade__c
            FROM APP_JuncUnidade__c
            WHERE APP_Paciente__c IN :pacienteIds OR
                  APP_Medico__c IN :medicoIds OR
                  APP_EquipeMulti__c IN :equipeIds
        ];

        for (APP_JuncUnidade__c rec : newRecords) {
            for (APP_JuncUnidade__c existingRec : existing) {
                if (rec.Id != null && rec.Id == existingRec.Id) continue;

                Boolean isDuplicate = (
                    (rec.APP_Paciente__c != null && rec.APP_Unidade__c != null &&
                     rec.APP_Paciente__c == existingRec.APP_Paciente__c &&
                     rec.APP_Unidade__c == existingRec.APP_Unidade__c)
                ||
                    (rec.APP_Medico__c != null && rec.APP_Unidade__c != null &&
                     rec.APP_Medico__c == existingRec.APP_Medico__c &&
                     rec.APP_Unidade__c == existingRec.APP_Unidade__c)
                ||
                    (rec.APP_EquipeMulti__c != null && rec.APP_Unidade__c != null &&
                     rec.APP_EquipeMulti__c == existingRec.APP_EquipeMulti__c &&
                     rec.APP_Unidade__c == existingRec.APP_Unidade__c)
                );

                if (isDuplicate) {
                    rec.addError('Já existe um registro com essa combinação de Pessoa/Unidade, Médico/Unidade ou Equipe/Unidade.');
                    break;
                }
            }
        }
    }
}