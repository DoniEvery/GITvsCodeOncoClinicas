public class APP_ApiIdentificacaoClienteController {

    @AuraEnabled(cacheable=true)
    public static void identificarCliente() {
        String cnpj = APP_ApiIdentificacaoClienteService.validaIdPlusoft();
        if (cnpj != null) {
            APP_ApiIdentificacaoClienteDTO dto = new APP_ApiIdentificacaoClienteDTO(cnpj);
            APP_ApiIdentificacaoClienteService.identificarOuCriarPessoa(dto);
        }
        
    }

   
}