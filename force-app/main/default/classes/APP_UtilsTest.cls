@IsTest
private class APP_UtilsTest {
    
    @IsTest
    static void testStatusCodeExists() {
        // Testa código 200
        String result200 = APP_Utils.getStatusDescription(200);
        System.assertEquals('OK', result200, 'Descrição do status 200 incorreta');

        // Testa código 404
        String result404 = APP_Utils.getStatusDescription(404);
        System.assertEquals('Not Found', result404, 'Descrição do status 404 incorreta');

        // Testa código 503
        String result503 = APP_Utils.getStatusDescription(503);
        System.assertEquals('Service Unavailable', result503, 'Descrição do status 503 incorreta');
    }
    
    @IsTest
    static void testStatusCodeUnknown() {
        // Testa um código inexistente
        String result = APP_Utils.getStatusDescription(999);
        System.assertEquals('Unknown Status Code', result, 'Deveria retornar descrição padrão para código desconhecido');
    }
}