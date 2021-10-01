/**
 * Helper class for getting data and metadata on sObject.
 * @author Jeremy SML
 */
global class SObjectDataGetter {
    global class FieldTooDeepException extends Exception{}

    /**
     * Get the selected field from a SObject
     * @param so                            The sObject from which the function will retrieve the field value
     * @param fieldName                     The name of the field to retrieve from the SObject
     * @return String                       The string value of the requested field
     */
    global static String get(sObject so, String fieldName) {
        String[] splittedName = fieldName.split('\\.');
        return get_CORE(so, splittedName, 0);
    }
    
    /**
     * Generate the list of sObject field names
     * @param final String sObjectName      The API Name of the sObject
     * @return Set<String>                  The set of all the sObject fields API Name
     */
    global static Set<String> getSObjectFieldNames(final String sObjectName) {
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keySet();
    }

    private static String get_CORE(sObject so, List<String> splitted, Integer currentRelationDepth) {
        if(splitted.size() == 1) {
            if(so.get(splitted[0]) instanceof Date) {
                return String.valueOf((Date) so.get(splitted[0]));
            } else {
                return String.valueOf(so.get(splitted[0]));
            }
        } else {
            if(currentRelationDepth >= 5) {
                throw new FieldTooDeepException('Cannot go deeper than 5 level in relationship.');
            }
            sObject tmp = so.getSObject(splitted[0]);
            splitted.remove(0);
            return get_CORE(tmp, splitted, currentRelationDepth + 1);
        }
    }
}