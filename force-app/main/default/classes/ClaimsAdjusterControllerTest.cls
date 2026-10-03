@isTest
private class ClaimsAdjusterControllerTest {

    @testSetup
    static void setupTestData() {

        User u = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        Id policyRT =
            Schema.SObjectType.Policy__c
                .getRecordTypeInfosByDeveloperName()
                .get('Auto')
                .getRecordTypeId();

        Id claimRT =
            Schema.SObjectType.Claim__c
                .getRecordTypeInfosByDeveloperName()
                .get('Accident')
                .getRecordTypeId();

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Customer'
        );
        insert con;

        Policy__c policy = new Policy__c(
            Customer__c = con.Id,
            RecordTypeId = policyRT,
            VIN__c = '1A903284375893532'
        );
        insert policy;

        Claim__c claim = new Claim__c(
            Policy__c = policy.Id,
            RecordTypeId = claimRT,
            Claim_Amount__c = 5000,
            Date_of_Loss__c = DateTime.now().addDays(-10),
            OwnerId = u.Id
        );
        insert claim;
    }

    @isTest
    static void testGetAssignedClaims() {

        Test.startTest();

        List<ClaimsAdjusterController.ClaimWrapper> results =
            ClaimsAdjusterController.getAssignedClaims();

        Test.stopTest();

        System.assert(results.size() > 0);

        ClaimsAdjusterController.ClaimWrapper result =
            results[0];

        System.assertNotEquals(null, result.claimId);
        System.assertNotEquals(null, result.claimNumber);
        System.assertEquals(5000, result.claimAmount);
        System.assertEquals('Auto', result.policyType);
        System.assertEquals('Test Customer', result.policyHolderName);
        System.assertEquals('New', result.status);
        System.assertEquals(10, result.daysOpen);
    }
}