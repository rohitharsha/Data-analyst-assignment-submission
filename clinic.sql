create database Clinic_Management_sysstem;

CREATE TABLE clinics (
  cid VARCHAR(20) PRIMARY KEY,
  clinic_name VARCHAR(150) NOT NULL,
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100)
);
CREATE TABLE customer (
  uid VARCHAR(20) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
  oid VARCHAR(30) PRIMARY KEY,
  uid VARCHAR(20) NOT NULL,
  cid VARCHAR(20) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  [datetime] DATETIME NOT NULL,
  sales_channel VARCHAR(50),
  CONSTRAINT FK_clinic_sales_customer FOREIGN KEY (uid) REFERENCES customer(uid),
  CONSTRAINT FK_clinic_sales_clinics FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
  eid VARCHAR(30) PRIMARY KEY,
  cid VARCHAR(20) NOT NULL,
  description VARCHAR(200),
  amount DECIMAL(12,2),
  [datetime] DATETIME,
  CONSTRAINT FK_expenses_clinics FOREIGN KEY (cid) REFERENCES clinics(cid)
);

-- 3) Insert data (clinics, customers, clinic_sales, expenses)

INSERT INTO clinics (cid, clinic_name, city, state, country) VALUES
('cnc-001','Alpha Clinic','Bengaluru','Karnataka','India'),
('cnc-002','Beta Clinic','Mysuru','Karnataka','India'),
('cnc-003','Gamma Clinic','Hyderabad','Telangana','India'),
('cnc-004','Delta Clinic','Secunderabad','Telangana','India'),
('cnc-005','Epsilon Clinic','Vijayawada','Andhra Pradesh','India'),
('cnc-006','Zeta Clinic','Guntur','Andhra Pradesh','India'),
('cnc-007','Eta Clinic','Chennai','Tamil Nadu','India'),
('cnc-008','Theta Clinic','Coimbatore','Tamil Nadu','India'),
('cnc-009','Iota Clinic','Pune','Maharashtra','India'),
('cnc-010','Kappa Clinic','Mumbai','Maharashtra','India');


INSERT INTO customer (uid, name, mobile) VALUES
('cust-001','John D','9791000001'),
('cust-002','Priya R','9791000002'),
('cust-003','Amit K','9791000003'),
('cust-004','Sara L','9791000004'),
('cust-005','Ravi P','9791000005'),
('cust-006','Meena S','9791000006'),
('cust-007','Vikram T','9791000007'),
('cust-008','Leena M','9791000008'),
('cust-009','Karan J','9791000009'),
('cust-010','Nisha B','9791000010');


INSERT INTO clinic_sales (oid, uid, cid, amount, [datetime], sales_channel) VALUES
('ord-001','cust-001','cnc-001',2499.00,'2021-01-15 10:10:00','online'),
('ord-002','cust-002','cnc-001',3499.00,'2021-02-20 11:30:00','walkin'),
('ord-003','cust-003','cnc-002',1999.00,'2021-03-05 09:00:00','online'),
('ord-004','cust-004','cnc-003',4999.00,'2021-04-12 12:03:22','phone'),
('ord-005','cust-005','cnc-004',1599.00,'2021-05-23 14:15:00','walkin'),
('ord-006','cust-006','cnc-005',2999.00,'2021-06-30 16:00:00','online'),
('ord-007','cust-007','cnc-006',1299.00,'2021-07-09 10:30:00','walkin'),
('ord-008','cust-008','cnc-007',3999.00,'2021-08-19 17:20:00','phone'),
('ord-009','cust-009','cnc-008',2599.00,'2021-09-23 12:03:22','online'),
('ord-010','cust-010','cnc-009',2199.00,'2021-11-11 13:13:13','walkin');


INSERT INTO expenses (eid, cid, description, amount, [datetime]) VALUES
('exp-001','cnc-001','first-aid supplies',557.00,'2021-01-10 07:36:48'),
('exp-002','cnc-001','electricity bill',1200.00,'2021-02-01 09:00:00'),
('exp-003','cnc-002','stationery',300.00,'2021-03-10 10:00:00'),
('exp-004','cnc-003','cleaning',800.00,'2021-04-15 15:00:00'),
('exp-005','cnc-004','equipment maintenance',2000.00,'2021-05-20 11:00:00'),
('exp-006','cnc-005','staff training',1200.00,'2021-06-25 09:30:00'),
('exp-007','cnc-006','drugs procurement',3500.00,'2021-07-04 08:00:00'),
('exp-008','cnc-007','internet',450.00,'2021-08-09 18:00:00'),
('exp-009','cnc-008','rent',5000.00,'2021-09-01 09:00:00'),
('exp-010','cnc-009','misc',250.00,'2021-11-05 10:00:00');




