public with sharing class InsuranceDashboardController {

    @AuraEnabled
    public static Integer getPolicyCount() {
        return [SELECT COUNT() FROM Policy__c];
    }

    @AuraEnabled
    public static Integer getClaimCount() {
        return [SELECT COUNT() FROM Claim__c];
    }
    @AuraEnabled
    public static Decimal getTotalPremium() {
        AggregateResult result = [
            SELECT SUM(Premium__c) totalPremium
            FROM Policy__c
        ];

        Decimal totalPremium = (Decimal) result.get('totalPremium');

        return totalPremium == null ? 0 : totalPremium;
    }
    @AuraEnabled
    public static Decimal getTotalClaimAmount() {
        AggregateResult result = [
            SELECT SUM(Claim_Amount__c) totalClaimAmount
            FROM Claim__c
        ];

        Decimal totalClaimAmount = (Decimal) result.get('totalClaimAmount');

        return totalClaimAmount == null ? 0 : totalClaimAmount;
    }
    @AuraEnabled
    public static List<Policy__c> getPolicies() {
        return [
            SELECT Id, Name, Premium__c, Policy_Start_Date__c, Policy_State__c
            FROM Policy__c
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }
    @AuraEnabled
public static List<Claim__c> getClaims() {
    return [
        SELECT Id, Name, Claim_Amount__c, Approval_Status__c, Policy__c
        FROM Claim__c
        ORDER BY CreatedDate DESC
        LIMIT 5
    ];
}
    @AuraEnabled
public static Map<String, Integer> getClaimStatusCounts() {

    Map<String, Integer> statusCounts = new Map<String, Integer>();

    statusCounts.put('New', 0);
    statusCounts.put('SubmittedForApproval', 0);
    statusCounts.put('Approved', 0);
    statusCounts.put('Rejected', 0);

    for (AggregateResult result : [
        SELECT Approval_Status__c status, COUNT(Id) total
        FROM Claim__c
        GROUP BY Approval_Status__c
    ]) {

        String status = (String) result.get('status');
        Integer total = (Integer) result.get('total');

        if (status == null || status == '') {
            statusCounts.put(
                'New',
                statusCounts.get('New') + total
            );
        }
        else if (status == 'New') {
            statusCounts.put('New', total);
        }
        else if (status == 'Submitted for Approval') {
            statusCounts.put('SubmittedForApproval', total);
        }
        else if (status == 'Approved') {
            statusCounts.put('Approved', total);
        }
        else if (status == 'Rejected') {
            statusCounts.put('Rejected', total);
        }
    }
    return statusCounts;
}
}