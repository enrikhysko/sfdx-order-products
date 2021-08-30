public with sharing class AvailableProductsCTRL {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String priceBookId, Integer rowOffset, Integer rowLimit) {
        System.debug('priceBookId '+ priceBookId);
        System.debug('rowOffset '+ rowOffset);
        System.debug('rowLimit '+ rowLimit);
        String query = 'SELECT Product2Id, Name, FORMAT(UnitPrice)';
        query += ' FROM PricebookEntry'; 
        query += ' WHERE Pricebook2Id = :priceBookId';
        // to appear each product only once in the list
        // in case of same product with different currency price (CurrencyIsoCode field exists only on multicurrency feature enabled orgs)
        query += UserInfo.isMultiCurrencyOrganization() ? (' AND CurrencyIsoCode = ' + UserInfo.getDefaultCurrency()) : '';
        query += ' AND isActive = TRUE';
        query += ' WITH SECURITY_ENFORCED';
        query += ' ORDER BY Name ASC';
        query += ' LIMIT :rowLimit OFFSET :rowOffset';

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Integer countAvailableProducts(String priceBookId){
        System.debug('count priceBookId '+ priceBookId);
        return [SELECT count()
                FROM PricebookEntry
                WHERE Pricebook2Id = :priceBookId
                AND isActive = TRUE
                WITH SECURITY_ENFORCED];
    }
}
