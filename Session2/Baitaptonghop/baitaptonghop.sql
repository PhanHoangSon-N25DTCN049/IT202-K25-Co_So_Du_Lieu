create database books;
use books;
DROP TABLE IF EXISTS borrow_books; 
DROP TABLE IF EXISTS table_book;

create table table_book (
book_Id char(5) primary key,
book_Name varchar(200) not null unique,
book_quantity int check (book_quantity >=0) not null,
book_price decimal(18,1) default 5000
);

alter table table_book
add column entry_date Datetime;

create table borrow_books (
borrow_Id int auto_increment primary key,
book_Id char(5),
foreign key (book_Id) references table_book(book_Id),
entry_date date default (current_date)
);
