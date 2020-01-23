/**
 * Test class for AnonymizationDatabase class
 */
@isTest
private class AnonymizationDatabaseTest {
    @isTest
    private static void itShouldWithGeneration() {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none', 
            AnnualRevenue = 15000
        );
        insert account;
        
        DateTime nowDateTime = DateTime.now();
        
        Event event = new Event(
            WhatId = account.Id, 
            ShowAs = 'Free', 
            StartDateTime = nowDateTime, 
            DurationInMinutes = 60
        );
        insert event;
        
        Date todayDate = Date.today();
        
        Test.startTest();
        
        AnonymizationDatabase anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{account}, 
            new Map<String,Object> {
                'Name' => 'testingErased', 
                'Phone' => 'phoneErased', 
                'Type' => null, 
                'Website' => 'http://errased.none', 
                'NumberOfEmployees' => 0, 
                'AnnualRevenue' => 0
            }, 
            new Set<String> {
                'Name', 
                'Phone', 
                'Type', 
                'Website', 
                'NumberOfEmployees', 
                'AnnualRevenue'
            }
        );
        List<Account> anonymizedData = anonymizationClass.anonymize(true);
        
        anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{event}, 
            new Map<String,Object> {
                'ShowAs' => 'Busy', 
                'StartDateTime' => DateTime.parse('01/01/2000 00:00'), 
                'ActivityDate' => Date.parse('01/01/2000')
            }, 
            new Set<String> {
                'ShowAs', 
                'StartDateTime', 
                'ActivityDate'
            }
        );
        List<Event> anonymizedEventData = anonymizationClass.anonymize(true);
        
        Test.stopTest();
        
        System.assertNotEquals(null, anonymizedData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedData.size(), 'Output sObject list cannot be empty');
        
        Account accountAnonymized = anonymizedData[0];
        System.assertEquals('testingErased', accountAnonymized.Name);
        System.assertEquals('phoneErased', accountAnonymized.Phone);
        System.assertEquals(null, accountAnonymized.Type);
        System.assertEquals('http://errased.none', accountAnonymized.Website);
        System.assertEquals(0, accountAnonymized.NumberOfEmployees);
        
        System.assertNotEquals(null, anonymizedEventData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedEventData.size(), 'Output sObject list cannot be empty');
        
        Event eventAnonymized = anonymizedEventData[0];
        System.assertEquals('Busy', eventAnonymized.ShowAs);
        System.assertEquals(DateTime.parse('01/01/2000 00:00'), eventAnonymized.StartDateTime);
        System.assertEquals(Date.parse('01/01/2000'), eventAnonymized.ActivityDate);
    }
    
    @isTest
    private static void itShouldWithGenerationExceptions() {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none', 
            AnnualRevenue = 15000
        );
        insert account;
        
        DateTime nowDateTime = DateTime.now();
        
        Event event = new Event(
            WhatId = account.Id, 
            ShowAs = 'Free', 
            StartDateTime = nowDateTime, 
            DurationInMinutes = 60
        );
        insert event;
        
        Date todayDate = Date.today();
        
        Test.startTest();
        
        AnonymizationDatabase anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{event}, 
            new Map<String,Object> {
                'ShowAs' => 'fdhfg', 
                'StartDateTime' => DateTime.parse('01/01/2000 00:00'), 
                'ActivityDate' => Date.parse('01/01/2000')
            }, 
            new Set<String> {
                'ShowAs', 
                'StartDateTime', 
                'ActivityDate'
            }
        );
        
        try {
            List<Event> anonymizedEventData = anonymizationClass.anonymize(true);
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongPicklistElementException') {
                throw error;
            }
            System.assert(true, 'WrongPicklistElementException is supposed to happen.');
        }
        
        anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{event}, 
            new Map<String,Object> {
                'ShowAs' => 'Busy', 
                'StartDateTime' => DateTime.parse('01/01/2000 00:00')
            }, 
            new Set<String> {
                'ShowAs', 
                'StartDateTime', 
                'fghhd'
            }
        );
        
        try {
            List<Event> anonymizedEventData = anonymizationClass.anonymize(true);
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.SObjectFieldNotFoundException') {
                throw error;
            }
            System.assert(true, 'SObjectFieldNotFoundException is supposed to happen.');
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void itShouldWithoutGeneration() {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none', 
            AnnualRevenue = 15000
        );
        insert account;
        
        Date todayDate = Date.today();
        
        Test.startTest();
        
        List<Account> anonymizedData = AnonymizationDatabase.anonymize(
            new Map<Id,sObject>{account.Id => account}, 
            new Map<Id,Map<String,Object>>{
                account.Id => new Map<String,Object> {
                    'Name' => 'testingErased', 
                    'Phone' => 'phoneErased', 
                    'Type' => null, 
                    'Website' => 'http://errased.none', 
                    'NumberOfEmployees' => 0, 
                    'AnnualRevenue' => 0
                }
            }, 
            true
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, anonymizedData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedData.size(), 'Output sObject list cannot be empty');
        
        Account accountAnonymized = anonymizedData[0];
        System.assertEquals('testingErased', accountAnonymized.Name);
        System.assertEquals('phoneErased', accountAnonymized.Phone);
        System.assertEquals(null, accountAnonymized.Type);
        System.assertEquals('http://errased.none', accountAnonymized.Website);
        System.assertEquals(0, accountAnonymized.NumberOfEmployees);
    }
    
    @isTest
    private static void itShouldWithoutData() {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none', 
            AnnualRevenue = 15000
        );
        insert account;
        
        Test.startTest();
        
        AnonymizationDatabase anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{account},
            null, 
            new Set<String> {
                'Name', 
                'Phone', 
                'Type', 
                'Website', 
                'NumberOfEmployees',
                'AnnualRevenue'
            }
        );
        List<Account> anonymizedData = anonymizationClass.anonymize(true);
        
        Test.stopTest();
        
        System.assertNotEquals(null, anonymizedData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedData.size(), 'Output sObject list cannot be empty');
        
        Account accountAnonymized = anonymizedData[0];
        System.assertEquals(null, accountAnonymized.Name);
        System.assertEquals(null, accountAnonymized.Phone);
        System.assertEquals(null, accountAnonymized.Type);
        System.assertEquals(null, accountAnonymized.Website);
        System.assertEquals(null, accountAnonymized.NumberOfEmployees);
    }
    
    @isTest
    private static void itShouldWithNullElements() {
        Test.startTest();
        
        try {
            AnonymizationDatabase anonymizationClass = new AnonymizationDatabase(
                null, 
                null, 
                null
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.NullParameterException') {
                throw error;
            }
            System.assert(true, 'NullParameterException is supposed to happen.');
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void itShouldWithRequiredData() {
        String email = 'hftgyhfc@hjg.yt';
        Id profileId = [SELECT Id FROM Profile ORDER BY Id ASC LIMIT 1].Id;
        Id newProfileId = [SELECT Id FROM Profile ORDER BY Id DESC LIMIT 1].Id;
        User user = new User(
            Username = email,
            LastName = email.substringBefore('@'),
            Email = email,
            Alias = 'FixTest',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'fr',
            IsActive = true,
            ProfileId = profileId
        );
        insert user;
        User existingUserAnonymized = new User(
            Username = 'hgfhfgfdsgfdg@none.null1',
            LastName = 'erasedAn',
            Email = 'erased@none.null',
            Alias = 'FixTest',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'fr',
            IsActive = true,
            ProfileId = newProfileId
        );
        insert existingUserAnonymized;
        
        Test.startTest();
        
        AnonymizationDatabase anonymizationClass = new AnonymizationDatabase(
            new List<sObject>{user}, 
            new Map<String,Object> {
                'Username' => 'hgfhfgfdsgfdg@none.null', 
                'LastName' => 'erasedAn',  
                'Email' => 'erased@none.null', 
                'ProfileId' => newProfileId
            }, 
            new Set<String> {
                'Username', 
                'LastName', 
                'Email', 
                'Alias', 
                'ProfileId'
            }
        );
        List<User> anonymizedData = anonymizationClass.anonymize(true);
        
        Test.stopTest();
        
        System.assertNotEquals(null, anonymizedData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedData.size(), 'Output sObject list cannot be empty');
        
        User userAnonymized = anonymizedData[0];
        System.assertEquals('hgfhfgfdsgfdg@none.null2', userAnonymized.Username);
        System.assertEquals('erasedAn', userAnonymized.LastName);
        System.assertEquals('erased@none.null', userAnonymized.Email);
        System.assertEquals(null, userAnonymized.Alias);
        System.assertEquals(newProfileId, userAnonymized.ProfileId);
    }
    
    @isTest
    private static void itShouldWithRequiredDataWithoutGeneration() {
        String email = 'hftgyhfc@hjg.yt';
        Id profileId = [SELECT Id FROM Profile ORDER BY Id ASC LIMIT 1].Id;
        Id newProfileId = [SELECT Id FROM Profile ORDER BY Id DESC LIMIT 1].Id;
        User user = new User(
            Username = email,
            LastName = email.substringBefore('@'),
            Email = email,
            Alias = 'FixTest',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'fr',
            IsActive = true,
            ProfileId = profileId
        );
        insert user;
        
        Test.startTest();
        
        List<User> anonymizedData = AnonymizationDatabase.anonymize(
            new Map<Id,sObject>{user.Id => user}, 
            new Map<Id,Map<String,Object>>{
                user.Id => new Map<String,Object> {
                    'Username' => 'hgfhfgfdsgfdg1@none.null', 
                    'LastName' => 'erasedAn',  
                    'Email' => 'erased@none.null', 
                    'Alias' => 'erased', 
                    'ProfileId' => newProfileId
                }
            }, 
            true
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, anonymizedData, 'Output sObject list cannot be null');
        System.assertEquals(1, anonymizedData.size(), 'Output sObject list cannot be empty');
        
        User userAnonymized = anonymizedData[0];
        System.assertEquals('hgfhfgfdsgfdg1@none.null', userAnonymized.Username);
        System.assertEquals('erasedAn', userAnonymized.LastName);
        System.assertEquals('erased@none.null', userAnonymized.Email);
        System.assertEquals('erased', userAnonymized.Alias);
        System.assertEquals(newProfileId, userAnonymized.ProfileId);
    }
    
    @isTest
    private static void itShouldWithoutGenerationExceptionsCovering() {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none'
        );
        insert account;
        
        Date todayDate = Date.today();
        
        Test.startTest();
        
        List<Account> anonymizedData = AnonymizationDatabase.anonymize(
            new Map<Id,sObject>{account.Id => account}, 
            new Map<Id,Map<String,Object>>(), 
            true
        );
        
        Map<Id,Map<String,Object>> dataAnonymized = new Map<Id,Map<String,Object>>{
            account.Id => new Map<String,Object> {
                'Name' => 'testingErased', 
                'Phone' => 'phoneErased', 
                'Type' => null, 
                'Website' => 'http://errased.none', 
                'NumberOfEmployees' => 'string', 
                'AnnualRevenue' => 0
            }
        };
        
        try {
            anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{account.Id => account}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(account.Id).put('NumberOfEmployees', 0);
        dataAnonymized.get(account.Id).put('Phone', 45);
        try {
            anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{account.Id => account}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(account.Id).put('Phone', 'phoneErased');
        dataAnonymized.get(account.Id).put('Website', 45);
        try {
            anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{account.Id => account}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(account.Id).put('Website', 'http://errased.none');
        dataAnonymized.get(account.Id).put('AnnualRevenue', 'phoneErased');
        try {
            anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{account.Id => account}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void itShouldWithoutGenerationExceptionsCovering2 () {
        Account account = new Account(
            Name = 'TestingToErase', 
            Phone = '311h54', 
            NumberOfEmployees = 15, 
            Type = 'Autre', 
            Website = 'https://toerase.none'
        );
        insert account;
        
        DateTime nowDateTime = DateTime.now();
        Date todayDate = Date.today();
        
        Event event = new Event(
            WhatId = account.Id, 
            ShowAs = 'Free', 
            StartDateTime = nowDateTime, 
            ActivityDate = todayDate, 
            DurationInMinutes = 60
        );
        insert event;
        
        Test.startTest();
        
        Map<Id,Map<String,Object>> dataAnonymized = new Map<Id,Map<String,Object>>{
            event.Id => new Map<String,Object> {
                'ShowAs' => 45, 
                'StartDateTime' => DateTime.parse('01/01/2000 00:00'), 
                'ActivityDate' => Date.parse('01/01/2000')
            }
        };
        
        try {
            List<Event> anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{event.Id => event}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(event.Id).put('ShowAs', 'Busy');
        dataAnonymized.get(event.Id).put('StartDateTime', 'gdfhfg');
        try {
            List<Event> anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{event.Id => event}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(event.Id).put('StartDateTime', DateTime.parse('01/01/2000 00:00'));
        dataAnonymized.get(event.Id).put('WhatId', 4510);
        try {
            List<Event> anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{event.Id => event}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        dataAnonymized.get(event.Id).put('WhatId', account.Id);
        dataAnonymized.get(event.Id).put('ActivityDate', 'string');
        try {
            List<Event> anonymizedData = AnonymizationDatabase.anonymize(
                new Map<Id,sObject>{event.Id => event}, 
                dataAnonymized, 
                true
            );
        } catch(Exception error) {
            String errorType = error.getTypeName();
            if(errorType != 'AnonymizationDatabase.WrongDataTypeException') {
                throw error;
            }
            System.assert(true, 'WrongDataTypeException is supposed to happen.');
        }
        
        Test.stopTest();
    }
}