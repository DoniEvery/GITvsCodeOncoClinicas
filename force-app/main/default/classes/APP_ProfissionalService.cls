public without sharing class APP_ProfissionalService {
    private static final String NAMED_CREDENTIAL = 'APIProfissional'; 
    private static final String ORG_DOMAIN_URL = URL.getOrgDomainURL().toExternalForm();

    public static List<APP_ProfissionalListResponseDTO> listarAgendamentosFiltrados(Integer page, Integer count, String dateStart, String dateEnd, String prontuario) {
        List<ServicePath__mdt> paths = [Select Service_Path__c from ServicePath__mdt where Service_Name__c = 'appointments date'];
        String path = paths[0].Service_Path__c;
        String endpoint = 'callout:' + NAMED_CREDENTIAL + path + 'appointments' +
            '?count=' + count +
            '&page=' + page +
            '&dateStart=' + EncodingUtil.urlEncode(dateStart, 'UTF-8') +
            '&dateEnd=' + EncodingUtil.urlEncode(dateEnd, 'UTF-8');
        
        if (String.isNotBlank(prontuario)) {
            endpoint += '&ehr=' + EncodingUtil.urlEncode(prontuario, 'UTF-8');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String jsonBody = res.getBody()
                .replace('"end"', '"endDate"')
                .replace('"system"', '"systemValue"');

                List<APP_ProfissionalListResponseDTO> lista = 
                    (List<APP_ProfissionalListResponseDTO>) JSON.deserialize(jsonBody, List<APP_ProfissionalListResponseDTO>.class);
        
            return lista;
        } else {
            Map<String, Object> erro = new Map<String, Object>{
                'endpoint' => endpoint,
                'statusCode' => res.getStatusCode(),
                'mensagem' => 'Erro ao buscar agendamentos',
                'body' => res.getBody()
            };
        
            throw new AuraHandledException(JSON.serialize(erro));
        }
    }

    public static List<APP_ProfissionalListResponseDTO> listarAgendamentosFiltradosMedicos(Integer page, Integer count, String dateStart, String dateEnd, String prontuario) {
        List<ServicePath__mdt> paths = [Select Service_Path__c from ServicePath__mdt where Service_Name__c = 'appointments date'];
        String path = paths[0].Service_Path__c;
        String endpoint = 'callout:' + NAMED_CREDENTIAL + path + 'appointments' +
            '?count=' + count +
            '&page=' + page +
            '&dateStart=' + EncodingUtil.urlEncode(dateStart, 'UTF-8') +
            '&dateEnd=' + EncodingUtil.urlEncode(dateEnd, 'UTF-8');
        
        if (String.isNotBlank(prontuario)) {
            endpoint += '&practitioner=' + EncodingUtil.urlEncode(prontuario, 'UTF-8');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String jsonBody = res.getBody()
                .replace('"end"', '"endDate"')
                .replace('"system"', '"systemValue"');

                List<APP_ProfissionalListResponseDTO> lista = 
                    (List<APP_ProfissionalListResponseDTO>) JSON.deserialize(jsonBody, List<APP_ProfissionalListResponseDTO>.class);
        
            return lista;
        } else {
            Map<String, Object> erro = new Map<String, Object>{
                'endpoint' => endpoint,
                'statusCode' => res.getStatusCode(),
                'mensagem' => 'Erro ao buscar agendamentos',
                'body' => res.getBody()
            };
        
            throw new AuraHandledException(JSON.serialize(erro));
        }
    }

    public static List<APP_PatientResponseDTO> buscarPacientePorCpf(String cpf, Integer page, Integer totalItems) {
        List<ServicePath__mdt> paths = [Select Service_Path__c from ServicePath__mdt where Service_Name__c = 'patients records'];
        String path = paths[0].Service_Path__c;
        String endpoint = 'callout:' + NAMED_CREDENTIAL + path +'patients' +
            '?totalItems=' + totalItems +
            '&page=' + page +
            '&document=' + EncodingUtil.urlEncode(cpf, 'UTF-8');
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
    
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String jsonBody = res.getBody()
                    .replace('"date"', '"dateValue"')
                    .replace('"number"', '"numberValue"')
                    .replace('"type"', '"typeValue"');
        
                List<APP_PatientResponseDTO> pacientes =
                    (List<APP_PatientResponseDTO>) JSON.deserialize(jsonBody, List<APP_PatientResponseDTO>.class);
    
                return pacientes;
        } else {
            Map<String, Object> erro = new Map<String, Object>{
                'endpoint' => endpoint,
                'statusCode' => res.getStatusCode(),
                'mensagem' => 'Erro ao buscar paciente',
                'body' => res.getBody()
            };
        
            throw new AuraHandledException(JSON.serialize(erro));
        }
    }  

    public static List<APP_PatientResponseDTO> buscarPorPronturario(String prontuario, Integer page, Integer totalItems) {
        List<ServicePath__mdt> paths = [Select Service_Path__c from ServicePath__mdt where Service_Name__c = 'patients records'];
        String path = paths[0].Service_Path__c;
        String endpoint = 'callout:' + NAMED_CREDENTIAL + path +'patients' +
            '?totalItems=' + totalItems +
            '&page=' + page +
            '&recordId=' + EncodingUtil.urlEncode(prontuario, 'UTF-8');
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
    
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String jsonBody = res.getBody()
                    .replace('"date"', '"dateValue"')
                    .replace('"number"', '"numberValue"')
                    .replace('"type"', '"typeValue"');
        
                List<APP_PatientResponseDTO> pacientes =
                    (List<APP_PatientResponseDTO>) JSON.deserialize(jsonBody, List<APP_PatientResponseDTO>.class);
    
                return pacientes;
        } else {
            Map<String, Object> erro = new Map<String, Object>{
                'endpoint' => endpoint,
                'statusCode' => res.getStatusCode(),
                'mensagem' => 'Erro ao buscar prontuário',
                'body' => res.getBody()
            };
        
            throw new AuraHandledException(JSON.serialize(erro));
        }
    }  

    public static APP_PatientRecordsResponseDTO buscarProntuarioPacientePorId(String id) {
        List<ServicePath__mdt> paths = [Select Service_Path__c from ServicePath__mdt where Service_Name__c = 'patients records'];
        String path = paths[0].Service_Path__c;
        String endpoint = 'callout:' + NAMED_CREDENTIAL + path +'patients' +
            '/' + id + '/records?';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
    
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            try {
                String jsonBody = res.getBody()
                    .replace('"date"', '"dateTm"');
        
                APP_PatientRecordsResponseDTO prontuario = (APP_PatientRecordsResponseDTO) JSON.deserialize(jsonBody, APP_PatientRecordsResponseDTO.class);
    
                return prontuario;
            } catch (Exception e) {
                APP_Logger.logErro(req.getEndpoint(), 500, 'Erro de parsing JSON', e.getMessage());
                return null;
            }
        } else {
            APP_Logger.logErro(req.getEndpoint(), res.getStatusCode(), 'Erro ao buscar prontuario', res.getBody());
            return null;
        }
    }      
}