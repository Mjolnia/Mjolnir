@isTest
private class ImportSObjectWithJSONTest {
    @isTest
    private static void itShouldJSONToSObject() {
        Map<String,String> accountFieldToJSONField = new Map<String,String>{
            'Name' => 'accountName', 
            'AnnualRevenue' => 'accountAnnualRevenue', 
            'ParentId' => 'accountParentId'
        };

        Map<String,String> accountFieldToParentExternalKeyField = new Map<String,String>{
            'ParentId' => 'Name'
        };


        Map<String,String> contactFieldToJSONField = new Map<String,String>{
            'LastName' => 'contactLastName', 
            'FirstName' => 'contactFirstName', 
            'Birthdate' => 'contactBirthdate'
        };


        Map<String,String> eventFieldToJSONField = new Map<String,String>{
            'ActivityDateTime' => 'eventActivityDateTime'
        };



        Map<String,Object> accountDataAsJSON = new Map<String,Object>{
            'accountName' => 'Account test name', 
            'accountAnnualRevenue' => '5.7', 
            'accountParentId' => 'PARENTTESTACCOUNT'
        }; 

        Account parentAccount = [SELECT Id, Name FROM Account WHERE Name = 'PARENTTESTACCOUNT' LIMIT 1];

        Map<String,Set<String>> accountReferencesFilters = new Map<String,Set<String>>{
            'ParentId' => new Set<String>{
                (String) accountDataAsJSON.get(accountFieldToJSONField.get('ParentId'))
            }
        };

        Map<String,List<SObject>> accountReferencesExistingFilters = new Map<String,List<SObject>>{
            'ParentId' => new List<SObject>{parentAccount}
        };


        Date testingDate = Date.today().addYears(-10);

        Map<String,Object> contactDataAsJSON = new Map<String,Object>{
            'contactLastName' => 'TESTING', 
            'contactFirstName' => 'Contact test', 
            'contactBirthdate' => String.valueOf(testingDate)
        }; 


        DateTime testingDateTime = DateTime.now().addYears(-10);

        Map<String,Object> eventDataAsJSON = new Map<String,Object>{
            'eventActivityDateTime' => String.valueOf(testingDateTime)
        }; 

        Account account = new Account();
        Contact contact = new Contact();
        Event event = new Event();

        Test.startTest();

        ImportSObjectWithJSON importerAccount = new ImportSObjectWithJSON('Account', accountFieldToJSONField, accountFieldToParentExternalKeyField, false);
        importerAccount.buildReferencesMapJSONToSObject(accountReferencesFilters, accountReferencesExistingFilters);
        account = (Account) importerAccount.fillSObjectFromJSON(account, accountDataAsJSON);

        ImportSObjectWithJSON importerContact = new ImportSObjectWithJSON('Contact', contactFieldToJSONField, false);
        contact = (Contact) importerContact.fillSObjectFromJSON(contact, contactDataAsJSON);

        ImportSObjectWithJSON importerEvent = new ImportSObjectWithJSON('Event', eventFieldToJSONField, false);
        event = (Event) importerEvent.fillSObjectFromJSON(event, eventDataAsJSON);

        Test.stopTest();

        System.assertEquals('Account test name', account.Name);
        System.assertEquals(5.7, account.AnnualRevenue);
        System.assertEquals(parentAccount.Id, account.ParentId);
        
        System.assertEquals('TESTING', contact.LastName);
        System.assertEquals('Contact test', contact.FirstName);
        System.assertEquals(testingDate, contact.Birthdate);

        System.assertEquals(testingDateTime, event.ActivityDateTime);
    }

