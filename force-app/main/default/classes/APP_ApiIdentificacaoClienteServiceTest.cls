@isTest
public class APP_ApiIdentificacaoClienteServiceTest {
 
    @isTest
    static void buscaPacienteSucessoTest() {

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new APP_ApiIdentificacaoClienteServiceMock(false));   
        APP_ApiIdentificacaoClienteRespostaDTO dto = new APP_ApiIdentificacaoClienteRespostaDTO();
        APP_ApiIdentificacaoClienteController.identificarCliente();
        
        Test.stopTest();
    }
    
    @isTest
    static void buscaPacienteErroTest() {

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new APP_ApiIdentificacaoClienteServiceMock(true));       
        APP_ApiIdentificacaoClienteController.identificarCliente();
        
        Test.stopTest();
    }
    
}