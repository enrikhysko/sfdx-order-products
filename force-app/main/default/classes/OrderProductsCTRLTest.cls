/**
 * Test class for OrderProductsCTRL.cls
 */
@IsTest
public class OrderProductsCTRLTest {
    @testSetup
    static void makeData() {
        // create Accounts
        List<Account> accList = TestDataFactory.createAccounts(2);
        // create Order for each Account
        List<Order> ordList = new List<Order>();
        for(Integer i = 0; i < accList.size(); i++) {
            ordList.addAll(TestDataFactory.createOrders(1, accList[i]));
        }
        // create Products
        List<Product2> prodList = TestDataFactory.createProducts(10);
        // create PriceBookEntries related to Products
        List<PricebookEntry> pbeList = TestDataFactory.createPriceBookEntries(10, prodList);
        // create OrderProducts for each Order containing each Product
        for(Integer i = 0; i < ordList.size(); i++) {
            TestDataFactory.createOrderProducts(10, ordList[i], pbeList);
        }
    }

    @IsTest
    static void getOrderProducts_test_noData() {
        List<OrderItem> orderProdList = OrderProductsCTRL.getOrderProducts(null);
        // no data should be retrieved
        System.assertEquals(0, orderProdList.size());
    }

    @IsTest
    static void getOrderProducts_test_WithData() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
            List<OrderItem> orderProdList = OrderProductsCTRL.getOrderProducts(ord.Id);
        Test.stopTest();
        // data should be present
        System.assertEquals(10, orderProdList.size());
    }

    @IsTest
    static void upsertOrderProducts_test() {
        List<Map<String,Object>> orderProducts = new List<Map<String,Object>>();
        List<OrderItem> orderProdList = [SELECT PriceBookEntryId, OrderId, UnitPrice, Quantity FROM OrderItem];
        for(OrderItem op : orderProdList) {
            op.UnitPrice = 9000;
            op.Quantity = 2;
            orderProducts.add(op.getPopulatedFieldsAsMap());
        }
        Test.startTest();
            OrderProductsCTRL.upsertOrderProducts(orderProducts, orderProdList[0].OrderId);
        Test.stopTest();
        // check if data are updated
        for(OrderItem op : [SELECT UnitPrice, Quantity FROM OrderItem WHERE OrderId = :orderProdList[0].OrderId]) {
            System.assertEquals(9000, op.UnitPrice);
            System.assertEquals(2, op.Quantity);
        }
    }
}