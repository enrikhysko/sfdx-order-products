/**
 * Factory class to produce test data records in apex test context
 */
@isTest
public class TestDataFactory {

    /** create test Account records specifing how many to create
    *   adapt the method to put additional fields as needed
    */
    public static List<Account> createAccounts(Integer nrRecs) {
        List<Account> accList = new List<Account>();
        for(Integer i = 1; i <= nrRecs; i++) {
            
            Account acc = new Account(
                Name = 'TestAccount'+i
            );
            accList.add(acc);
        }
        insert accList;

        return accList;
    }

    /** create test Order records specifing how many to create
    *   adapt the method to put additional fields as needed
    */
    public static List<Order> createOrders(Integer nrRecs, Account acc) {
        List<Order> ordList = new List<Order>();
        for(Integer i = 1; i <= nrRecs; i++) {
            Order ord = new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = System.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            );
            ordList.add(ord);
        }
        insert ordList;

        return ordList;
    }

    /** create test Product2 records specifing how many to create
    *   adapt the method to put additional fields as needed
    */
    public static List<Product2> createProducts(Integer nrRecs) {
        List<Product2> prodList = new List<Product2>();
        for(Integer i = 1; i <= nrRecs; i++) {
            Product2 prod = new Product2(
                Name = 'TestProd'+i,
                Family = 'Hardware'
            );
            prodList.add(prod);
        }
        insert prodList;

        return prodList;
    }

    /** create test Product2 records specifing how many to create
    *   prodList should match the size of nrRecs
    *   adapt the method to put additional fields as needed
    */
    public static List<PricebookEntry> createPriceBookEntries(Integer nrRecs, List<Product2> prodList) {
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Integer i = 1; i <= nrRecs; i++) {
            PricebookEntry pbe = new PricebookEntry(
                UnitPrice = 10000,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prodList[i-1].Id,
                IsActive = true
            );
            pbeList.add(pbe);
        }
        insert pbeList;

        return pbeList;
    }

    /** create test OrderItem records specifing how many to create
    *   adapt the method to put additional fields as needed
    */
    public static List<OrderItem> createOrderProducts(Integer nrRecs, Order ord, List<PricebookEntry> pbeList) {
        List<OrderItem> orderProdList = new List<OrderItem>();
        for(Integer i = 1; i <= nrRecs; i++) {
            OrderItem ordProd = new OrderItem(
                OrderId = ord.Id,
                Quantity = i,
                UnitPrice = pbeList[i-1].UnitPrice,
                PriceBookEntryId = pbeList[i-1].Id
            );
            orderProdList.add(ordProd);
        }
        insert orderProdList;

        return orderProdList;
    }
}