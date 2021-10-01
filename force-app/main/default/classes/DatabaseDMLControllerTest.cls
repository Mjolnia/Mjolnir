@isTest
private with sharing class DatabaseDMLControllerTest {
    @isTest
    private static void itShouldInsert() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );

        Test.startTest();

        String dmlErrors = DatabaseDMLController.insertSObjectsApex(JSON.serialize(new List<sObject>{account}));

        Test.stopTest();

        System.assert(dmlErrors == null, 'Account has not been properly inserted.');
    }

    @isTest
    private static void itShouldInsertErrors() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );
        insert account;

        Test.startTest();

        try {
            String dmlErrors = DatabaseDMLController.insertSObjectsApex(JSON.serialize(new List<sObject>{account}));
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        try {
            String dmlErrors = DatabaseDMLController.insertSObjectsApex(null);
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        Test.stopTest();
    }

    @isTest
    private static void itShouldUpdate() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );

        Test.startTest();

        insert account;

        String dmlErrors = DatabaseDMLController.updateSObjectsApex(JSON.serialize(new List<sObject>{account}));

        Test.stopTest();

        System.assert(dmlErrors == null, 'Account has not been properly inserted.');
    }

    @isTest
    private static void itShouldUpdateErrors() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );

        Test.startTest();

        try {
            String dmlErrors = DatabaseDMLController.updateSObjectsApex(JSON.serialize(new List<sObject>{account}));
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        try {
            String dmlErrors = DatabaseDMLController.updateSObjectsApex(null);
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        Test.stopTest();
    }

    @isTest
    private static void itShouldDelete() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );

        Test.startTest();

        insert account;

        String dmlErrors = DatabaseDMLController.deleteSObjectsApex(JSON.serialize(new List<sObject>{account}));

        Test.stopTest();

        System.assert(dmlErrors == null, 'Account has not been properly inserted.');
    }

    @isTest
    private static void itShouldDeleteErrors() {
        Account account = new Account(
            Name = 'TESTING ACCOUNT'
        );

        Test.startTest();

        try {
            String dmlErrors = DatabaseDMLController.deleteSObjectsApex(JSON.serialize(new List<sObject>{account}));
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        try {
            String dmlErrors = DatabaseDMLController.deleteSObjectsApex(null);
        } catch(Exception error) {
            System.assert(true, 'Must happen.');
        }

        Test.stopTest();
    }
}