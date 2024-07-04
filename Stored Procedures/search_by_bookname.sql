CREATE PROC search_by_bookname
	@ProductName VARCHAR(50) 
	AS
BEGIN
	SELECT * FROM Products where ProductName like '%' + @ProductName + '%'
END