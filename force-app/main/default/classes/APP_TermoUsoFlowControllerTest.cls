@isTest
public class APP_TermoUsoFlowControllerTest {

    @isTest
    static void testGerarHash() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = p.Id
        );
        insert u;

        APP_TermoUsoFlowController.TermoUsoInput input = new APP_TermoUsoFlowController.TermoUsoInput();
        input.termContent = 'Conteúdo do termo de uso';
        input.userId = u.Id;

        List<APP_TermoUsoFlowController.TermoUsoInput> inputList = new List<APP_TermoUsoFlowController.TermoUsoInput>{ input };

        List<APP_TermoUsoFlowController.TermoUsoOutput> outputs = APP_TermoUsoFlowController.gerarHash(inputList);

        System.assertEquals(1, outputs.size());
        System.assertNotEquals(null, outputs[0].hash);
        System.assert(outputs[0].hash.length() > 0);
    }
}