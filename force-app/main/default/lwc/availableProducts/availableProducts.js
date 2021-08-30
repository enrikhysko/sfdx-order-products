import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ShowToastEvent from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import getAvailableProducts from '@salesforce/apex/AvailableProductsCTRL.getAvailableProducts';
import countAvailableProducts from '@salesforce/apex/AvailableProductsCTRL.countAvailableProducts';
// Order fields
import PRICEBOOK2ID from '@salesforce/schema/Order.Pricebook2Id';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'List Price', fieldName: 'UnitPrice' },
    // { type: 'button', typeAttributes: { label: 'Add to Order', variant: 'brand-outline' }, cellAttributes: { alignment: 'center' } },
];

export default class AvailableProducts extends LightningElement {
    @api recordId;
    priceBookId;
    rowLimit = 201;
    rowOffset = 0;
    rowOffsetStart = 0;
    @track loadMoreStatus = '';
    @track availableProducts = [];
    columns = columns;
    tableElement;
    totalRecords;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: PRICEBOOK2ID })
    wiredOrder({ error, data }) {
        if (error) {
            // this.showToast('Error loading order', error, 'error');
            this.priceBookId = undefined;
            this.error = error;
        } else if (data) {
            // console.log(1);
            // this.priceBookId = getFieldValue(data, PRICEBOOK2ID);
            this.priceBookId = data.fields.Pricebook2Id.value;
            console.log('priceBookId', this.priceBookId)
        }
    }

    @wire(countAvailableProducts, { priceBookId: '$priceBookId' })
    wiredCount({ error, data }) {
        if (error) {
            this.totalRecords = 0;
            this.error = error;
        } else if (data) {
            this.totalRecords = data;
            console.log('totalRecords', JSON.stringify(this.totalRecords))
            this.error = undefined;
        }
    }

    @wire(getAvailableProducts,  { priceBookId: '$priceBookId', rowLimit: '$rowLimit', rowOffset: '$rowOffsetStart' })
    onProducts({ error, data }) {
        if (error) {
            // this.showToast('Error loading products', error, 'error');
            this.availableProducts = undefined;
            this.error = error;
        } else if (data) {
            this.availableProducts = data;
            console.log('availableProducts', JSON.stringify(this.availableProducts))
            this.error = undefined;
        }
    }

    loadMoreData(event) {
        if (event.target){
            event.target.isLoading = true;
        }
        this.tableElement = event.target;
        //Display "Loading" text when more data is being loaded
        this.loadMoreStatus = 'Loading more...';
        this.rowOffset = this.rowOffset + this.rowLimit;
        getAvailableProducts({ priceBookId: this.priceBookId, rowLimit: this.rowLimit, rowOffset: this.rowOffset })
            .then((result) => {
                this.availableProducts = this.availableProducts.concat(result);
                if (this.availableProducts.length >= this.totalRecords) {
                    this.tableElement.enableInfiniteLoading = false;
                    this.loadMoreStatus = '';
                }
                if (this.tableElement) {
                    this.tableElement.isLoading = false;
                    this.loadMoreStatus = '';
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.availableProducts = [];
                this.error = error;
                console.error('loadMoreData.error', JSON.stringify(error))
            })
    }

    handleRowAction(event) {
        let row = event.detail.row;
    }

    showToast(title, error, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: reduceErrors(error).join(', '),
            variant: variant
            })
        );
    }
}