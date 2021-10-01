@isTest
private class SObjectDataGetterTest {
    @isTest
    private static void itShould() {
        Contact c = [
            SELECT 
                Id, 
                Birthdate, 
                ReportsTo.LastName, 
                ReportsTo.ReportsTo.LastName, 
                ReportsTo.ReportsTo.ReportsTo.LastName, 
                ReportsTo.ReportsTo.ReportsTo.ReportsTo.LastName, 
                ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.LastName
            FROM Contact
            WHERE LastName = 'SACHA'
            LIMIT 1
        ];
        
        Test.startTest();

        String contactNameM1 = SObjectDataGetter.get(c, 'ReportsTo.LastName');
        String contactNameM2 = SObjectDataGetter.get(c, 'ReportsTo.ReportsTo.LastName');
        String contactNameM3 = SObjectDataGetter.get(c, 'ReportsTo.ReportsTo.ReportsTo.LastName');
        String contactNameM4 = SObjectDataGetter.get(c, 'ReportsTo.ReportsTo.ReportsTo.ReportsTo.LastName');
        String contactNameM5 = SObjectDataGetter.get(c, 'ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.LastName');
        String contactBirthdate = SObjectDataGetter.get(c, 'Birthdate');

        Set<String> contactFieldAPINames = SObjectDataGetter.getSObjectFieldNames('Contact');

        Test.stopTest();

        System.assertEquals('PIERRE', contactNameM1);
        System.assertEquals('ONDINE', contactNameM2);
        System.assertEquals('PETER', contactNameM3);
        System.assertEquals('REGIS', contactNameM4);
        System.assertEquals('CHEN', contactNameM5);

        try {
            String highManagerContactLastName = SObjectDataGetter.get(c, 'ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.LastName');
            System.assert(false);
        } catch(SObjectDataGetter.FieldTooDeepException e) {
            System.assert(true);
        }
    }

    @testSetup
    private static void initData() {
        Test.startTest();
        
        Contact m0 = new Contact(LastName = 'PIKACHU');
        insert m0;

        Contact m1 = new Contact(LastName = 'CHEN', ReportsToId = m0.Id);
        insert m1;

        Contact m2 = new Contact(LastName = 'REGIS', ReportsToId = m1.Id);
        insert m2;

        Contact m3 = new Contact(LastName = 'PETER', ReportsToId = m2.Id);
        insert m3;

        Contact m4 = new Contact(LastName = 'ONDINE', ReportsToId = m3.Id);
        insert m4;

        Contact m5 = new Contact(LastName = 'PIERRE', ReportsToId = m4.Id);
        insert m5;

        Contact c = new Contact(LastName = 'SACHA', Birthdate = Date.today().addYears(-10), ReportsToId = m5.Id);
        insert c;

        Test.stopTest();
    }
}