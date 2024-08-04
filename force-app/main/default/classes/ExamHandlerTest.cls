@isTest
public with sharing class ExamHandlerTest {
    @isTest
    static void testGetAvailableExamsAreAvailableExams() {
        List<Exam__c> testExams = TestDataFactory.createExams(3, true, true);

        Test.startTest();
        Map<String, String> result = ExamHandler.getAvailableExams();
        Test.stopTest();

        validateExams(testExams, result);
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

        validateExams(testAvailableExams, result);
    }

    @isTest
    static void testMakeExam() {
        Exam__c exam = TestDataFactory.createExams(1, true, true)[0];
        TestDataFactory.makeExam(exam, 4);

        Test.startTest();
        List<Question__c> result = ExamHandler.makeExam(exam.URI__c);
        Test.stopTest();

        Map<String, Integer> questionsPerTopic = calculateQuestionsPerTopic(exam);

        Assert.areEqual(exam.Number_of_Questions__c, result.size());

        for (Question__c question : result) {
            String currentTopic = question.Topic__r.Name;
            questionsPerTopic.put(currentTopic, questionsPerTopic.get(currentTopic) - 1);
            Assert.isTrue(questionsPerTopic.keySet().contains(currentTopic), 'The question\'s topic must be one of the exam\'s defined topics.');
        }

        for (Integer remainingQuestions : questionsPerTopic.values()) {
            Assert.areEqual(0, remainingQuestions);
        }
    }

    private static void validateExams(List<Exam__c> testExams, Map<String, String> result) {
        for (Exam__c e : testExams) {
            Assert.isTrue(result.keySet().contains(e.Name), 'The key should be the exam name.');
            Assert.isTrue(result.values().contains(e.URI__c), 'The value should be the exam URI.');
        }

        Assert.areEqual(testExams.size(), result.size());
    }

    private static Map<String, Integer> calculateQuestionsPerTopic(Exam__c exam) {
        List<Exam_Topic__c> examTopics = [SELECT Name, Coverage_Percentage__c FROM Exam_Topic__c WHERE Exam__c = :exam.Id];
        Map<String, Integer> questionsPerTopic = new Map<String, Integer>();
        Integer actualTotalOfQuestions = 0;

        for (Exam_Topic__c et : examTopics) {
            Integer numberOfQuestions = (Integer) Math.floor(exam.Number_of_Questions__c * et.Coverage_Percentage__c / 100);
            questionsPerTopic.put(et.Name, numberOfQuestions);

            actualTotalOfQuestions += numberOfQuestions;
        }

        Integer questionsRemaining = Integer.valueOf(exam.Number_of_Questions__c) - actualTotalOfQuestions;

        if (questionsRemaining > 0) {
            String topicName = examTopics[0].Name;
            questionsPerTopic.put(topicName, questionsPerTopic.get(topicName) + questionsRemaining);
        }

        return questionsPerTopic;
    }
}
