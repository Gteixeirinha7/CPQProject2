trigger TipoRecursoProduto on TipoRecursoProduto__c (before insert, before update, after insert, after update, before delete) {
    //System.debug(Trigger.new);
    if(TipoRecursosProdutoHelper.isTriggerEnabled()){
        switch on Trigger.operationType{
             
            when BEFORE_UPDATE {
                TipoRecursosProdutoHelper.updateInternalId(Trigger.new);
            } 

            when BEFORE_INSERT {
                TipoRecursosProdutoHelper.updateInternalId(Trigger.new);
            }

            when AFTER_UPDATE {
                TipoRecursosProdutoHelper.updateExternalIdProduct(Trigger.new);
            } 

            when AFTER_INSERT {
                TipoRecursosProdutoHelper.updateExternalIdProduct(Trigger.new);
            }
            
            when AFTER_DELETE {
                TipoRecursosProdutoHelper.updateExternalIdProduct(Trigger.old);
            }
        }
    }

}