public with sharing class WppMensagemContatoIntegracao {
	
    @InvocableMethod
    public static void integraMensagemMedico(List<Id> listaContatoId){
        String mensagemErro = 'nenhum erro';
        try{

            Contact contato = [SELECT Id, MobilePhone FROM Contact WHERE Id = :listaContatoId[0]];

            boolean isSandbox = [SELECT Id, IsSandbox FROM Organization].IsSandbox;
			String telefone = TakeBlipServiceUtils.telefoneFormat(contato.MobilePhone);
            
            //Verifica WhatsApp take blip
            String retornoVerificaWpp = TakeBlipService.verificarWhatsBlip(telefone, isSandbox);
			if(retornoVerificaWpp.contains('Erro')) mensagemErro = retornoVerificaWpp;
            if(mensagemErro == 'nenhum erro'){
                //Envia Mensagem Takeblip
                String retornoMensagem = TakeBlipService.enviaMensagemBlip(retornoVerificaWpp, isSandbox);
                if(retornoMensagem.contains('Erro')) mensagemErro = retornoMensagem;
                if(mensagemErro == 'nenhum erro'){
                    //Direciona para o ChatBot
                    String retornoChatBot = TakeBlipService.direcionarChatBot(retornoVerificaWpp, isSandbox);
                    if(retornoChatBot.contains('Erro')) mensagemErro = retornoChatBot;
                    if(mensagemErro == 'nenhum erro'){
                        //Direciona para o bloco do Bot
                        String retornoBlocoBot = TakeBlipService.direcionarBlocoBot(retornoVerificaWpp, isSandbox);
                        if(retornoBlocoBot.contains('Erro')) mensagemErro = retornoBlocoBot;    
                    }
                }           
            }
            
            //Atualiza o contato
            Contact con = new Contact(Id = listaContatoId[0]);
            con.StatusIntegracaoMensagem__c = (mensagemErro == 'nenhum erro' ? 'Integrado com Sucesso' : mensagemErro);
            update con;
        }catch(Exception e){
            Contact con = new Contact(Id = listaContatoId[0]);
            con.StatusIntegracaoMensagem__c = 'Erro Apex: ' + e.getMessage();
            update con;
        }
    }

}