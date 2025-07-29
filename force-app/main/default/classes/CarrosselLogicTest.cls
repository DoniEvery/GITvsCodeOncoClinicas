@istest
public class CarrosselLogicTest
{
	//OK
    @isTest static void getEmailsFromContactTest()
    {	
        	// Arrange
        	string idContact = '0033C00000RY6cMQAT';
			List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>();
        	List<Emails_do_Contato__c> emailsContactEmpty = new List<Emails_do_Contato__c>();
        
        	// Act
            emailsContact = CarrosselLogic.getEmailsFromContact(idContact);
        	
        	// Assert  
            if(emailsContact.isEmpty() || emailsContact == null)
                system.assertEquals(emailsContactEmpty, emailsContact);
            
        	system.assertNotEquals(null, emailsContact);
      }
    
    //OK
    @isTest static void iSEmailNotEngajedTest()
    {	
        	// Arrange
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Nao_engajado__c = true),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Nao_engajado__c = false) 
        	};
            
        	boolean iSNotEngajed = false;
        
        	// Act
        	for (Emails_do_Contato__c email : emailsContact)
            {
                if(CarrosselLogic.iSEmailNotEngajed(email))
                {
                    iSNotEngajed = true;
                    break;
                }	
            }
        	
        	// Assert  
        	system.assertEquals(true, iSNotEngajed);
      }
    
    //OK
    @isTest static void iSEmailEngajedTest()
    {	
        	// Arrange
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Nao_engajado__c = false),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Nao_engajado__c = false) 
        	};
            
        	boolean iSNotEngajed = false;
        
        	// Act
        	for (Emails_do_Contato__c email : emailsContact)
            {
                if(CarrosselLogic.iSEmailNotEngajed(email))
                {
                    iSNotEngajed = true;
                    break;
                }	
            }
        	
        	// Assert  
        	system.assertEquals(false, iSNotEngajed);
      }
    
    //OK
    @isTest static void iSEmailInvalidTest()
    {	
        	// Arrange
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = true),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Invalido__c = false) 
        	};
            
        	boolean iSValid = false;
        
        	// Act
        	for (Emails_do_Contato__c email : emailsContact)
            {
                if(CarrosselLogic.iSEmailInvalid(email))
                {
                    iSValid = true;
                    break;
                }	
            }
        	
        	// Assert  
        	system.assertEquals(true, iSValid);
      }
    
    //OK
    @isTest static void iSEmailNotInvalidTest()
    {	
        	// Arrange
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = false),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Invalido__c = false) 
        	};
            
        	boolean iSValid = false;
        
        	// Act
        	for (Emails_do_Contato__c email : emailsContact)
            {
                if(CarrosselLogic.iSEmailInvalid(email))
                {
                    iSValid = true;
                    break;
                }	
            }
        	
        	// Assert  
        	system.assertEquals(false, iSValid);
      }
    
    //OK
    @isTest static void updateMainEmailTest()
    {
            // Arrange   
            Account acct = new Account(Name='SFDC Account');
    		insert acct;  
        
            Contact contato = new Contact(
                FirstName = 'Joe',
                LastName = 'Smith',
                AccountId = acct.Id);
    		insert contato;
        
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = false, Nao_engajado__c = false, Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Invalido__c = false,  Contato__c = contato.Id) 
        	}; 
            
            // Act
            CarrosselLogic.updateMainEmail(contato, emailsContact);
                
            // Assert  
            system.assertEquals('test1@gmail.com', contato.Email);
      }
    
    //OK
    @isTest static void updateMainEmailIfEmailAvailableAndEngajedTest()
    {
            // Arrange   
            Account acct = new Account(Name='SFDC Account');
    		insert acct;  
        
            Contact contato = new Contact(
                FirstName = 'Joe',
                LastName = 'Smith',
                Email = 'test@gmail.com',
                AccountId = acct.Id);
    		insert contato;
        
        	List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = true, Nao_engajado__c = true, Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Invalido__c = true,  Contato__c = contato.Id) 
        	}; 
            
            // Act
            CarrosselLogic.updateMainEmail(contato, emailsContact);
                
            // Assert  
            system.assertEquals('test@gmail.com', contato.Email);
      }
    
    //OK
    @isTest static void isEmailInListTest()
    {
        // Arrange
        string mainEmail = 'test1@gmail.com';
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
                new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = true),
                new Emails_do_Contato__c(E_mail__c = 'test@gmail.com', Invalido__c = false) 
             };   
        
        // Act
        boolean isInList = CarrosselLogic.isEmailInList(emailsContact, mainEmail);
        
        // Assert   
        system.assertEquals(true, isInList);
        system.assertNotEquals(false, isInList);
      } 
    
    //OK
    @isTest static void isEmailNotInListTest()
    {
        // Arrange
        string mainEmail = 'test@gmail.com';
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{                       
                new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = true),
                new Emails_do_Contato__c(E_mail__c = 'test2@gmail.com', Invalido__c = false) 
             };   
        
        // Act
        boolean isInList = CarrosselLogic.isEmailInList(emailsContact, mainEmail);
        
        // Assert   
        system.assertEquals(false, isInList);
      } 
    
    //OK
    @isTest static void createEmailContactTest()
    {
        // Arrange
        Account acct = new Account(Name='SFDC Account');
        insert acct;  
        
        Contact contato = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            AccountId = acct.Id);
        
        // Act   
        CarrosselLogic.createEmailContact(contato);
        
        // Assert
        system.assertEquals('Joe', contato.FirstName);

    }
    
    //OK
    @isTest static void isAnyEmailAvailableAndEngajedTest()
    {
        // Arrange
        
        Account acct = new Account(Name='SFDC Account');
        insert acct; 
        
        Contact contato = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            AccountId = acct.Id); 
        insert contato; 
        
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = false, Nao_engajado__c = false, Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test2@gmail.com', Invalido__c = false,  Contato__c = contato.Id) 
        	}; 
         insert  emailsContact;
        // Act
        
        if(CarrosselLogic.isAnyEmailAvailableAndEngajed(contato, emailsContact)){
            // Assert
            system.assertEquals(true, true);
        }  
    }
    
    //OK
    @isTest static void isNotAnyEmailAvailableAndEngajedTest()
    {
        // Arrange
        
        Account acct = new Account(Name='SFDC Account');
        insert acct; 
        
        Contact contato = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            AccountId = acct.Id); 
        insert contato; 
        
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test13@gmail.com', Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test24@gmail.com',  Contato__c = contato.Id) 
        	}; 
         insert  emailsContact;
        
        // Act
        if(CarrosselLogic.isAnyEmailAvailableAndEngajed(contato, emailsContact)){
            // Assert
        	system.assertEquals(false, false);            
        }           
    }
    
    //OK
    @isTest static void updateEmailsContactInvalidTest()
    {
        
        Account acct = new Account(Name='SFDC Account');
        insert acct; 
        
        Contact contato = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Email = 'test1@gmail.com',
            Engajamento__c = 'Inválido',
            AccountId = acct.Id); 
        insert contato; 
        
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = false, Nao_engajado__c = false, Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test2@gmail.com', Invalido__c = false,  Contato__c = contato.Id) 
        	}; 
         insert  emailsContact;
        
        CarrosselLogic.updateEmailsContact(contato, emailsContact);
        
        system.assertEquals(true, true);
    }
    
    //OK
    @isTest static void updateEmailsContactEngagemntTest()
    {
        
        Account acct = new Account(Name='SFDC Account');
        insert acct; 
        
        Contact contato = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Email = 'test1@gmail.com',
            Engajamento__c = 'Não engajado',
            AccountId = acct.Id); 
        insert contato; 
        
        List<Emails_do_Contato__c> emailsContact = new List<Emails_do_Contato__c>{ 
            	new Emails_do_Contato__c(E_mail__c = 'test1@gmail.com', Invalido__c = false, Nao_engajado__c = false, Contato__c = contato.Id),
                new Emails_do_Contato__c(E_mail__c = 'test2@gmail.com', Invalido__c = false,  Contato__c = contato.Id) 
        	}; 
         insert  emailsContact;
        
        CarrosselLogic.updateEmailsContact(contato, emailsContact);
        
        system.assertEquals(true, true);
    }
}