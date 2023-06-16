@IsTest
private with sharing class ProductScreenControllerTest {
	@TestSetup
	static void makeData() {
		update new Pricebook2(
			Id = Test.getStandardPricebookId(),
			IsActive = true
		);

		Account newAccount = new Account(
			Name = 'Account Test'
		);
		insert newAccount;

		Opportunity newOpportunity = new Opportunity(
			AccountId = newAccount.Id,
			Name = 'Opportunity Test',
			CloseDate = Date.today() + 30,
			StageName = 'Qualification',
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert newOpportunity;

		Quote newQuote = new Quote(
			Name = 'Quote Test',
			OpportunityId = newOpportunity.Id,
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert newQuote;

		EstruturaProduto__c newStructure = new EstruturaProduto__c(
			Name = 'Structure Test',
			Agrupador__c = 'Foco XLED',
			CodigoInterno__c = 'Foco XLED',
			Ativo__c = true
		);
		insert newStructure;

		KitAcessorios__c newKit = new KitAcessorios__c(
			Name = 'Kit Test',
			CodigoInterno__c = '01',
			PossuiObrigatorios__c = false,
			Ativo__c = true
		);
		insert newKit;

		List<Product2> newProductList = new List<Product2>{
			new Product2(
				Name = 'Product 1',
				ExternalId__c = '010305',
				EstruturaProduto__c = newStructure.Id,
				IsActive = true
			),
			new Product2(
				Name = 'Product 2',
				ExternalId__c = '020406',
				EstruturaProduto__c = newStructure.Id,
				KitAcessorios__c = newKit.Id,
				IsActive = true
			),
			new Product2(
				Name = 'Product 3',
				ExternalId__c = '020407',
				EstruturaProduto__c = newStructure.Id,
				IsActive = true
			),
			new Product2(
				Name = 'Product 4',
				ExternalId__c = '020408',
				EstruturaProduto__c = newStructure.Id,
				IsActive = true
			)
		};
		insert newProductList;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
			new PricebookEntry(
				UnitPrice = 100,
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = newProductList[0].Id,
				IsActive = true
			),
			new PricebookEntry(
				UnitPrice = 100,
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = newProductList[1].Id,
				IsActive = true
			),
			new PricebookEntry(
				UnitPrice = 100,
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = newProductList[2].Id,
				IsActive = true
			),
			new PricebookEntry(
				UnitPrice = 100,
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = newProductList[3].Id,
				IsActive = true
			)
		};
		insert pricebookEntryList;

		insert new List<OpportunityLineItem>{
			new OpportunityLineItem(
				Quantity = 100,
				UnitPrice = 100,
				Product2Id = newProductList[0].Id,
				OpportunityId = newOpportunity.Id
			),
			new OpportunityLineItem(
				Quantity = 100,
				UnitPrice = 100,
				Product2Id = newProductList[1].Id,
				OpportunityId = newOpportunity.Id
			),
			new OpportunityLineItem(
				Quantity = 100,
				UnitPrice = 100,
				ParentProduct__c = newProductList[0].Id,
				Product2Id = newProductList[2].Id,
				OpportunityId = newOpportunity.Id
			),
			new OpportunityLineItem(
				Quantity = 100,
				UnitPrice = 100,
				ParentProduct__c = newProductList[1].Id,
				Product2Id = newProductList[3].Id,
				OpportunityId = newOpportunity.Id
			)
		};

		insert new List<QuoteLineItem>{
			new QuoteLineItem(
				Quantity = 100,
				UnitPrice = 100,
				Product2Id = newProductList[0].Id,
				PricebookEntryId = pricebookEntryList[0].Id,
				QuoteId = newQuote.Id
			),
			new QuoteLineItem(
				Quantity = 100,
				UnitPrice = 100,
				Product2Id = newProductList[1].Id,
				PricebookEntryId = pricebookEntryList[1].Id,
				QuoteId = newQuote.Id
			)
		};

		List<RecursosProduto__c> newResourceList = new List<RecursosProduto__c>{
			new RecursosProduto__c(
				Name = 'Dimension',
				EstruturaProduto__c = newStructure.Id,
				Sequencial__c = 1
			),
			new RecursosProduto__c(
				Name = 'Door Type',
				EstruturaProduto__c = newStructure.Id,
				Sequencial__c = 2
			),
			new RecursosProduto__c(
				Name = 'Mounting',
				EstruturaProduto__c = newStructure.Id,
				Sequencial__c = 3
			)
		};
		insert newResourceList;

		insert new List<TiposRecurso__c>{
			new TiposRecurso__c(
				DescricaoRecurso__c = 'D1',
				Sequencial__c = '1',
				ExternalId__c = '01',
				RecursoProduto__c = newResourceList[0].Id,
				Ativo__c = true
			),
			new TiposRecurso__c(
				DescricaoRecurso__c = 'D2',
				Sequencial__c = '2',
				ExternalId__c = '02',
				RecursoProduto__c = newResourceList[0].Id,
				Ativo__c = true
			),
			new TiposRecurso__c(
				DescricaoRecurso__c = 'DT3',
				Sequencial__c = '3',
				ExternalId__c = '03',
				RecursoProduto__c = newResourceList[1].Id,
				Ativo__c = true
			),
			new TiposRecurso__c(
				DescricaoRecurso__c = 'DT4',
				Sequencial__c = '4',
				ExternalId__c = '04',
				RecursoProduto__c = newResourceList[1].Id,
				Ativo__c = true
			),
			new TiposRecurso__c(
				DescricaoRecurso__c = 'M5',
				Sequencial__c = '5',
				ExternalId__c = '05',
				RecursoProduto__c = newResourceList[2].Id,
				Ativo__c = true
			),
			new TiposRecurso__c(
				DescricaoRecurso__c = 'M6',
				Sequencial__c = '6',
				ExternalId__c = '06',
				RecursoProduto__c = newResourceList[2].Id,
				Ativo__c = true
			)
		};

		insert new TipoRecursoProduto__c(
			Produto__c =  [SELECT id FROM Product2 LIMIT 1].Id,
			TipoRecurso__c = [SELECT id FROM TiposRecurso__c LIMIT 1].Id
		);
	}

	@IsTest
	static void getBaseObjectTest() {
		Quote currentQuote = getQuote();

		ProductScreenController.getBaseObject(currentQuote.Id);
	}

	@IsTest
	static void getCheckoutDataTest() {
		Quote currentQuote = getQuote();
		ProductScreenController.getCheckoutData(currentQuote.Id);

		Opportunity currentOpportunity = getOpportunity();
		ProductScreenController.getCheckoutData(currentOpportunity.Id);
	}

	@IsTest
	static void getDataTest() {
		Quote currentQuote = getQuote();
		EstruturaProduto__c currentStructure = getStructure();

		ProductScreenController.getProducts(currentQuote.Id, currentStructure.Id, '', new List<String>{'01', '03'}, 10);
		ProductScreenController.getProducts(currentQuote.Id, null, '', new List<String>{'02', '04'}, 10);

		ProductScreenController.getStructures();

		ProductScreenController.getResources(currentStructure.Id);
	}

	@IsTest
	static void productScreenController() {
		try{CreateStructureResourcesController.getCurrentRecordsSteris(new List<CreateStructureResourcesController.ProductResourceData>{new CreateStructureResourcesController.ProductResourceData(true)});}catch(Exception ex){}
		try{CreateAcessoryResourcesController.getCurrentRecordsSteris(new CreateAcessoryResourcesController.AllAcessoryData(true));}catch(Exception ex){}
		try{CreateAcessoryResourcesController.createRecords(JSON.serialize(new CreateAcessoryResourcesController.AllAcessoryData(true)));}catch(Exception ex){}
	}

	@IsTest
	static void openQuotePDFController() {
		OpenQuotePDFController.getURL(getQuote().Id);
	}

	@IsTest
	static void openPDFController() {
		try{
			ApexPages.currentPage().getParameters().put('Id', [SELECT id FROM Quote LIMIT 1].Id);
			Test.startTest();
			PDFQuoteController pdfs = new PDFQuoteController();
			Test.stopTest();
		}catch(Exception ex){

		}
		try{
			PDFQuoteController.createPDF('', getQuote().Id, '1212');
		}catch(Exception ex){

		}

	}

	@IsTest
	static void checkNextTypeResourcesTest() {
		EstruturaProduto__c currentStructure = getStructure();

		ProductScreenController.checkNextTypeResources(currentStructure.Id, 2, new List<String>{'01', '03'});
		ProductScreenController.checkNextTypeResources(currentStructure.Id, 1, new List<String>{'02', '04'});
	}

	@IsTest
	static void saveLineItemsTest() {
		Quote currentQuote = getQuote();
		Product2 currentProduct = getProduct();
		List<ProductScreenModel.ProductData> quoteItemList = new List<ProductScreenModel.ProductData>();
		ProductScreenModel.ProductData productData = new ProductScreenModel.ProductData(currentProduct);
		ProductScreenModel.ProductData emptyProductData = new ProductScreenModel.ProductData();

		productData.price = 90;
		productData.quantity = 5;

		quoteItemList.add(productData);

		ProductScreenController.saveLineItems(currentQuote.Id, quoteItemList);
		ProductScreenController.saveLineItems(currentQuote.Id, quoteItemList);

		quoteItemList[0].id = null;
		ProductScreenController.saveLineItems(currentQuote.Id, quoteItemList);
		ProductScreenController.saveLineItems(null, quoteItemList);
	}

	static Product2 getProduct() {
		Product2 currentProduct;

		for (Product2 retrievedProduct : [
			SELECT Id,
				   Name,
				   ExternalId__c,
				   Imagem_URL__c,
				   EstruturaProduto__c,
				   KitAcessorios__c,
				   ProductCodeExternalId__c,
				   ProductCode
			  FROM Product2
			 LIMIT 1
		]) {
			currentProduct = retrievedProduct;
		}

		return currentProduct;
	}

	static EstruturaProduto__c getStructure() {
		EstruturaProduto__c currentStructure;

		for (EstruturaProduto__c retrievedStructure : [
			SELECT Id
			  FROM EstruturaProduto__c
			 LIMIT 1
		]) {
			currentStructure = retrievedStructure;
		}

		return currentStructure;
	}

	static Quote getQuote() {
		Quote currentQuote;

		for (Quote retrievedQuote : [
			SELECT Id
			  FROM Quote
			 LIMIT 1
		]) {
			currentQuote = retrievedQuote;
		}

		return currentQuote;
	}

	static Opportunity getOpportunity() {
		Opportunity currentOpportunity;

		for (Opportunity retrievedOpportunity : [
			SELECT Id
			  FROM Opportunity
			 LIMIT 1
		]) {
			currentOpportunity = retrievedOpportunity;
		}

		return currentOpportunity;
	}
}
