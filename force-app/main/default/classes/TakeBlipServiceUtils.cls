public class TakeBlipServiceUtils {

    //Verifica formatação do telefone
    public static String telefoneFormat(String telefone){
        String telefoneFormatado = removeSpecialCaracters(telefone);
        //criar um logica pra verificar se tem 55 no comneço se nao tiver passa o telefone formatado  
        if(telefoneFormatado.substring(0,1) == '5' && telefoneFormatado.substring(1,2) == '5'){
            telefoneFormatado = telefoneFormatado.substring(2,telefoneFormatado.length());
        }
        
        return telefoneFormatado;
    }
    
    private static string removeSpecialCaracters(string str){
        system.debug(str);
        String s = str.replaceAll('[^a-zA-Z0-9\\s+]', '');
        
        s = s.replace('-', '');
        
        return s.replace(' ', '');       
    }

    //VerificaWhatsapp Request ------------------------------------------------------------------------
    public class verificaWhatsappReq{
        public String id;
        public String to;
        public String method;
        public String uri;
    }

    //VerificaWhatsapp Response
    public class verificaWhatsappResp{
        public String status;
        public Resource resource;
    }

    public class Resource{
        public String alternativeAccount;
        public String identity;
    }

    //Envia Mensagem Request --------------------------------------------------------------------------
    public class EnviaMensagemReq{
        public String id;
        public String to;
        public String type;
        public Content content;
    }

    public class Content{
        public String type;
        public Template template;
    }

    public class Template{
        public String namespace;
        public String name;
        public Language language;
        public List<Components> components;
    }

    public class Language{
        public String code;
        public String policy;
    }

    public class Components{
        public String type;
    }
    
    //Direcionar Chat Request ------------------------------------------------------------------
    public class direcionarChatReq{
        public String id;
        public String to;
        public String method;
        public String uri;
        public String type;
        public String resource;
    }
    
    //Direcionar Chat Response
    public class direcionarChatResp{
        public String status;
    }

    //VerificaWhatsapp Request ------------------------------------------------------------------------
    public class direcionarBlocoReq{
        public String id;
        public String to;
        public String method;
        public String uri;
        public String type;
        public String resource;
    }

    //Direcionar Chat Response
    public class direcionarBlocoResp{
        public String status;
    }
}