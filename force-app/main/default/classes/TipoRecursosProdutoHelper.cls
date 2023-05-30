public class TipoRecursosProdutoHelper {
    private static Boolean runTrigger;
    static {
        runTrigger = true;
    }

    public static Boolean isTriggerEnabled(){
        return runTrigger;
    }

    public static Boolean enableTrigger(){
        return runTrigger = true;
    }

    public static Boolean disableTrigger(){
        return runTrigger = false;
    }

    public static void updateInternalId(TipoRecursoProduto__c[] context){
        for(TipoRecursoProduto__c record : context){
            record.ChaveInternaDuplicidade__c = record.Produto__c +' - '+record.Sequencial__c; 
        }
    }
    public static void updateExternalIdProduct(TipoRecursoProduto__c[] context){
        Map<Id, Map<Decimal, String>> contextMap = new Map<Id, Map<Decimal, String>>();
        Map<Id, String> prodIdMap = new Map<Id, String>();
        for(TipoRecursoProduto__c record : context){
            if(!contextMap.containsKey(record.Produto__c))
                contextMap.put(record.Produto__c, new Map<Decimal, String>());
            contextMap.get(record.Produto__c).put(0, record.IdentificadorBase__c);
        }

        for(TipoRecursoProduto__c record : [SELECT id, Sequencial__c, IdentificadorChave__c, Produto__c
                                            FROM TipoRecursoProduto__c 
                                            WHERE Produto__c IN :contextMap.keySet() 
                                            ORDER BY Produto__c DESC, Sequencial__c ASC]){
            contextMap.get(record.Produto__c).put(record.Sequencial__c, record.IdentificadorChave__c);
        }

        List<Product2> productList= new List<Product2>();
        for(Id prodId : contextMap.keySet()){
            productList.add(new Product2(Id = prodId, ExternalId__c = String.join(contextMap.get(prodId).values(), '')));
        }

        if(!productList.isEmpty()){
            update productList;
        }
    }
}