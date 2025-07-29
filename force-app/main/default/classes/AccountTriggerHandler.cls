public class AccountTriggerHandler {

    public class IntegracaoTasyServiceException extends Exception {}

    public static void impedirExclusaoConta(List<Account> lstAccount){
        Map<String, Bloqueio_Perfil_Exclusao_Conta_Contato__mdt> mapPerfisBloqueio = Bloqueio_Perfil_Exclusao_Conta_Contato__mdt.getAll();
        Profile perfil = [SELECT Id, Name, PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() limit 1];
        if (perfil.PermissionsModifyAllData == false) {
            for(Account conta : lstAccount){ // MasterRecordId == null -> não é um registro mesclado.
                if(mapPerfisBloqueio.containsKey(perfil.name) && conta.MasterRecordId == null) conta.addError('Você não tem permissão para excluir esta conta.');
            }
        }
    }
   
    public static void integraContatos(List<Account> listaContas){
        /*Desenvolvido para funcionar apenas para 1 registro por vez, acionado por criação manual de registro */
        if(listaContas.size() > 1) return;

        List<Account> listaPacientes = new List<Account>();
        String tipoPaciente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        List<String> listaIdsPacientesIntegrarCelular = new List<String>();
        List<String> listaIdsPacientesIntegrarEmail = new List<String>();

        for(Account acc : listaContas){
            if(acc.RecordTypeId == tipoPaciente && String.isNotBlank(acc.KeyTasy__c) && acc.IntegrarTasy__c){
                if(String.isNotBlank(acc.PersonEmail)) listaIdsPacientesIntegrarEmail.add(acc.Id); 
                if(String.isNotBlank(acc.PersonMobilePhone)) listaIdsPacientesIntegrarCelular.add(acc.Id);
            }

            acc.IntegrarTasy__c = false;
        }

        if(listaIdsPacientesIntegrarEmail.size() == 1) integraContato(listaIdsPacientesIntegrarEmail[0], 'email');
        if(listaIdsPacientesIntegrarCelular.size() == 1) integraContato(listaIdsPacientesIntegrarCelular[0], 'mobile');
    }

    @Future(callout = true)
    private static void integraContato(String idPaciente, String tipoIntegracao){
        Account paciente = [SELECT Id, PersonEmail, PersonMobilePhone, IntegrationLog__c, KeyTasy__c FROM Account WHERE Id = :idPaciente];
        String token = '';

        try{
            IntegracaoTasyServiceUtils.ResponseToken responseToken = IntegracaoTasyService.buscarToken(); 

            if(responseToken.statusCode != 200 && responseToken.statusCode != 201) {
                throw new IntegracaoTasyServiceException(responseToken.errorDescription);
            }

            token = responseToken.accessToken;
        }catch(Exception e){
            paciente.IntegrationLog__c = 'Erro em '+System.now().format()+' ao obter Token para integrar o '+tipoIntegracao+'. \n\n' +e.getMessage();
            paciente.IntegrarTasy__c = false;
            update paciente;

            return;
        }

        try{
            IntegracaoTasyServiceUtils.ContatoPaciente contatoPaciente = new IntegracaoTasyServiceUtils.ContatoPaciente();
            contatoPaciente.key = paciente.KeyTasy__c;
            contatoPaciente.value = tipoIntegracao == 'email' ? paciente.PersonEmail : paciente.PersonMobilePhone;
            contatoPaciente.type = tipoIntegracao;
            String requestBody = JSON.serialize(contatoPaciente);

            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String dadosIntegracao = isSandbox ? 'CreatePatientSB' : 'CreatePatient';
            IntegracaoTasy__mdt integracaoTasyConfig = IntegracaoTasy__mdt.getInstance(dadosIntegracao);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(integracaoTasyConfig.Endpoint__c+'/'+paciente.KeyTasy__c+'/contact');
		    request.setMethod('POST');
		    request.setTimeout(120000);
            request.setClientCertificateName(integracaoTasyConfig.Certificado__c);
            request.setHeader('Accept', '*/*');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setBody(requestBody);

            HttpResponse response = new Http().send(request);

            if(response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                throw new IntegracaoTasyServiceException(response.getBody());
            }

        }catch(Exception e){
            paciente.IntegrationLog__c = 'Erro em '+System.now().format()+' ao obter tentar integrar o '+tipoIntegracao+'. \n\n' +e.getMessage();
            paciente.IntegrarTasy__c = false;
            update paciente;

            return;
        }
    }
    
    public static void formatPersonMobilePhone(List<Account> accounts) {
        // Define o padrão regex para números de telefone válidos
        Pattern validPattern = Pattern.compile('^55\\(\\d{2}\\)\\d{5}-\\d{4}$');
        // Define o padrão regex para números de telefone inválidos com letras ou mais de 13 dígitos
        Pattern invalidPattern = Pattern.compile('[^0-9\\-\\(\\)]'); // Permite apenas números, hífens e parênteses
    
        for (Account acc : accounts) {
            if (acc.PersonMobilePhone != null) {
                // Remove todos os caracteres que não sejam números
                String cleanedPhone = acc.PersonMobilePhone.replaceAll('[^0-9]', '');
                
                // Verifica se o telefone tem mais de 13 dígitos ou contém letras
                Matcher invalidMatcher = invalidPattern.matcher(acc.PersonMobilePhone);
                System.debug(acc.PersonMobilePhone);
                
                if (cleanedPhone.length() > 13 || invalidMatcher.find()) {
                    acc.PersonMobilePhone.addError('Preencha apenas o número do "DDD + Número do celular sem letras ou caracteres."');
                } 
                // Verifica se o telefone tem exatamente 13 dígitos e começa com "55"
                else if (cleanedPhone.length() == 13) {
                    if (cleanedPhone.startsWith('55')) {
                        // Formata o telefone para 55(XX)XXXXX-XXXX
                        String formattedPhone = '55(' + cleanedPhone.substring(2, 4) + ')' + 
                                                cleanedPhone.substring(4, 9) + '-' + 
                                                cleanedPhone.substring(9);
                        acc.PersonMobilePhone = formattedPhone;
                    } else {
                        acc.PersonMobilePhone.addError('Em caso de 13 digitos número de telefone deve começar com o código do país "55".');
                    }
                } 
                // Se o telefone tiver 11 dígitos (sem "55")
                else if (cleanedPhone.length() == 11) {
                    // Adiciona o código "55" e formata o telefone
                    String formattedPhone = '55(' + cleanedPhone.substring(0, 2) + ')' + 
                                            cleanedPhone.substring(2, 7) + '-' + 
                                            cleanedPhone.substring(7);
                    acc.PersonMobilePhone = formattedPhone;
                } 
                // Se o telefone não corresponde ao formato esperado
                else {
                    acc.PersonMobilePhone.addError('Preencha apenas o número do "DDD + Número do celular sem letras ou caracteres."');
                }
            }
        }
    }
}