public with sharing class APP_MFAController {
    @AuraEnabled
    public static Boolean validateToken(String token) {
        // Troque por validação real (ex: buscar em um objeto customizado ou cache)
        String expectedToken = '123456';
        return token == expectedToken;
    }
}