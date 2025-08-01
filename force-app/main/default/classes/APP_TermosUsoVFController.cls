public with sharing class APP_TermosUsoVFController {
    public Boolean mostrarTermoUso { get; set; }
    public Boolean mostrarPoliticaPrivacidade { get; set; }
    public String conteudoTermo { get; set; }
    public String conteudoPolitica { get; set; }
    public Boolean aceiteMarcado { get; set; }
    public String checkboxLabel { get; set; }
    public Boolean exibirTermos { get; set; } // Novo campo para controle de exibição
    public String startUrl { get; private set; }

    public APP_TermosUsoVFController() {
        this.startUrl = ApexPages.currentPage().getParameters().get('startURL');
        this.aceiteMarcado = false;
        this.checkboxLabel = 'Declaro que li e aceito os termos acima.';
        this.exibirTermos = true; // Inicialmente verdadeiro

        // Verifica se o usuário já aceitou os termos
        verificarAceitePrevio();
        
        // Se não precisa exibir termos, redireciona imediatamente
        if(!exibirTermos) {
            return;
        }

        // Carrega os termos apenas se for necessário exibi-los
        carregarTermos();
    }

    private void verificarAceitePrevio() {
        Id userId = UserInfo.getUserId();
        List<String> tiposTermos = new List<String>{'Termo e Condições de Uso', 'Política de Privacidade'};

        // Busca os termos mais recentes de cada tipo
        List<APP_Term__c> termosRecentes = [
            SELECT Id, Term_Type__c
            FROM APP_Term__c
            WHERE Is_Active__c = true AND Term_Type__c IN :tiposTermos
            ORDER BY Term_Type__c, Version__c DESC
        ];

        // Mapeia os termos mais recentes por tipo
        Map<String, Id> termosPorTipo = new Map<String, Id>();
        for(APP_Term__c termo : termosRecentes) {
            if(!termosPorTipo.containsKey(termo.Term_Type__c)) {
                termosPorTipo.put(termo.Term_Type__c, termo.Id);
            }
        }

        // Verifica se existem acordos para os termos mais recentes
        if(!termosPorTipo.isEmpty()) {
            List<APP_Term_Agreement__c> acordos = [
                SELECT Id, Term__c
                FROM APP_Term_Agreement__c
                WHERE User__c = :userId AND Term__c IN :termosPorTipo.values()
            ];

            // Verifica se todos os termos foram aceitos
            Set<Id> termosAceitos = new Set<Id>();
            for(APP_Term_Agreement__c acordo : acordos) {
                termosAceitos.add(acordo.Term__c);
            }

            // Se todos os termos atuais foram aceitos, não precisa exibir
            this.exibirTermos = termosAceitos.size() < termosPorTipo.size();
        }
    }

    private void carregarTermos() {
        try {
            List<APP_Term__c> termos = [
                SELECT Id, Term_Content__c, Term_Type__c, Version__c
                FROM APP_Term__c
                WHERE Is_Active__c = true 
                AND Term_Type__c IN ('Termo e Condições de Uso', 'Política de Privacidade')
                ORDER BY Term_Type__c, Version__c DESC
                LIMIT 100
            ];

            Map<String, APP_Term__c> termosPorTipo = new Map<String, APP_Term__c>();
            for (APP_Term__c termo : termos) {
                if (!termosPorTipo.containsKey(termo.Term_Type__c)) {
                    termosPorTipo.put(termo.Term_Type__c, termo);
                }
            }

            this.mostrarTermoUso = termosPorTipo.containsKey('Termo e Condições de Uso');
            this.mostrarPoliticaPrivacidade = termosPorTipo.containsKey('Política de Privacidade');

            this.conteudoTermo = mostrarTermoUso ? termosPorTipo.get('Termo e Condições de Uso').Term_Content__c : '';
            this.conteudoPolitica = mostrarPoliticaPrivacidade ? termosPorTipo.get('Política de Privacidade').Term_Content__c : '';

        } catch(Exception e) {
            System.debug('Erro ao carregar termos: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erro ao carregar os termos de uso.'));
        }
    }

    public PageReference aceitarTermos() {
        if (!aceiteMarcado) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'É necessário aceitar os termos para continuar.'));
            return null;
        }

        try {
            Id userId = UserInfo.getUserId();
            List<String> tiposTermos = new List<String>();
            
            if (mostrarTermoUso) tiposTermos.add('Termo e Condições de Uso');
            if (mostrarPoliticaPrivacidade) tiposTermos.add('Política de Privacidade');

            if (!tiposTermos.isEmpty()) {
                List<APP_Term__c> termos = [
                    SELECT Id, Term_Content__c, Version__c, Term_Type__c
                    FROM APP_Term__c
                    WHERE Is_Active__c = true AND Term_Type__c IN :tiposTermos
                    ORDER BY Version__c DESC
                    LIMIT 100
                ];

                Map<String, APP_Term__c> termosMaisRecentes = new Map<String, APP_Term__c>();
                for (APP_Term__c termo : termos) {
                    if (!termosMaisRecentes.containsKey(termo.Term_Type__c)) {
                        termosMaisRecentes.put(termo.Term_Type__c, termo);
                    }
                }

                List<APP_Term_Agreement__c> acordos = new List<APP_Term_Agreement__c>();
                for (APP_Term__c termo : termosMaisRecentes.values()) {
                    String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', 
                        Blob.valueOf(termo.Term_Content__c + userId)));
                    
                    acordos.add(new APP_Term_Agreement__c(
                        User__c = userId,
                        Term__c = termo.Id,
                        Accepted_DateTime__c = Datetime.now(),
                        Accepted_User__c = hash,
                        Version__c = termo.Version__c
                    ));
                }

                if (!acordos.isEmpty()) {
                    insert acordos;
                }
            }

            if (String.isNotBlank(this.startUrl)) {
                return Auth.SessionManagement.finishLoginFlow(this.startUrl);
            } else {
                return Auth.SessionManagement.finishLoginFlow();
            }

        } catch(DmlException e) {
            System.debug('Erro ao registrar aceite: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erro ao registrar o aceite dos termos.'));
            return null;
        } catch(Exception e) {
            System.debug('Erro geral: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ocorreu um erro inesperado.'));
            return null;
        }
    }

    public PageReference sair() {
        PageReference logoutPage = new PageReference('/secur/logout.jsp');
        logoutPage.setRedirect(true);
        return logoutPage;
    }

    // Método para redirecionamento caso não precise aceitar termos
    public PageReference redirecionarSeNaoPrecisaAceitar() {
        if(!exibirTermos) {
            if (String.isNotBlank(this.startUrl)) {
                return Auth.SessionManagement.finishLoginFlow(this.startUrl);
            } else {
                return Auth.SessionManagement.finishLoginFlow();
            }
        }
        return null;
    }
}