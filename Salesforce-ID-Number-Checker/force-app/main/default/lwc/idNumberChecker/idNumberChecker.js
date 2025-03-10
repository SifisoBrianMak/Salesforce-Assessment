import { LightningElement, track, wire } from 'lwc';
import getPublicHolidays from '@salesforce/apex/CalendarificAPIController.getPublicHolidays';

export default class IdNumberChecker extends LightningElement {
    @track idNumber = '';
    @track message = '';
    @track holidays = [];

    handleIdChange(event) {
        this.idNumber = event.target.value;
        this.message = '';
    }

    validateIdNumber(id) {
        return id.length === 13 && !isNaN(id); // Basic validation: 13 digits and numeric
    }

    decodeIdNumber(id) {
        const year = parseInt(id.substring(0, 2));
        const month = parseInt(id.substring(2, 4));
        const day = parseInt(id.substring(4, 6));
        const fullYear = year + (year < 22 ? 2000 : 1900); // Adjust for century
        return { year: fullYear, month, day };
    }

    handleSearch() {
        this.message = '';

        if (!this.validateIdNumber(this.idNumber)) {
            this.message = 'Invalid ID number!';
            return;
        }

        const dob = this.decodeIdNumber(this.idNumber);
        if (!dob) {
            this.message = 'Failed to decode ID number.';
            return;
        }

        getPublicHolidays({ year: dob.year.toString() })
            .then(response => {
                const parsedData = JSON.parse(response);
                this.holidays = parsedData.response.holidays || [];
            })
            .catch(error => {
                this.message = 'Error fetching holidays. Please try again later.';
                console.error(error);
            });
    }
}