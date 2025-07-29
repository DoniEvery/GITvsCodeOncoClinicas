public with sharing class APP_Logger {

    public static void logErro(String endpoint, Integer statusCode, String mensagem, String body) {
        System.debug('### LOG DE ERRO ###');
        System.debug('Endpoint: ' + endpoint);
        System.debug('StatusCode: ' + statusCode);
        System.debug('Mensagem: ' + mensagem);
        System.debug('Body: ' + body);
        try {
            Log__c log = new Log__c();
            log.TipoLog__c = 'APP';
            log.APP_Body__c = body;
            log.APP_Endpoint__c = endpoint;
            log.APP_StatusCode__c = statusCode;
            log.APP_ReturnMessage__c = mensagem;
            log.APP_StatusDscription__c = mensagem;
            insert log;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Erro ao salvar log no APP_Logs__c: ' + e.getMessage());
        }
    }
}