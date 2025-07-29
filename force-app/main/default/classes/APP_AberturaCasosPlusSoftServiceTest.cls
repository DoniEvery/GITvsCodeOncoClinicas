@isTest
public class APP_AberturaCasosPlusSoftServiceTest {
    
    @isTest
    static void criaCasoSucessoTest() {

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new APP_AberturaCasosPlusSoftServiceMock(false));   
        List<APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput> inputs = new List<APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput>();
        APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput input = new APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput();
        input.idPlusoft = '1015967';
        input.motivo = '10100';
        inputs.add(input);
        APP_AberturaCasosPlusSoftRespostaDTO dto = new APP_AberturaCasosPlusSoftRespostaDTO();
        APP_AberturaCasosPlusSoftController.criarCaso(inputs);
        
        Test.stopTest();
    }
    
    @isTest
    static void buscaPacienteErroTest() {

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new APP_AberturaCasosPlusSoftServiceMock(true)); 
        List<APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput> inputs = new List<APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput>();
        APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput input = new APP_AberturaCasosPlusSoftController.CasosPlusSoftWrapperInput();
        input.idPlusoft = '1015967';     
        input.motivo = '10100'; 
        inputs.add(input);
        APP_AberturaCasosPlusSoftRespostaDTO dto = new APP_AberturaCasosPlusSoftRespostaDTO();
        APP_AberturaCasosPlusSoftController.criarCaso(inputs);
        
        Test.stopTest();
    }
}