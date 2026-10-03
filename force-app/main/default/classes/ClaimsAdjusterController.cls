public class ClaimsAdjusterController {

    public class ClaimWrapper {

        @AuraEnabled public Id claimId;
        @AuraEnabled public String claimNumber;
        @AuraEnabled public Decimal claimAmount;
        @AuraEnabled public String status;
        @AuraEnabled public String policyType;
        @AuraEnabled public String policyHolderName;
        @AuraEnabled public Integer daysOpen;

        public ClaimWrapper(
            Claim__c claim,
            Policy__c policy,
            Contact customer
        ) {

            this.claimId = claim.Id;
            this.claimNumber = claim.Name;
            this.claimAmount = claim.Claim_Amount__c;
            this.status = claim.Approval_Status__c;

            if (policy != null && policy.RecordType != null) {
                this.policyType = policy.RecordType.Name;
            } else {
                this.policyType = 'Unknown';
            }

            if (customer != null) {
                this.policyHolderName = customer.Name;
            } else {
                this.policyHolderName = '';
            }

            if (claim.Date_of_Loss__c != null) {
                this.daysOpen =
                    claim.Date_of_Loss__c.date()
                    .daysBetween(Date.today());
            } else {
                this.daysOpen = 0;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ClaimWrapper> getAssignedClaims() {

        List<ClaimWrapper> results =
            new List<ClaimWrapper>();

        List<Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claim_Amount__c,
                Approval_Status__c,
                Date_of_Loss__c,
                Policy__r.Name,
                Policy__r.RecordType.Name,
                Policy__r.Customer__r.Name
            FROM Claim__c
            WHERE OwnerId = :UserInfo.getUserId()
            ORDER BY Date_of_Loss__c DESC
        ];

        for (Claim__c claim : claims) {

            Policy__c policy = claim.Policy__r;

            Contact customer =
                (policy != null && policy.Customer__r != null)
                ? policy.Customer__r
                : null;

            results.add(
                new ClaimWrapper(
                    claim,
                    policy,
                    customer
                )
            );
        }

        return results;
    }
}