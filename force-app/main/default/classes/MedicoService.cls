public with sharing class MedicoService {
	private static Id CONTATO_MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();

	/* -------------------------------------------------------------------------- */
	/*                               PUBLIC METHODS                               */
	/* -------------------------------------------------------------------------- */

	public Contact consultaMedico(Integer crm, String ufCrm) {
		Contact result = new Contact();

		Map<String, Consulta_Medicos__mdt> consultasMedicoMdt = getConsultaMedicosMap();

		String chave = consultasMedicoMdt.get('Chave').Chave__c;

		cfmService.ServicoConsultaMedicosPort response = new cfmService.ServicoConsultaMedicosPort();
		cfmService.medicoVO medico = response.Consultar(crm, ufCrm, chave);
        System.debug('Medico : ' + medico);

		if (medico != null) {
            if (medico.codigoErro == null && !String.isBlank(medico.nome)) {
                if(medico.situacao != 'F' && medico.situacao != 'C'){
                    System.debug(JSON.serializePretty(medico));
                    
                    List<String> nome = medico.nome.contains(' ') ? medico.nome.split(' ') : new List<String>{ medico.nome };
                        
                        result.RecordTypeId = CONTATO_MEDICO_RTYPE;
                    result.FirstName = nome.remove(0);
                    result.LastName = String.join(nome, ' ');
                    
                    if (medico.especialidade != null && medico.especialidade.size() > 0) {
                        result.Especialidade_CRM__c = String.join(medico.especialidade, ', ');
                    }
                    
                    result.CRM__c = medico.crm;
                    result.UF_do_CRM__c = medico.uf;
                    result.CRM_UF__c = medico.crm + medico.uf;
                    result.Tipo_Inscricao_CRM__c = consultasMedicoMdt.get('T' + medico.tipoInscricao).Tipo_de_Inscricao__c;
                    result.Situacao_do_CRM__c = consultasMedicoMdt.get('S' + medico.situacao).Situacao__c;
                }else{
                    throw new MedicoServiceException('Você não pode cadastrar esse médico(a), porque ele(a) está ' + consultasMedicoMdt.get('S' + medico.situacao).Situacao__c);
                }
			} else {
				throw new MedicoServiceException(getErrorMessage('X' + medico.codigoErro, consultasMedicoMdt)); //Quando o serviço retornar algum erro.
			}
		} else {
			throw new MedicoServiceException(getErrorMessage('X0000', consultasMedicoMdt)); //Quando o serviço não localizar nenhum medico.
		}

		return result;
	}

    /* -------------------------------------------------------------------------- */
    /*                               PRIVATE METHODS                              */
    /* -------------------------------------------------------------------------- */

	private String getErrorMessage(String errorKey, Map<String, Consulta_Medicos__mdt> consultasMedicoMdt) {
		String errorMessage = 'Erro ao se comunicar com o serviço do CFM.';

		if (consultasMedicoMdt.containsKey(errorKey)) {
			errorMessage = consultasMedicoMdt.get(errorKey).Mensagem__c;
		}

		return errorMessage;
	}

    private Map<String, Consulta_Medicos__mdt> getConsultaMedicosMap() {
		Map<String, Consulta_Medicos__mdt> result = new Map<String, Consulta_Medicos__mdt>();

		List<Consulta_Medicos__mdt> consultasMedicos = [
			SELECT Id, DeveloperName, Mensagem__c, Chave__c, Situacao__c, Tipo_de_Inscricao__c
			FROM Consulta_Medicos__mdt
			ORDER BY DeveloperName ASC
			LIMIT 2000
		];

		for (Consulta_Medicos__mdt consulta : consultasMedicos) {
			result.put(consulta.DeveloperName, consulta);
		}

		return result;
	}

    /* -------------------------------------------------------------------------- */
    /*                                INNER CLASSES                               */
    /* -------------------------------------------------------------------------- */

	public class MedicoServiceException extends Exception {
	}
}