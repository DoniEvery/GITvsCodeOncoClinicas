public class APP_JuncAcompanhanteHandler {

    public static void preventDuplicates(List<APP_JuncAcompanhante__c> newRecords) {

        Set<Id> pacienteIds   = new Set<Id>();
        Set<Id> acompIds      = new Set<Id>();

        for (APP_JuncAcompanhante__c rec : newRecords) {
            if (rec.APP_Paciente__c     != null &&
                rec.APP_Acompanhantes__c != null) {

                pacienteIds.add(rec.APP_Paciente__c);
                acompIds.add(rec.APP_Acompanhantes__c);
            }
        }

        if (pacienteIds.isEmpty() || acompIds.isEmpty()) {
            return;
        }

        List<APP_JuncAcompanhante__c> existentes = [
            SELECT Id, APP_Paciente__c, APP_Acompanhantes__c
            FROM   APP_JuncAcompanhante__c
            WHERE  APP_Paciente__c     IN :pacienteIds
            AND    APP_Acompanhantes__c IN :acompIds
        ];

        Map<String, Id> chaveParaId = new Map<String, Id>();
        for (APP_JuncAcompanhante__c e : existentes) {
            if (e.APP_Paciente__c != null && e.APP_Acompanhantes__c != null) {
                String chave = e.APP_Paciente__c + '_' + e.APP_Acompanhantes__c;
                chaveParaId.put(chave, e.Id);
            }
        }

        Set<String> chavesNaTransacao = new Set<String>(); 

        for (APP_JuncAcompanhante__c rec : newRecords) {

            if (rec.APP_Paciente__c == null || rec.APP_Acompanhantes__c == null) {
                continue;
            }

            String chave = rec.APP_Paciente__c + '_' + rec.APP_Acompanhantes__c;

            if (chaveParaId.containsKey(chave) &&
                (rec.Id == null || rec.Id != chaveParaId.get(chave))) {

                rec.addError('Já existe um registro com esta combinação de Paciente e Acompanhante.');
                continue;
            }

            if (chavesNaTransacao.contains(chave)) {
                rec.addError('Duplicidade na própria transação: Paciente e Acompanhante já informados em outro registro deste lote.');
            } else {
                chavesNaTransacao.add(chave);
            }
        }
    }
}