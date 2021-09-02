/**
 * Controller class for orderProducts lwc
 */
public with sharing class OrderProductsCTRL {
    /** note: string label values are used directly, not via Custom Labels */

    /** get from DB the order product records
     *  here the format of currency fields is not working...?!
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(String orderId) {
        return [SELECT Product2Id, Product2.Name, FORMAT(UnitPrice), Quantity, FORMAT(TotalPrice)
                FROM OrderItem
                WHERE OrderId = :orderId
                WITH SECURITY_ENFORCED
                ORDER BY Product2.Name ASC];
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
}