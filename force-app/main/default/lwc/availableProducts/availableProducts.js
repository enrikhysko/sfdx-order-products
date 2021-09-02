import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ShowToastEvent from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';

/** Apex CTRL methods */
import getAvailableProducts from '@salesforce/apex/AvailableProductsCTRL.getAvailableProducts';
import countAvailableProducts from '@salesforce/apex/AvailableProductsCTRL.countAvailableProducts';

/** Order Schema. */
import PRICEBOOK2ID_FIELD from '@salesforce/schema/Order.Pricebook2Id';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

/** available products table columns */
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'List Price', fieldName: 'UnitPrice' },
];

/** note: string label values are used directly, not via Custom Labels */

export default class AvailableProducts extends LightningElement {
    /** Id of Order SObject. */
    @api recordId;

    /** Id of PriceBook related SObject. */
    priceBookId;

    /** Status of Order SObject. */
    orderStatus;

    /** used for infinite scrolling of record on datatable. */
    rowLimit = 200;
    rowOffset = 0;
    rowOffsetStart = 0;
    @track loadMoreStatus = '';

    @track availableProducts = [];
    _allAvailableProducts = [];
    columns = columns;
    tableElement;
    totalRecords;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: [PRICEBOOK2ID_FIELD, STATUS_FIELD] })
    wiredOrder({ error, data }) {
        if (error) {
            this.priceBookId = undefined;
            this.error = error;
        } else if (data) {
            this.priceBookId = getFieldValue(data, PRICEBOOK2ID_FIELD);
            this.orderStatus = getFieldValue(data, STATUS_FIELD);
        }
    }

    get isActiveStatus() {
        return this.orderStatus === 'Activated';
    }

    @wire(countAvailableProducts, { priceBookId: '$priceBookId' })
    wiredCount({ error, data }) {
        if (error) {
            this.totalRecords = 0;
            this.error = error;
        } else if (data) {
            this.totalRecords = data;
            this.error = undefined;
        }
    }

    @wire(getAvailableProducts,  { priceBookId: '$priceBookId', rowLimit: '$rowLimit', rowOffset: '$rowOffsetStart' })
    onProducts({ error, data }) {
        if (error) {
            this.availableProducts = undefined;
            this._allAvailableProducts = undefined;
            this.error = error;
        } else if (data) {
            this.availableProducts = data;
            this._allAvailableProducts = [...this.availableProducts];
            this.error = undefined;
        }
    }

    get showTable() {
        return this.availableProducts.length > 0 && !this.isActiveStatus
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
                this._allAvailableProducts = this._allAvailableProducts.concat(result);
                if (this._allAvailableProducts.length >= this.totalRecords) {
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
            })
    }

    searchTermChange(event) {
        let searchTermProduct = event.target.value;
        this.availableProducts = this._allAvailableProducts
                                    .filter(
                                        item => !searchTermProduct ||
                                        item.Name.toLowerCase().match(searchTermProduct.toLowerCase()));
    }

    handleClick() {
        this.selectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();
        let event = new CustomEvent('orderproducts', {
            detail: {
                value: this.selectedRows
            },
            bubbles: true
        });
        this.dispatchEvent(event);
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