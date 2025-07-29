public class APP_PatientResponseDTO {
    public String id;
    public String name;
    public String cpf;
    public String rg;
    public String foreignResidentId;
    public String passportId;
    public String deceaseDate;
    public String birthDate;
    public String nameSocial;
    public String gender;
    public MaritalStatus maritalStatus;
    public Ethnicity ethnicity;
    public Religion religion;
    public Occupation occupation;
    public EducationLevel educationLevel;
    public String dateValue;
    public String revisionDate;
    public ReferringPhysician referringPhysician;
    public Nationality nationality;
    public List<Contact> contacts;
    public List<Address> address;
    public List<Relative> relatives;
    public List<ScheduleCareUnit> scheduleCareUnit;

    public class MaritalStatus {
        public String code;
        public String description;
    }

    public class Ethnicity {
        public String code;
        public String description;
    }

    public class Religion {
        public Integer code;
        public String description;
    }

    public class Occupation {
        public Integer code;
        public String description;
    }

    public class EducationLevel {
        public String code;
        public String description;
    }

    public class ReferringPhysician {
        public String code;
        public String name;
        public String enrollment;
    }

    public class Nationality {
        public String code;
        public String description;
    }

    public class Contact {
        public String code;
        public String value;
        public String typeValue;
        public Boolean absent;
    }

    public class Address {
        public String code;
        public String typeValue;
        public String street;
        public String district;
        public String complement;
        public Integer numberValue;
        public String city;
        public String state;
        public String zipCode;
        public String streetType;
    }

    public class Relative {
        public String code;
        public String name;
        public String kinship;
        public String mobilePhone;
        public String phoneContact;
        public String accountable;
        public List<Address> address;
    }

    public class ScheduleCareUnit {
        public String code;
        public String ein;
        public String description;
        public String street;
        public String numberValue;
        public String complement;
        public String district;
        public String city;
        public String state;
        public String zipCode;
        public Boolean schedule;
        public Integer unit;
    }
}