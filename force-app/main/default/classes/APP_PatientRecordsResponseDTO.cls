public class APP_PatientRecordsResponseDTO {
    public List<Observation> observations;
    public List<Allergy> allergies;
    public List<Medication> medications;
    public List<Treatment> treatments;

    public class Observation {
        public Integer id;
        public String type;
        public datetime dateTm;
        public Integer encounter;
        public Integer patient;
        public String unit;
        public Decimal value;
    }

    public class Allergy {
        public Integer id;
        public datetime dateTm;
        public Integer encounter;
        public Integer patient;
        public String substance;
        public String reaction;
    }

    public class Medication {
        public Integer id;
        public datetime dateTm;
        public String patient;
        public String description;
        public Decimal dosageQuantity;
        public String dosageUnit;
    }

    public class Treatment {
        public String id;
        public Diagnosis diagnosis;
        public List<Anamnesis> anamnesis;
        public List<Evolution> evolution;
        public List<Conduct> conducts;
        public List<DiagnosticImpression> diagnosticImpression;
        public Object plans;
    }

    public class Diagnosis {
        public Integer id;
        public datetime dateTm;
        public Disease disease;
        public Topography topografy;
        public Morphology morfology;
        public Physician physician;
        public UnitCare unitCare;
    }

    public class Disease {
        public String code;
        public String description;
    }

    public class Topography {
        public String code;
        public String description;
    }

    public class Morphology {
        public String code;
        public String description;
    }

    public class Physician {
        public String code;
        public String name;
    }

    public class UnitCare {
        public Integer code;
        public String description;
    }

    public class Anamnesis {
        public String complaint;
        public String hpma;
        public String isda;
        public datetime dateTm;
    }

    public class Evolution {
        public String description;
        public String complement;
        public datetime dateTm;
        public String conduct;
    }

    public class Conduct {
        public String description;
        public datetime dateTm;
    }

    public class DiagnosticImpression {
        public String description;
        public datetime dateTm;
    }
}