-- The following drop table queries will not work unless cascade deleting
DROP TABLE IF EXISTS Pur_Inv_Lk ,
Minted,
Not_Minted,
Product,
MFG_Location,
Style,
Relief,
Shape,
Purchase,
Not_Series,
Series,
Category_Sub_Lk,
Inventory_Collection,
Prod_Inv_Lk,
Raw_Pricing,
Sub_Category,
Category,
Transaction,
Name_Change_History,
Account CASCADE;


-- Purchases
CREATE TABLE Raw_Pricing(
	monthly_avg_id SERIAL PRIMARY KEY,
	price_date DATE NOT NULL,
	average_monthly_price DECIMAL(4,2) NOT NULL
);

CREATE TABLE Transaction(
	transaction_id SERIAL PRIMARY KEY,
	transaction VARCHAR(12) NOT NULL
);

-- Account
CREATE TABLE Account(
	acct_id SERIAL PRIMARY KEY,
	user_name VARCHAR(16) NOT NULL,
	first_name VARCHAR(32) NOT NULL,
	last_name VARCHAR(32) NOT NULL,
	email VARCHAR(64)
);

-- Name_Change_History
CREATE TABLE Name_Change_History(
	history_id SERIAL PRIMARY KEY,
	acct_id INT NOT NULL,
	old_last_name VARCHAR(32) NOT NULL,
	new_last_name VARCHAR(32) NOT NULL,
	date_of_change DATE NOT NULL,
	FOREIGN KEY(acct_id) REFERENCES Account(acct_id)
);

-- Categories
CREATE TABLE Sub_Category(
	subcategory_id SERIAL PRIMARY KEY,
	subcategory VARCHAR(64) NOT NULL
);

CREATE TABLE Category(
	category_id SERIAL PRIMARY KEY,
	category VARCHAR(64) NOT NULL
);

CREATE TABLE Category_Sub_Lk(
	category_sub_id SERIAL PRIMARY KEY,
	subcategory_id INT NOT NULL,
	category_id INT NOT NULL,
	FOREIGN KEY(subcategory_id) REFERENCES Sub_Category(subcategory_id),
	FOREIGN KEY(category_id) REFERENCES Category(category_id)
);

-- Products
CREATE TABLE Shape(
	shape_id SERIAL PRIMARY KEY,
	shape VARCHAR(36) NOT NULL
	--is_coin CHAR(1) NOT NULL
);

CREATE TABLE Relief(
	relief_id SERIAL PRIMARY KEY,
	relief VARCHAR(64) NOT NULL
);

CREATE TABLE Style(
	style_id SERIAL PRIMARY KEY,
	style VARCHAR(16)
);

CREATE TABLE MFG_Location(
	mfg_location_id SERIAL PRIMARY KEY,
	mfg_location VARCHAR(36) NOT NULL
);

CREATE TABLE Product(
	product_id SERIAL PRIMARY KEY,
	category_id INT NOT NULL,
	mfg_location_id INT NOT NULL,
	shape_id INT NOT NULL,
	relief_id INT NOT NULL,
	style_id INT NOT NULL,
	coin_name VARCHAR(64) NOT NULL,
	coin_subname VARCHAR(64),
	coin_description VARCHAR(1024),
	year_made DECIMAL(4),  
	mintage_number DECIMAL(12),
	denomination DECIMAL(12),
	weight DECIMAL(12) NOT NULL,
	grade VARCHAR(12),
	FOREIGN KEY(category_id) REFERENCES Category(category_id),
	FOREIGN KEY(mfg_location_id) REFERENCES MFG_Location(mfg_location_id),
	FOREIGN KEY(shape_id) REFERENCES Shape(shape_id),
	FOREIGN KEY(relief_id) REFERENCES Relief(relief_id),
	FOREIGN KEY(style_id) REFERENCES Style(style_id)
);

