public with sharing class MarketingCloudService {

    public class MarketingCloudServiceException extends Exception {}

    /**
     * @description buscarToken description
     * @return   return ResponseToken do Marketing Cloud
     */
    public MarketingCloudServiceUtils.ResponseToken buscarToken(){
        MarketingCloudServiceUtils.ResponseToken responseToken;
        MarketingCloudAcesso__mdt mktData = MarketingCloudAcesso__mdt.getInstance('Marketing_Cloud');
        String bodyToken = 'grant_type=client_credentials&client_secret=' + mktData.client_Secret__c + '&client_id=' + mktData.Client_Id__c;

        Map<String, String> mapHeaders = new Map<String, String>();
        mapHeaders.put('Content-Type', 'application/x-www-form-urlencoded');

        MarketingCloudServiceUtils.MarketingCloudHttpRequest httpRequestParameters = new MarketingCloudServiceUtils.MarketingCloudHttpRequest();
        httpRequestParameters.endpoint = mktData.Endpoint_Token__c;
        httpRequestParameters.method = 'POST'; 
        httpRequestParameters.headers = mapHeaders;
        httpRequestParameters.body = bodyToken;
        httpRequestParameters.timeout = 36000;
        
        try {
            Http http = new Http();
            HttpRequest request = this.makeHttpRequest(httpRequestParameters);
            HttpResponse response = http.send(request);
    
            responseToken = (MarketingCloudServiceUtils.ResponseToken) JSON.deserialize(response.getBody(), MarketingCloudServiceUtils.responseToken.class);
            responseToken.statusCode = response.getStatusCode();
        } catch (Exception e) {
            responseToken.error_Description = e.getMessage(); 
        }

        return responseToken; 
    }

    /**
     * @description Recupera dados de uma Data Extension do Marketing Cloud
     * @param  dataExtension Nome da Data extension
     * @param  fields        Lista de campos a serem recuperados
     * @return               Lista de registros que foram recuperados
     */
    public Object retrieveDataExtension(String dataExtension, List<String> fields, String idRegistro, Date dataInicial, Date dataFinal) {
        Object listReturn;
        MarketingCloudServiceUtils.ResponseToken responseToken = this.buscarToken(); 

        // Valida retorno da coleta do token
        if (responseToken.statusCode != 200) {
            throw new MarketingCloudServiceException(responseToken.error_Description);
        }

        String endpoint = responseToken.soap_instance_url + 'Service.asmx';
        String body = MarketingCloudServiceUtils.createRetrieveDataExtensionBody(responseToken.access_Token, fields, dataExtension, idRegistro, dataInicial, dataFinal);

        Map<String, String> mapHeaders = new Map<String, String>();
        mapHeaders.put('Content-Type', 'text/xml; charset=utf-8');
        mapHeaders.put('SOAPAction', 'Retrieve');

        MarketingCloudServiceUtils.MarketingCloudHttpRequest httpRequestParameters = new MarketingCloudServiceUtils.MarketingCloudHttpRequest();
        httpRequestParameters.endpoint = endpoint;
        httpRequestParameters.method = 'POST'; 
        httpRequestParameters.headers = mapHeaders;
        httpRequestParameters.body = body;
        httpRequestParameters.timeout = 36000;

        HttpRequest request = this.makeHttpRequest(httpRequestParameters);
        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            listReturn = this.mktCloudRetrieveSoapResponse2list(response.getBodyDocument());
        }

        return listReturn;
    }

    /**
     * @description Envia o e-mail alternativo para o MKT Cloud "Trigger de Casos"
     * @param  endpointMkt endpointMkt
     * @param  token       token
     * @param  body        body
     * @return             Retorno dos dados utilizado o struct MarketingCloudServiceUtils.responseEmailAlt
     */
    public MarketingCloudServiceUtils.responseEmailAlt insereEmailAlternativoExtension(String endpointMkt, String token, String body){
        
        String endpointUrl = endpointMkt + 'messaging/v1/messageDefinitionSends/key:VALTECHDEVTRIGGERED/send';
        Map<String, String> mapHeaders = new Map<String, String>();
        mapHeaders.put('Content-Type', 'application/json');
        mapHeaders.put('Authorization','Bearer '+ token);        

        MarketingCloudServiceUtils.MarketingCloudHttpRequest httpRequestParameters = new MarketingCloudServiceUtils.MarketingCloudHttpRequest();
        httpRequestParameters.endpoint = endpointUrl;
        httpRequestParameters.method = 'POST'; 
        httpRequestParameters.headers = mapHeaders;
        httpRequestParameters.body = body; 
        httpRequestParameters.timeout = 36000;

        Http http = new Http();
        HttpRequest request = this.makeHttpRequest(httpRequestParameters);
        HttpResponse response = http.send(request);
		
        MarketingCloudServiceUtils.responseEmailAlt retornoEmail = new MarketingCloudServiceUtils.responseEmailAlt();
        
        system.debug('response envio: ' + response.getBody());
		
        if(response.getStatusCode() == 202){    
            //Sucesso 
            retornoEmail = (MarketingCloudServiceUtils.responseEmailAlt) JSON.deserialize(response.getBody(), MarketingCloudServiceUtils.responseEmailAlt.class);
            retornoEmail.statusCode = response.getStatusCode();
        }else{
            //Erro envio API
            retornoEmail.statusCode = response.getStatusCode();
            retornoEmail.mensagemErro = 'Erro Enviar E-mail API: \n'+ response.getBody() + '\nStatus Code: ' +  response.getStatusCode();
        }
		
        return retornoEmail;
        
    }

    /**
     * @description Realiza a conversão do resultado em XML em uma Lista de registros com o map dos campos
     * @param  doc Document do XML de retorno do webservice (SOAP)
     * @return     Lista de registros retornados pelo webservice
     */
    private Object mktCloudRetrieveSoapResponse2list(Dom.Document doc) {
        List<Map<String,Object>> listResultValues = new List<Map<String,Object>>();
        Map<String,Object> mapResultValue = new Map<String,Object>();
        Map<String,Object> mapReturnValues = new Map<String, Object>();
        Integer contador = 0;

        Dom.XMLNode address = doc.getRootElement();
        address = address.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        address = address.getChildElement('RetrieveResponseMsg', 'http://exacttarget.com/wsdl/partnerAPI');
        
        for(Dom.XMLNode item : address.getChildElements()) {
            if(item.getName() != 'Results') {
                continue;
            }

            mapResultValue.clear();
            
            Dom.XMLNode results = item.getChildElement('Properties', 'http://exacttarget.com/wsdl/partnerAPI');
            for(Dom.XMLNode result : results.getChildElements()) {
                String field = result.getChildElement('Name', 'http://exacttarget.com/wsdl/partnerAPI').getText();
                String value = result.getChildElement('Value', 'http://exacttarget.com/wsdl/partnerAPI').getText();
                mapResultValue.put(field, value);
            }

            if (!mapResultValue.isEmpty()) {
                listResultValues.add(mapResultValue);
                contador++;
            }
        }

        mapReturnValues.put('results', listResultValues);
        mapReturnValues.put('size', contador);

        return mapReturnValues;
    }

    /**
     * @description Faz a requisição para o webservice
     * @param  httpRequestParameters Parâmetros da requisição
     * @return                       Retorno da chamada (HttpRequest)
     */
    private HttpRequest makeHttpRequest(MarketingCloudServiceUtils.MarketingCloudHttpRequest httpRequestParameters) {
		HttpRequest request = new HttpRequest();

		request.setEndpoint(httpRequestParameters.endpoint);
		request.setMethod(httpRequestParameters.method);
		request.setTimeout(httpRequestParameters.timeout);

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
}