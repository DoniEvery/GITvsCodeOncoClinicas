public class APP_PatientRecordsResponseDTO {
    @AuraEnabled  public List<Observation> observations;
    @AuraEnabled  public List<Allergy> allergies;
    @AuraEnabled  public List<Medication> medications;
    @AuraEnabled  public List<Treatment> treatments;
    public class Observation {
        @AuraEnabled  public Integer id;
        @AuraEnabled  public String type;
        @AuraEnabled  public datetime dateTm;
        @AuraEnabled  public Integer encounter;
        @AuraEnabled  public Integer patient;
        @AuraEnabled  public String unit;
        @AuraEnabled  public Decimal value;
    }

    public class Allergy {
        @AuraEnabled  public Integer id;
        @AuraEnabled  public datetime dateTm;
        @AuraEnabled  public Integer encounter;
        @AuraEnabled  public Integer patient;
        @AuraEnabled  public String substance;
        @AuraEnabled  public String reaction;
    }

    public class Medication {
        @AuraEnabled  public Integer id;
        @AuraEnabled  public datetime dateTm;
        @AuraEnabled  public String patient;
        @AuraEnabled  public String description;
        @AuraEnabled  public Decimal dosageQuantity;
        @AuraEnabled  public String dosageUnit;
    }

    public class Treatment {
        @AuraEnabled  public String id;
        @AuraEnabled  public Diagnosis diagnosis;
        @AuraEnabled  public List<Anamnesis> anamnesis;
        @AuraEnabled  public List<Evolution> evolution;
        @AuraEnabled  public List<Conduct> conducts;
        @AuraEnabled  public List<DiagnosticImpression> diagnosticImpression;
        @AuraEnabled  public List<Plan> plans;
    }

    public class Diagnosis {
        @AuraEnabled  public Integer id;
        @AuraEnabled  public datetime dateTm;
        @AuraEnabled  public Disease disease;
        @AuraEnabled  public Topography topografy;
        @AuraEnabled  public Morphology morfology;
        @AuraEnabled  public Physician physician;
        @AuraEnabled  public UnitCare unitCare;
    }

    public class Disease {
        @AuraEnabled  public String code;
        @AuraEnabled  public String description;
    }

    public class Topography {
        @AuraEnabled  public String code;
        @AuraEnabled  public String description;
    }

    public class Morphology {
        @AuraEnabled  public String code;
        @AuraEnabled  public String description;
    }

    public class Physician {
        @AuraEnabled  public String code;
        @AuraEnabled  public String name;
    }

    public class UnitCare {
        public Integer code;
        public String description;
    }

    public class Anamnesis {
        @AuraEnabled  public String complaint;
        @AuraEnabled  public String hpma;
        @AuraEnabled  public String isda;
        @AuraEnabled  public datetime dateTm;
    }

    public class Evolution {
        @AuraEnabled  public String description;
        @AuraEnabled  public String complement;
        @AuraEnabled  public datetime dateTm;
        @AuraEnabled  public String conduct;
    }

    public class Conduct {
        @AuraEnabled  public String description;
        @AuraEnabled  public datetime dateTm;
    }

    public class DiagnosticImpression {
        @AuraEnabled  public String description;
        @AuraEnabled  public datetime dateTm;
    }

    public class Plan {
        @AuraEnabled  public Physician physician;
        @AuraEnabled  public String summary;
        @AuraEnabled  public String protocolKey;
        @AuraEnabled  public DateTime startDate;
        @AuraEnabled  public DateTime lastSessionDate;
        @AuraEnabled  public List<Session> sessions;
    }

    public class Session {
        @AuraEnabled  public Integer id;
        @AuraEnabled  public Integer cycle;
        @AuraEnabled  public String day;
        @AuraEnabled  public List<String> state;
        @AuraEnabled  public DateTime expectedDate;
        @AuraEnabled  public DateTime realDate;

    }

}