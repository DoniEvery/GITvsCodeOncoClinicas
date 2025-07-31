public without sharing class APP_ProfissionalController {
    // Retorna os dados do prontuário por id
    @AuraEnabled(cacheable=false)
    public static APP_PatientRecordsResponseDTO buscarProntuarioPacientePorId(String id, Integer page, Integer count, String dateStart, String dateEnd) {
        return APP_ProfissionalService.buscarProntuarioPacientePorId(id, page, count, dateStart, dateEnd);
    }
}