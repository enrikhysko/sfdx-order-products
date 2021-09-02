/**
 * Controller class for lwc availableProducts
 */
public with sharing class AvailableProductsCTRL {
    /** get available products with their unitPrice from priceBookEntry records */
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String priceBookId, Integer rowOffset, Integer rowLimit) {
        String query = 'SELECT Product2Id, Name, FORMAT(UnitPrice)';
        query += ' FROM PricebookEntry';
        query += ' WHERE Pricebook2Id = :priceBookId';
        // to appear each product only once in the list
        // in case of same product with different currency price
        query += getDefaultCurrencyIsoCodeQueryFilter();
        query += ' AND IsActive = TRUE';
        query += ' WITH SECURITY_ENFORCED';
        query += ' ORDER BY Name ASC';
        query += ' LIMIT :rowLimit OFFSET :rowOffset';
        return Database.query(query);
    }

    /** count how many products are through priceBookEntry records */
    @AuraEnabled(cacheable=true)
    public static Integer countAvailableProducts(String priceBookId) {
        String query = 'SELECT count()';
        query += ' FROM PricebookEntry';
        query += ' WHERE Pricebook2Id = :priceBookId';
        query += getDefaultCurrencyIsoCodeQueryFilter();
        query += ' AND IsActive = TRUE';
        query += ' WITH SECURITY_ENFORCED';
        return Database.countQuery(query);
    }

    /** get SOQL query filter statement for default currency of running user */
    public static String getDefaultCurrencyIsoCodeQueryFilter() {
        String defaultCurrency = UserInfo.getDefaultCurrency();
        // CurrencyIsoCode field exists only on multicurrency feature enabled orgs
        return UserInfo.isMultiCurrencyOrganization() ? (' AND CurrencyIsoCode = :defaultCurrency' ) : '';
    }
}