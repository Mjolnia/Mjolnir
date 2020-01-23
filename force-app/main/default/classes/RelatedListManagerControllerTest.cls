@isTest
private class RelatedListManagerControllerTest {
    @isTest
    private static void itShould() {
        String sObjectName = 'Account';
        List<String> fieldsToQuery = new List<String>{'Name', 'DandbCompanyId', 'Industry'};
        Account account = [SELECT Id FROM Account LIMIT 1];
            
        Test.startTest();
        
        RelatedListManagerController.getFieldMetadataApex(sObjectName, fieldsToQuery);
        RelatedListManagerController.getRowsApex(account.Id, sObjectName, 'ParentId', fieldsToQuery);
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