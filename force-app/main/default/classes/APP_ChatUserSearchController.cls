public without sharing class APP_ChatUserSearchController {
    @AuraEnabled
    public static List<MinimalUserResult> searchPatients(String prefix) {
        if (String.isBlank(prefix) || prefix.length() < 3) {
            return new List<MinimalUserResult>();
        }

        List<MinimalUserResult> results = new List<MinimalUserResult>();
        for (User a : [
            SELECT Id, ContactId, Contact.Nome_completo__c
            FROM User
            WHERE Contact.Nome_completo__c LIKE :prefix + '%'
            AND Account.RecordType.DeveloperName = 'PersonAccount'
            AND Account.APP_Ativo__c = true
            ORDER BY Contact.Nome_completo__c
            LIMIT 50
        ]) {
            results.add(new MinimalUserResult(a.ContactId, a.Contact.Nome_completo__c));
        }
        return results;
    }

    @AuraEnabled
    public static List<MinimalUserResult> searchProfessionals(String prefix, Id userId) {
        if (String.isBlank(prefix) || prefix.length() < 3) {
            return new List<MinimalUserResult>();
        }

        User user = [
            SELECT Id, Profile.Name, Contact.AccountId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        // Caso seja paciente, filtrar por unidades compartilhadas
        if (user.Profile.Name == 'APP_Paciente') {
            Id pacienteId = user.Contact?.AccountId;
            if (pacienteId == null) return new List<MinimalUserResult>();

            // Buscar IDs das unidades do paciente via objeto de junção
            Set<Id> unidadeIds = new Set<Id>();
            for (APP_JuncUnidade__c j : [
                SELECT APP_Unidade__c
                FROM APP_JuncUnidade__c
                WHERE APP_Paciente__c = :pacienteId
                AND APP_Ativo__c = true
                AND APP_Unidade__r.APP_Ativo__c = true
                AND APP_Unidade__c <> NULL
            ]) {
                    unidadeIds.add(j.APP_Unidade__c);
            }

            if (unidadeIds.isEmpty()) return new List<MinimalUserResult>();

            // Buscar profissionais (Contact) vinculados a essas unidades
            Set<Id> profissionalIds = new Set<Id>();

            for (APP_JuncUnidade__c unidade : [
                SELECT APP_Medico__c, APP_EquipeMulti__c
                FROM APP_JuncUnidade__c
                WHERE APP_Unidade__c IN :unidadeIds
                AND APP_Ativo__c = true
                AND APP_Unidade__r.APP_Ativo__c = true
                AND (APP_Medico__c <> NULL OR APP_EquipeMulti__c <> NULL)
            ]) {
                if (unidade.APP_Medico__c != null) profissionalIds.add(unidade.APP_Medico__c);
                if (unidade.APP_EquipeMulti__c != null) profissionalIds.add(unidade.APP_EquipeMulti__c);
            }

            if (profissionalIds.isEmpty()) return new List<MinimalUserResult>();

            List<MinimalUserResult> result = new List<MinimalUserResult>();

            // 1. Buscar contatos conforme os critérios
            List<Contact> contatos = [
                SELECT Id, Nome_completo__c
                FROM Contact
                WHERE Id IN :profissionalIds
                AND Nome_completo__c LIKE :prefix + '%'
                AND RecordType.DeveloperName IN ('MedicoCorpoClinico', 'APP_EquipeMulti')
                AND APP_Ativo__c = true
                AND APP_AvailableInChat__c = true
                ORDER BY Nome_completo__c
                LIMIT 50
            ];

            // 2. Coletar os IDs dos contatos encontrados
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            for (Contact c : contatos) {
                contactIds.add(c.Id);
                contactMap.put(c.Id, c);
            }

            // 3. Buscar usuários cujo campo texto referencia os contatos
            Set<Id> contactIdsComUser = new Set<Id>();
            for (User u : [
                SELECT Id, APP_ContatoId__c
                FROM User
                WHERE APP_ContatoId__c IN :contactIds
            ]) {
                if (String.isNotBlank(u.APP_ContatoId__c)) {
                    contactIdsComUser.add((Id)u.APP_ContatoId__c);
                }
            }

            // 4. Filtrar os contatos que têm um user associado
            for (Id cid : contactIdsComUser) {
                Contact c = contactMap.get(cid);
                if (c != null) {
                    result.add(new MinimalUserResult(cid, c.Nome_completo__c));
                }
            }

            return result;
        }

        // Se não for paciente, retorna normalmente
        List<MinimalUserResult> defaultResult = new List<MinimalUserResult>();
        
        // 1. Buscar contatos conforme os critérios
        List<Contact> contatos = [
            SELECT Id, Nome_completo__c
            FROM Contact
            WHERE Nome_completo__c LIKE :prefix + '%'
            AND RecordType.DeveloperName IN ('MedicoCorpoClinico', 'APP_EquipeMulti')
            AND APP_Ativo__c = true
            AND APP_AvailableInChat__c = true
            ORDER BY Nome_completo__c
            LIMIT 50
        ];

        // 2. Coletar os IDs dos contatos encontrados
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact c : contatos) {
            contactIds.add(c.Id);
            contactMap.put(c.Id, c);
        }

        // 3. Buscar usuários cujo campo texto referencia os contatos
        Set<Id> contactIdsComUser = new Set<Id>();
        for (User u : [
            SELECT Id, APP_ContatoId__c
            FROM User
            WHERE APP_ContatoId__c IN :contactIds
        ]) {
            if (String.isNotBlank(u.APP_ContatoId__c)) {
                contactIdsComUser.add((Id)u.APP_ContatoId__c);
            }
        }

        // 4. Filtrar os contatos que têm um user associado
        for (Id cid : contactIdsComUser) {
            Contact c = contactMap.get(cid);
            if (c != null) {
                defaultResult.add(new MinimalUserResult(cid, c.Nome_completo__c));
            }
        }

        return defaultResult;
    }

    public class MinimalUserResult {
        @AuraEnabled public String id;
        @AuraEnabled public String name;

        public MinimalUserResult(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }
}