select * from clinics;
select * from customer;
select * from clinic_sales;
select * from expenses;
-- 
SELECT sales_channel, SUM(amount) AS revenue
FROM clinic_sales
WHERE datetime >= '2021-01-01' AND datetime < '2022-01-01'
GROUP BY sales_channel;
--Top 10 most valuable customers for a given year (by total spend)
SELECT TOP 10 
    cs.uid, 
    c.name, 
    SUM(cs.amount) AS total_spend
FROM clinic_sales cs
JOIN customer c ON cs.uid = c.uid
WHERE cs.datetime >= '2021-01-01'
  AND cs.datetime < '2022-01-01'
GROUP BY cs.uid, c.name
ORDER BY total_spend DESC;
--B3 — Month-wise revenue, expense, profit, status
WITH rev AS (
    SELECT
        DATEADD(month, DATEDIFF(month, 0, [datetime]), 0) AS [month],
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE [datetime] >= '2021-01-01' AND [datetime] < '2022-01-01'
    GROUP BY DATEADD(month, DATEDIFF(month, 0, [datetime]), 0)
),
exp AS (
    SELECT
        DATEADD(month, DATEDIFF(month, 0, [datetime]), 0) AS [month],
        SUM(amount) AS expense
    FROM expenses
    WHERE [datetime] >= '2021-01-01' AND [datetime] < '2022-01-01'
    GROUP BY DATEADD(month, DATEDIFF(month, 0, [datetime]), 0)
)
SELECT
    ISNULL(r.[month], e.[month]) AS [month],
    ISNULL(r.revenue, 0)    AS revenue,
    ISNULL(e.expense, 0)    AS expense,
    ISNULL(r.revenue, 0) - ISNULL(e.expense, 0) AS profit,
    CASE
        WHEN ISNULL(r.revenue, 0) - ISNULL(e.expense, 0) > 0 THEN 'profitable'
        ELSE 'not-profitable'
    END AS status
FROM rev r
FULL OUTER JOIN exp e
    ON r.[month] = e.[month]
ORDER BY [month];
--For each city find the most profitable clinic for a given month 
-- Profit per clinic per month = revenue - expense
WITH clinic_rev AS (
    SELECT 
        cid,
        -- Truncate to month
        DATEADD(month, DATEDIFF(month, 0, [datetime]), 0) AS [month],
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE [datetime] >= '2021-01-01' AND [datetime] < '2022-01-01'
    GROUP BY cid, DATEADD(month, DATEDIFF(month, 0, [datetime]), 0)
),
clinic_exp AS (
    SELECT 
        cid,
        DATEADD(month, DATEDIFF(month, 0, [datetime]), 0) AS [month],
        SUM(amount) AS expense
    FROM expenses
    WHERE [datetime] >= '2021-01-01' AND [datetime] < '2022-01-01'
    GROUP BY cid, DATEADD(month, DATEDIFF(month, 0, [datetime]), 0)
),
clinic_profit AS (
    SELECT 
        c.cid,
        c.clinic_name,
        c.city,
        ISNULL(r.revenue, 0) - ISNULL(e.expense, 0) AS profit,
        ISNULL(r.[month], e.[month]) AS [month]
    FROM clinics c
    LEFT JOIN clinic_rev r 
        ON c.cid = r.cid
    LEFT JOIN clinic_exp e 
        ON c.cid = e.cid 
        AND r.[month] = e.[month]
)
SELECT 
    cp.[month],
    cp.city,
    cp.cid,
    cp.clinic_name,
    cp.profit
FROM (
    SELECT 
        [month],
        city,
        cid,
        clinic_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY [month], city
            ORDER BY profit DESC
        ) AS rn
    FROM clinic_profit
) cp
WHERE cp.rn = 1
ORDER BY cp.[month], cp.city;

--For each state find the second least profitable clinic for a given month 
-- 2nd-lowest profit clinic per state per month (SQL Server)
DECLARE @Year INT = 2021;   -- change as needed
DECLARE @Month INT = 8;     -- change as needed

WITH sales AS (
    SELECT 
        cid,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR([datetime]) = @Year
      AND MONTH([datetime]) = @Month
    GROUP BY cid
),
exp AS (
    SELECT 
        cid,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR([datetime]) = @Year
      AND MONTH([datetime]) = @Month
    GROUP BY cid
),
profit AS (
    SELECT 
        c.cid,
        c.clinic_name,
        c.city,
        c.state,
        ISNULL(s.revenue, 0) AS revenue,
        ISNULL(e.expense, 0) AS expense,
        ISNULL(s.revenue, 0) - ISNULL(e.expense, 0) AS profit
    FROM clinics c
    LEFT JOIN sales s ON c.cid = s.cid
    LEFT JOIN exp   e ON c.cid = e.cid
)
SELECT 
    state,
    cid,
    clinic_name,
    city,
    revenue,
    expense,
    profit
FROM (
    SELECT 
        p.*,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY profit ASC) AS rn
    FROM profit p
) x
WHERE rn = 2
ORDER BY state;
