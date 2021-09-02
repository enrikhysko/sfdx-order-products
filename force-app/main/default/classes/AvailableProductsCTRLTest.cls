/**
 * Test class for AvailableProductsCTRL.cls
 */
@IsTest
public class AvailableProductsCTRLTest {
    @TestSetup
    static void makeData(){
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
    }

    @IsTest
    static void getAvailableProducts_test_noData() {
        List<PricebookEntry> pbeList = AvailableProductsCTRL.getAvailableProducts(null, 0, 50);
        // no data should be retrieved
        System.assertEquals(true, pbeList.isEmpty());
    }

    @IsTest
    static void getAvailableProducts_test_WithData() {
        List<PricebookEntry> pbeList = AvailableProductsCTRL.getAvailableProducts(Test.getStandardPricebookId(), 0, 50);
        // should be equal to the number of PBE records inserted
        System.assertEquals(10, pbeList.size());
    }

    @IsTest
    static void countAvailableProducts_noData(){
        Integer nrOfRecords = AvailableProductsCTRL.countAvailableProducts(null);
        // no data should be retrieved
        System.assertEquals(0, nrOfRecords);
    }

    @IsTest
    static void countAvailableProducts_WithData(){
        Integer nrOfRecords = AvailableProductsCTRL.countAvailableProducts(Test.getStandardPricebookId());
        // should be equal to the number of PBE records inserted
        System.assertEquals(10, nrOfRecords);
    }
}