CREATE TABLE Cities(
    id NUMBER PRIMARY KEY,
    
    postal_code NUMBER(10) NOT NULL,
    city_name VARCHAR2(100) NOT NULL 
); 

CREATE TABLE Addresses (
    id NUMBER PRIMARY KEY,

    street VARCHAR2(100) NOT NULL,
    building_no VARCHAR2(10) NOT NULL,

    city_id NUMBER NOT NULL, CONSTRAINT fk_addresses_city FOREIGN KEY (city_id) REFERENCES Cities(id) 
); 

CREATE TABLE Customers (
    id NUMBER PRIMARY KEY,

    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(255) UNIQUE NOT NULL,
    phone VARCHAR2(20), 
    
    address_id NUMBER NOT NULL,

    CONSTRAINT fk_customers_address FOREIGN KEY (address_id) REFERENCES Addresses(id)
); 

CREATE TABLE Couriers ( 
    id NUMBER PRIMARY KEY, 

    first_name VARCHAR2(50) NOT NULL, 
    last_name VARCHAR2(50) NOT NULL, 
    phone VARCHAR2(20) UNIQUE NOT NULL, 
    vehicle_type VARCHAR2(20) NOT NULL CHECK (vehicle_type IN ('BIKE', 'CAR', 'SCOOTER')) 
); 

CREATE TABLE Restaurants ( 
    id NUMBER PRIMARY KEY, 

    name VARCHAR2(100) NOT NULL,
    phone VARCHAR2(20) NOT NULL,
    email VARCHAR2(255), 

    address_id NUMBER NOT NULL, 
    
    CONSTRAINT fk_restaurants_address FOREIGN KEY (address_id) REFERENCES Addresses(id) 
); 

CREATE TABLE Products ( 
    id NUMBER PRIMARY KEY, 

    name VARCHAR2(100) NOT NULL, 
    price NUMBER(10, 2) NOT NULL, 
    category VARCHAR2(30) CHECK (category IN ('DRINK', 'FOOD', 'OTHERS')), 

    restaurant_id NUMBER NOT NULL, 

    CONSTRAINT fk_products_restaurant FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id) 
); 

CREATE TABLE Customer_orders ( 
    id NUMBER PRIMARY KEY, 
    order_date TIMESTAMP NOT NULL, 
    total_price NUMBER(10, 2) NOT NULL, 
    order_status VARCHAR2(20) NOT NULL CHECK ( order_status IN ('ACCEPT', 'PREPARING', 'DENIED', 'ARRIVED', 'DELIVERING') ), 
    
    customer_id NUMBER NOT NULL, 
    restaurant_id NUMBER NOT NULL, 
    courier_id NUMBER, 

    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES Customers(id), 
    CONSTRAINT fk_orders_restaurant FOREIGN KEY (restaurant_id) REFERENCES Restaurants(id), 
    CONSTRAINT fk_orders_courier FOREIGN KEY (courier_id) REFERENCES Couriers(id) 
); 
    
CREATE TABLE Payments ( 
    id NUMBER PRIMARY KEY, 

    payment_method VARCHAR2(20) NOT NULL CHECK (payment_method IN ('CASH', 'CARD')), 
    status VARCHAR2(20) NOT NULL CHECK (status IN ('PENDING', 'PAID')), 
    payment_date DATE, amount NUMBER(10,2) NOT NULL, 

    order_id NUMBER NOT NULL UNIQUE, 

    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES Customer_orders(id) 
); 

CREATE TABLE Order_items ( 
    id NUMBER PRIMARY KEY,

    price NUMBER(10, 2) NOT NULL, 
    quantity NUMBER(10) NOT NULL, 

    product_id NUMBER NOT NULL, 
    order_id NUMBER NOT NULL, 

    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES Products(id), 
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES Customer_orders(id) 
);

