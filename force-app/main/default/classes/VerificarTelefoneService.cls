public class VerificarTelefoneService extends ServiceBase{
    public class verificarTelefoneException extends Exception{
        
    }
	public VerificarTelefoneEntity.Retorno verificarTelefone(string requestBody) {
		VerificarTelefoneEntity.Retorno result;

        try {
            Servico__mdt TelefoneService = getServico('ValidacaoTelefoneBlip');

            if (!String.isBlank(requestBody)) {
				HttpRequest httpRequest = makeHttpRequest(
					isSandBox() ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c,
					TelefoneService.Metodo__c,
					gerarHeaderOAuth2(TelefoneService.Token__c),
					requestBody,
					60000
				);

				HttpResponse httpResponse = new Http().send(httpRequest);

				if (httpResponse.getStatusCode() == 200) {
					result = (VerificarTelefoneEntity.Retorno) JSON.deserialize(
						httpResponse.getBody(),
						VerificarTelefoneEntity.Retorno.class
					);
					System.debug('ValidacaoTelefoneBlip Response => ' + JSON.serialize(httpResponse.getBody(),true));
				} else {
					throw new verificarTelefoneException(
						'Erro no serviço : ValidacaoTelefoneBlip : \nRequest : ' +
						httpRequest.getBody() +
						', \nResponse : ' +
						JSON.serializePretty(httpResponse.getBody())
					);
				}
			}
        }catch (Exception e) {
			System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());  
			// EmailAlertaErro.enviaEmailErro(e, 'DSExpermed', 'ExpermedIntegrationService', false);
		}
		return result;
	}
    
    public void EnvioMensagem(string requestBody) {

        try {
            Servico__mdt TelefoneService = getServico('EnvioMensagemBlip');

            if (!String.isBlank(requestBody)) {
				HttpRequest httpRequest = makeHttpRequest(
					isSandBox() ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c,
					TelefoneService.Metodo__c,
					gerarHeaderOAuth2(TelefoneService.Token__c),
					requestBody,
					60000
				);

				HttpResponse httpResponse = new Http().send(httpRequest);

				if (httpResponse.getStatusCode() == 202) {
					System.debug('EnvioMensagemBlip Response => ' + JSON.serialize(httpResponse.getBody(),true));
				} else {
					throw new verificarTelefoneException(
						'Erro no serviço : EnvioMensagemBlip : \nRequest : ' +
						httpRequest.getBody() +
						', \nResponse : ' +
						JSON.serializePretty(httpResponse.getBody())
					);
				}
			}
        }catch (Exception e) {
			System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());  
			// EmailAlertaErro.enviaEmailErro(e, 'DSExpermed', 'ExpermedIntegrationService', false);
		}
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