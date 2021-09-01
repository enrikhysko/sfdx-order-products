public with sharing class OrderProductsCTRL {
    /** note: string label values are used directly, not via Custom Labels */

    /** get from DB the order product records
     *  and return a list of wrapper because are referenced lookup field values
     *  which can't be shown directly in datatable
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(String orderId) {
        return [SELECT Product2Id, Product2.Name, FORMAT(UnitPrice), Quantity, FORMAT(TotalPrice)
                FROM OrderItem
                WHERE OrderId = :orderId
                WITH SECURITY_ENFORCED
                ORDER BY Product2.Name ASC];
        // List<OrderProductWrapper> opWrpList = new List<OrderProductWrapper>();
        // for(OrderItem op : [SELECT Product2Id, Product2.Name, FORMAT(UnitPrice), Quantity, FORMAT(TotalPrice)
        //                     FROM OrderItem
        //                     WHERE OrderId = :orderId
        //                     WITH SECURITY_ENFORCED
        //                     ORDER BY Product2.Name ASC])
        // {
        //     OrderProductWrapper opWrp = new OrderProductWrapper();
        //     opWrp.Id = op.Id;
        //     opWrp.Product2Id = op.Product2Id;
        //     opWrp.ProductName = op.Product2.Name;
        //     opWrp.UnitPrice = String.valueOf(op.UnitPrice);
        //     opWrp.Quantity = String.valueOf(op.Quantity);
        //     opWrp.TotalPrice = String.valueOf(op.TotalPrice);
        //     opWrpList.add(opWrp);
        // }
        // return opWrpList;
    }

    /** upsert order products chosen from available products list, for the current order */
    @AuraEnabled
    public static void upsertOrderProducts(List<Map<String, Object>> orderProducts, String orderId) {
        List<OrderItem> orderProdToUpsertList = new List<OrderItem>();
        for(Map<String, Object> orderProdMap : orderProducts) {
            OrderItem op = new OrderItem();
            op.Id = String.valueOf(orderProdMap.get('Id'));
            if(op.Id == null) {
                // these fields can be specified only on creation of record
                op.PriceBookEntryId = String.valueOf(orderProdMap.get('PriceBookEntryId'));
                op.OrderId = orderId;
            }
            op.UnitPrice = Decimal.valueOf(String.valueOf(orderProdMap.get('UnitPrice')));
            op.Quantity = Double.valueOf(orderProdMap.get('Quantity'));
            orderProdToUpsertList.add(op);
        }
        if (Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()) {
            upsert orderProdToUpsertList;
        }
        else throw new AuraHandledException('User doesn\'t have permission rights to modify OrderItem object');
    }

    /** inner wrapper class to display order product records on table */
    public class OrderProductWrapper {
        @AuraEnabled
        public String Id;

        @AuraEnabled
        public String Product2Id;

        @AuraEnabled
        public String ProductName;

        @AuraEnabled
        public String UnitPrice;

        @AuraEnabled
        public String Quantity;

        @AuraEnabled
        public String TotalPrice;
    }
}