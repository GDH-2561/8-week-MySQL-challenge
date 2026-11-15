-- Case Study #1 - Danny's Diner
-- Solutions
-- 1.每位顾客在餐厅的总消费金额是多少？
select sales.customer_id,sum(menu.price) as xiaofei
from sales,menu
where sales.product_id = menu.product_id
group by sales.customer_id;
-- 2.每位顾客平均光顾过餐厅多少次？
select sales.customer_id,COUNT(DISTINCT order_date) as cishu 
FROM sales
GROUP BY customer_id;
-- 3.每位顾客从菜单上购买的第一道菜是什么？
SELECT sales.customer_id,order_date,menu.product_name  
AS FIRST_product_name
FROM sales,menu
WHERE sales.product_id = menu.product_id
AND (sales.customer_id,sales.order_date)IN
(SELECT customer_id,MIN(order_date)
FROM sales
GROUP BY customer_id);
-- 4.菜单上最畅销的菜品是什么？所有顾客一共购买了多少次？
SELECT menu.product_name,COUNT(sales.product_id) AS buy_times
FROM sales,menu
WHERE menu.product_id=sales.product_id
GROUP BY menu.product_name
ORDER BY buy_times DESC；
-- 5.每个顾客最喜欢哪件商品？
with CustomerProductCounts AS 
(select sales.customer_id,menu.product_name, COUNT(sales.product_id) AS buy_times,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) as rnk 
from sales
join menu on sales .product_id = menu.product_id
GROUP BY sales.customer_id,menu.product_name)
SELECT
customer_id,
product_name,
buy_times
FROM CustomerProductCounts
where rnk = 1;
-- 6.顾客成为会员后购买的第一件商品是什么？
with MemberFirstOrder as(
select members.customer_id,sales.order_date,product_name as firstProduct,
ROW_NUMBER() OVER(PARTITION BY members.customer_id ORDER BY sales.order_date ASC)as rn
from sales 
join members ON sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date>=members.join_date)
select 
customer_id,
order_date,
firstProduct
from MemberFirstOrder
WHERE rn = 1;
-- 7.顾客成为会员之前购买了哪件商品？
with LastOrderBeforMembers as(
select members.customer_id,sales.order_date,product_name as firstProduct,
ROW_NUMBER() OVER(PARTITION BY members.customer_id ORDER BY sales.order_date DESC)as rn
from sales 
join members ON sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date<members.join_date)
select 
customer_id,
order_date,
firstProduct
from LastOrderBeforMembers
where rn = 1;
-- 8.每位会员在成为会员之前，总共购买了多少件商品，花费了多少金额？
select members.customer_id,COUNT(sales.product_id) as spent_times,SUM(menu.price)as spent_price
FROM sales 
JOIN members ON members.customer_id = sales.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date<members.join_date
GROUP BY members.customer_id;
-- 9.如果每消费 1​​ 美元可获得 10 个积分，而寿司的积分倍率为 2 倍，那么每位顾客将获得多少积分？
SELECT sales.customer_id,
SUM(
CASE  
	WHEN menu.price = 'sushi' THEN menu.price*2
	ELSE menu.price*10
END
)as jifen
FROM sales 
join menu on sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 10.在顾客加入该计划后的第一周（包括加入日期），他们购买所有商品（不仅仅是寿司）可获得 2 倍积分 - 顾客 A 和 B 在 1 月底分别有多少积分？
select members.customer_id,
SUM(
CASE
	WHEN sales.order_date>=members.join_date 
  AND sales.order_date<=DATE_ADD(members.join_date, INTERVAL 6 DAY)
	THEN menu.price*20
	
  WHEN menu.product_name = 'sushi' THEN menu.price*20
  
  ELSE menu.price*10
END) AS jifen
FROM sales
JOIN menu ON sales.product_id = menu.product_id
JOIN members on sales .customer_id = members.customer_id
where members.customer_id IN ('A','B')
and sales.order_date<='2021-01-31'
GROUP BY members.customer_id;

