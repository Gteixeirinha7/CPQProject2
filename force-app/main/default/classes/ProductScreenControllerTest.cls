@IsTest
private with sharing class ProductScreenControllerTest {
	@TestSetup
	static void makeData() {
		Account newAccount = new Account(
			Name = 'Account Test'
		);
		insert newAccount;

		Opportunity newOpportunity = new Opportunity(
			AccountId = newAccount.Id,
			Name = 'Opportunity Test',
			CloseDate = Date.today() + 30,
			StageName = 'Qualification'
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
			Agrupador__c = 'Lavadora',
			Ativo__c = true
		);
		insert newStructure;

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
				IsActive = true
			)
		};
		insert newProductList;

		insert new List<PricebookEntry>{
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
	}

	@IsTest
	static void getDataTest() {
		Quote currentQuote = getQuote();
		EstruturaProduto__c currentStructure = getStructure();

		ProductScreenController.getProducts(currentQuote.Id, currentStructure.Id, '0103');
		ProductScreenController.getProducts(currentQuote.Id, null, '0204');

		ProductScreenController.getStructures();

		ProductScreenController.getResources(currentStructure.Id);
	}

	@IsTest
	static void checkNextTypeResourcesTest() {
		EstruturaProduto__c currentStructure = getStructure();

		ProductScreenController.checkNextTypeResources(currentStructure.Id, '010305', 2);
		ProductScreenController.checkNextTypeResources(currentStructure.Id, '0204', 1);
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
				   KitAcessorios__c
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
}