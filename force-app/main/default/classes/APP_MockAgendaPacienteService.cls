public without sharing class APP_MockAgendaPacienteService {
    @AuraEnabled(cacheable=true)
    public static String buscarAgendaMock() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://f7ad9a2e-b0fa-4d4c-b1cd-096ddc71b2ea.mock.pstmn.io/agenda');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = http.send(req);

        System.debug(res.getStatusCode());
        System.debug(res.getBody());

        try {
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                throw new AuraHandledException('Erro HTTP: ' + res.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar agenda: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String buscarAgendaMedicoMock() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://f6bf08bd-c00d-43ac-b852-ff586b273ea6.mock.pstmn.io/agenda');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = http.send(req);

        System.debug(res.getStatusCode());
        System.debug(res.getBody());

        try {
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                throw new AuraHandledException('Erro HTTP: ' + res.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar agenda: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static APP_Parametro__c buscarParametros() { 
        return [
            SELECT MaximumRetroactivePeriodMonths__c, MaximumFuturePeriodMonths__c 
            FROM APP_Parametro__c 
            WHERE RecordType.DeveloperName = 'Agenda'
            LIMIT 1
        ];
    }
}