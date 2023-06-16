trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update, after insert, after update, before delete) {
    if(QuoteLineItemHandler.isTriggerEnabled()){
	/*
		Desenvolvido por: Leonardo Fernandes
		Data:20/09/2017
		Descrição: Responsável por atualizar o frete relacionado ao item da cotação
	*/

        if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){
            Set<Id> setProdutos = new Set<Id>();
            Set<Id> setPricebookEntries = new Set<Id>();
            for(QuoteLineItem item : trigger.new){
                setProdutos.add(item.Product2Id);
                setPricebookEntries.add(item.PricebookEntryId);
            }
            Map<Id, Double> entradaEPrecoLista = new Map<Id, Double>();
            List<PricebookEntry> entradasDePreco = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id IN:setPricebookEntries];
            for(PricebookEntry entrada : entradasDePreco){
				entradaEPrecoLista.put(entrada.Id, entrada.UnitPrice);                
            }
            for(QuoteLineItem item : trigger.new){
                item.Interno_Preco_de_lista__c = entradaEPrecoLista.get(item.PricebookEntryId) * item.Quantity;
            }
            List<Product2> produtos = [SELECT Id, Product_Sales_Category__c FROM Product2 WHERE Id IN: setProdutos];
            for(QuoteLineItem item : trigger.new){
                for(Product2 produto : produtos){
                    if(produto.Id == item.Product2Id){
                        if(produto.Product_Sales_Category__c == 'CAPEQUIP'){
                            item.Custo_Frete__c = item.UnitPrice * item.Quantity * 0.01;
                        }else{
                            item.Custo_Frete__c = 0;
                        }
                    }
                }
            }    
        }

    /*
    	Desenvolvido por: Leonardo Fernandes
		Data:03/05/2018
		Descrição: Método responsável por preencher o peso Bruto/Liquído dos produtos relacionados aos itens da cotação
    */    
        if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){
            Set<Id> idsProdutos = new Set<Id>();
            for(QuoteLineItem item : trigger.new){
                idsProdutos.add(item.Product2Id);
            }
            List<Product2> produtos = [SELECT Id, net_weight__c, gross_weight__c FROM Product2 WHERE Id IN:idsProdutos];
            for(QuoteLineItem item : trigger.new){
                Double pesoBruto = 0;
                Double pesoLiquido = 0;
                for(Product2 produto : produtos){
                    if(item.Product2Id == produto.Id){
                        pesoBruto = produto.net_weight__c <> null && produto.net_weight__c <> 0? produto.net_weight__c * item.Quantity : 0;
                        pesoLiquido = produto.gross_weight__c <> null && produto.gross_weight__c <> 0? produto.gross_weight__c * item.Quantity : 0;
                    }
                }
                item.net_weight__c = pesoBruto;
                item.gross_weight__c = pesoLiquido;
            }
        }    
    
    
        if(trigger.isInsert && trigger.isAfter){
            set<Id> idDasCotacoes = new set<Id>();
            map<Id, Decimal> valorDaCotacao = new map<Id, Decimal>();
            for( QuoteLineItem item : trigger.new ){
                if(!idDasCotacoes.contains(item.QuoteId))
                    idDasCotacoes.add(item.QuoteId);
            }
            List<Quote> cotacoes = [ SELECT Id, Preco_de_lista_de_produtos_new__c, CriadoContrato__c FROM Quote WHERE Id IN : idDasCotacoes ];
            for( Id idQuote : idDasCotacoes ){
                Decimal valorFor = 0.00;
                Quote CorrectQuote = null;
                for( Quote cotacao : cotacoes ){
                    if(cotacao.Id == idQuote){
                        CorrectQuote = cotacao;
                        if(cotacao.Preco_de_lista_de_produtos_new__c != null)
                            valorFor = cotacao.Preco_de_lista_de_produtos_new__c;
                    }
                }
                for( QuoteLineItem item : trigger.new ){
                    if(item.QuoteId == idQuote){
                        Decimal novoValor = (CorrectQuote != null ? (CorrectQuote.CriadoContrato__c ? 0 :  item.Pre_o_de_Lista__c) : item.Pre_o_de_Lista__c) * item.Quantity;
                        valorFor += novoValor;
                    }
                }
                if(!valorDaCotacao.containsKey(idQuote))
                    valorDaCotacao.put(idQuote, valorFor);
            }
            for( Quote cotacao : cotacoes ){
                cotacao.Preco_de_lista_de_produtos_new__c = valorDaCotacao.get(cotacao.Id);     
            }
            update cotacoes;
        }
        if(trigger.isUpdate && trigger.isAfter){
            set<Id> idDasCotacoes = new set<Id>();
            for( QuoteLineItem item : trigger.new ){
                if(!idDasCotacoes.contains(item.QuoteId))
                    idDasCotacoes.add(item.QuoteId);
            }
            List<Quote> cotacoes = [ SELECT Id, Preco_de_lista_de_produtos_new__c, CriadoContrato__c FROM Quote WHERE Id IN : idDasCotacoes ];
            List<QuoteLineItem> itensDaCotacao = [SELECT Id, QuoteId, Pre_o_de_Lista__c, Quantity, UnitPrice FROM QuoteLineItem WHERE QuoteId IN: idDasCotacoes ];
            for( Quote cotacao : cotacoes ){
                if(!cotacao.CriadoContrato__c){
                    cotacao.Preco_de_lista_de_produtos_new__c = 0;
                }
                for( QuoteLineItem item : itensDaCotacao ){
                    if(!cotacao.CriadoContrato__c){                      
                        cotacao.Preco_de_lista_de_produtos_new__c += item.Pre_o_de_Lista__c * item.Quantity;
                    }
                }
            }
            update cotacoes;	    
        }
        if(trigger.isDelete && trigger.isBefore){
            set<Id> idDasCotacoes = new set<Id>();
            map<Id, Decimal> valorDaCotacao = new map<Id, Decimal>();
            for( QuoteLineItem item : trigger.old ){
                if(!idDasCotacoes.contains(item.QuoteId))
                    idDasCotacoes.add(item.QuoteId);
            }
            List<Quote> cotacoes = [ SELECT Id, Preco_de_lista_de_produtos_new__c, CriadoContrato__c FROM Quote WHERE Id IN : idDasCotacoes ];
            for( Id idQuote : idDasCotacoes ){
                Decimal valorFor = 0.00;
                Quote CorrectQuote = null;
                for(Quote cotacaoFor : cotacoes ){
                    if(cotacaoFor.Id == idQuote){
                        CorrectQuote = cotacaoFor;
                        if(cotacaoFor.Preco_de_lista_de_produtos_new__c != null)
                            valorFor = cotacaoFor.Preco_de_lista_de_produtos_new__c;
                    }
                }
                for( QuoteLineItem item : trigger.old ){
                    if(item.QuoteId == idQuote){
                         Decimal novoValor = (CorrectQuote != null ? (CorrectQuote.CriadoContrato__c ? 0 :  item.Pre_o_de_Lista__c) : item.Pre_o_de_Lista__c) * item.Quantity;
                        valorFor -= novoValor;
                    }
                }
                if(!valorDaCotacao.containsKey(idQuote))
                    valorDaCotacao.put(idQuote, valorFor);
            }
            for( Quote cotacao : cotacoes ){
                cotacao.Preco_de_lista_de_produtos_new__c = valorDaCotacao.get(cotacao.Id);     
            }
            update cotacoes;
        }

        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            QuoteLineItemHandler.automaticCommission(trigger.new);
            // QuoteLineItemHandler.checkApproval(trigger.new);
            QuoteLineItemHandler.updateCheckApproval(trigger.new);
        }
        if(Trigger.isBefore && Trigger.isDelete){
            // QuoteLineItemHandler.checkApproval(trigger.old);
        }
        if(Trigger.isBefore && (Trigger.isInsert)){
            QuoteLineItemHandler.setInternalDiscount(trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            QuoteLineItemHandler.checkDiscount(trigger.new, Trigger.oldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert && !System.isFuture() && !System.isBatch()){
            QuoteLineItemHandler.checkDiscountFuture(Trigger.new);
        }
        if(Trigger.isAfter){
            QuoteLineItemHandler.setConditionPagment(Trigger.new);
        }
        //if(Trigger.isAfter && (Trigger.isInsert)){
        //    QuoteLineItemHandler.createComissionLineItem(trigger.new);
        //}
    }
}