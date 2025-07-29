public abstract class ServiceBase {
	// Esta classe possui um conjunto de métodos que auxiliam na chamada de serviços HTTP

	public Map<String, String> gerarHeaderOAuth2(String headerAutorizacao) {
		Map<String, String> header = new Map<String, String>();
		header.put('Content-Type', 'application/json');
		header.put('Accept', 'application/json');

		if (String.isNotBlank(headerAutorizacao)) {
			header.put('Authorization', headerAutorizacao);
		}

		return header;
	}

	public Servico__mdt getServico(String developerName) {
		Servico__mdt result;

		List<Servico__mdt> servicos = [
			SELECT Id, Endpoint__c, Endpoint_Sandbox__c, Metodo__c, DeveloperName, username__c, password__c, Ativo__c,Token__c
			FROM Servico__mdt
			WHERE DeveloperName = :developerName
		];

		if (servicos.size() > 0) {
			result = servicos.get(0);
		}

		return result;
	}

	public HttpRequest makeHttpRequest(String endPoint, String method, Map<String, String> headers, String body, Integer timeout) {
		HttpRequest request = new HttpRequest();

		request.setEndpoint(endPoint);
		request.setMethod(method);
		request.setTimeout(timeout);

		//Gera body = '' apenas para o método POST
		if (method == 'POST' || method == 'PUT')
			request.setBody(body != null ? body : '');
		else if (body != null)
			request.setBody(body);

		for (String nomeHeader : headers.keySet()) {
			request.setHeader(nomeHeader, headers.get(nomeHeader));
		}

		return request;
	}

	public HttpResponse sendRequest(String endPoint, String method, Map<String, String> headers, String body, Integer timeout) {
		return new Http().send(this.makeHttpRequest(endPoint, method, headers, body, timeout));
	}
}