public with sharing class ExamHandler {
    public static Map<String, String> getAvailableExams() {
        Map<String, String> availableExams = new Map<String, String>();

        for (Exam__c exam : [SELECT Name, URI__c FROM Exam__c WHERE Available__c = TRUE]) {
            availableExams.put(exam.Name, exam.URI__c);
        }

        return availableExams;
    }
}
