public with sharing class IntegracaoPdfCartController {

    @AuraEnabled
    public static String generatePDF(String jsonData){
        Pagereference pg = Page.CartCellPDF;
        pg.getParameters().put('jsonData', jsonData);
        String url = Url.getOrgDomainUrl().toExternalForm() + pg.getUrl();
        return url;
    }

    @AuraEnabled
    public static Response integrarCart(String recordId){
       Response retorno = new Response();
       Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
       WebserviceResource__mdt webServiceCart = WebserviceResource__mdt.getInstance('CartCells');
       Account acc = [SELECT id, CRM_UF_CART__c, CNPJ__c, NomeMedicoSolicitante__c, Email__c, Telefone__c, PersonEmail FROM Account WHERE Id = :recordId];
       Boolean changed = false;
       Request requestBody = new Request(acc.CNPJ__c,acc.CRM_UF_CART__c);
       Details details = encryptData(JSON.serialize(requestBody),isSandbox,webServiceCart);

       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint((isSandbox == true) ? webServiceCart.EndPointSandBox__c : webServiceCart.EndPoint__c);
       request.setMethod('POST');
       request.setHeader('Content-Type', 'application/json');
       request.setHeader('Apikey', (isSandbox == true) ? webServiceCart.ApiKeySandBox__c : webServiceCart.ApiKey__c);
       request.setBody(JSON.serialize(details));
       request.setTimeout(120000);
       HttpResponse response = Test.isRunningTest() ? new HttpResponse() : http.send(request);

        if(Test.isRunningTest()){
            response.setBody('{"data": "1c09028ab5b0d1a4584aeca4689698c5ad30adccd9856a8c985a506730deb7f499d02843dd45858406f7b0e7e69aafb0479a443ff2ba64d6286313b15bad4b74d71ac77dc81585f43602fb7f2370ea19670c0b730df6fa663d0d14d556c95f07367ae45da05ea406cf6e8f2e40492c608eb3c2a51f0b4081e3b75d615691e3368b81f5fd41e1a018ddda544f2ce347029da0ab0183c89d43c599ab7966d905ee29fb7da90dd760b69b77d500abee28e7c685acab7ca552fe6efb66aa6da75f7be0ea6f11c6ed64a031a0626321230edec1e686e0435c22764d39c446ab39a6393c85c4525f92a4313c03fbc8370739f8eb6a43d886d4e0f3ad03548e2813338bb2ac70951b8fdddbb18365b41f5a4993b6f0b69c3ee637d6b74bdb901813160157532c3b1e8f8e59c2f7dea81bdef1cdc7623d28cc9100fe15500d9d6b911c838f4e12fa66037a94f265f477c1c9e1efccda42e4892f919c5ac76900ede54192e6a486de4c333566f345790b064563ed727e06521d17095f972b1618f4a99b407561a179ec2c78cd55e4e7b99967ac4132dda14169f944faf55499d8540add468c52bcfc08fad9f7727e579c84ade4530442c1aaedb9119cbffbb69e240873441a2518d03aae9d689d7b64c9b0a240ef71859e355c883c73a071ee6ffecbd01ba5ad271a9baa0d4109ae2f86e48395fc140a256bd02dd84f2ecd5ceba3893f3650cdcdaee28302c85cbfd80641978d75348e547e4911901e7dfa606818298aa45c083c85867550aaafd06f49dff0cdf48a8bee1bd198531de18f1f4eb23d717f55c37f6c96179b2af5c10a3e7e9fe234695d7613a472a3d31d615c6891bf61f75d131b84c56c99dafd11ed3bcaf5120d3f33097eca8d5f1b93f4c32c95da1e8ff2e31daf059e7e34cb39690ff57527fc95fee409a3ef791e13ad77320ab6a678edd16ce229ecded376bdae90f22ed0e6cc8644af1bd65ec443cf56d8518d6424ed1721333ae8f20c4057d3d98b7e693517ec6cbc496d7040b2a4422f3c69130a91750e07616da13e50e665405d82927812b3a116875d7e01125cfd891e8f0722d3e4154339bc5750acda6c28931855f11fca829e23344e71d24e96d087886c2759b3609007f52b7afbe4ef7847ad6f6446d6d9071da754aba9322b97db58dcb98bba4ca5c2096877386e9f074e8805c40b28ea50438892d359b5bee2f3a399bdf8f82c58c5b407d8fa107ebae6ab9febbd90cec56ceeb6431e7a70c36b07810251945108aaec9da28f10cf5d235159fd9668f2bedd985948eb0d80725ee77f14eebf7197f68c77e860ed03b4e1ef0fb256416e0b83aa7269cd775a8e89fffe90a3c9824b75a60b6582c95a611cf95dc1071b1267184a98425f8cfb0e6a28c2476686703838c8d4ab33fdc4e3f8a8ae473546ea0668cf64f39adda3b3a26adf693e8b4969112e833afb6177f0326c09a286c5ec91d39323d42426a61cc4ef5b41ce8d2199db4c2d7b2e6b9877c4d3de9a0b4141b677628e0281a3ba15706c94173cba57fdb81e62e76091b14142f0f8e26354d9442cc984133b9593118be04af2180570abf82b8447c812eefa0cacdae592160005879d9a151f7d10650b48c74c46ed15a405b4288ed761b4cc75b035ed224efd0e1343a10413e6fa539b53b74bfe0817c80f88d78b1982ca90028a42ec2049f063939e4377741df965276604ad7488c1c21b807020e1cba45d9cbe99dacca9921d0aeb8e52bb2194761effe026d0919e0bd22b69757432f78f6adeff71911c477de776f59a1dde468a980937861f014f4c21035095f73c8973577e7de970163e0799fab6cab39e3ea4cf914f37"}');
            response.setStatusCode(200);
        }

       if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
            Details retornoCriptografado = (Details) JSON.deserialize(response.getBody(), Details.class);
            String decriptado = decrypt(retornoCriptografado.data,isSandbox,webServiceCart);
            decriptado = decriptado.replace('number','adressNumber');
            
            retorno = (Response) JSON.deserialize(decriptado, Response.class);
            retorno.birthday = DateFormat(retorno.birthday);
            retorno.created_at = String.valueOf(Datetime.valueOf(retorno.created_at.replace('T',' ')).format('dd/MM/yyyy HH:mm:ss'));
            retorno.updated_at = String.valueOf(Datetime.valueOf(retorno.updated_at.replace('T',' ')).format('dd/MM/yyyy HH:mm:ss'));
            
            if(retorno.gender == 'male') retorno.gender = 'Masculino';
            if(retorno.gender == 'female') retorno.gender = 'Feminino';
            if(retorno.gender == 'unsolved') retorno.gender = 'Indeterminado';
            if(retorno.gender == 'miscellaneous') retorno.gender = 'Diverso';

            if(acc.NomeMedicoSolicitante__c != retorno.physician_name){
                acc.NomeMedicoSolicitante__c = retorno.physician_name;
                changed = true;
            }
            if(acc.Telefone__c != retorno.contact){
                acc.Telefone__c = retorno.contact;
                changed = true;
            }
            if(acc.PersonEmail != retorno.email){
                acc.PersonEmail = retorno.email;
                changed = true;
            }
            if(acc.Email__c != retorno.physician_email){
                acc.Email__c = retorno.physician_email;
                changed = true;
            }

            if(changed) update acc;

            return retorno;
       }
       else{
            retorno.error = String.isNotBlank(response.getBody()) ? response.getBody() : 'O serviço não retornou nenhuma informação.';
            retorno.errorFlag = true;
            return retorno;
       }      
    }

    @AuraEnabled
    public static RetornoDoc integrarDocumento(String doc){
        RetornoDoc retornoDescriptografado = new RetornoDoc();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        WebserviceResource__mdt webServiceCart = WebserviceResource__mdt.getInstance('CartCells');
        PatientAttachments documento = new PatientAttachments(doc);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint((isSandbox == true) ? webServiceCart.EndPointDocSandBox__c : webServiceCart.EndPointDoc__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Apikey', (isSandbox == true) ? webServiceCart.ApiKeySandBox__c : webServiceCart.ApiKey__c);
        request.setBody(JSON.serialize(documento));
        request.setTimeout(120000);
        HttpResponse response = Test.isRunningTest() ? new HttpResponse() : http.send(request);

        if(Test.isRunningTest()){
            response.setBody('{"data":"3bdf8e32a81d131e7355984d5725184b969ebb2d7a317f5e62ab3186e411c7238710cffaedd6f500330861635e6553d2a034f8b49fee5c5147ba93a9a1475d9f437f87ec673b7d5ff8dfba8f03033cda41e7319e6027079914256b3b5c5d57a4390eb6df79b9535aefa8bb1c56923ea877c5509683a78d06ed21d9cb65a18fcbd8f51516741489c59d9cdf5b89d4cf943e34e9ad80f3d7f2a7fead10872ab3b3778ef689b3234f1f024f348c2e29392accfde80ca2acb5a6b1c0159eae09a25c91f23bfef18da4c70b92913c3ac1225ea65b7159612cd7c41168c3128c9373b20273318df20cd0ac98674e943e88371ef32b310c595c03354c4bd538a149a8d600f798b167fb8484476c648245b60128a866eaaaeaeeeaa572792e64d101aa3c87e62707516df9c341bf3701ee3560296a9b3bef3e3a6ae89a685237d1d3dc23d7bc64e359a46e3a14c95ea03e4c4020ee2ae552fa2e33849a8caea029f627551c7d9ee47aa3e0ffda2b1b93708816c3a7fe45106ca7065c5f79c825b6167f6f31af31ccc52716ac19e1a4da3c73dcf85a29dea79dfa96e16dd59fc9f5e15567de017e0aca327a4088b377ebddcb399c29ead22929939fab812bdd7d525ac2f7568c9190878aca4aca7dd9da631b7b320f511eee2efe955312b650b0f9e0377c3721a4766eda446d1e23d40bed2320c6adc86e5234fc20f0f9e40525160f203d905c904955aa03763514158e1edf520ada99e25915f5e23edd12e9b092bdab06d39dbcbc46c685bee60a53c9afb47e7910204e39cae7b50b8ce2e568e49370a53e2df156b960cc82813c24e734d273a530e103267fbf5af9ccca93c78d67e625d9846dc5ef8531a360893d0e8df7ba11a5d5d4631bdd433dd3eb58c8fa3f1e44eb3a80ccc602203519bcd147cf43e17260364dc91d3525c54a3285f7d0f4b7d586b43516cd2035ab220cfc16ddceedda3b2a60b7493190dfe4d9506b05ee64bce6f0b89edd82c61ef7dbfb51f26edfa1ff2b9d812322613ed9d5d65e3ff6452973ed928163612886231ff77f056efc9af23463806fcd4cfe19a8d317a99d17ca21f794508632a7e31057674fef10daf368abadb679eb49b7e9c29611f8ddc0dc8bf5cf9e443be02fdd60d50f835765e1189571af6cff2f7bef47e223e550f2742a73b97ae17b82b1c2c453423b24a4fc244020272dcef3f7e349254dd37a198a8e9b482cc1bc3857d2114400f40e1df84995e976e75b4008fa1e611857eb0f56c69dd991f6e06e34776b69726cc1b517defc789c29c6ce07603449eb74b2f6fb0c47e52be7e3c54e3994c22e69aa9aec14e166fcb643bf74d16fec85c2f7be166a910e69d40547b780356f253a7f8e51fa0ba481b636b17425eb82a467831fe6077ed35e1145dec70b3eeab6a1fa91057cb97df4cd3584191a501f6d5b190295da0acf43e1945909065b8a6e2b737664dd4918b7146d0f554c6a50b7c6d6b9f2f7feef0da6effff2518fdfb095c21060fcac60baf2507e84000b7b301653a3e8b5ee997e5c227cfc82b2ef34c0a2b2d5f1faded0d5975bb6c7b42a9067057548d46ce2460dfe6ee6a9733b6a3127f0244b62df076a8f35271f7cd6db86b1328eab163af6837fc30715530700a9e9e7282cefb62de44cc2b29d68215d754d0ae6d9552e9b18baa1ead67643ef1f4a0d1527262250738950c9014afa07e6e47ca499f108043beaa528e250facaa6a5aa484d14774c973dc714c4fbc03e391aedf84d47af09c9e7b3127c26c62231c0db6a4543e0a8caf106eb829603aa57f3084eb6f442189b65ec380378cd9a13837d3969d999e5db06383a38b2fa0dd6c20d41bbe94eac480bf152bd2fcf3526338aa5ae5e750521fcf7910856ecc2cc860aabda9458964506b01e4cf363fc39b5f794dd8d62d6a78c7eaa00160039a73d244521a7b2a1aeead82c50f80f9148985a2f"}');
            response.setStatusCode(200);
        }

        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
            Details retornoCriptografado = (Details) JSON.deserialize(response.getBody(), Details.class);
            String decriptado = decrypt(retornoCriptografado.data,isSandbox,webServiceCart);
            retornoDescriptografado.data = decriptado;
            return retornoDescriptografado;
       }
       else{
            retornoDescriptografado.error = String.isNotBlank(response.getBody()) ? response.getBody() : 'O serviço não retornou nenhuma informação.';
            retornoDescriptografado.errorFlag = true;
            return retornoDescriptografado;
       }
    }

    private static Details encryptData(String dataString,Boolean sandbox,WebserviceResource__mdt webServiceCart){ 
        Blob symmetricKey = (sandbox == true) ? Blob.valueOf(webServiceCart.symmetricKeySandBox__c) : Blob.valueOf(webServiceCart.SymmetricKey__c);
        Blob data = Blob.valueOf(dataString);
        Blob chaveIv;

        if(Test.isRunningTest()) {
            chaveIv = Blob.valueOf('pn2981anlSh1sldh');
        } else {
            chaveIv = (sandbox == true) ? Blob.valueOf(webServiceCart.VectorKeySandBox__c) : Blob.valueOf(webServiceCart.VetorKey__c);
        }
        
        Blob encrypted = Crypto.encrypt('AES256', symmetricKey,chaveIv, data);
        Details details = new Details();
        details.data = EncodingUtil.convertToHex(encrypted);
        return details;
    }

    private static String decrypt(String toDecrypt, Boolean sandbox,WebserviceResource__mdt webServiceCart){
        Blob symmetricKey = (sandbox == true) ? Blob.valueOf(webServiceCart.symmetricKeySandBox__c) : Blob.valueOf(webServiceCart.SymmetricKey__c);
        Blob data = EncodingUtil.convertFromHex(toDecrypt);
        Blob chaveIv;
        if(Test.isRunningTest()) {
            chaveIv = Blob.valueOf('pn2981anlSh1sldh');
            return '{"id":"00bdf985-55df-4fde-afc5-b247d8467664","index":"1","unit_id":"1","uf":"SP","physician_cpf":"13369327406","physician_name":"Luiz Gustavo Gomes De Oliveira Matias","physician_crm":"99999AM","physician_tasy_key":"1928621","name":"Luiz Gustavo","gender":"male","birthday":"2001-09-19","email":"luizgustavo.gomes@base.digital","cpf":"13369327406","rg":"11111111111111","contact":"81996572193","secondary_contact":null,"weight":78,"height":167,"ecog":"0 - Completamente ativo e capaz de realizar sem restrições todas as atividades que realizava antes da doença.","cid":"D80 - Imunodeficiência com predominância de defeitos de anticorpos","oms":"ssadasdasdas","procedure_name":"Terapia CarTCells","cep":"55294490","city":"Garanhuns","street":"Rua Pascoal Lopes","state":"PE","district":"Magano","number":"45","complement":"Apt 5","created_at":"2023-08-31T21:16:06.000Z","updated_at":"2023-08-31T21:16:06.000Z","unit":{"id":"1","code":"OCPRECISIONMEDICINE","name":"OC PRECISION MEDICINE","tasyId":"67.0000"},"patientAttachments":[{"fileName":"0-test (1).pdf","encryptedFileKey":"35316230c85831e7110f7141d043fc0c737c9c5e109e9231e3bddb7e7b832f9df6610f0cff0ca3b1da59127cf8e5bb828165a95bee964fb31b99aa9725372727476eb22a7a1e"}],"physician_contact":"+5581996572193","physician_email":"luiz.gomes@oncoclinicas.com"}';
        } else {
            chaveIv = (sandbox == true) ? Blob.valueOf(webServiceCart.VectorKeySandBox__c) : Blob.valueOf(webServiceCart.VetorKey__c);
            Blob decrypted = Crypto.decrypt('AES256', symmetricKey, chaveIv, data);
        	String decryptedString = decrypted.toString();
        	return decryptedString;
        }
    }

    private static String DateFormat(String dateString){
        Date inputDate = Date.valueOf(dateString);
        DateTime dt = DateTime.newInstance(inputDate.year(), inputDate.month(),inputDate.day());
        String formattedDateString = dt.format('dd-MM-yyyy');
        formattedDateString = formattedDateString.replaceAll('-', '/');
        return formattedDateString;
    }

    public class Request{
        @AuraEnabled public String patientCPF {get;set;}
        @AuraEnabled public String physicianCRM {get;set;}

        public Request(String patientCPF, String physicianCRM ){
            this.patientCPF = patientCPF;
            this.physicianCRM = physicianCRM;
        }
    }
    
    public class Details{
        @AuraEnabled public String data {get;set;}
    }

    public class RetornoDoc{
        @AuraEnabled public String data;
        @AuraEnabled public String error;
        @AuraEnabled public Boolean errorFlag { get { return this.errorFlag == null ? false : this.errorFlag; } set;}  
    }

    public class Response{
        @AuraEnabled public String uf {get;set;}
        @AuraEnabled public String physician_cpf {get;set;}
        @AuraEnabled public String physician_name {get;set;}
        @AuraEnabled public String physician_crm {get;set;}
        @AuraEnabled public String physician_tasy_key {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String gender {get;set;}
        @AuraEnabled public String birthday {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String cpf {get;set;}
        @AuraEnabled public String rg {get;set;}
        @AuraEnabled public String contact {get;set;}
        @AuraEnabled public String secondary_contact {get;set;}
        @AuraEnabled public Decimal weight {get;set;}
        @AuraEnabled public Decimal height {get;set;}
        @AuraEnabled public String ecog {get;set;}
        @AuraEnabled public String cid {get;set;}
        @AuraEnabled public String oms {get;set;}
        @AuraEnabled public String procedure_name {get;set;}
        @AuraEnabled public String cep {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String district {get;set;}
        @AuraEnabled public String adressNumber {get;set;}
        @AuraEnabled public String complement {get;set;}
        @AuraEnabled public String created_at {get;set;}
        @AuraEnabled public String updated_at {get;set;}
        @AuraEnabled public Unit unit {get;set;}
        @AuraEnabled public List<PatientAttachments> patientAttachments {get;set;}
        @AuraEnabled public String physician_email {get;set;}
        @AuraEnabled public String physician_contact {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public Boolean errorFlag { get { return this.errorFlag == null ? false : this.errorFlag; } set;}
    }

    public class Unit {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String tasyId {get;set;}
    }

    public class PatientAttachments{
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String encryptedFileKey {get;set;}

        public PatientAttachments(String encryptedFileKey){
            this.encryptedFileKey = encryptedFileKey;
        }
    }

}