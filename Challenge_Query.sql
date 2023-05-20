--1. What is the total amount each customer spent at the restaurant?

Select sales.customer_id, Sum(menu.price) As T0talAmount 
From sales
Inner Join menu
On sales.product_id = menu.product_id
Group By sales.customer_id;

--2. How many days has each customer visited the restaurant?

Select customer_id, Count(Distinct order_date) As Days
From sales
Group By customer_id;

--3. What was the first item from the menu purchased by each customer?

Select Distinct sales.customer_id,  menu.product_name, sales.order_date,
Rank() Over(Partition By sales.customer_id Order By sales.order_date Asc) As item_order
From sales
Inner Join menu
On sales.product_id = menu.product_id;
--  The first item purchased was sushi
--4. What is the most purchased item on the menu and 
-- how many times was it purchased by all customers?

Select Distinct product_name, Count(order_date) As orders
From sales
Inner Join menu
On sales.product_id = menu.product_id
Group By product_name
Order By orders Desc
Limit 1;
-- ramen is the most purchased item on the menu

--5. Which item was the most popular for each customer?
Select  Distinct product_name, customer_id, Count(order_date) As orders
From sales
Inner Join menu
On sales.product_id = menu.product_id
Group By product_name, 
customer_id
Limit 1;
-- ramen is the most popular item on the menu

--6. Which item was purchased first by the customer after they became a member?
Select Distinct order_date,  join_date, product_name
From sales
Inner Join members
On sales.customer_id = members.customer_id
Inner Join menu
On sales.product_id = menu.product_id
Where order_date >= join_date
Order By order_date;
-- The item purchased on the day the first day customer became members is curry

--7. Which item was purchased just before the customer became a member?
Select Distinct order_date,  join_date, product_name
From sales
Inner Join members
On sales.customer_id = members.customer_id
Inner Join menu
On sales.product_id = menu.product_id
Where order_date <= join_date
Order By order_date Desc;
-- The item purchased just before the customer became members is sushi

--8. What is the total items and amount spent for each member before they became a member?
Select Distinct product_name, sales.customer_id,
Count(product_name) As P_list, Sum(price) As t_amount
From sales
Inner Join members
On sales.customer_id = members.customer_id
Inner Join menu
On sales.product_id = menu.product_id
Where order_date < join_date
Group By  product_name, sales.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?

Select Distinct product_name, price,
Case
	When product_name = 'sushi' Then (price * 2 * 10)
	Else (price * 10)
End As d_point,
Sum (Case
	When product_name = 'sushi' Then (price * 2 * 10)
	Else (price * 10)
End) As sd_point
From menu
Group By product_name, price
Order By price Desc;

--10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?
Select Distinct sales.customer_id,
Sum(Case
	When sales.order_date >= members.join_date Then price * 2 *10
	Else price * 10
End )As T_earn_point
From sales
Inner Join menu
On sales.product_id = menu.product_id
Inner Join members
On sales.customer_id = members.customer_id
Where order_date Between join_date And join_date + Interval '1 week' And Order_date <= '2021-01-31'
-- This shows the 1st week after join
Group By sales.customer_id;

--Bonus Questions
--	Join All The Things
Select Distinct sales.customer_id, sales.order_date, menu.product_name, menu.price,
Case
	When order_date < join_date Then 'N'
	Else 'Y'
End As member_s
From sales
Inner Join menu
On sales.product_id = menu.product_id
Inner Join members
On members.customer_id = sales.customer_id;

-- Rank All The Things
Select Distinct sales.customer_id, order_date, product_name, price,
Case
	When order_date >= join_date Then 'Y'
	Else 'N'
End As member_s,
Case
	When order_date >= join_date  Then Rank () Over(Partition By sales.customer_id, ) 
	Else Null
End As ranks
From sales
Left Join menu
On sales.product_id = menu.product_id
Inner Join members
On sales.customer_id = members.customer_id;



