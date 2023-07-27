-- LMS Project
-- Table Creation Script: 
The library management system is a computer based application used to automate a library.
It allows the librarian to maintain the information about books, magazines and other library materials.
It also allows the librarian to maintain and organize the information about the borrowers.

This project focuses on the automation of system process of adding newly acquired books, borrowing books
and borrower information, returning of books, searching for the location of the books and printing of the inventory 
of books in the library.
-------------------------------
/*PROCESS FLOW:
Problem statement
requirement gathering
design
database table structure
table ralation
table creation
relation creation
data population (application side)
feature addition */
---------------------------------
CREATE TABLE [dbo].[Subject]
(
	[SubjectID] [int] NOT NULL,
	[SubjectName] [varchar](64) NULL,
    CONSTRAINT [PK_Subject] PRIMARY KEY CLUSTERED ([SubjectID] ASC)
) 
GO
insert into dbo.subject values(1, 'sanskrit')
insert into dbo.subject values(2, 'marathi')
insert into dbo.subject values(3, 'hindi')
insert into dbo.subject values(4, 'english')

select * from subject
----------------
CREATE TABLE [dbo].[Department]
(
	[DeptID] [int] NOT NULL,
	[DeptName] [varchar](64) NOT NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([DeptID] ASC)
) 
GO
insert into dbo.Department values(1, 'Dept A')
insert into dbo.Department values(2, 'Dept B')
insert into dbo.Department values(3, 'Dept C')
insert into dbo.Department values(4, 'Dept D')

select * from Department
----------------
CREATE TABLE [dbo].[BookDetails]
(
	[BookID] [int] NOT NULL,
	[BookName] [varchar](64) NOT NULL,
	[AuthorName] [varchar](64) NOT NULL,
	[BookSerialNumber] [varchar](64) NOT NULL,
	[SubjectID] [int] NOT NULL,
	[Publisher] [varchar](64) NOT NULL,
	[Price] [int] NULL,
 CONSTRAINT [PK_BookDetails] PRIMARY KEY CLUSTERED ([BookID] ASC)
) 
GO
insert into BookDetails values(11, 'veda', 'shankar', 21, 1, 'mahadev', 200)
insert into BookDetails values(12, 'gita', 'radhe', 22, 2, 'krishna', 300)
insert into BookDetails values(13, 'puran', 'maha', 23, 3, 'vishnu', 400)
insert into BookDetails values(14, 'katha', 'maha', 24, 4, 'vishnu', 500)

