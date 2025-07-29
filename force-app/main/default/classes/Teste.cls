public class Teste {
public static String TOKEN = 'Bearer 283c9004-385e-4853-9bd7-8fba40a25919'; // pegue do Postman

    public static APP_ProfissionalListResponseDTO listarAgendamentoPorCpf(String prontuario) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://barramento-qa.oncoclinicas.com.br/eapi-salesforce/api/v1/appointments/' + prontuario);
        req.setMethod('GET');
        req.setHeader('Authorization', TOKEN);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Status: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());

        if (res.getStatusCode() == 200) {
            return (APP_ProfissionalListResponseDTO) JSON.deserialize(res.getBody(), APP_ProfissionalListResponseDTO.class);
        }
        return null;
    }
}