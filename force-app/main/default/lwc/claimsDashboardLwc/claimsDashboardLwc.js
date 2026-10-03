import { LightningElement, wire } from 'lwc';

import getAssignedClaims
    from '@salesforce/apex/ClaimsAdjusterController.getAssignedClaims';

export default class ClaimsDashboardLwc extends LightningElement {

    allClaims = [];
    visibleClaims = [];
    selectedPolicyType = 'All';
    error;

    @wire(getAssignedClaims)
    wiredClaims({ error, data }) {

        if (data) {
            this.allClaims = data;
            this.visibleClaims = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.allClaims = [];
            this.visibleClaims = [];
            console.error(
                'Error retrieving claims:',
                JSON.stringify(error)
            );
        }
    }

    handleFilterChange(event) {

        this.selectedPolicyType = event.target.value;

        if (this.selectedPolicyType === 'All') {
            this.visibleClaims = this.allClaims;
        } else {
            this.visibleClaims = this.allClaims.filter(
                claim => claim.policyType === this.selectedPolicyType
            );
        }
    }

    get policyTypeOptions() {
        return [
            {
                label: 'All Policy Types',
                value: 'All'
            },
            {
                label: 'Auto',
                value: 'Auto'
            },
            {
                label: 'Property',
                value: 'Property'
            },
            {
                label: 'Life',
                value: 'Life'
            }
        ];
    }
}