INSERT INTO Cities (id, postal_code, city_name) VALUES (1, 81101, 'Bratislava');
INSERT INTO Cities (id, postal_code, city_name) VALUES (2, 04001, 'Kosice');
INSERT INTO Cities (id, postal_code, city_name) VALUES (3, 08001, 'Presov');
INSERT INTO Cities (id, postal_code, city_name) VALUES (4, 01001, 'Zilina');
INSERT INTO Cities (id, postal_code, city_name) VALUES (5, 94901, 'Nitra');
INSERT INTO Cities (id, postal_code, city_name) VALUES (6, 91701, 'Trnava');
INSERT INTO Cities (id, postal_code, city_name) VALUES (7, 03601, 'Martin');
INSERT INTO Cities (id, postal_code, city_name) VALUES (8, 97401, 'Banska Bystrica');
INSERT INTO Cities (id, postal_code, city_name) VALUES (9, 91101, 'Trencin');
INSERT INTO Cities (id, postal_code, city_name) VALUES (10, 05201, 'Spisska Nova Ves');
INSERT INTO Cities (id, postal_code, city_name) VALUES (11, 06001, 'Kezmarok');
INSERT INTO Cities (id, postal_code, city_name) VALUES (12, 08501, 'Bardejov');
INSERT INTO Cities (id, postal_code, city_name) VALUES (13, 07101, 'Michalovce');
INSERT INTO Cities (id, postal_code, city_name) VALUES (14, 92101, 'Piestany');
INSERT INTO Cities (id, postal_code, city_name) VALUES (15, 98401, 'Lucenec');

INSERT INTO Addresses (id, street, building_no, city_id) VALUES (1, 'Hlavna', '12', 1);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (2, 'Mlynska', '5', 2);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (3, 'Sabinovska', '23', 3);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (4, 'Narodna', '8', 4);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (5, 'Stefanikova', '44', 5);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (6, 'Hlboka', '19', 6);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (7, 'Jesenskeho', '7', 7);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (8, 'Lazovna', '31', 8);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (9, 'Palackeho', '17', 9);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (10, 'Letna', '9', 10);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (11, 'Hviezdoslavova', '14', 11);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (12, 'Radnicne Namestie', '3', 12);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (13, 'Sobranecka', '28', 13);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (14, 'Winterova', '11', 14);
INSERT INTO Addresses (id, street, building_no, city_id) VALUES (15, 'Tovarenska', '6', 15);

INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (1, 'Jan', 'Novak', 'jan.novak@example.com', '0901000001', 1);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (2, 'Petra', 'Kovacova', 'petra.kovacova@example.com', '0901000002', 2);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (3, 'Martin', 'Horvat', 'martin.horvat@example.com', '0901000003', 3);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (4, 'Lucia', 'Bielikova', 'lucia.bielikova@example.com', '0901000004', 4);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (5, 'Tomas', 'Mikula', 'tomas.mikula@example.com', '0901000005', 5);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (6, 'Veronika', 'Simkova', 'veronika.simkova@example.com', '0901000006', 6);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (7, 'Marek', 'Urban', 'marek.urban@example.com', '0901000007', 7);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (8, 'Katarina', 'Polakova', 'katarina.polakova@example.com', '0901000008', 8);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (9, 'Peter', 'Balaz', 'peter.balaz@example.com', '0901000009', 9);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (10, 'Jana', 'Krupova', 'jana.krupova@example.com', '0901000010', 10);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (11, 'Michal', 'Fedor', 'michal.fedor@example.com', '0901000011', 11);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (12, 'Zuzana', 'Liptakova', 'zuzana.liptakova@example.com', '0901000012', 12);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (13, 'Andrej', 'Hudak', 'andrej.hudak@example.com', '0901000013', 13);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (14, 'Nikola', 'Marosova', 'nikola.marosova@example.com', '0901000014', 14);
INSERT INTO Customers (id, first_name, last_name, email, phone, address_id) VALUES (15, 'Samuel', 'Boros', 'samuel.boros@example.com', '0901000015', 15);

INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (1, 'Milan', 'Sabo', '0911000001', 'BIKE');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (2, 'Robo', 'Kral', '0911000002', 'CAR');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (3, 'Igor', 'Maly', '0911000003', 'SCOOTER');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (4, 'David', 'Kovac', '0911000004', 'BIKE');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (5, 'Erik', 'Hudec', '0911000005', 'CAR');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (6, 'Patrik', 'Jurik', '0911000006', 'SCOOTER');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (7, 'Roman', 'Bartos', '0911000007', 'BIKE');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (8, 'Lukas', 'Brezina', '0911000008', 'CAR');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (9, 'Adam', 'Dvorak', '0911000009', 'SCOOTER');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (10, 'Filip', 'Koren', '0911000010', 'CAR');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (11, 'Juraj', 'Kovacik', '0911000011', 'BIKE');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (12, 'Richard', 'Toth', '0911000012', 'SCOOTER');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (13, 'Tibor', 'Sima', '0911000013', 'CAR');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (14, 'Oliver', 'Klein', '0911000014', 'BIKE');
INSERT INTO Couriers (id, first_name, last_name, phone, vehicle_type) VALUES (15, 'Sebastian', 'Hasko', '0911000015', 'SCOOTER');

INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (1, 'Pizza Point Bratislava', '0211111111', 'ba@pizzapoint.sk', 1);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (2, 'Burger House Kosice', '0552222222', 'ke@burgerhouse.sk', 2);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (3, 'Sushi Go Presov', '0513333333', 'po@sushigo.sk', 3);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (4, 'Grill Zilina', '0414444444', 'za@grill.sk', 4);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (5, 'Pasta Nitra', '0375555555', 'nr@pasta.sk', 5);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (6, 'Fresh Trnava', '0336666666', 'tt@fresh.sk', 6);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (7, 'Steak Martin', '0437777777', 'mt@steak.sk', 7);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (8, 'Bistro Banska', '0488888888', 'bb@bistro.sk', 8);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (9, 'Doner Trencin', '0329999999', 'tn@doner.sk', 9);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (10, 'Wok SNV', '0531010101', 'snv@wok.sk', 10);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (11, 'Kebab Kezmarok', '0522020202', 'kk@kebab.sk', 11);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (12, 'Cafe Bardejov', '0543030303', 'bj@cafe.sk', 12);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (13, 'Food Factory Michalovce', '0564040404', 'mi@foodfactory.sk', 13);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (14, 'Pizza Piestany', '0335050505', 'pn@pizza.sk', 14);
INSERT INTO Restaurants (id, name, phone, email, address_id) VALUES (15, 'Lunch Lucenec', '0476060606', 'lc@lunch.sk', 15);

INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (1, 'Margherita Pizza', 8.50, 'FOOD', 1);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (2, 'Cheeseburger', 7.90, 'FOOD', 2);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (3, 'Salmon Sushi Set', 12.90, 'FOOD', 3);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (4, 'Grilled Chicken', 10.50, 'FOOD', 4);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (5, 'Carbonara Pasta', 9.20, 'FOOD', 5);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (6, 'Caesar Salad', 7.50, 'FOOD', 6);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (7, 'Ribeye Steak', 16.90, 'FOOD', 7);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (8, 'Tomato Soup', 4.50, 'FOOD', 8);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (9, 'Chicken Doner', 6.80, 'FOOD', 9);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (10, 'Chicken Noodles', 8.70, 'FOOD', 10);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (11, 'Beef Kebab', 7.20, 'FOOD', 11);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (12, 'Cappuccino', 2.80, 'DRINK', 12);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (13, 'Cola 0.5L', 2.20, 'DRINK', 13);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (14, 'Pepperoni Pizza', 9.50, 'FOOD', 14);
INSERT INTO Products (id, name, price, category, restaurant_id) VALUES (15, 'Daily Menu', 6.90, 'FOOD', 15);

INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (1, TIMESTAMP '2026-03-20 11:15:00', 11.00, 'ARRIVED', 1, 1, 1);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (2, TIMESTAMP '2026-03-20 12:05:00', 10.10, 'ARRIVED', 2, 2, 2);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (3, TIMESTAMP '2026-03-20 13:30:00', 12.90, 'PREPARING', 3, 3, 3);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (4, TIMESTAMP '2026-03-21 10:20:00', 10.50, 'DELIVERING', 4, 4, 4);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (5, TIMESTAMP '2026-03-21 11:00:00', 11.40, 'ARRIVED', 5, 5, 5);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (6, TIMESTAMP '2026-03-21 12:40:00', 10.30, 'ACCEPT', 6, 6, 6);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (7, TIMESTAMP '2026-03-21 18:10:00', 16.90, 'PREPARING', 7, 7, 7);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (8, TIMESTAMP '2026-03-22 09:45:00', 9.00, 'ARRIVED', 8, 8, 8);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (9, TIMESTAMP '2026-03-22 14:25:00', 13.60, 'DELIVERING', 9, 9, 9);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (10, TIMESTAMP '2026-03-22 15:50:00', 8.70, 'ACCEPT', 10, 10, 10);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (11, TIMESTAMP '2026-03-22 17:05:00', 14.40, 'DENIED', 11, 11, 11);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (12, TIMESTAMP '2026-03-23 08:30:00', 5.60, 'ARRIVED', 12, 12, 12);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (13, TIMESTAMP '2026-03-23 13:10:00', 8.80, 'ARRIVED', 13, 13, 13);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (14, TIMESTAMP '2026-03-23 19:20:00', 9.50, 'DELIVERING', 14, 14, 14);
INSERT INTO Customer_orders (id, order_date, total_price, order_status, customer_id, restaurant_id, courier_id) VALUES (15, TIMESTAMP '2026-03-24 11:55:00', 13.80, 'ACCEPT', 15, 15, 15);

INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (1, 'CARD', 'PAID', DATE '2026-03-20', 11.00, 1);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (2, 'CASH', 'PAID', DATE '2026-03-20', 10.10, 2);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (3, 'CARD', 'PENDING', DATE '2026-03-20', 12.90, 3);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (4, 'CARD', 'PENDING', DATE '2026-03-21', 10.50, 4);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (5, 'CASH', 'PAID', DATE '2026-03-21', 11.40, 5);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (6, 'CARD', 'PENDING', DATE '2026-03-21', 10.30, 6);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (7, 'CARD', 'PENDING', DATE '2026-03-21', 16.90, 7);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (8, 'CASH', 'PAID', DATE '2026-03-22', 9.00, 8);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (9, 'CARD', 'PENDING', DATE '2026-03-22', 13.60, 9);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (10, 'CARD', 'PENDING', DATE '2026-03-22', 8.70, 10);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (11, 'CASH', 'PENDING', DATE '2026-03-22', 14.40, 11);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (12, 'CARD', 'PAID', DATE '2026-03-23', 5.60, 12);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (13, 'CARD', 'PAID', DATE '2026-03-23', 8.80, 13);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (14, 'CASH', 'PENDING', DATE '2026-03-23', 9.50, 14);
INSERT INTO Payments (id, payment_method, status, payment_date, amount, order_id) VALUES (15, 'CARD', 'PENDING', DATE '2026-03-24', 13.80, 15);

INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (1, 8.50, 1, 1, 1);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (2, 2.50, 1, 13, 1);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (3, 7.90, 1, 2, 2);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (4, 2.20, 1, 13, 2);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (5, 12.90, 1, 3, 3);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (6, 10.50, 1, 4, 4);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (7, 9.20, 1, 5, 5);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (8, 2.20, 1, 13, 5);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (9, 7.50, 1, 6, 6);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (10, 2.80, 1, 12, 6);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (11, 16.90, 1, 7, 7);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (12, 4.50, 2, 8, 8);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (13, 6.80, 2, 9, 9);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (14, 8.70, 1, 10, 10);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (15, 7.20, 2, 11, 11);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (16, 2.80, 2, 12, 12);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (17, 2.20, 4, 13, 13);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (18, 9.50, 1, 14, 14);
INSERT INTO Order_items (id, price, quantity, product_id, order_id) VALUES (19, 6.90, 2, 15, 15);