CREATE TABLE Prod_Inv_Lk(
	prod_inv_id SERIAL PRIMARY KEY,
	acct_id INT NOT NULL,
	product_id INT NOT NULL,	
	FOREIGN KEY(acct_id) REFERENCES Account(acct_id),
	FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

CREATE TABLE Inventory_Collection(
	inventory_id SERIAL PRIMARY KEY,
	prod_inv_id INT NOT NULL,
	quantity DECIMAL(12) NOT NULL,
	FOREIGN KEY(prod_inv_id) REFERENCES Prod_Inv_Lk(prod_inv_id)
);

CREATE TABLE Purchase(
	purchase_id SERIAL PRIMARY KEY,
	monthly_avg_id INT NOT NULL,
	acct_id INT NOT NULL,
	transaction_id INT NOT NULL,
	product_id INT NOT NULL,
	purchase_date DATE, 
	price DECIMAL(5, 2) NOT NULL,
	--is_minted CHAR(1) NOT NULL,
	FOREIGN KEY(monthly_avg_id) REFERENCES Raw_Pricing(monthly_avg_id),
	FOREIGN KEY(acct_id) REFERENCES Account(acct_id),
	FOREIGN KEY(transaction_id) REFERENCES Transaction(transaction_id),
	FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

CREATE TABLE Not_Minted(
	purchase_id INT PRIMARY KEY,
	quantity DECIMAL(12) NOT NULL,
	FOREIGN KEY(purchase_id) REFERENCES Purchase(purchase_id)
);

CREATE TABLE Minted(
	purchase_id INT PRIMARY KEY,
	quantity DECIMAL(1) NOT NULL,
	FOREIGN KEY(purchase_id) REFERENCES Purchase(purchase_id)
);

CREATE TABLE Pur_Inv_Lk(
	pur_inv_id SERIAL PRIMARY KEY,
	purchase_id INT NOT NULL,
	inventory_id INT NOT NULL,
	FOREIGN KEY(purchase_id) REFERENCES Purchase(purchase_id),
	FOREIGN KEY(inventory_id) REFERENCES Inventory_Collection(inventory_id)
);

CREATE TABLE Series(
	product_id INT NOT NULL PRIMARY KEY,
	series_name VARCHAR(64) NOT NULL,
	FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

CREATE TABLE Not_Series(
	product_id INT NOT NULL PRIMARY KEY,
	FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

-- Add indexing
CREATE INDEX PurchaseMonthlyAvgid_idx
ON Purchase(monthly_avg_id);

CREATE INDEX PurchaseAcct_idx
ON Purchase(acct_id);

CREATE INDEX ProductCategoryid_idx
ON Product(category_id);

CREATE INDEX ProductShape_idx
ON Product(shape_id);

CREATE INDEX ProductStyleid_idx
ON Product(style_id);

CREATE INDEX InventoryProdInvIdx
ON Inventory_Collection(prod_inv_id);

/* =========================================================================*/
-- Add Accounts
CREATE OR REPLACE FUNCTION ADD_ACCT( 
	username_arg IN VARCHAR,
	first_name_arg IN VARCHAR,
	last_name_arg IN VARCHAR,
	email_arg IN VARCHAR) 
	RETURNS VOID LANGUAGE plpgsql
AS $$       
BEGIN              
	INSERT INTO Account (user_name, first_name, last_name, email)         
	VALUES (username_arg, first_name_arg, last_name_arg, email_arg);      
END;      
$$;

DO
	$$
		BEGIN
			EXECUTE ADD_ACCT('shaunSilver2019','Shaun','Marple','stmarple@hotmail.com');
			EXECUTE ADD_ACCT('JSmith45','John','Smith','ILuvPocahautus@yahoo.com');
			EXECUTE ADD_ACCT('BlackPearlNGold','Jack','Sparrow', NULL);
			EXECUTE ADD_ACCT('BahHumbugDec25', 'Ebenezer', 'Scrooge', NULL);
		END;
	$$;
/* =========================================================================*/
-- Add Shape
CREATE OR REPLACE FUNCTION ADD_SHAPE( 
	shape_arg IN VARCHAR) 
	RETURNS VOID LANGUAGE plpgsql
AS $$       
BEGIN              
	INSERT INTO Shape (shape)       
	VALUES (shape_arg); 
END;      
$$;

DO
	$$
		BEGIN
			EXECUTE ADD_SHAPE('Round');
			EXECUTE ADD_SHAPE('Rectangular');
			EXECUTE ADD_SHAPE('Poured');
			EXECUTE ADD_SHAPE('Statue');
			EXECUTE ADD_SHAPE('Route 66');
		END;
	$$;

/* ************************************ */
-- Add Reliefs
CREATE OR REPLACE FUNCTION ADD_RELIEF(
	relief_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO Relief(relief)         
		VALUES (relief_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_RELIEF('Normal');
			EXECUTE ADD_RELIEF('High');
			EXECUTE ADD_RELIEF('Ultra High');
		END;
	$$;
-- ******************************************
-- ADD STYLE
CREATE OR REPLACE FUNCTION ADD_STYLE(
	style_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO STYLE(STYLE)         
		VALUES (style_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_STYLE('Colorized');
			EXECUTE ADD_STYLE('Antique');
			EXECUTE ADD_STYLE('Shiny');
			EXECUTE ADD_STYLE('Gold Gilded');
			EXECUTE ADD_STYLE('Hematite');
		END;
	$$;

-- ******************************************
-- ADD TRANSACTION
CREATE OR REPLACE FUNCTION ADD_TRANSACTION(
	trans_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO TRANSACTION(transaction)         
		VALUES (trans_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_TRANSACTION('Buy');
			EXECUTE ADD_TRANSACTION('Sell');
		END;
	$$;
-- ******************************************
-- ADD Silver Pricing
CREATE OR REPLACE FUNCTION ADD_Raw_Silver_Pricing(
	date_arg DATE,
	price_arg IN DECIMAL
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO Raw_Pricing(price_date,average_monthly_price)         
		VALUES (date_arg, price_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_Raw_Silver_Pricing('9/1/2017', 17.26);
			EXECUTE ADD_Raw_Silver_Pricing('10/1/2017', 17.09);
			EXECUTE ADD_Raw_Silver_Pricing('11/1/2017', 17.07);
			EXECUTE ADD_Raw_Silver_Pricing('12/1/2017', 16.66);			
			EXECUTE ADD_Raw_Silver_Pricing('1/1/2018', 16.87);
			EXECUTE ADD_Raw_Silver_Pricing('2/1/2018', 16.49);			
			EXECUTE ADD_Raw_Silver_Pricing('3/1/2018', 16.28);
			EXECUTE ADD_Raw_Silver_Pricing('4/1/2018', 16.48);		
			EXECUTE ADD_Raw_Silver_Pricing('5/1/2018', 16.29);
			EXECUTE ADD_Raw_Silver_Pricing('6/1/2018', 16.27);
			EXECUTE ADD_Raw_Silver_Pricing('7/1/2018', 15.73);
			EXECUTE ADD_Raw_Silver_Pricing('8/1/2018', 15.33);
			EXECUTE ADD_Raw_Silver_Pricing('9/1/2018', 15.14);
			EXECUTE ADD_Raw_Silver_Pricing('10/1/2018', 15.12);
			EXECUTE ADD_Raw_Silver_Pricing('11/1/2018', 14.96);
			EXECUTE ADD_Raw_Silver_Pricing('12/1/2018', 15.34);
			EXECUTE ADD_Raw_Silver_Pricing('1/1/2018', 15.71);
			EXECUTE ADD_Raw_Silver_Pricing('2/1/2018', 15.57);
			EXECUTE ADD_Raw_Silver_Pricing('3/1/2018', 15.70);
			EXECUTE ADD_Raw_Silver_Pricing('4/1/2018', 15.91);		
		END;
	$$;
-- ***********************************************
-- ADD Category
CREATE OR REPLACE FUNCTION ADD_CATEGORY(
	categ_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO CATEGORY(category)         
		VALUES (categ_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_CATEGORY('Greek');
			EXECUTE ADD_CATEGORY('Roman');
			EXECUTE ADD_CATEGORY('Mythology');
			EXECUTE ADD_CATEGORY('Warriors');
			EXECUTE ADD_CATEGORY('Knights');
			EXECUTE ADD_CATEGORY('Heros');
			EXECUTE ADD_CATEGORY('Star Wars');
			EXECUTE ADD_CATEGORY('Historical');
		END;
	$$;
-- ***********************************************
-- ADD Sub-Category
CREATE OR REPLACE FUNCTION ADD_SUB_CATEGORY(
	s_categ_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO SUB_CATEGORY(subcategory)         
		VALUES (s_categ_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_SUB_CATEGORY('Gods');
			EXECUTE ADD_SUB_CATEGORY('Warriors');
			EXECUTE ADD_SUB_CATEGORY('Star Wars');
			EXECUTE ADD_SUB_CATEGORY('Mythical Creatures');
			EXECUTE ADD_SUB_CATEGORY('Leonidas');
			EXECUTE ADD_SUB_CATEGORY('Gladiators');
			EXECUTE ADD_SUB_CATEGORY('Marvel');
			EXECUTE ADD_SUB_CATEGORY('Leader of Men (type 2)');
		END;
	$$;
-- ***********************************************
-- ADD MFG_Location
CREATE OR REPLACE FUNCTION ADD_MFG_Location(
	loc_arg IN VARCHAR
	) RETURNS VOID 
	
AS $$       
	BEGIN              
		INSERT INTO MFG_Location(mfg_location)         
		VALUES (loc_arg);      
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_MFG_Location('Tuvalu');
			EXECUTE ADD_MFG_Location('Cook Islands');
			EXECUTE ADD_MFG_Location('Solomon Islands');
			EXECUTE ADD_MFG_Location('Anonomous');
			EXECUTE ADD_MFG_Location('Canadian');
			EXECUTE ADD_MFG_Location('Niue');
			EXECUTE ADD_MFG_Location('Palau');
			EXECUTE ADD_MFG_Location('Perth');
			EXECUTE ADD_MFG_Location('British Indian Ocean Territory');
			EXECUTE ADD_MFG_Location('New Zealand');
			EXECUTE ADD_MFG_Location('Serbia');
			EXECUTE ADD_MFG_Location('Tanzania');
		END;
	$$;
-- ***********************************************
-- ADD Product, 

CREATE OR REPLACE FUNCTION ADD_PRODUCT(
	categ_arg VARCHAR,
	loc_arg IN VARCHAR,
	shape_arg IN VARCHAR,
	relief_arg IN VARCHAR,
	style_arg IN VARCHAR,
	
	coin_arg IN VARCHAR,
	coinSub_arg IN VARCHAR,
	desc_arg IN VARCHAR,
	yr_made_arg IN INT,
	mintage IN INT,
	currency_arg IN DECIMAL,
	weight_arg IN DECIMAL,
	grade_arg IN VARCHAR,
	series_arg IN VARCHAR
	) RETURNS VOID 	
AS $$   
DECLARE
	var_categ_id INT;
	var_loc_id INT;
	var_shape_id INT;
	var_relief_id INT;
	var_style_id INT;
	var_new_id INT; 
	BEGIN 
		SELECT category_id INTO var_categ_id
		FROM Category
		WHERE category = categ_arg;

		SELECT mfg_location_id INTO var_loc_id
		FROM MFG_Location
		WHERE mfg_location = loc_arg;

		SELECT shape_id INTO var_shape_id
		FROM SHAPE
		WHERE shape = shape_arg;

		SELECT relief_id INTO var_relief_id
		FROM RELIEF
		WHERE relief = relief_arg;

		SELECT style_id INTO var_style_id
		FROM STYLE
		WHERE style = style_arg;

		SELECT nextval(pg_get_serial_sequence('product', 'product_id'))	INTO var_new_id;

		INSERT INTO Product(product_id, category_id, mfg_location_id, shape_id, relief_id, style_id,
			coin_name, coin_subname, coin_description, year_made, mintage_number, denomination, weight, grade)   
											  
		VALUES (var_new_id, var_categ_id, var_loc_id, var_shape_id, var_relief_id, var_style_id,
			coin_arg, coinSub_arg, desc_arg, yr_made_arg, mintage, currency_arg, weight_arg, grade_arg);   

		IF series_arg IS NOT NULL THEN
			INSERT INTO Series (product_id, series_name)       
			VALUES (var_new_id, series_arg);
		ELSE
			INSERT INTO NOT_SERIES (product_id) 
			VALUES (var_new_id);						  
		END IF;
	END;
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
							/*   categ, loc, shape,          relief,     style,   coin, 
								coinsub, desc, yr, mintage,denom, weight, grade, series_arg*/
			EXECUTE ADD_PRODUCT('Star Wars','Niue','Round','Ultra High','Shiny','Millenium Falcon', 
								NULL,                     NULL, 2019, 5000, 50, 1, NULL, NULL);
											  
			EXECUTE ADD_PRODUCT('Greek', 'Anonomous', 'Round', 'High', 'Shiny', 'Spartans', 
								'Leader of Men (type 2)', NULL, 2019, NULL, 0, 1,NULL,'Molon Labe');
			
			EXECUTE ADD_PRODUCT('Greek', 'Anonomous', 'Round', 'High', 'Gold Gilded', 'Spartans', 
								'With Spear', NULL, 2019, NULL, 0,1,NULL,'Molon Labe');

			EXECUTE ADD_PRODUCT('Historical', 'Serbia', 'Round', 'Normal', 'Shiny', 'Nikola Tesla', 
								'Alternating Current', 'Throughout the world, Nikola Tesla is recognized as one of history''s 
								greatest minds. He has over 280 patents to his name, and developed a way to harness the power 
								that still runs the world today. In 2018, the Serbian Mint began a bullion series to honor their 
								national hero. Like the bullion coin, the Proofs are struck from one ounce of .999 fine silver. 
								This piece has a total mintage of 3,327 pieces, a reference to room 3327 at the New Yorker Hotel 
								in which Tesla kept his scientific papers locked. This piece remains in GEM Proof 
								condition.', 2018, 3327, 100,1,NULL, NULL);
			
			EXECUTE ADD_PRODUCT('Mythology', 'Tanzania', 'Round', 'Normal', 'Shiny', 'Griffin', 
								NULL, 'The griffin, griffon, or gryphon is a legendary creature with the body, tail, 
								and back legs of a lion, the head and wings of an eagle, and an eagle''s talons as its 
								front feet.  Because the lion was traditionally considered the king of the beasts and the 
								eagle the king of birds, the griffin was thought to be an especially powerful and majestic 
								creature. The griffin was also thought of as king of all creatures. Griffins are known 
								for guarding treasure and priceless possessions.', 2018, 499, 1500,1,NULL, 'Mythology Series');
			
			EXECUTE ADD_PRODUCT('Roman', 'Tuvalu', 'Round', 'High', 'Antique', 'Roman Legion', 
								'Tuvalu Warfare', NULL, 2018, 2000, 0,1,'PCGS69','Warfare Series');
			
			EXECUTE ADD_PRODUCT('Greek', 'Cook Islands', 'Round', 'Ultra High', 'Antique', 'Shield of Athena', 
								'Aegis', 'Shield of Athena - aegis The aegis, as stated in the Iliad, 
								is carried by Athena and Zeus, but its nature is uncertain. It had been 
								interpreted as an animal skin or a shield, sometimes bearing the head 
								of a Gorgon. There may be a connection with a deity named Aex or Aix, 
								a daughter of Helios and a nurse of Zeus or alternatively a mistress of 
								Zeus. The aegis of Athena is referred to in several places in the Iliad. 
								“It produced a sound as from a myriad roaring dragons (Iliad, 4.17) and 
								was borne by Athena in battle ... and among them went bright-eyed Athene, 
								holding the precious aegis which is ageless and immortal: a hundred tassels 
								of pure gold hang fluttering from it, tight-woven each of them, and each 
								the worth of a hundred oxen”.', 2018, 999, 0,1,'PCGS70','Mythology Series');
			
			EXECUTE ADD_PRODUCT('Greek', 'Niue', 'Round', 'Ultra High', 'Hematite', 'Achilles', 
								'Achilles Vs Hector', NULL, 2017, 650, 0,1,NULL,'Demigods Series');											  
		
		END;
	$$;

-- I'm not sure why NULL is not excepted in function, so...
UPDATE Product
SET denomination = NULL
WHERE denomination = 0;

-- ===================================================================
 -- ADD Inventory 
IF EXISTS DROP FUNCTION ADD_INVENTORY;
											  
CREATE OR REPLACE FUNCTION ADD_INVENTORY(
	userid_arg IN INT,
	productid_arg IN INT,
	qty_arg IN INT
	) RETURNS INT
	
AS $$
	DECLARE 
		var_inv_id INT;
		var_prod_inv_id INT;
		var_qty_srch INT;		
	BEGIN	
		SELECT inventory_collection.inventory_id, inventory_collection.prod_inv_id, quantity 
		INTO var_inv_id, var_prod_inv_id, var_qty_srch
		FROM inventory_collection JOIN
		prod_inv_lk ON inventory_collection.prod_inv_id = prod_inv_lk.prod_inv_id
		WHERE
		prod_inv_lk.product_id = productid_arg
		AND prod_inv_lk.acct_id = userid_arg;
		
		IF var_qty_srch IS NULL THEN
			SELECT nextval(pg_get_serial_sequence('prod_inv_lk', 'prod_inv_id')) into var_prod_inv_id;
			
			INSERT INTO prod_inv_lk (prod_inv_id, acct_id, product_id) 
			VALUES (var_prod_inv_id, userid_arg, productid_arg);
			
			SELECT nextval(pg_get_serial_sequence('inventory_collection', 'inventory_id')) INTO var_inv_id;
			
			INSERT INTO INVENTORY_COLLECTION(inventory_id, prod_inv_id, quantity)         
			VALUES (var_inv_id, var_prod_inv_id, qty_arg);
		ELSE
			UPDATE INVENTORY_COLLECTION SET quantity = var_qty_srch + qty_arg 
			WHERE prod_inv_id = var_prod_inv_id;	
		END IF;
		
		RETURN var_inv_id;
	END;      
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN			-- user_id, product_id, qty
			PERFORM ADD_INVENTORY(2, 1, 1);
		END;
	$$;
-- ***********************************************
-- ADD Purchases, 
CREATE OR REPLACE FUNCTION ADD_PURCHASE(
	--price_arg IN VARCHAR,
	product_id_arg in INTEGER,
	acct_arg IN VARCHAR,
	trans_arg IN VARCHAR,
	
	date_arg IN DATE,  
	price_arg IN DECIMAL,
	qty_arg IN INT,
	mint_arg IN VARCHAR
	) RETURNS VOID 	

AS $$   
DECLARE
	var_price_id INT;
	var_acct_id INT;
	var_trans_id INT;
	var_new_id INT;
	var_inv_id INT;
											 
	BEGIN 
		SELECT Raw_Pricing.monthly_avg_id INTO var_price_id
		FROM Raw_Pricing
		WHERE to_char(date_arg, 'YYYYMM') = to_char(Raw_Pricing.price_date, 'YYYYMM');

		SELECT acct_id INTO var_acct_id
		FROM Account
		WHERE user_name = acct_arg;		
											  
		SELECT transaction_id INTO var_trans_id
		FROM Transaction
		WHERE transaction = trans_arg;											  
											  
		SELECT nextval(pg_get_serial_sequence('purchase', 'purchase_id'))	
		INTO var_new_id;

		INSERT INTO Purchase(purchase_id, monthly_avg_id, acct_id, transaction_id,
							product_id,
							purchase_date, price)
		VALUES (var_new_id, var_price_id, var_acct_id, var_trans_id,
				product_id_arg,
				date_arg, price_arg);

			
		IF mint_arg IS NOT NULL THEN
			INSERT INTO Minted (purchase_id, quantity)       
			VALUES (var_new_id, 1);
		ELSE
			INSERT INTO NOT_minted (purchase_id, quantity) 
			VALUES (var_new_id, qty_arg);						  
		END IF;
		
		
		SELECT ADD_INVENTORY(var_acct_id, product_id_arg, qty_arg) INTO var_inv_id;
		
		INSERT INTO Pur_Inv_Lk(purchase_id, inventory_id) VALUES (
			var_new_id, var_inv_id);

	END;
$$ LANGUAGE plpgsql;

DO
	$$
		BEGIN
			EXECUTE ADD_PURCHASE(
				1, --product id 
				'shaunSilver2019', -- username
				'Buy', --trans_arg
				to_date('10/12/2017', 'MM/DD/YYYY'), --date_arg
				40, --price_arg
				1, -- qty_arg
				NULL
				);
			EXECUTE ADD_PURCHASE(
				1, --product id 
				'JSmith45', -- username
				'Buy', --trans_arg
				to_date('10/12/2017', 'MM/DD/YYYY'), --date_arg
				40, --price_arg
				1, -- qty_arg
				NULL
				);	
			EXECUTE ADD_PURCHASE(
				2, --product id 
				'shaunSilver2019', -- username
				'Buy', --trans_arg
				to_date('10/25/2017', 'MM/DD/YYYY'), --date_arg
				37, --price_arg
				4, -- qty_arg
				NULL
				);	
			EXECUTE ADD_PURCHASE(
				5, --product id 
				'shaunSilver2019', -- username
				'Buy', --trans_arg
				to_date('1/25/2018', 'MM/DD/YYYY'), --date_arg
				37, --price_arg
				4, -- qty_arg
				NULL
				);	
			EXECUTE ADD_PURCHASE(
				5, --product id 
				'shaunSilver2019', -- username
				'Buy', --trans_arg
				to_date('3/1/2018', 'MM/DD/YYYY'), --date_arg
				90, --price_arg
				1, -- qty_arg
				NULL
				);
		END;
	$$;
	select * from purchase						
	-- Later, I will make the mintage arguement a part of the table design to allow tracking of specific numbers
	-- Nulls will trigger the subtype
											   
/* ==============================================================*/
-- Triggers
CREATE OR REPLACE FUNCTION Name_Change_History_func() 
RETURNS TRIGGER LANGUAGE plpgsql 
AS $$ 
BEGIN     
	IF OLD.last_name <> NEW.last_name THEN         
		INSERT INTO Name_Change_History (acct_id, old_last_name, new_last_name, date_of_change)         
		VALUES(NEW.acct_id, OLD.last_name, NEW.last_name, CURRENT_DATE);     
	END IF;     
	RETURN NEW; 
END; 
$$;

CREATE TRIGGER Name_Change_History_trg 
BEFORE UPDATE ON Account 
FOR EACH ROW 
EXECUTE PROCEDURE Name_Change_History_func(); 

/* ================================================================*/
-- Question Section
-- What are all the series names for all of your products and how many products do you have for each series?											  
SELECT year_made, series_name, COUNT(product.coin_name) AS Product_Count
FROM Product
JOIN Series ON product.product_id = Series.product_id
JOIN Not_Series ON product.product_id = Series.product_id
GROUP BY year_made, Series_name
ORDER BY Product_Count DESC;
											  
--Name all the products whose prices are greater than the average.
SELECT Category.category, Series.series_name, Product.coin_name, Cast(Purchase.price as money) AS Cash
FROM Category 
JOIN Product ON Category.category_id = Product.category_id
JOIN Purchase ON Product.product_id = Purchase.product_id
JOIN Series ON Series.product_id = Product.product_id
WHERE (
	(SELECT AVG(Purchase.price)
	FROM Purchase) > Purchase.price);
	
-- What are the ratios for each product
SELECT DISTINCT Category.category, Product.coin_name, Cast(Purchase.price as money) as Cash_Money,
			TRUNC(Purchase.price / Raw_Pricing.average_monthly_price, 3) AS Purchase_Ratio
FROM Category
RIGHT JOIN Product ON Category.category_id = Product.category_id
RIGHT JOIN Purchase ON Product.product_id = Purchase.product_id
RIGHT JOIN Raw_Pricing ON Purchase.monthly_avg_id = Raw_Pricing.monthly_avg_id
WHERE (to_char(Purchase.purchase_date, 'YYYYMM') = to_char(Raw_Pricing.price_date, 'YYYYMM')
	   AND (Product.weight = 1))
ORDER BY purchase_ratio DESC;

-- *************************************
--Test trigger
-- Test
SELECT * FROM ACCOUNT;
											  
UPDATE ACCOUNT
SET last_name = 'Sparrow'
WHERE first_name = 'Jack';

SELECT * FROM Name_Change_History;

