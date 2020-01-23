@isTest
private class DatabaseRequesterWithSharingTest {
    @isTest
    private static void itShouldSOQL() {
        Test.startTest();
        
        DatabaseRequesterWithSharing.getSelectFieldsFromSObject(
            new Set<String>{'Id'}, 
            'Account', 
            'everything', 
            'Name != \'NULL\'', 
            'SECURITY_ENFORCED', 
            null, 
            null, 
            'Name ASC', 
            '1', 
            '0', 
            'VIEW', 
            null
        );
        
        DatabaseRequesterWithSharing.getSelectFieldsFromSObjectGroupBy(
            new Set<String>{'Name'}, 
            'Account', 
            'everything', 
            'Name != \'NULL\'', 
            'SECURITY_ENFORCED', 
            'Name', 
            'Name != NULL', 
            'Name ASC', 
            '1', 
            '0'
        );
        
        DatabaseRequesterWithSharing.getSelectFieldsFromSObjectFor(
            new Set<String>{'Id'}, 
            'Account', 
            'everything', 
            'Name != \'NULL\'', 
            'SECURITY_ENFORCED', 
            'Name ASC', 
            '1', 
            '0', 
            'VIEW'
        );
        
        DatabaseRequesterWithSharing.getSelectStarFromSObject(
            'Account', 
            'everything', 
            'Name != \'NULL\'', 
            'SECURITY_ENFORCED', 
            'Name ASC', 
            '1', 
            '0', 
            'VIEW'
        );
            
        Test.stopTest();
    }
    
    @isTest
    private static void itShouldSOSL() {
        Test.startTest();
        
        DatabaseRequesterWithSharing.searchInSObjects(
            'TEST', 
            'ALL FIELDS', 
            'Account(Id, Name), Contact(Id, LastName, FirstName)', 
            new List<String>{'HIGHLIGHT', 'METADATA = \'LABELS\'', 'SNIPPET', 'SPELL_CORRECTION = FALSE'}, 
            '5', 
            null
        );
        
        DatabaseRequesterWithSharing.searchInSObjects(
            'TEST', 
            'ALL FIELDS', 
            'Account(Id, Name), Contact(Id, LastName, FirstName)', 
            new List<String>{'HIGHLIGHT', 'METADATA = \'LABELS\'', 'SNIPPET', 'SPELL_CORRECTION = FALSE'}, 
            '5'
        );
            
        Test.stopTest();
    }
    
    @testSetup
    private static void initData() {
        Test.startTest();
		
        Account account = new Account(
            Name = 'TEST ' + String.valueOf(DateTime.now().getTime())
        );
        insert account;
		
        insert new Contact(
            AccountId = account.Id, 
            LastName = 'TEST', 
            FirstName = 'TEST', 
            Email = String.valueOf(DateTime.now().getTime()) + '@testing.com'
        );
            
        Test.stopTest();
    }
}