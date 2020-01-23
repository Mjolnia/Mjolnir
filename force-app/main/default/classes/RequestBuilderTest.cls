@isTest
private class RequestBuilderTest {
    @isTest
    private static void itShould() {
        Test.startTest();
        
        RequestBuilder.getSOQLQuery(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOSLQuery(
            'testing search', 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.testIfListNotNull(null);
        
        RequestBuilder.testIfListNotNull(new List<sObject>());
        
        Test.stopTest();
    }
}