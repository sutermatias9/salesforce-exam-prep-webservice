public with sharing class ExamHandler {
    public static Map<String, String> getAvailableExams() {
        Map<String, String> availableExams = new Map<String, String>();

        for (Exam__c exam : [SELECT Name, URI__c FROM Exam__c WHERE Available__c = TRUE]) {
            availableExams.put(exam.Name, exam.URI__c);
        }

        return availableExams;
    }

    public static List<Question__c> makeExam(String examURI) {
        Exam__c exam = [
            SELECT Number_of_Questions__c, (SELECT Name, Coverage_Percentage__c FROM Exam_Topics__r)
            FROM Exam__c
            WHERE URI__c = :examURI
        ];

        Map<String, List<Question__c>> questionsByTopic = new Map<String, List<Question__c>>();
        Map<String, Integer> questionsPerTopic = new Map<String, Integer>();
        Integer total = 0;

        for (Exam_Topic__c topic : exam.Exam_Topics__r) {
            Integer numberOfQuestions = (Integer) Math.floor(exam.Number_of_Questions__c * topic.Coverage_Percentage__c / 100);

            questionsPerTopic.put(topic.Name, numberOfQuestions);
            questionsByTopic.put(topic.Name, new List<Question__c>());

            total += numberOfQuestions;
        }

        Integer questionsRemaining = Integer.valueOf(exam.Number_of_Questions__c) - total;

        // Add the remaining questions to the first exam topic, to get to the expected exam num of questions
        if (questionsRemaining > 0) {
            String topicName = exam.Exam_Topics__r[0].Name;
            questionsPerTopic.put(topicName, questionsPerTopic.get(topicName) + questionsRemaining);
        }

        distributeQuestionsByTopic(questionsByTopic, questionsPerTopic);

        List<Question__c> examQuestions = flat(questionsByTopic.values());
        shuffle(examQuestions);

        return examQuestions;
    }

    private static void distributeQuestionsByTopic(Map<String, List<Question__c>> questionsByTopic, Map<String, Integer> questionsPerTopic) {
        for (Question__c question : [
            SELECT Topic__r.Name, Question_Text__c, Option_A__c, Option_B__c, Option_C__c, Option_D__c, Option_E__c, Correct_Answers__c
            FROM Question__c
            WHERE Topic__r.Name IN :questionsByTopic.keySet()
        ]) {
            String currentTopic = question.Topic__r.Name;
            Integer maxNumberOfTopicQuestions = questionsPerTopic.get(currentTopic);
            List<Question__c> topicQuestions = questionsByTopic.get(currentTopic);

            if (topicQuestions.size() < maxNumberOfTopicQuestions) {
                topicQuestions.add(question);
            }
        }
    }

    private static List<Question__c> flat(List<List<Question__c>> questions) {
        List<Question__c> result = new List<Question__c>();

        for (List<Question__c> q : questions) {
            result.addAll(q);
        }

        return result;
    }

    private static void shuffle(List<Question__c> questions) {
        Integer size = questions.size();

        for (Integer currentIndex = size - 1; currentIndex > 0; currentIndex--) {
            Integer randomIndex = Integer.valueOf(Math.floor(Math.random() * currentIndex));

            Question__c temp = questions[currentIndex];
            questions[currentIndex] = questions[randomIndex];
            questions[randomIndex] = temp;
        }
    }
}
