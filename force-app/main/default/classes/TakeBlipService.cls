public with sharing class TakeBlipService {

    public static String verificarWhatsBlip(String telefone, boolean isSandbox){

        Servico__mdt TelefoneService = [SELECT Id, Endpoint__c, Endpoint_Sandbox__c, Metodo__c, DeveloperName, username__c, password__c, Ativo__c,Token__c
                                        FROM Servico__mdt
                                        WHERE DeveloperName = 'ValidacaoWhatsMsgAtivaBlip' limit 1];
        
        //monta body da requisição
        Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
        TakeBlipServiceUtils.verificaWhatsappReq bodyReq = new TakeBlipServiceUtils.verificaWhatsappReq();
        bodyReq.id = string.valueof(IntrandomNumber);
        bodyReq.to = 'postmaster@wa.gw.msging.net';
        bodyReq.method = 'get';
        bodyReq.uri = 'lime://wa.gw.msging.net/accounts/+55' + telefone;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(isSandbox ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c);
        request.setMethod(TelefoneService.Metodo__c);
        request.setHeader('Authorization', telefoneService.Token__c);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json.serialize(bodyReq));
        request.setTimeout(120000);

        HttpResponse Response = new Http().send(request);
        String resposta = response.getBody();
        
        if(Response.getStatusCode() == 200){
            TakeBlipServiceUtils.verificaWhatsappResp retorno = (TakeBlipServiceUtils.verificaWhatsappResp) JSON.deserialize(resposta, TakeBlipServiceUtils.verificaWhatsappResp.class);
            if(retorno.status == 'success') return retorno.Resource.identity;
            else return 'Erro verificarWhatsBlip: ' +  Response.getBody();
        }
        else{
            return Response.getStatusCode() + ' Erro verificarWhatsBlip: ' +  Response.getBody();
        }
    }

    public static String enviaMensagemBlip(String identity, boolean isSandbox){

        Servico__mdt TelefoneService = [SELECT Id, Endpoint__c, Endpoint_Sandbox__c, Metodo__c, DeveloperName, username__c, password__c, Ativo__c,Token__c
                                        FROM Servico__mdt
                                        WHERE DeveloperName = 'EnvioMensagemMsgAtivaBlip' AND Ativo__c = true limit 1];
        
        MensagemWhatsApp__mdt mensagemMedico = [SELECT Id, Parametro__c FROM MensagemWhatsApp__mdt WHERE DeveloperName = 'RelacionamentoMedico'];

        //Monta o Body da requisição
        Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
        
        List<TakeBlipServiceUtils.Components> listaComponents = new List<TakeBlipServiceUtils.Components>();
        TakeBlipServiceUtils.Components comp = new TakeBlipServiceUtils.Components();
        comp.type = 'body';
        listaComponents.add(comp);

        TakeBlipServiceUtils.Language lang = new TakeBlipServiceUtils.Language();
        lang.code = 'pt_BR';
        lang.policy = 'deterministic';
        
        TakeBlipServiceUtils.Template temp = new TakeBlipServiceUtils.Template();
        temp.namespace = '8cd8ec1c_60df_ce96_3eef_ec7d6763adc0';
        temp.name = mensagemMedico.Parametro__c;
        temp.language = lang;
        temp.components = listaComponents;

        TakeBlipServiceUtils.Content cont = new TakeBlipServiceUtils.Content();
        cont.type = 'template';
        cont.template = temp;

        TakeBlipServiceUtils.EnviaMensagemReq bodyReq = new TakeBlipServiceUtils.EnviaMensagemReq();
        bodyReq.id = string.valueof(IntrandomNumber);
        bodyReq.to = identity;
        bodyReq.type = 'application/json';
        bodyReq.content = cont;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(isSandbox ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c);
        request.setMethod(TelefoneService.Metodo__c);
        request.setHeader('Authorization', TelefoneService.Token__c);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json.serialize(bodyReq));
        request.setTimeout(120000);

        HttpResponse Response = new Http().send(request);
        String resposta = response.getBody();

        if(Response.getStatusCode() == 202){
            return 'Mensagem enviada';
        }else{
            return 'Erro enviaMensagemBlip:' + resposta;
        }
    }

    public static String direcionarChatBot(String identity, boolean isSandbox){
        
        Servico__mdt TelefoneService = [SELECT Id, Endpoint__c, Endpoint_Sandbox__c, Metodo__c, DeveloperName, username__c, password__c, Ativo__c,Token__c
                                        FROM Servico__mdt
                                        WHERE DeveloperName = 'direcionarChatBotBlip' AND Ativo__c = true limit 1];
        
        //Monta o Body da requisição
        Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
        
        TakeBlipServiceUtils.direcionarChatReq bodyReq = new TakeBlipServiceUtils.direcionarChatReq();
        bodyReq.id = String.valueOf(IntrandomNumber);
        bodyReq.method = 'set';
        bodyReq.to = 'postmaster@msging.net';
        bodyReq.uri = '/contexts/' + identity + '/Master-State';
        bodyReq.type = 'text/plain';
        bodyReq.resource = 'transbordocentralmeddev1@msging.net';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(isSandbox ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c);
        request.setMethod(TelefoneService.Metodo__c);
        request.setHeader('Authorization', TelefoneService.Token__c);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json.serialize(bodyReq));
        request.setTimeout(120000);
       
        HttpResponse Response = new Http().send(request);
        String resposta = response.getBody();
        
        if(Response.getStatusCode() == 200){
            TakeBlipServiceUtils.direcionarChatResp retorno = (TakeBlipServiceUtils.direcionarChatResp) JSON.deserialize(resposta, TakeBlipServiceUtils.direcionarChatResp.class);
            if(retorno.status == 'success') return 'Sucesso';
            else return Response.getStatusCode() + ' Erro direcionarChatBot: ' + resposta;
        }else{
            return Response.getStatusCode() + ' Erro verificarWhatsBlip: ' +  Response.getBody();
        }
    }

    public static String direcionarBlocoBot(String identity, boolean isSandbox){
        Servico__mdt TelefoneService = [SELECT Id, Endpoint__c, Endpoint_Sandbox__c, Metodo__c, DeveloperName, username__c, password__c, Ativo__c,Token__c
                                        FROM Servico__mdt
                                        WHERE DeveloperName = 'direcionarBlocoBlip' AND Ativo__c = true limit 1];

        
        //Monta o Body da requisição
        Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
        
        TakeBlipServiceUtils.direcionarChatReq bodyReq = new TakeBlipServiceUtils.direcionarChatReq();
        bodyReq.id = String.valueOf(IntrandomNumber);
        bodyReq.method = 'set';
        bodyReq.to = 'postmaster@msging.net';
        bodyReq.uri = '/contexts/' + identity + '/stateid%40daeafb3d-637c-428e-bca9-6b1ec7ba1061';
        bodyReq.type = 'text/plain';
        bodyReq.resource = '58e4ae59-882d-4d23-8588-7770180c37e9';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(isSandbox ? TelefoneService.Endpoint_Sandbox__c : TelefoneService.Endpoint__c);
        request.setMethod(TelefoneService.Metodo__c);
        request.setHeader('Authorization', TelefoneService.Token__c/*'Key cm91dGVyY2VudHJhbG1lZGljb3NkZXY6SzFDZWlhbHExSlJJMEIzZTJ1ck0='*/);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json.serialize(bodyReq));
        request.setTimeout(120000);
       
        HttpResponse Response = new Http().send(request);
        String resposta = response.getBody();
        
        if(Response.getStatusCode() == 200){
            TakeBlipServiceUtils.direcionarBlocoResp retorno = (TakeBlipServiceUtils.direcionarBlocoResp) JSON.deserialize(resposta, TakeBlipServiceUtils.direcionarBlocoResp.class);
            if(retorno.status == 'success') return 'Sucesso';
            else return Response.getStatusCode() + ' Erro direcionarBlocoBot: ' + resposta;
        }else{
            return Response.getStatusCode() + ' Erro direcionarBlocoBot: ' +  Response.getBody();
        }
    }
}