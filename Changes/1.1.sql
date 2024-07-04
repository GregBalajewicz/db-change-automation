IF OBJECT_ID('dbo.[PK_Products]', 'C') IS NOT NULL 
	ALTER TABLE Products 
	ADD CONSTRAINT PK_Products 
	PRIMARY KEY(ProductID)