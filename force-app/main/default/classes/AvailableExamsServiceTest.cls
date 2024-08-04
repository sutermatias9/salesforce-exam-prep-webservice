@isTest
public with sharing class AvailableExamsServiceTest {
    @TestSetup
    static void makeData() {
        List<Exam__c> exams = TestDataFactory.createExams(3, true, true);
        exams.addAll(TestDataFactory.createExams(8, false, true));

        for (Exam__c exam : exams) {
            TestDataFactory.makeExam(exam, Math.round(Math.random() * 5 + 1));
        }
    }

    @isTest
    static void testGetAvailableExams() {
        RestRequest request = new RestRequest();
        request.addHeader('content-type', 'application/json');
        request.requestURI = '/AvailableExams';
        request.httpMethod = 'GET';

        RestContext.request = request;

        Map<String, String> result = AvailableExamsService.getAvailableExams();

        List<Exam__c> exams = [SELECT Name, URI__c, Available__c FROM Exam__c];

        for (Exam__c exam : exams) {
            if (exam.Available__c) {
                Assert.isTrue(result.containsKey(exam.Name), 'All available exams should be in the map as a key.');
                Assert.isTrue(result.values().contains(exam.URI__c), 'Map values should contain the URI of the available exam.');
            } else {
                Assert.isFalse(result.containsKey(exam.Name), 'Unavailable exams should not be in the map.');
                Assert.isFalse(result.values().contains(exam.URI__c), 'The map values should not contain URIs from unavailable exams');
            }
        }
    }
}
