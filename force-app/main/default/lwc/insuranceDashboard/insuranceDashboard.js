import { LightningElement } from 'lwc';

import getPolicyCount from '@salesforce/apex/InsuranceDashboardController.getPolicyCount';
import getClaimCount from '@salesforce/apex/InsuranceDashboardController.getClaimCount';
import getTotalPremium from '@salesforce/apex/InsuranceDashboardController.getTotalPremium';
import getTotalClaimAmount from '@salesforce/apex/InsuranceDashboardController.getTotalClaimAmount';
import getPolicies from '@salesforce/apex/InsuranceDashboardController.getPolicies';
import getClaims from '@salesforce/apex/InsuranceDashboardController.getClaims';
import getClaimStatusCounts from '@salesforce/apex/InsuranceDashboardController.getClaimStatusCounts';

export default class InsuranceDashboard extends LightningElement {

    policyCount = 0;
    claimCount = 0;
    totalPremium = 0;
    totalClaimAmount = 0;

    policies = [];
    claims = [];
    claimStatusCounts = {};

    isLoading = false;
    refreshMessage = '';

    connectedCallback() {
        this.loadDashboard();
    }

    loadDashboard() {
        this.isLoading = true;

        Promise.all([
            getPolicyCount(),
            getClaimCount(),
            getTotalPremium(),
            getTotalClaimAmount(),
            getPolicies(),
            getClaims(),
            getClaimStatusCounts()
        ])
        .then(results => {

            this.policyCount = results[0];
            this.claimCount = results[1];
            this.totalPremium = results[2];
            this.totalClaimAmount = results[3];

            this.policies = results[4];
            this.claims = results[5];
            this.claimStatusCounts = results[6];

            this.refreshMessage = 'Dashboard refreshed successfully';

        })
        .catch(error => {
            console.error('Dashboard loading error:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleRefresh() {
    console.log('Refresh button clicked');

    this.refreshMessage = 'Refreshing dashboard...';

    this.loadDashboard();
}
}