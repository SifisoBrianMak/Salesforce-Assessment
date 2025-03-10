import { LightningElement, track, wire } from 'lwc';
import getPublicHolidays from '@salesforce/apex/CalendarificAPIController.getPublicHolidays';

export default class IdNumberSearch extends LightningElement {
    @track idNumber = '';
    @track errorMessage = '';
    @track holidayResults = [];
    @track isLoading = false;
    isSearchDisabled = true;

    handleIdChange(event) {
        this.idNumber = event.target.value;
        this.isSearchDisabled = !this.validateIDFormat(this.idNumber);
    }

    validateIDFormat(idNumber) {
        const regex = /^[0-9]{13}$/;
        return regex.test(idNumber);
    }

    async searchHolidays() {
        this.errorMessage = '';
        this.holidayResults = [];

        if (this.isSearchDisabled) {
            this.errorMessage = 'Please enter a valid South African ID Number.';
            return;
        }

        this.isLoading = true;

        try {
            const dobStr = this.idNumber.substring(0, 6);
            const yearSuffix = dobStr.substring(4, 6);
            const fullYear = parseInt(yearSuffix) < 22 ? '20' + yearSuffix : '19' + yearSuffix;

            this.holidayResults = await getPublicHolidays({ year: fullYear });
        } catch (error) {
            this.errorMessage = 'An error occurred while fetching holidays: ' + error.message;
        } finally {
            this.isLoading = false;
        }
    }
}