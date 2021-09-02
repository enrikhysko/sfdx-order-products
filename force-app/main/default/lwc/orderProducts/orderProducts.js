import { api, LightningElement, track, wire } from "lwc";
import ShowToastEvent from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { reduceErrors } from "c/ldsUtils";
import getOrderProducts from "@salesforce/apex/OrderProductsCTRL.getOrderProducts";
import upsertOrderProducts from "@salesforce/apex/OrderProductsCTRL.upsertOrderProducts";

/** note: string label values are used directly, not via Custom Labels */

/** order products table columns */
const columns = [
  { label: 'Name', fieldName: 'ProductName' },
  { label: 'Unit Price', fieldName: 'UnitPrice' },
  { label: 'Quantity', fieldName: 'Quantity' },
  { label: 'TotalPrice', fieldName: 'TotalPrice' },
];

export default class OrderProducts extends LightningElement {

  /** Id of Order SObject. */
  @api recordId;

  /** The OrderItem SObjects to display. */
  @track orderProducts = [];

  /** Wired Apex result so it may be programmatically refreshed. */
  wiredOrderProducts;

  /** datatable columns */
  columns = columns;

  error;

  /** Apex load the OrderProduct details */
  @wire(getOrderProducts, { orderId: "$recordId" })
  onOrderProducts(value) {
    this.wiredOrderProducts = value;
    if (value.error) {
      this.orderProducts = undefined;
      this.error = value.error;
    } else if (value.data) {
      this.orderProducts = [];
      value.data.forEach((orderProd) => {
        // cannot mutate the data so has to create new object as wrapper of data
        let op = {};
        if (orderProd.Product2) {
          op.ProductName = orderProd.Product2.Name;
        }
        op.Id = orderProd.Id;
        op.Product2Id = orderProd.Product2Id;
        op.UnitPrice = orderProd.UnitPrice;
        op.Quantity = orderProd.Quantity;
        op.TotalPrice = orderProd.TotalPrice;
        this.orderProducts.push(op);
      });
      this.error = undefined;
    }
  }

  connectedCallback() {
    window.addEventListener("orderProducts", this.handleMessage, false);
  }

  /** handle the message from orderProducts event */
  handleMessage = (event) => {
    let addedProducts = event.detail.value;
    let orderProdToUpsert = [];
    addedProducts.forEach((pbe) => {
      // eslint-disable-next-line no-useless-escape
      pbe.UnitPrice = pbe.UnitPrice.substring(1).replace(/\,/g, ""); // remove currency symbol at the beginning and to have as number format
      pbe.UnitPrice = parseFloat(pbe.UnitPrice, 10);
      let found = false;
      for (let i = 0; i < this.orderProducts.length; i++) {
        if (this.orderProducts[i].Product2Id === pbe.Product2Id) {
          found = true;
          // When the product already exists the quantity of the existing order product be increased by 1
          const orderProdQty = {
            PriceBookEntryId: pbe.Id,
            UnitPrice: pbe.UnitPrice,
            Quantity: this.orderProducts[i].Quantity + 1
          };
          const updatedQtyProd = Object.assign(
            {},
            this.orderProducts[i],
            orderProdQty
          );
          orderProdToUpsert.push(updatedQtyProd);
          break;
        }
      }
      if (!found) {
        // when the same product is not yet added to the order it will be added with a quantity of 1
        orderProdToUpsert.push({
          PriceBookEntryId: pbe.Id,
          UnitPrice: pbe.UnitPrice,
          Quantity: 1
        });
      }
    });
    // to show laoding spinner
    let tableElement = this.template.querySelector("lightning-datatable");
    tableElement.isLoading = true;

    upsertOrderProducts({
      orderProducts: orderProdToUpsert,
      orderId: this.recordId
    })
      .then(() => {
        tableElement.isLoading = false;
        return refreshApex(this.wiredOrderProducts);
      })
      .catch((error) => {
        this.error = error;
      });
  };

  disconnectedCallback() {
    window.removeEventListener("orderProducts", this.handleMessage, false);
  }

  showToast(title, error, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: reduceErrors(error).join(", "),
        variant: variant
      })
    );
  }
}
