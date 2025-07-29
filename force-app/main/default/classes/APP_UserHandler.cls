public without sharing class APP_UserHandler {
    public static void atualizarFotoEmConta(Map<Id, User> oldMap, List<User> newUsers) {
        Set<Id> contactIds = new Set<Id>();

        for (User u : newUsers) {
            if (u.ContactId != null) {
                contactIds.add(u.ContactId);
            }
        }

        System.debug('🔍 ContactIds detectados: ' + contactIds);

        if (contactIds.isEmpty()) return;

        Map<Id, Account> contatoParaConta = new Map<Id, Account>(
            [SELECT Id, PersonContactId, APP_FotoPerfil__c
             FROM Account
             WHERE PersonContactId IN :contactIds]
        );

        System.debug('📦 Contas encontradas: ' + contatoParaConta.keySet());

        List<Account> contasParaAtualizar = new List<Account>();

        for (User u : newUsers) {
            if (u.ContactId == null || !contatoParaConta.containsKey(u.ContactId)) {
                System.debug('⛔ Sem conta vinculada ao contato: ' + u.ContactId);
                continue;
            }

            if (String.isNotBlank(u.FullPhotoUrl)) {
                Account acc = contatoParaConta.get(u.ContactId);
                
                // Só atualiza se for diferente para evitar DML desnecessário
                if (acc.APP_FotoPerfil__c != u.FullPhotoUrl) {
                    System.debug('✅ Atualizando conta ' + acc.Id + ' com nova foto: ' + u.FullPhotoUrl);
                    acc.APP_FotoPerfil__c = u.FullPhotoUrl;
                    contasParaAtualizar.add(acc);
                } else {
                    System.debug('ℹ️ Foto já está igual na conta. Nada a fazer.');
                }
            } else {
                System.debug('⚠️ FullPhotoUrl está vazio para usuário: ' + u.Id);
            }
        }

        if (!contasParaAtualizar.isEmpty()) {
            System.debug('💾 Atualizando contas: ' + contasParaAtualizar);
            update contasParaAtualizar;
        } else {
            System.debug('⚠️ Nenhuma conta será atualizada.');
        }
    }
}