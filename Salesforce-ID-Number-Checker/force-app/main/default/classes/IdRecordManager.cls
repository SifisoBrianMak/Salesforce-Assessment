public with sharing class IDRecordManager {
    @AuraEnabled
    public static Map<String, Object> saveOrUpdateIDRecord(String idNumber) {
        Map<String, Object> result = new Map<String, Object>(); // Use a map to return results or errors

        try {
            // Validate the ID number
            if (!isValidIDNumberWithChecksum(idNumber)) {
                result.put('success', false);
                result.put('message', 'Invalid ID Number');
                return result;
            }

            // Decode the ID number
            Date dob;
            try {
                String dobStr = idNumber.substring(0, 6);
                Integer year = Integer.valueOf(dobStr.substring(4, 6));
                if (year < 22) {
                    dob = Date.parse(dobStr.substring(0, 2) + '/' + dobStr.substring(2, 4) + '/20' + dobStr.substring(4, 6));
                } else {
                    dob = Date.parse(dobStr.substring(0, 2) + '/' + dobStr.substring(2, 4) + '/19' + dobStr.substring(4, 6));
                }
            } catch (Exception e) {
                result.put('success', false);
                result.put('message', 'Error parsing date of birth: ' + e.getMessage());
                return result;
            }

            Integer genderDigit = Integer.valueOf(idNumber.substring(6, 7));
            String gender = genderDigit < 5 ? 'Female' : 'Male';

            Boolean isCitizen = Integer.valueOf(idNumber.substring(10, 11)) == 0;

            // Query for existing record
            List<ID_Record__c> records = [SELECT Id, Search_Count__c FROM ID_Record__c WHERE ID_Number__c = :idNumber LIMIT 1];
            ID_Record__c record;

            try {
                if (records.isEmpty()) {
                    // Create a new record
                    record = new ID_Record__c(
                        ID_Number__c = idNumber,
                        Date_of_Birth__c = dob,
                        Gender__c = gender,
                        SA_Citizen__c = isCitizen,
                        Search_Count__c = 1
                    );
                    insert record;
                } else {
                    // Update the existing record
                    record = records[0];
                    record.Search_Count__c += 1;
                    update record;
                }

                result.put('success', true);
                result.put('message', 'Record saved successfully!');
                result.put('recordId', record.Id); // Return the record ID for confirmation
                return result;

            } catch (DmlException e) {
                // Handle DML exceptions without throwing AuraHandledException
                result.put('success', false);
                result.put('message', 'Error saving record: ' + truncateMessage(e.getMessage()));
                return result;
            }
        } catch (Exception e) {
            // Handle all other exceptions without throwing AuraHandledException
            result.put('success', false);
            result.put('message', 'An unexpected error occurred: ' + truncateMessage(e.getMessage()));
            return result;
        }
    }

    // Helper method to truncate long messages to avoid exceeding limits
    private static String truncateMessage(String message) {
        if (message != null && message.length() > 200) { // Truncate if message exceeds 200 characters
            return message.substring(0, 200) + '...';
        }
        return message;
    }

    private static Boolean isValidIDNumberWithChecksum(String idNumber) {
        if (idNumber == null || idNumber.length() != 13 || !isNumeric(idNumber)) {
            return false;
        }

        Integer sum = 0;
        Boolean isEven = true;
        for (Integer i = 0; i < idNumber.length(); i++) {
            Integer digit = Integer.valueOf(idNumber.substring(i, i + 1));
            if (!isEven) {
                digit *= 2;
                if (digit > 9) {
                    digit -= 9;
                }
            }
            sum += digit;
            isEven = !isEven;
        }
        return Math.mod(sum, 10) == 0;
    }

    private static Boolean isNumeric(String str) {
        Pattern pattern = Pattern.compile('^[0-9]+$');
        Matcher matcher = pattern.matcher(str);
        return matcher.matches();
    }
}