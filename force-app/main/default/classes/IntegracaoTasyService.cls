global without sharing class IntegracaoTasyService { 

    public class IntegracaoTasyServiceException extends Exception {}

    @InvocableMethod(callout=true label='Insere pré-cadastro no Tasy' description='Realiza a inclusão do pré-cadastro no Tasy vinculando o id do Tasy com a conta de pré-cadastro' category='Account')
    global static List<Integer> inserePacienteTasy(List<InserePacienteTasyRequest> requests) {
        IntegracaoTasyServiceUtils.ResponseToken responseToken = IntegracaoTasyService.buscarToken(); 

        // Valida retorno da coleta do token
        if (responseToken.statusCode != 200 && responseToken.statusCode != 201) {
            throw new IntegracaoTasyServiceException(responseToken.errorDescription);
        }

        InserePacienteTasyRequest regScreenFlow = requests[0];
        IntegracaoTasyServiceUtils.Paciente paciente = new IntegracaoTasyServiceUtils.Paciente();
        IntegracaoTasyServiceUtils.Contacts contacts = new IntegracaoTasyServiceUtils.Contacts();

        // Define os dados
        paciente.name = regScreenFlow.nome + ' ' + regScreenFlow.sobrenome;
        paciente.cpf = regScreenFlow.cpf;
        paciente.birthDate = regScreenFlow.dataNascimento;

        if(String.isNotEmpty(regScreenFlow.email)) {
            contacts.value = regScreenFlow.email;
            contacts.type = 'email';
            paciente.contacts = new List<IntegracaoTasyServiceUtils.Contacts>();
            paciente.contacts.add(contacts);
        }

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String dadosIntegracao = isSandbox ? 'CreatePatientSB' : 'CreatePatient';
        IntegracaoTasy__mdt integracaoTasyConfig = IntegracaoTasy__mdt.getInstance(dadosIntegracao);
        Map<String, String> mapHeaders = new Map<String, String>(); 
        mapHeaders.put('Accept', '*/*');
        mapHeaders.put('Content-Type', 'application/json');
        mapHeaders.put('Authorization', 'Bearer ' + responseToken.accessToken);

        IntegracaoTasyServiceUtils.IntegracaoTasyHttpRequest httpRequestParameters = new IntegracaoTasyServiceUtils.IntegracaoTasyHttpRequest();
        httpRequestParameters.endpoint = integracaoTasyConfig.Endpoint__c;
        httpRequestParameters.method   = integracaoTasyConfig.Metodo__c; 
        httpRequestParameters.headers  = mapHeaders;
        httpRequestParameters.body     = JSON.serialize(paciente, true);
        httpRequestParameters.timeout  = Integer.valueOf(integracaoTasyConfig.Timeout__c);
        httpRequestParameters.certificado = integracaoTasyConfig.Certificado__c;
         
        HttpRequest request = IntegracaoTasyService.makeHttpRequest(httpRequestParameters);
        Http http = new Http();
        HttpResponse response = http.send(request);

        if ( (response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null) {
            IntegracaoTasyServiceUtils.ResponsePostPatience responsePostPatience = (IntegracaoTasyServiceUtils.ResponsePostPatience) JSON.deserialize(response.getBody(), IntegracaoTasyServiceUtils.ResponsePostPatience.class);
            System.debug('#######  response.getBody(): ' + response.getBody());

            if (responsePostPatience.errors == null) {
                Account conta = new Account();
                conta.Id = regScreenFlow.accountId;
                conta.RetornoIntegracao__c = 'Codigo Tasy: ' + responsePostPatience.createdId;
                conta.KeyTasy__c = responsePostPatience.createdId;
                conta.IntegrarTasy__c = true;
                update conta;
            } else {
                throw new IntegracaoTasyServiceException(responsePostPatience.errors[0].message);
            }
        } else {
            throw new IntegracaoTasyServiceException('Falha ao realizar a integração do pré-cadastro');
        }

        return new List<Integer>(0);
    }

    public static IntegracaoTasyServiceUtils.ResponseToken buscarToken(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String dadosIntegracao = isSandbox ? 'AuthorizationSB' : 'Authorization';
        IntegracaoTasy__mdt integracaoTasyConfig = IntegracaoTasy__mdt.getInstance(dadosIntegracao);
        String body = '"client_id" : "' + integracaoTasyConfig.client_id__c + '", ' +
                      '"response_type" : "' + integracaoTasyConfig.response_type__c + '", ' +
                      '"scope" : "' + integracaoTasyConfig.scope__c + '", ' +
                      '"provision_key" : "' + integracaoTasyConfig.provision_key__c + '", ' +
                      '"authenticated_userid" : "' + integracaoTasyConfig.authenticated_userid__c + '" ';
                      
        Map<String, String> mapHeaders = new Map<String, String>(); 
        mapHeaders.put('Accept', '*/*');
        mapHeaders.put('Content-Type', 'application/json');

        IntegracaoTasyServiceUtils.IntegracaoTasyHttpRequest httpRequestParameters = new IntegracaoTasyServiceUtils.IntegracaoTasyHttpRequest();
        httpRequestParameters.endpoint = integracaoTasyConfig.Endpoint__c;
        httpRequestParameters.method   = integracaoTasyConfig.Metodo__c; 
        httpRequestParameters.headers  = mapHeaders;
        httpRequestParameters.body     = '{' + body + '}';
        httpRequestParameters.timeout  = Integer.valueOf(integracaoTasyConfig.Timeout__c);
        httpRequestParameters.certificado = integracaoTasyConfig.Certificado__c;

        IntegracaoTasyServiceUtils.ResponseToken responseToken = new IntegracaoTasyServiceUtils.ResponseToken();

        Http http = new Http();
        HttpRequest request = IntegracaoTasyService.makeHttpRequest(httpRequestParameters);
        HttpResponse response = http.send(request);
    
        system.debug('response.getBody(): ' + response.getBody());

        responseToken.statusCode = response.getStatusCode();

        if ( (response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null) {
            Map<String, Object> untypedMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String urlToken = (String) untypedMap.get('redirect_uri');
            responseToken.accessToken = urlToken.substring(urlToken.indexOf('access_token=')+13, urlToken.indexOf('&'));
        }

        return responseToken; 
    }

    public static HttpRequest makeHttpRequest(IntegracaoTasyServiceUtils.IntegracaoTasyHttpRequest httpRequestParameters) {
		HttpRequest request = new HttpRequest();

		request.setEndpoint(httpRequestParameters.endpoint);
		request.setMethod(httpRequestParameters.method);
		request.setTimeout(httpRequestParameters.timeout);
        if (!String.isEmpty(httpRequestParameters.certificado)) {
        	system.debug('httpRequestParameters.certificado: ' + httpRequestParameters.certificado);
	        request.setClientCertificateName(httpRequestParameters.certificado);
        }

		//Gera body = '' apenas para o método POST
		if (httpRequestParameters.method == 'POST' || httpRequestParameters.method == 'PUT') {
			request.setBody(httpRequestParameters.body != null ? httpRequestParameters.body : '');
        } else if (httpRequestParameters.body != null) {
			request.setBody(httpRequestParameters.body);
        }

		for (String nomeHeader : httpRequestParameters.headers.keySet()) {
			request.setHeader(nomeHeader, httpRequestParameters.headers.get(nomeHeader));
		}

		return request;
	}

    global class InserePacienteTasyRequest {
        @InvocableVariable
        global String accountId;

        @InvocableVariable
        global String nome;

        @InvocableVariable
        global String sobrenome;

        @InvocableVariable
        global String cpf;

        @InvocableVariable
        global String email;

        @InvocableVariable
        global Date dataNascimento;
    }

}