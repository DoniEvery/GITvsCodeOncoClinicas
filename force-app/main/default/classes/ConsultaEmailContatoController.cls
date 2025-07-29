public with sharing class ConsultaEmailContatoController { 

    @AuraEnabled 
    public static Object buscaEmailsMkt(String recordId, Date dataInicial, Date dataFinal){
        List<String> listFields = new List<String>();
        listFields.add('SubscriberKey');
        listFields.add('Assunto');
        listFields.add('Nome Jornada');
        listFields.add('Nome Email');
        listFields.add('JobID');
        listFields.add('Data Envio');
        listFields.add('Abertura'); 
        listFields.add('Data Abertura');
        listFields.add('Clique');
        listFields.add('Data Clique');
        listFields.add('Bounce');
        listFields.add('Data Bounce');
        listFields.add('Unsubscribe');
        listFields.add('Data Unsubscribe');

        Boolean isSandbox = [SELECT IsSandbox, Id FROM Organization].IsSandbox;

        if (isSandbox) {
            recordId = '0034x00000cER90AAG';
        } else if (recordId.substring(0,3) == '001') {
            Account conta = [SELECT Id, PersonContactId FROM Account WHERE Id = :recordId];
            recordId = (String.isEmpty(conta.PersonContactId)) ? recordId : conta.PersonContactId;
        }

        MarketingCloudService marketingCloudService = new MarketingCloudService();
        return marketingCloudService.retrieveDataExtension('Relatorio de Engajamento', listFields, recordId, dataInicial, dataFinal);
    }
}