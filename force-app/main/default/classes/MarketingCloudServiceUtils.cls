public without sharing class MarketingCloudServiceUtils {

    public class MarketingCloudHttpRequest {
        public String endpoint;
        public String method;
        public Map<String, String> headers;
        public String body;
        public Integer timeout;
    }

    //Request
    public class RequestBody{
        public To to;
    }

    public class To{
        public String Address;
        public String SubscriberKey;
        public ContactAtt ContactAttributes;
    }

    public class ContactAtt{
        public Subscriber SubscriberAttributes;
    }

    public class Subscriber{
        public String PrimeiroNome;
        public String NumeroProtocolo;
        public String DataEnvio;
    }

    //Response
    public class responseEmailAlt{
        public Integer statusCode;
        public String mensagemErro;
        public String requestId;
        public List<Responses> responses;
    }

    public class Responses{
        public String recipientSendId;
        public boolean hasErrors;
        public List<String> messages;
    }

    /* -------------------------------------------------------------------------- */
    /*                             Busca E-mails                                  */
    /* -------------------------------------------------------------------------- */ 

    public static String createRetrieveDataExtensionBody(String token, List<String> fields, String dataExtension, String idRegistro, Date dataInicial, Date dataFinal){
        Datetime dtDataInicial = DateTime.newInstance(dataInicial.year(), dataInicial.month(),dataInicial.day());
        Datetime dtDataFinal = DateTime.newInstance(dataFinal.year(), dataFinal.month(),dataFinal.day());

        // Cabeçalho da chamada
        String body = ''+
        '<?xml version="1.0" encoding="utf-8"?>'+
        ' <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
        '     <soapenv:Header>'+
        '         <fueloauth>'+ token +'</fueloauth>'+
        '     </soapenv:Header>'+
        '     <soapenv:Body>'+
        '         <RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
        '             <RetrieveRequest>'+
        '                 <ObjectType>DataExtensionObject[' + dataExtension + ']</ObjectType>';

        // Loop dos campos a serem retornados
        for (String field : fields) {
            body += '                 <Properties>' + field + '</Properties>';
        }

        // Inclusão do restante do body
        body += ''+
        '                 <Filter xsi:type="par:ComplexFilterPart" xmlns:par="http://exacttarget.com/wsdl/partnerAPI">'+
        '                     <LeftOperand xsi:type="par:SimpleFilterPart">'+
        '                         <Property>SubscriberKey</Property>'+
        '                         <SimpleOperator>equals</SimpleOperator>'+
        '                         <Value>' + idRegistro + '</Value>'+
        '                     </LeftOperand>'+
        '                     <LogicalOperator>AND</LogicalOperator>'+
        '                     <RightOperand xsi:type="par:SimpleFilterPart">'+
        '                         <Property>Data Envio</Property>'+
        '                         <SimpleOperator>between</SimpleOperator>'+
        '                         <DateValue>' + dtDataInicial.format('yyyy-MM-dd') + '</DateValue>'+
        '                         <DateValue>' + dtDataFinal.format('yyyy-MM-dd') + '</DateValue>'+
        '                     </RightOperand>'+
        '                 </Filter>'+
        '             </RetrieveRequest>'+
        '         </RetrieveRequestMsg>'+
        '     </soapenv:Body>'+
        ' </soapenv:Envelope>';

        return body;
    }

    /* -------------------------------------------------------------------------- */
    /*                      Busca Token                                           */
    /* -------------------------------------------------------------------------- */

    //Response
    public class ResponseToken{
        public String access_Token;
        public String soap_instance_url;
        public String rest_instance_url;
        public String error;
        public String error_Description;
        public Integer statusCode;
    }
}