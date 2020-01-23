@isTest
private class AuraHelperControllerTest {
    @isTest
    private static void itShould() {
        Test.startTest();
        
        AuraHelperController.getTranslations(new List<String>{'Account', 'Contact'});
        AuraHelperController.getTranslationsAura(new List<String>{'Account', 'Contact'});
        
        try {
            AuraHelperController.getTranslationsAura(null);
        } catch(Exception error) {
            System.debug('Exception covered.');
        }
        
        Test.stopTest();
    }
}