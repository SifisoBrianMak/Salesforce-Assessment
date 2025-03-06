import { LightningElement, track } from 'lwc';
import saveOrUpdateIDRecord from '@salesforce/apex/IDRecordManager.saveOrUpdateIDRecord';
import fetchHolidays from '@salesforce/apex/HolidayFetcher.fetchHolidays';

export default class IdNumberChecker extends LightningElement {
    @track idNumber = '';
    @track message = '';
    @track holidays = [];
    @track isSearchDisabled = true;
    @track hasSearched = false;

    handleIdChange(event) {
        this.idNumber = event.target.value.trim();
        this.isSearchDisabled = !this.validateIdNumber(this.idNumber);
    }

    validateIdNumber(id) {
        return id.length === 13 && !isNaN(id);
    }

    handleSearch() {
        this.message = '';
        this.hasSearched = true;

        if (!this.validateIdNumber(this.idNumber)) {
            this.message = 'Invalid ID number! Please enter a valid 13-digit ID.';
            return;
        }

        this.saveRecord();
    }

    saveRecord() {
        saveOrUpdateIDRecord({ idNumber: this.idNumber })
            .then(result => {
                if (result.success) {
                    console.log('Record saved with ID:', result.recordId);
                    this.message = result.message;
                    const dob = this.decodeIdNumber(this.idNumber);
                    if (dob) {
                        this.fetchHolidays(dob.year);
                    }
                } else {
                    console.error('Error saving record:', result.message);
                    this.message = result.message;
                }
            })
            .catch(error => {
                console.error('Unexpected error:', error.body?.message || 'Unknown error');
                this.message = 'An unexpected error occurred while saving the record.';
            });
    }

    decodeIdNumber(id) {
        try {
            const year = parseInt(id.substring(0, 2));
            const month = parseInt(id.substring(2, 4));
            const day = parseInt(id.substring(4, 6));

            if (isNaN(year) || isNaN(month) || isNaN(day)) {
                throw new Error('Invalid date format in ID number.');
            }

            const fullYear = year + (year < 22 ? 2000 : 1900);
            return { year: fullYear, month, day };
        } catch (error) {
            console.error('Error decoding ID number:', error.message);
            this.message = 'Error decoding ID number. Please check the entered value.';
            return null;
        }
    }

    fetchHolidays(year) {
        fetchHolidays({ year: year.toString() })
            .then(result => {
                if (result.success) {
                    this.holidays = result.holidays?.holidays || [];
                    if (this.holidays.length === 0) {
                        this.message = 'No holidays found for the given year.';
                    }
                } else {
                    this.message = result.message || 'Error fetching holidays.';
                }
            })
            .catch(error => {
                this.message = 'An unexpected error occurred while fetching holidays.';
                console.error('Error:', error.body?.message || 'Unknown error');
            });
    }
}