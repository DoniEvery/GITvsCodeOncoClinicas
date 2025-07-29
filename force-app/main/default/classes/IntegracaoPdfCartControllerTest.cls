@isTest
public class IntegracaoPdfCartControllerTest {

    @isTest
    public static void testaController(){
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c ='13369327406';
        paciente.CPF__pc ='13369327406';
        paciente.CRM_UF_CART__c ='99999AM';
        insert paciente;

        Test.startTest();
        IntegracaoPdfCartController.Response resp = IntegracaoPdfCartController.integrarCart(paciente.id);
        IntegracaoPdfCartController.generatePDF(JSON.serialize(resp));
        IntegracaoPdfCartController.integrarDocumento(resp.patientAttachments[0].encryptedFileKey);

        IntegracaoPdfCartController.Response resp2 = new IntegracaoPdfCartController.Response();
        resp2.uf = '2';
        resp2.physician_cpf = '2';
        resp2.physician_name = '2';
        resp2.physician_crm = '2';
        resp2.physician_tasy_key = '2';
        resp2.name = '2';
        resp2.gender = '2';
        resp2.birthday = '2';
        resp2.email = '2';
        resp2.cpf = '2';
        resp2.rg = '2';
        resp2.contact = '2';
        resp2.secondary_contact = '2';
        resp2.weight = 10;
        resp2.height = 10;
        resp2.ecog = '2';
        resp2.cid = '2';
        resp2.oms = '2';
        resp2.procedure_name = '2';
        resp2.cep = '2';
        resp2.city = '2';
        resp2.street = '2';
        resp2.state = '2';
        resp2.district = '2';
        resp2.adressNumber = '2';
        resp2.complement = '2';
        resp2.created_at = '2';
        resp2.updated_at = '2';
        resp2.physician_email = '2';
        resp2.physician_contact = '2';
        resp2.error = '2';
        resp2.errorFlag = false;
        Test.stopTest();

        CartCellPDFcontroller cont = new CartCellPDFcontroller();
    }

}