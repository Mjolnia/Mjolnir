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
        
        RequestBuilder.getSOQLQueryGroupBy(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOQLQueryFor(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOQLQuerySimple(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOQLInnerQuery(
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
        
        RequestBuilder.getSOQLInnerQueryGroupBy(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOQLInnerQueryFor(
            new List<String>{'Id'}, 
            'Account', 
            null, 
            null, 
            null, 
            null, 
            null, 
            null, 
            null
        );
        
        RequestBuilder.getSOQLInnerQuerySimple(
            new List<String>{'Id'}, 
            'Account', 
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