public with sharing class IntegracaoTasyServiceUtils {

    //HttpRequest
    public class IntegracaoTasyHttpRequest {
        public String endpoint;
        public String method;
        public Map<String, String> headers;
        public String body;
        public Integer timeout;
        public String certificado;
    }

    //Response 
    public class ResponseToken{
        public String accessToken;
        public String error;
        public String errorDescription;
        public Integer statusCode;
    }

    //Inclusão de Paciente
    public class Paciente{
        public string name;
        public string cpf;
        public date birthDate;
        public List<Contacts> contacts;
    }

    public class Contacts{
        public string value;
        public string type;
    }

    //Response Inclusão Paciente
    public class ResponsePostPatience {
        public String createdId;
        public List<ResponsePostPatienceErrors> errors;
    }

    public class ResponsePostPatienceErrors {
        public String message;
    }

    public class ContatoPaciente {
        public String key;
        public String value;
        public String type;
    }

}