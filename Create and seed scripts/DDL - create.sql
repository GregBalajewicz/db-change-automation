create database programming_book_store
go 
use programming_book_store

create table Products 
(
	ProductID int not null,
	ProductName varchar(50), 
	Price  DECIMAL(19,4)
)

insert into Products(ProductID, ProductName, Price) values (1, 'Clean Code', 99.99)
insert into Products(ProductID, ProductName, Price) values  (2, 'The Mythical Man-month', 59.99)
insert into Products(ProductID, ProductName, Price) values  (3, 'Javasccript - the good parts', 69.99)

















