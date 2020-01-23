@isTest
private class PicklistHelperTest {
    @isTest
    private static void itShould() {
        Test.startTest();
        
        PicklistHelper.getPickListValues('Account', 'Industry');
        PicklistHelper.getPickListValuesAura('Account', 'Industry');
        PicklistHelper.getPickListValuesSet('Account', 'Industry');
        PicklistHelper.getPickListLabelByValueMap('Account', 'Industry');
        PicklistHelper.getPickListLabelByValueMapAura('Account', 'Industry');
        PicklistHelper.getDependentPicklistValues('Account', 'Industry');
        PicklistHelper.getDependentPicklistValuesAura('Account', 'Industry');
        PicklistHelper.getDependentPicklistValuesAura('Account', '');
        PicklistHelper.getDependentPicklistValuesAura('', '');
        
        try {
            PicklistHelper.getPickListValuesAura(null, null);
        } catch(AuraHandledException error) {
            System.debug('Covered exception');
        }
        
        try {
            PicklistHelper.getPickListLabelByValueMapAura(null, null);
        } catch(AuraHandledException error) {
            System.debug('Covered exception');
        }
        
        Test.stopTest();
    }
}