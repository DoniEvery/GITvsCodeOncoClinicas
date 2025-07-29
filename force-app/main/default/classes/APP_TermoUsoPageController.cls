public without sharing class APP_TermoUsoPageController {
    public static final String TIPO_TERMO_CONDICOES = 'Termo e Condições de Uso';
    public static final String TIPO_POLITICA_PRIVACIDADE = 'Política de Privacidade';

    @AuraEnabled(cacheable=true)
    public static Boolean precisaAceitarTermo() {
        Id userId = UserInfo.getUserId();

        List<String> tipos = new List<String>{ TIPO_TERMO_CONDICOES, TIPO_POLITICA_PRIVACIDADE };

        List<APP_Term__c> termos = [
            SELECT Id, Version__c, Term_Type__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c IN :tipos
            ORDER BY Term_Type__c, Version__c DESC
        ];

        if (termos.isEmpty()) {
            return true;
        }

        // Agrupar os termos mais recentes por tipo
        Map<String, APP_Term__c> termosMaisRecentesPorTipo = new Map<String, APP_Term__c>();
        for (APP_Term__c termo : termos) {
            if (!termosMaisRecentesPorTipo.containsKey(termo.Term_Type__c)) {
                termosMaisRecentesPorTipo.put(termo.Term_Type__c, termo);
            }
        }

        List<Id> idsTermosRecentes = new List<Id>();
        for (APP_Term__c termo : termosMaisRecentesPorTipo.values()) {
            idsTermosRecentes.add(termo.Id);
        }

        List<APP_Term_Agreement__c> acordos = [
            SELECT Id, Term__c
            FROM APP_Term_Agreement__c
            WHERE User__c = :userId AND Term__c IN :idsTermosRecentes
        ];

        // Verifica se o usuário aceitou todos os termos mais recentes
        Set<Id> termosAceitos = new Set<Id>();
        for (APP_Term_Agreement__c acordo : acordos) {
            termosAceitos.add(acordo.Term__c);
        }

        for (Id termoId : idsTermosRecentes) {
            if (!termosAceitos.contains(termoId)) {
                return true; // Ainda falta aceitar pelo menos um termo
            }
        }

        return false; // Todos os termos aceitos
    }

    @AuraEnabled
    public static void registrarAceite(List<String> tiposTermos) {
        Id userId = UserInfo.getUserId();

        if (tiposTermos == null || tiposTermos.isEmpty()) {
            throw new AuraHandledException('Nenhum tipo de termo informado.');
        }

        List<APP_Term__c> termos = [
            SELECT Id, Term_Content__c, Version__c, Term_Type__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c IN :tiposTermos
            ORDER BY Version__c DESC
        ];

        if (termos.isEmpty()) {
            throw new AuraHandledException('Nenhum termo ativo encontrado.');
        }

        List<APP_Term_Agreement__c> acordos = new List<APP_Term_Agreement__c>();

        for (APP_Term__c termo : termos) {
            String conteudoParaHash = termo.Term_Content__c + userId;
            Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(conteudoParaHash));
            String hashBase64 = EncodingUtil.base64Encode(hashBlob);

            APP_Term_Agreement__c aceite = new APP_Term_Agreement__c(
                User__c = userId,
                Term__c = termo.Id,
                Accepted_DateTime__c = Datetime.now(),
                Accepted_User__c = hashBase64,
                Version__c = termo.Version__c
            );

            acordos.add(aceite);
        }

        insert acordos;
    }

    @AuraEnabled(cacheable=true)
    public static String obterConteudoTermo() {
        List<APP_Term__c> termos = [
            SELECT Term_Content__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c = 'Termo e Condições de Uso'
            ORDER BY Version__c DESC
            LIMIT 1
        ];

        if (termos.isEmpty()) {
            return 'Termo de uso não disponível.';
        }

        return termos[0].Term_Content__c;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> obterTermosPendentes() {
        Id userId = UserInfo.getUserId();
        Map<String, Boolean> resultado = new Map<String, Boolean>{
            'Termo e Condições de Uso' => false,
            'Política de Privacidade' => false
        };

        List<APP_Term__c> termos = [
            SELECT Id, Term_Type__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c IN ('Termo e Condições de Uso', 'Política de Privacidade')
            ORDER BY Version__c DESC
        ];

        for (APP_Term__c termo : termos) {
            if (!resultado.containsKey(termo.Term_Type__c)) continue;

            List<APP_Term_Agreement__c> acordos = [
                SELECT Id
                FROM APP_Term_Agreement__c
                WHERE User__c = :userId AND Term__c = :termo.Id
                LIMIT 1
            ];

            if (acordos.isEmpty()) {
                resultado.put(termo.Term_Type__c, true);
            }
        }

        return resultado;
    }
    @AuraEnabled(cacheable=true)
    public static String obterConteudoPolitica() {
        List<APP_Term__c> termos = [
            SELECT Term_Content__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c = 'Política de Privacidade'
            ORDER BY Version__c DESC
            LIMIT 1
        ];

        if (termos.isEmpty()) {
            return 'Política de privacidade não disponível.';
        }

        return termos[0].Term_Content__c;
    }

}