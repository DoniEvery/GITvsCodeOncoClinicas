public class APP_ExceptionHelper {

    public static APP_Exception lancarELogar(String endpoint, Integer statusCode, String mensagem, String responseBody) {
        try {
            APP_Logger.logErro(endpoint, statusCode, mensagem, responseBody);
        } catch (Exception logEx) {
            System.debug('Erro ao tentar registrar log: ' + logEx.getMessage());
        }
        return new APP_Exception(endpoint, statusCode, mensagem, responseBody);
    }
}