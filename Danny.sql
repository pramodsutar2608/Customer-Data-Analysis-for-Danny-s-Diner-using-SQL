
CREATE TABLE sales (
customer_id VARCHAR2(5),
order_date DATE,
product_id number
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '01-JAN-21', 1);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '01-JAN-21', 2);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '07-JAN-21', 2);
  
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '10-JAN-21', 3);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '11-JAN-21', 3);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '07-JAN-21', 3);
  
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('B', '01-JAN-21', 2);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('B', '02-JAN-21', 2);
 
 INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES 
  ('B', '04-JAN-21', 1);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('B', '11-JAN-21', 1);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('B', '16-JAN-21', 3);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('B', '01-FEB-21', 3);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('C', '01-JAN-21', 3);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES 
  ('C', '01-JAN-21', 3);
  
  INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('C', '07-JAN-21', 3);
  
  select * from sales;

--------------------------------------------------------------------------- 

CREATE TABLE menu (
  product_id int,
  product_name VARCHAR(5),
  price int
);

 
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10');
  
  INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('2', 'curry', '15');
  
  INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('3', 'ramen', '12');
  
select * from menu;


--------------------------------------------------------------------------------

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '07-JAN-21');
  
 INSERT INTO members
  (customer_id, join_date)
VALUES 
  ('B', '09-JAN-21');
  
select * from members;

-------------------------------------------------------------------------------

1. What is the total amount each customer spent at the restaurant?

select * from sales;
select * from menu;
select * from members;


select a.customer_id,sum(b.price) as spent
from sales a,menu b
where a.product_id=b.product_id
group by a.customer_id; 
  
  
--------------------------------------------------------------------------------

2. How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) as visits
from sales
group by customer_id;

-------------------------------------------------------------------------------

3. What was the first item from the menu purchased by each customer?

SELECT 
  customer_id, 
  MIN(product_name) AS first_product
FROM sales s
JOIN menu m ON s.product_id = m.product_id
WHERE (customer_id, order_date) IN (
  SELECT customer_id, MIN(order_date)
  FROM sales
  GROUP BY customer_id
)
GROUP BY customer_id;

--------------------------------------------------------------------------------

4. What is the most purchased item on the menu and how many times was it 
purchased by all customers?

select * from sales;
select * from menu;
select * from members;
  
select a.product_id,b.product_name,count(a.product_id) as No_of_Times
from sales a,menu b
where a.product_id=b.product_id
group by a.product_id,b.product_name
order by No_of_Times desc;

--------------------------------------------------------------------------------

5. Which item was the most popular for each customer?

WITH most_popular AS (
    SELECT
        s.customer_id,
        s.product_id,
        COUNT(s.product_id) AS no_of_times
    FROM sales s
    GROUP BY s.customer_id, s.product_id
)

SELECT
    mp.customer_id,
    mp.product_id,
    mp.no_of_times,
    m.product_name
FROM most_popular mp
JOIN menu m ON mp.product_id = m.product_id
WHERE (mp.customer_id, mp.no_of_times) IN (
    SELECT customer_id, MAX(no_of_times)
    FROM most_popular
    GROUP BY customer_id
);

-------------------------------------------------------------------------------

6. Which item was purchased first by the customer after they became a member?

select * from sales;
select * from menu;
select * from members;

select c.customer_id,c.join_date,b.product_name
       from members c,menu b,sales a
       where c.customer_id=a.customer_id
       and b.product_id=a.product_id
       and c.join_date<a.order_date
       group by c.customer_id,c.join_date,b.product_name;

-------------------------------------------------------------------------------
 
 7. Which item was purchased just before the customer became a member?

select c.customer_id,b.product_name
from members c,menu b, sales a
where  c.customer_id=a.customer_id
and a.product_id=b.product_id
and c.join_date>a.order_date
group by c.customer_id,b.product_name;
 
------------------------------------------------------------------------------- 

8. What is the total items and amount spent for each member before they became a 
member?

select c.customer_id,count(a.product_id) as total_items,
       sum(b.price) as total_amount,
from members c,sales a,menu b
where  c.customer_id=a.customer_id
and a.product_id=b.product_id
and c.join_date>a.order_date
group by c.customer_id;


--------------------------------------------------------------------------------

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
- how many points would each customer have?

select * from sales;
select * from menu;
select * from members;

SELECT c.customer_id, 
       COUNT(a.product_id) AS total_items, 
       SUM(b.price) AS total_amount,
       SUM(CASE 
             WHEN b.product_name = 'sushi' THEN 20 * b.price
             ELSE 10 * b.price
           END) AS total_points
FROM members c
JOIN sales a ON c.customer_id = a.customer_id
JOIN menu b ON a.product_id = b.product_id
GROUP BY c.customer_id;

--------------------------------------------------------------------------------

10. In the first week after a customer joins the program (including their join date) they 
earn 2x points on all items, not just sushi - how many points do customer A and B 
have at the end of January?

--Corrections
SELECT c.customer_id, 
       COUNT(a.product_id) AS total_items, 
       SUM(b.price) AS total_amount,
       SUM(CASE
           WHEN (b.product_name = 'sushi' AND a.order_date <= c.join_date + INTERVAL '7' DAY) THEN 20 * b.price
           WHEN a.order_date <= c.join_date + INTERVAL '7' DAY THEN 10 * b.price
           ELSE 10 * b.price
         END
) AS total_points
FROM members c
JOIN sales a ON c.customer_id = a.customer_id
JOIN menu b ON a.product_id = b.product_id
GROUP BY c.customer_id;


================================================================================


  
  
  
  