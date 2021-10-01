@isTest
private class AuraHandlerControllerTest {
    @isTest
    private static void itShould() {
        Test.startTest();
        
        AuraHandlerController.getTranslations(new List<String>{'Account', 'Contact'});
        AuraHandlerController.getTranslationsAura(new List<String>{'Account', 'Contact'});
        
        try {
            AuraHandlerController.getTranslationsAura(null);
        } catch(Exception error) {
            System.debug('Exception covered.');
        }
        
        Test.stopTest();
    }
}