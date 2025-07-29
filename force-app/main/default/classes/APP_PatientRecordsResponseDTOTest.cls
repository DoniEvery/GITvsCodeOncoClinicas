@isTest
private class APP_PatientRecordsResponseDTOTest {
    @isTest
    static void testDTOConstruction() {
        APP_PatientRecordsResponseDTO dto = new APP_PatientRecordsResponseDTO();

 APP_PatientRecordsResponseDTO.Observation obs = new APP_PatientRecordsResponseDTO.Observation();
        obs.id = 1;
        obs.type = 'Blood Pressure';
        obs.dateTm = System.now();
        obs.encounter = 100;
        obs.patient = 200;
        obs.unit = 'mmHg';
        obs.value = 120.5;
        dto.observations = new List<APP_PatientRecordsResponseDTO.Observation>{ obs };

        APP_PatientRecordsResponseDTO.Allergy allergy = new APP_PatientRecordsResponseDTO.Allergy();
        allergy.id = 2;
        allergy.dateTm = System.now();
        allergy.encounter = 101;
        allergy.patient = 201;
        allergy.substance = 'Peanuts';
        allergy.reaction = 'Anaphylaxis';
        dto.allergies = new List<APP_PatientRecordsResponseDTO.Allergy>{ allergy };


        APP_PatientRecordsResponseDTO.Medication med = new APP_PatientRecordsResponseDTO.Medication();
        med.id = 3;
        med.dateTm = System.now();
        med.patient = '202';
        med.description = 'Amoxicillin';
        med.dosageQuantity = 500.0;
        med.dosageUnit = 'mg';
        dto.medications = new List<APP_PatientRecordsResponseDTO.Medication>{ med };


        APP_PatientRecordsResponseDTO.Treatment treatment = new APP_PatientRecordsResponseDTO.Treatment();
        treatment.id = 'T1';

        APP_PatientRecordsResponseDTO.Diagnosis diag = new APP_PatientRecordsResponseDTO.Diagnosis();
        diag.id = 4;
        diag.dateTm = System.now();

        APP_PatientRecordsResponseDTO.Disease disease = new APP_PatientRecordsResponseDTO.Disease();
        disease.code = 'C50';
        disease.description = 'Breast cancer';
        diag.disease = disease;

        APP_PatientRecordsResponseDTO.Topography topo = new APP_PatientRecordsResponseDTO.Topography();
        topo.code = 'T20';
        topo.description = 'Chest';
        diag.topografy = topo;

        APP_PatientRecordsResponseDTO.Morphology morph = new APP_PatientRecordsResponseDTO.Morphology();
        morph.code = 'M20';
        morph.description = 'Benign tumor';
        diag.morfology = morph;

        APP_PatientRecordsResponseDTO.Physician doc = new APP_PatientRecordsResponseDTO.Physician();
        doc.code = 'P001';
        doc.name = 'Dr. Smith';
        diag.physician = doc;

        APP_PatientRecordsResponseDTO.UnitCare uc = new APP_PatientRecordsResponseDTO.UnitCare();
        uc.code = 10;
        uc.description = 'ICU';
        diag.unitCare = uc;

        treatment.diagnosis = diag;


        APP_PatientRecordsResponseDTO.Anamnesis anam = new APP_PatientRecordsResponseDTO.Anamnesis();
        anam.complaint = 'Headache';
        anam.hpma = '3 days';
        anam.isda = 'No prior issues';
        anam.dateTm = System.now();
        treatment.anamnesis = new List<APP_PatientRecordsResponseDTO.Anamnesis>{ anam };


        APP_PatientRecordsResponseDTO.Evolution evo = new APP_PatientRecordsResponseDTO.Evolution();
        evo.description = 'Improving';
        evo.complement = 'Vital signs stable';
        evo.dateTm = System.now();
        evo.conduct = 'Continue meds';
        treatment.evolution = new List<APP_PatientRecordsResponseDTO.Evolution>{ evo };


        APP_PatientRecordsResponseDTO.Conduct conduct = new APP_PatientRecordsResponseDTO.Conduct();
        conduct.description = 'Surgery scheduled';
        conduct.dateTm = System.now();
        treatment.conducts = new List<APP_PatientRecordsResponseDTO.Conduct>{ conduct };


        APP_PatientRecordsResponseDTO.DiagnosticImpression diagImp = new APP_PatientRecordsResponseDTO.DiagnosticImpression();
        diagImp.description = 'Possible infection';
        diagImp.dateTm = System.now();
        treatment.diagnosticImpression = new List<APP_PatientRecordsResponseDTO.DiagnosticImpression>{ diagImp };


        treatment.plans = 'Follow-up in 1 week';

        dto.treatments = new List<APP_PatientRecordsResponseDTO.Treatment>{ treatment };

        System.assertNotEquals(null, dto);
    }
}