@isTest
public with sharing class TestDataFactory {
    public static List<Exam__c> createExams(Integer numberOfExams, Boolean isAvailable, Boolean doInsert) {
        List<Exam__c> examList = new List<Exam__c>();

        for (Integer i = 0; i < numberOfExams; i++) {
            Long random = System.currentTimeMillis();

            Exam__c exam = new Exam__c();
            exam.Name = 'test exam ' + i + random;
            exam.URI__c = 'testexam' + i + random;
            exam.Available__c = isAvailable;
            exam.Number_of_Questions__c = 54;
            exam.Time_to_Complete_minutes__c = 60;
            exam.Passing_Score__c = 65;
            examList.add(exam);
        }

        if (doInsert) {
            insert examList;
        }

        return examList;
    }
}
