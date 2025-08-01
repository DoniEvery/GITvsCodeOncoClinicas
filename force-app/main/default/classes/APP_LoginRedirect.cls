public with sharing class APP_LoginRedirect {
    @InvocableMethod(label='Redirecionar para Termos de Uso')
    public static List<String> redirectToTermsPage() {
        String sparkId = 'APPTermoDeUsoLoginComVisualforce';
        String vfPage = '/apex/AppTermoUsoPage';
        
        // Força o redirecionamento SEM opção de pular
        String finalUrl = '/secur/login.jsp?retURL=' + 
                          EncodingUtil.urlEncode(vfPage, 'UTF-8') + 
                          '&sparkID=' + sparkId;
        
        return new List<String>{ finalUrl };
    }
}