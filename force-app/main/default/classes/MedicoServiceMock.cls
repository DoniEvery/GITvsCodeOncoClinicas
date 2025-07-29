@isTest
global class MedicoServiceMock {
	global class MockServicoConsultaMedicosPort implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ConsultarResponse cfmResponse = new cfmService.ConsultarResponse();
			cfmResponse.dadosMedico = new cfmService.medicoVO();
			cfmResponse.dadosMedico.verificarAutoriazacao = '';
			cfmResponse.dadosMedico.uf = 'SP';
			cfmResponse.dadosMedico.tipoInscricao = 'P';
			cfmResponse.dadosMedico.situacao = 'A';
			cfmResponse.dadosMedico.numeroCPF = '';
			cfmResponse.dadosMedico.nome = 'Garrosh Hellscream';
			cfmResponse.dadosMedico.imagem = '';
			cfmResponse.dadosMedico.dataNascimento = '';
			cfmResponse.dadosMedico.dataAtualizacao = '';
			cfmResponse.dadosMedico.crm = '12345';
			cfmResponse.dadosMedico.codigoErro = null;
			cfmResponse.dadosMedico.especialidade = new List<String>{ 'DERMATOLOGIA - RQE Nº: 91483', 'DERMATOLOGIA - RQE Nº: 12345' };
			// end

			response.put('response_x', cfmResponse);
		}
	}

	global class MockServicoConsultaMedicosErro implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ConsultarResponse cfmResponse = new cfmService.ConsultarResponse();
			response.put('response_x', cfmResponse);
		}
	}

	global class MockServicoConsultaMedicosNaoEncontrado implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			cfmService.ConsultarResponse cfmResponse = new cfmService.ConsultarResponse();
			cfmResponse.dadosMedico = new cfmService.medicoVO();
			cfmResponse.dadosMedico.codigoErro = '8101';
			response.put('response_x', cfmResponse);
		}
	}
}