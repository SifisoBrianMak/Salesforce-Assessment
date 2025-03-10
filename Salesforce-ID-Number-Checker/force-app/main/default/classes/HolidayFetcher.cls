public with sharing class HolidayFetcher {
    @AuraEnabled
    public static Map<String, Object> fetchHolidays(String year) {
        try {
            // Define the API endpoint
            String apiKey = '24c5e86734eb44dc4496282632445546e74dc42f';
            String endpoint = 'https://calendarific.com/api/v2/holidays?api_key=' + apiKey + '&country=ZA&year=' + year;

            // Create an HTTP request
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');

            // Send the request
            HttpResponse response = http.send(request);

            // Debug: Log the API response
            System.debug('API Response Status: ' + response.getStatus());
            System.debug('API Response Body: ' + response.getBody());

            // Check the response status code
            if (response.getStatusCode() == 200) {
                // Parse the response and return the holidays
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return new Map<String, Object>{
                    'success' => true,
                    'holidays' => responseMap
                };
            } else {
                return new Map<String, Object>{
                    'success' => false,
                    'message' => 'Error fetching holidays: ' + response.getStatus()
                };
            }
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error: ' + e.getMessage()
            };
        }
    }
}