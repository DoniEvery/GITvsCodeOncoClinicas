public class APP_ProfissionalListResponseDTO {
    @AuraEnabled public Long id;
    @AuraEnabled public AppointmentType appointmentType;
    @AuraEnabled public String comment;
    @AuraEnabled public String description;
    @AuraEnabled public String start;
    @AuraEnabled public String endDate;
    @AuraEnabled public String lastUpdated;
    @AuraEnabled public List<APP_ProfissionalSpecialtyDTO> specialty;
    @AuraEnabled public List<Actor> actor;
    @AuraEnabled public String status;
    @AuraEnabled public Insurance insurance;

    public class AppointmentType {
        @AuraEnabled public String code;
        @AuraEnabled public String display;
        @AuraEnabled public String systemValue;
    }

    public class Actor {
        @AuraEnabled public String reference;
        @AuraEnabled public String display;
        @AuraEnabled public String typeValue;
        @AuraEnabled public String required;
        @AuraEnabled public Address address;
        @AuraEnabled public String nomeMedico;
        @AuraEnabled public String fotoMedicoUrl;
    }

    public class Address {
        @AuraEnabled public String street;
        @AuraEnabled public String numberValue;
        @AuraEnabled public String complement;
        @AuraEnabled public String district;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zipcode;
    }

    public class Insurance {
        @AuraEnabled public Integer code;
        @AuraEnabled public String display;
        @AuraEnabled public Category category;
    }

    public class Category {
        @AuraEnabled public String code;
        @AuraEnabled public String display;
    }
}