select * from BookDetails
------------------
ALTER TABLE [dbo].[BookDetails]  WITH CHECK 
ADD  CONSTRAINT [FK_BookDetails_subject_SubjectID] FOREIGN KEY([SubjectID])
REFERENCES [dbo].[Subject] ([SubjectID])
GO
-------------------
CREATE TABLE [dbo].[BorrowerDetails]
(
	[BorrowerID] [int] NOT NULL,
	[BorrowerName] [varchar](64) NOT NULL,
	[BorrowerContact] [varchar](64) NOT NULL,
	[DeptID] [int] NOT NULL,
	[Address] [varchar](64) NOT NULL,
    CONSTRAINT [PK_BorrowerDetails] PRIMARY KEY CLUSTERED ([BorrowerID] ASC)
) 
GO
insert into BorrowerDetails values(1, 'samarth', 1234567890, 1, 'solapur')
insert into BorrowerDetails values(2, 'vaiju', 0987654321, 2, 'solapur')
insert into BorrowerDetails values(3, 'om', 1597538520, 3, 'solapur')
insert into BorrowerDetails values(4, 'niku', 1597538528, 4, 'solapur')
insert into BorrowerDetails values(5, 'Sam', 1597538554, 3, 'solapur')
select * from BorrowerDetails
-----------------------
ALTER TABLE [dbo].[BorrowerDetails]  WITH CHECK 
ADD  CONSTRAINT [FK_Borrowerdetails_Department_DeptID] FOREIGN KEY([DeptID])
REFERENCES [dbo].[Department] ([DeptID])
GO
-----------------------
CREATE TABLE [dbo].[BookBorrowed]
(
	[BookBorrowedID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
	[BorrowerID] [int] NOT NULL,
	[BorrowedOn] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[NumberOfCopies] [int] NOT NULL,
	[ReturnStatus] [varchar](64) NOT NULL,
    CONSTRAINT [PK_BookBorrowed] PRIMARY KEY CLUSTERED ([BookBorrowedID] ASC)
) ON [PRIMARY]
GO
insert into BookBorrowed values(1, 1, 1, 8-2-2023, 9-2-2023, 4, 'Yes')
insert into BookBorrowed values(2, 2, 2, 4-2-2023, 9-2-2023, 2, 'Yes')
insert into BookBorrowed values(3, 3, 3, 6-2-2023, 10-2-2023, 1, 'No')

select * from BookBorrowed
-----------------------------
ALTER TABLE [dbo].[BookBorrowed]  WITH CHECK 
ADD  CONSTRAINT [FK_Bookborrowed_BookDetails_BookID] FOREIGN KEY([BookID])
REFERENCES [dbo].[BookDetails] ([BookID])
GO
-----------
ALTER TABLE [dbo].[BookBorrowed]  WITH CHECK 
ADD CONSTRAINT [FK_Bookborrowed_Borrowerdetails_BorrowerID] FOREIGN KEY([BorrowerID])
REFERENCES [dbo].[BorrowerDetails] ([BorrowerID])
GO
------------------------------
-- create a report/view to see bookname, authorname, subjectname and price
select * from subject
select * from BookDetails

CREATE VIEW BookReport
AS
select bookname,authorname,subjectname, price 
from subject as s
inner join bookdetails as b 
on b.subjectid = s.subjectid
-------------
-- create a report/view to see Borrowername, BorrowerContact, DepartmentName and Address
select * from BorrowerDetails
select * from Department

CREATE VIEW BorrowerReport
AS
select b.Borrowername, b.BorrowerContact, d.DeptName as DepartmentName, b.Address
from Department as d
inner join BorrowerDetails as b 
on d.DeptID = b.DeptID
-----------------
-- create a report/view to see borrowd book details: BookName, authorname, borrowercontact, BorrowerName,
borrowedON, Duedate
select * from BorrowerDetails
select * from BookBorrowed
select * from BookDetails

CREATE VIEW BorrowedBookReport
AS
select bd.BookName, bd.AuthorName, br.BorrowerName, br.BorrowerContact, bb.BorrowedOn, bb.DueDate 
from bookdetails as bd
INNER JOIN bookborrowed as bb ON bd.BookID = bb.BookID
INNER JOIN BorrowerDetails as br ON bb.BorrowerID = br.BorrowerID
WHERE bb.ReturnStatus = 'No'
--------------------------
-- Create a Stored Procedure to borrow a book (Add a entry to BookBorrowed table)
-- BookName, BorrowerName

CREATE PROCEDURE BorrowNewBook
@BookName Varchar(32),
@BorrowerName Varchar(32)
AS
BEGIN
	declare @bid int = NULL , @brid int = NULL, @bbid int = 1
	select @bbid = max(bookborrowedid)+1 from BookBorrowed
	IF NOT EXISTS (select * from BookDetails where BookName = @BookName)
	BEGIN
		Print 'Book does not exist in the library: ' + @BookName
	END
	ELSE
	BEGIN
		select @bid = BookID from BookDetails where BookName = @BookName
	END
	IF NOT EXISTS (select * from BorrowerDetails where BorrowerName = @BorrowerName)
	BEGIN
		Print 'Not a member of the library: ' + @BorrowerName
	END
	ELSE
	BEGIN
		select @brid = BorrowerID from BorrowerDetails where BorrowerName = @BorrowerName
	END
	IF (@bid IS NOT NULL) AND (@brid IS NOT NULL)
	BEGIN
		INSERT INTO BookBorrowed (BookBorrowedID, bookid, BorrowerID, BorrowedOn, DueDate, NumberOfCopies, ReturnStatus)
		Values(@bbid, @bid, @brid, getdate(), dateadd(day, 3, getdate()), 1, 'No')
	END
END
-------------------------------------------------
exec BorrowNewBook 'puran', 'Sam'
select * from BookBorrowed

select * from BorrowerReport
select * from [dbo].[BookReport]
select * from [dbo].[BorrowedBookReport]
--------------------------------------------------