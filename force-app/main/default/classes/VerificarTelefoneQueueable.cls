public class VerificarTelefoneQueueable implements Queueable, Database.AllowsCallouts {
    
	private map<Id,Account> accountMap;
    
    public VerificarTelefoneQueueable(map<Id,Account> accountMap){
        this.accountMap = accountMap;
    }
    
    public void execute(QueueableContext context){
        Id idConta;
        for(Id idAcc : accountMap.keyset()){
            idConta = idAcc;
            break;
        }
        try{
            Account acc = accountMap.get(idConta);
            VerificarTelefoneEntity.Telefone entidade = new VerificarTelefoneEntity.Telefone();
            verificarTelefoneService service = new verificarTelefoneService();
            Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
            entidade.id = string.valueof(IntrandomNumber);
            entidade.to = 'postmaster@wa.gw.msging.net';
            entidade.method = 'get';
            entidade.uri = 'lime://wa.gw.msging.net/accounts/+55'+telefoneFormat(acc.PersonAssistantPhone);
            VerificarTelefoneEntity.Retorno retorno = service.verificarTelefone(JSON.serialize(entidade));
            
            if(retorno != null){
                acc.logIntegracaoVerificacaoWhatsApp__c = JSON.serialize(retorno);
                acc.StatusVerificacaoWhatsApp__c = retorno.status; 
                if(retorno.status == 'success'){
                    envioMensagem(acc);
                }else{
                    system.debug('falha no envio de mensagem');
                }
            }else{
                acc.logIntegracaoVerificacaoWhatsApp__c = 'Sem retorno do serviço';
                acc.StatusVerificacaoWhatsApp__c = ''; 
            }
            acc.UltimaIntegracaoBlip__c = DateTime.now();
            update acc;
        }catch(Exception e){
            //Account acc = accountMap.get(idConta);
            //acc.deuErro__c = true;
            //acc.MsgErro__c = e.getMessage();
            //update acc;
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());
        }finally{
            accountMap.remove(idConta);
            if(!accountMap.isEmpty()){
                System.enqueueJob(new VerificarTelefoneQueueable(accountMap));
            }
        }
    }
    public static void envioMensagem(Account conta){
        
        verificarTelefoneService service = new verificarTelefoneService();
        Integer IntrandomNumber = Integer.valueOf((Math.random() * 1000));
        
        VerificarTelefoneEntity.EnvioMensagem entidadeEnvio = new VerificarTelefoneEntity.EnvioMensagem();
        entidadeEnvio.id = string.valueof(IntrandomNumber);
        entidadeEnvio.to = '55'+telefoneFormat(conta.PersonAssistantPhone)+'@wa.gw.msging.net';
        entidadeEnvio.Content = new VerificarTelefoneEntity.Content();
        entidadeEnvio.content.template = new VerificarTelefoneEntity.Template();
        entidadeEnvio.content.template.components = new List<VerificarTelefoneEntity.Components>();
        entidadeEnvio.content.template.language = new VerificarTelefoneEntity.Language();
        
        VerificarTelefoneEntity.Components dadosComponents = new VerificarTelefoneEntity.Components();
        dadosComponents.parameters = new List<VerificarTelefoneEntity.Parameters>(); 
        
        VerificarTelefoneEntity.Parameters dadosParameters = new VerificarTelefoneEntity.Parameters();
        dadosParameters.text = conta.Id;
        
        dadosComponents.parameters.add(dadosParameters);
        entidadeEnvio.content.template.components.add(dadosComponents);
        
        system.debug('JSON entidadeEnvio' + JSON.serialize(entidadeEnvio));        
        
        system.debug(entidadeEnvio.to);
        
        service.EnvioMensagem(JSON.serialize(entidadeEnvio));
        
    }
    
    public static String telefoneFormat(String telefone){
        String telefoneFormatado = removeSpecialCaracters(telefone);
        //criar um logica pra verificar se tem 55 no comneço se nao tiver passa o telefone formatado  
        if(telefoneFormatado.substring(0,1) == '5' && telefoneFormatado.substring(1,2) == '5'){
            telefoneFormatado = telefoneFormatado.substring(2,telefoneFormatado.length());
        }
        
        return telefoneFormatado;
    }
    
    private static string removeSpecialCaracters(string str){
        system.debug(str);
        String s = str.replaceAll('[^a-zA-Z0-9\\s+]', '');
        
        s = s.replace('-', '');
        
        return s.replace(' ', '');
        
    }
}