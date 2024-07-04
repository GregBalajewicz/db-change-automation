CREATE PROC search_by_authorname
	@Author VARCHAR(50) 
	AS
BEGIN
	SELECT * FROM Products where Author like '%' + @Author + '%'
END