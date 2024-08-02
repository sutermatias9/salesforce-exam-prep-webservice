@isTest
public with sharing class ExamHandlerTest {
    @isTest
    static void testGetAvailableExamsAreAvailableExams() {
        List<Exam__c> testExams = TestDataFactory.createExams(3, true, true);

        Test.startTest();
        Map<String, String> result = ExamHandler.getAvailableExams();
        Test.stopTest();

        for (Exam__c e : testExams) {
            Assert.isTrue(result.keySet().contains(e.Name), 'The key should be the exam name.');
            Assert.isTrue(result.values().contains(e.URI__c), 'The value should be the exam URI.');
        }

        Assert.areEqual(testExams.size(), result.size());
    }

    @isTest
    static void testGetAvailableExamsNoAvailableExams() {
        TestDataFactory.createExams(6, false, true);

        Test.startTest();
        Map<String, String> result = ExamHandler.getAvailableExams();
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'The map should be empty.');
    }

    @isTest
    static void testGetAvailableExamsMix() {
        List<Exam__c> testAvailableExams = TestDataFactory.createExams(3, true, true);
        TestDataFactory.createExams(6, false, true);

        Test.startTest();
        Map<String, String> result = ExamHandler.getAvailableExams();
        Test.stopTest();

        for (Exam__c e : testAvailableExams) {
            Assert.isTrue(result.keySet().contains(e.Name), 'The key should be the exam name.');
            Assert.isTrue(result.values().contains(e.URI__c), 'The value should be the exam URI.');
        }

        Assert.areEqual(testAvailableExams.size(), result.size());
    }
}
