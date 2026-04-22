

create database wallets;
use wallets;

CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT, 
    UserName VARCHAR(100) NOT NULL,        
    Email VARCHAR(100) UNIQUE              
);


CREATE TABLE Wallets (
    WalletID INT PRIMARY KEY AUTO_INCREMENT,  
    UserID INT NOT NULL UNIQUE,               
    Balance DECIMAL(18, 2) DEFAULT 0,         
    CONSTRAINT FK_Wallet_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CHK_Balance_NonNegative CHECK (Balance >= 0)
);


CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT, 
    WalletID INT NOT NULL,                        
    TransactionType ENUM('Deposit', 'Withdraw', 'Payment') NOT NULL, 
    Amount DECIMAL(18, 2) NOT NULL,               
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
    Status ENUM('Pending', 'Success', 'Failed') DEFAULT 'Pending',
    CONSTRAINT FK_Transaction_Wallet FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT CHK_Amount_Positive CHECK (Amount > 0)
);