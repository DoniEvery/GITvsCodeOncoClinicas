global class encontroPacienteController {

    public static responseEncontro getEncontro(String paciente) {
        responseEncontro response = new responseEncontro();
        Boolean temEncontros = null;
        Boolean temCasos = null;
        Paciente pacienteFormatado = (Paciente) JSON.deserialize(paciente, Paciente.class);
        
        List<HealthCloudGA__EhrEncounter__c> listEncontros = encontroPacienteService.getEncontros(pacienteFormatado.cpfPaciente);
        List<Case> listCasos = encontroPacienteService.getCasos(pacienteFormatado.cpfPaciente);
        
        System.debug('listEncontros > ' + listEncontros);
        System.debug('listCasos > ' + listCasos);
        
        if (!listEncontros.isEmpty()) {
            for (HealthCloudGA__EhrEncounter__c encontro : listEncontros) {
                System.debug(encontro);
                response.encontroList.add(encontro);
            }
            temEncontros = true;
            response.mensagem = ' | Encontros localizados com sucesso! |';
        } else {
            temEncontros = false;
            response.mensagem = ' | Encontros não localizados. |';
        }
        
        if (!listCasos.isEmpty()) {
            for (Case caso : listCasos) {
                response.casoList.add(caso);    
            }
            temCasos = true;
            response.mensagem += ' | Casos localizados com sucesso! |';
        } else {
            temCasos = false;
            response.mensagem += ' | Casos não localizados. |';
        }
        
        if (temEncontros && !temCasos) {
            response.codigoStatus = '001';
            response.status = 'Sucesso';
        } else if (!temEncontros && temCasos) {
            response.codigoStatus = '002';
            response.status = 'Sucesso';
        } else if (temEncontros && temCasos) {
            response.codigoStatus = '003';
            response.status = 'Sucesso';
        } else {
            response.codigoStatus = '004';
            response.mensagem = 'Nenhum registro encontrado.';
            response.status = 'Erro';
        }
        
        return response;
    }

    // A classe interna agora está correta como global
    global class responseEncontro {
        global String status;
        global String codigoStatus;
        global String mensagem;
        global List<HealthCloudGA__EhrEncounter__c> encontroList = new List<HealthCloudGA__EhrEncounter__c>();
        global List<Case> casoList = new List<Case>();
    
        // Construtor da classe
        global responseEncontro() {
            encontroList = new List<HealthCloudGA__EhrEncounter__c>();
            casoList = new List<Case>();
        }
    }
    
    public class Paciente {
        public String cpfPaciente {get; set;}
    }
}