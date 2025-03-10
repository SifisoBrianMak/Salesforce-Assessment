public with sharing class CalendarificAPIController {
    @AuraEnabled(cacheable=true)
    public static String getPublicHolidays(String year) {
        String apiKey = '24c5e86734eb44dc4a962826324a5546e74dc42f';
        String endpoint = 'https://calendarific.com/api/v2/holidays?api_key=' + apiKey + '&country=ZA&year=' + year;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody(); // Return the raw JSON response
        } else {
            throw new AuraHandledException('API Error: ' + res.getStatus());
        }
    }
}