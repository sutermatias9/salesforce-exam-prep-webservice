@RestResource(urlMapping='/AvailableExams')
global with sharing class AvailableExamsService {
    @HttpGet
    global static Map<String, String> getAvailableExams() {
        Map<String, String> availableExams = ExamHandler.getAvailableExams();
        return availableExams;
    }
}
