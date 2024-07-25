use pizzahut;
-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) total_orders
FROM
    orders;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizzas.price, pizza_types.name
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- Identify the most common pizza size ordered.
SELECT 
    PIZZAS.SIZE,
    COUNT(order_details.order_details_id) AS COMMON_SIZE_ORDERED
FROM
    order_details
        JOIN
    pizzas ON PIZZAS.pizza_id = order_details.pizza_id
GROUP BY PIZZAS.SIZE
ORDER BY SIZE
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.NAME, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = PIZZAS.PIZZA_TYPE_ID
        JOIN
    order_details ON order_details.PIZZA_ID = pizzas.pizza_id
GROUP BY pizza_types.NAME
ORDER BY quantity DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = PIZZAS.PIZZA_TYPE_ID
        JOIN
    order_details ON order_details.PIZZA_ID = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) as hour, COUNT(order_id) count
FROM
    orders
GROUP BY HOUR(order_time);
-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT round(AVG(quantity)) as avg_pizzas_ord_per_day FROM 
    ( SELECT ORDER_DATE, SUM(order_details.quantity) quantity
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY order_date) AS ORDERED_QUANTITY;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT * FROM pizza_types;
SELECT * FROM pizzas; -- PRICE, PIZZA TYPE
SELECT * FROM orders; 
SELECT * FROM order_details; -- QUANTITY
SELECT 
    PIZZAS.pizza_type_ID,
    SUM(PRICE * QUANTITY) AS REVENUE
FROM 
    PIZZAS 
JOIN 
    order_details 
ON 
    PIZZAS.pizza_id = order_details.pizza_id
GROUP BY  
    PIZZAS.pizza_type_ID
ORDER BY REVENUE DESC LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(order_details.quantity*pizzas.price)/(select round(sum(order_details.quantity*pizzas.price),2)as total_sales
from order_details
join pizzas on pizzas.pizza_id=order_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;
-- Analyze the cumulative revenue generated over time.
WITH RankedPizzas AS (
  SELECT 
    pt.CATEGORY, 
    pt.NAME, 
    SUM(od.QUANTITY * p.PRICE) AS REVENUE,
    RANK() OVER (PARTITION BY pt.CATEGORY ORDER BY SUM(od.QUANTITY * p.PRICE) DESC) AS RN
  FROM 
    PIZZA_TYPES pt
  JOIN 
    PIZZAS p ON pt.PIZZA_TYPE_ID = p.PIZZA_TYPE_ID
  JOIN 
    ORDER_DETAILS od ON od.PIZZA_ID = p.PIZZA_ID
  GROUP BY 
    pt.CATEGORY, 
    pt.NAME
)
SELECT 
  CATEGORY,
  NAME,
  REVENUE,
  RN
FROM 
  RankedPizzas
WHERE 
  RN <= 3;

