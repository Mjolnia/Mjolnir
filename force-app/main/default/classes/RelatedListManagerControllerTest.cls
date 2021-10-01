@isTest
private class RelatedListManagerControllerTest {
    @isTest
    private static void itShould() {
        String sObjectName = 'Account';
        List<String> fieldsToQuery = new List<String>{'Name', 'ParentId', 'Industry'};
        Account account = [SELECT Id FROM Account LIMIT 1];
            
        Test.startTest();

        RelatedListManagerController.getDataApex(fieldsToQuery, sObjectName, null);
        RelatedListManagerController.getFieldMetadataApex(sObjectName, fieldsToQuery, 'None');
        RelatedListMAnagerController.saveRowsApex('[]', '[]', '[]');
        
        Test.stopTest();
    }
    
    @testSetup
    private static void initData() {
        Test.startTest();
        
        insert new Account(
            Name = 'TestingAccountRLM'
        );
        
        Test.stopTest();
    }
}