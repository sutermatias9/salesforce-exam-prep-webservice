@isTest
public with sharing class TestDataFactory {
    public static void makeExam(Exam__c exam, Integer numberOfExamTopics) {
        List<Exam_Topic__c> examTopics = createExamTopics(exam.Id, numberOfExamTopics, true);

        List<Question__c> questionsToInsert = new List<Question__c>();

        for (Exam_Topic__c et : examTopics) {
            List<Question__c> questions = createQuestions(et.Topic__c, (Integer) exam.Number_of_Questions__c, false);
            questionsToInsert.addAll(questions);
        }

        insert questionsToInsert;
    }

    public static List<Exam__c> createExams(Integer numberOfExams, Boolean isAvailable, Boolean doInsert) {
        List<Exam__c> examList = new List<Exam__c>();

        for (Integer i = 0; i < numberOfExams; i++) {
            Long random = System.currentTimeMillis();

            Exam__c exam = new Exam__c();
            exam.Name = 'test exam ' + i + random;
            exam.URI__c = 'testexam' + i + random;
            exam.Available__c = isAvailable;
            exam.Number_of_Questions__c = 65;
            exam.Time_to_Complete_minutes__c = 60;
            exam.Passing_Score__c = 65;
            examList.add(exam);
        }

        if (doInsert) {
            insert examList;
        }

        return examList;
    }

    public static List<Exam_Topic__c> createExamTopics(Id examId, Integer numberOfExamTopics, Boolean doInsert) {
        List<Exam_Topic__c> examTopics = new List<Exam_Topic__c>();
        List<Topic__c> topics = createTopics(numberOfExamTopics, true);

        Integer coveragePerTopic = Math.round(100 / numberOfExamTopics);

        for (Integer i = 0; i < numberOfExamTopics; i++) {
            Exam_Topic__c examTopic = new Exam_Topic__c();
            examTopic.Exam__c = examId;
            examTopic.Topic__c = topics[i].Id;

            // If it's the last one, set a percentage to reach 100% exam coverage
            if (i == numberOfExamTopics - 1) {
                Integer amountToReach100 = 100 - coveragePerTopic * numberOfExamTopics;
                examTopic.Coverage_Percentage__c = coveragePerTopic + amountToReach100;
            } else {
                examTopic.Coverage_Percentage__c = coveragePerTopic;
            }

            examTopics.add(examTopic);
        }

        if (doInsert) {
            insert examTopics;
        }

        return examTopics;
    }

    private static List<Topic__c> createTopics(Integer numberOfTopics, Boolean doInsert) {
        List<Topic__c> topics = new List<Topic__c>();

        for (Integer i = 0; i < numberOfTopics; i++) {
            topics.add(new Topic__c(Name = 'Test Topic ' + i));
        }

        if (doInsert) {
            insert topics;
        }

        return topics;
    }

    public static List<Question__c> createQuestions(Id topicId, Integer numberOfQuestions, Boolean doInsert) {
        List<Question__c> questions = new List<Question__c>();

        for (Integer i = 0; i < numberOfQuestions; i++) {
            Question__c question = new Question__c();
            question.Topic__c = topicId;
            question.Question_Text__c = 'test question text ' + i + System.currentTimeMillis();
            question.Option_A__c = 'Test option A';
            question.Option_B__c = 'Test option B';
            question.Option_C__c = 'Test option C';
            question.Option_D__c = 'Test option D';
            question.Correct_Answers__c = 'Option A';
            questions.add(question);
        }

        if (doInsert) {
            insert questions;
        }

        return questions;
    }
}