    @isTest
    private static void itShouldSObjectToJSON() {
        Map<String,String> accountFieldToJSONField = new Map<String,String>{
            'Name' => 'accountName', 
            'AnnualRevenue' => 'accountAnnualRevenue', 
            'ParentId' => 'accountParentId'
        };

        Map<String,String> accountFieldToParentExternalKeyField = new Map<String,String>{
            'ParentId' => 'Name'
        };


        Map<String,String> contactFieldToJSONField = new Map<String,String>{
            'LastName' => 'contactLastName', 
            'FirstName' => 'contactFirstName', 
            'Birthdate' => 'contactBirthdate'
        };


        Map<String,String> eventFieldToJSONField = new Map<String,String>{
            'ActivityDateTime' => 'eventActivityDateTime'
        };

        Date testingDate = Date.today().addYears(-10);
        DateTime testingDateTime = DateTime.now().addYears(-10);
        Account parent = [SELECT Id, Name FROM Account WHERE Name = 'PARENTTESTACCOUNT' LIMIT 1];

        Account account = new Account(
            Name = 'Account test name',
            AnnualRevenue = 5.7, 
            ParentId = parent.Id
        );
        account.Parent = parent;
        Contact contact = new Contact(
            LastName = 'TESTING', 
            FirstName = 'Contact test', 
            Birthdate = testingDate
        );
        Event event = new Event(
            ActivityDateTime = testingDateTime
        );

        
        JSONGenerator accountGenerator = JSON.createGenerator(false);
        accountGenerator.writeStartObject();
        JSONGenerator contactGenerator = JSON.createGenerator(false);
        contactGenerator.writeStartObject();
        JSONGenerator eventGenerator = JSON.createGenerator(false);
        eventGenerator.writeStartObject();

        Test.startTest();

        ImportSObjectWithJSON importerAccount = new ImportSObjectWithJSON('Account', accountFieldToJSONField, accountFieldToParentExternalKeyField, false);
        importerAccount.buildReferencesMapSObjectToJSON(
            new Map<String,Set<String>>{'ParentId' => new Set<String>{account.ParentId}}, 
            new Map<String,List<sObject>>{'ParentId' => new List<sObject>{parent}}
        );
        accountGenerator = importerAccount.generateJSONFromSObject(account, accountGenerator);

        ImportSObjectWithJSON importerContact = new ImportSObjectWithJSON('Contact', contactFieldToJSONField, false);
        contactGenerator = importerContact.generateJSONFromSObject(contact, contactGenerator);

        ImportSObjectWithJSON importerEvent = new ImportSObjectWithJSON('Event', eventFieldToJSONField, false);
        eventGenerator = importerEvent.generateJSONFromSObject(event, eventGenerator);

        Test.stopTest();

        accountGenerator.writeEndObject();
        contactGenerator.writeEndObject();
        eventGenerator.writeEndObject();

        System.assertEquals(
            '{"accountName":"Account test name","accountAnnualRevenue":5.7,"accountParentId":"PARENTTESTACCOUNT"}', 
            accountGenerator.getAsString()
        );
        
        System.assertEquals(
            '{"contactLastName":"TESTING","contactFirstName":"Contact test","contactBirthdate":"' + String.valueOf(testingDate) + '"}', 
            contactGenerator.getAsString()
        );

        System.assertEquals(
            '{"eventActivityDateTime":"' + String.valueOf(testingDateTime) + '"}', 
            eventGenerator.getAsString()
        );
    }

    @isTest
    private static void itShouldExceptions() {
        Map<String,String> accountFieldToJSONField = new Map<String,String>{
            'Name' => 'accountName', 
            'AnnualRevenue' => 'accountAnnualRevenue', 
            'ParentId' => 'accountParentId'
        };

        Map<String,String> accountFieldToParentExternalKeyField = new Map<String,String>{
            'ParentId' => 'Name'
        };

        Map<String,Object> accountDataAsJSON = new Map<String,Object>{
            'accountName' => 'Account test name', 
            'accountAnnualRevenue' => '5.7', 
            'accountPersonDoNotCall' => 'true', 
            'accountParentId' => 'PARENTTESTACCOUNT'
        }; 
        
        Account account = new Account();

        Contact firstContact = new Contact();
        Contact secondContact = new Contact();
        Contact thirdContact = new Contact();
        Contact fourthContact = new Contact();
        Contact fifthContact = new Contact();
        Contact sixthContact = new Contact();
        Contact seventhContact = new Contact();
        firstContact.ReportsTo = secondContact;
        secondContact.ReportsTo = thirdContact;
        thirdContact.ReportsTo = fourthContact;
        fourthContact.ReportsTo = fifthContact;
        fifthContact.ReportsTo = sixthContact;
        sixthContact.ReportsTo = seventhContact;

        Test.startTest();

        ImportSObjectWithJSON importerAccount = new ImportSObjectWithJSON('Account', accountFieldToJSONField, accountFieldToParentExternalKeyField, false);

        try {
            account = (Account) importerAccount.fillSObjectFromJSON(account, accountDataAsJSON);
            System.assert(false, 'ImportSObjectWithJSON.RequiredActionException must be thrown');
        } catch(ImportSObjectWithJSON.RequiredActionException error) {
            System.assert(true);
        }

        try {
            ImportSObjectWithJSON.get(firstContact, 'ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.Id');
            System.assert(false, 'ImportSObjectWithJSON.FieldTooDeepException must be thrown');
        } catch(ImportSObjectWithJSON.FieldTooDeepException error) {
            System.assert(true);
        }

        Test.stopTest();
    }

    @isTest
    private static void itShouldPrivate() {
        Date todayDate = Date.today();

        Contact contact = new Contact(
            Birthdate = todayDate
        );


        Test.startTest();

        String retrievedDate = ImportSObjectWithJSON.get(contact, 'Birthdate');

        Test.stopTest();

        System.assertEquals(String.valueOf(todayDate), retrievedDate);
    }

    @testSetup
    private static void initData() {
        Test.startTest();

        insert new Account(Name = 'PARENTTESTACCOUNT');
        insert new Account(Name = 'WrongPARENTTESTACCOUNT');

        Test.stopTest();
    }
}