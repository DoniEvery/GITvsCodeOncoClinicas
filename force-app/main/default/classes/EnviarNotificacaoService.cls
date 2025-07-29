public class EnviarNotificacaoService extends ServiceBase{
    public class enviarNotificacaoException extends Exception{
        
    }
	public EnviarNotificacaoEntity.Retorno enviarNotificacao(String requestBody) {
		EnviarNotificacaoEntity.Retorno result = new EnviarNotificacaoEntity.Retorno();

        try {
            Servico__mdt enviarNotificacaoService = getServico('enviarNotificacao');
			System.debug('Body=> ' + requestBody);
            if (!String.isBlank(requestBody)) {
				HttpRequest httpRequest = makeHttpRequest(
					isSandBox() ? enviarNotificacaoService.Endpoint_Sandbox__c : enviarNotificacaoService.Endpoint__c,
					enviarNotificacaoService.Metodo__c,
					gerarHeaderOAuth2(enviarNotificacaoService.Token__c),
					requestBody,
					60000
				);

				HttpResponse httpResponse = new Http().send(httpRequest);
				System.debug('getStatusCode=> ' + httpResponse.getStatusCode());
				System.debug('getBodyResponse=> ' + httpResponse.getBody());

				result.statusCode = httpResponse.getStatusCode();
				result.bodyResponse = httpResponse.getBody();
			}
        }catch (Exception e) {
			System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace String: ' + e.getStackTraceString());
		}
		return result;
	}
    public Boolean isSandbox() {
        Boolean isSandbox;
        if (isSandbox == null) {
            List<Organization> mOrg = [SELECT Id, IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
            if (!mOrg.isEmpty()) {
                isSandbox = mOrg.get(0).IsSandbox;
            }
        }
        return isSandbox;
    }

}