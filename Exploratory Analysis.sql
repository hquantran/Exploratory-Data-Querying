

-- Get a list of cities and provinces in the Northern region of Vietnam. There is information about domain name, domain code, area name, area code, after id, name, code of province/city.
select 
r.code as region_code,
r.name as region_name,
s.code as sub_region_code,
s.name as sub_region_name,
c.id as city_id,
c.code as city_code,
c.name as city_name
from [dbo].[sub_region] s
join [dbo].[region] r on s.region_id = r.id 
join [dbo].[city] c on s.id = c.sub_region_id
where r.code = 'MB'
order by r.name, s.name, c.name

-- Get a list of customers who are eligible to participate in the promotion following the opening of a new store in the North.
select top(100) * from [dbo].[customer]
select * from [dbo].[purchase_header]
select top(1000) * from [dbo].[pos_sales_header]

select c.id,
c.code,
c.full_name,
c.first_name,
sum(s.total_amount)
from [dbo].[customer] c
join [dbo].[pos_sales_header] s on c.id = s.customer_id
join [dbo].[district] d on c.district_id = d.id
where (s.transaction_date between '2020-10-01 00:00:00.000' and '2020-10-20 00:00:00.000') and d.id = 1
group by c.id, c.code, c.full_name, c.first_name
having sum(s.total_amount) > 10000000
order by sum(s.total_amount) desc, c.first_name asc

-- Every week, the lucky spin program will find 5 lucky orders and refund 50% for order not more than 1 million VND. The list of winning orders for the week from August 31, 2020 to September 6, 2020 are orders with the following document_code: SO-VMHNI4-202009034389708, SO-VMHNI109-202008316193214, SO-VMHNI51-202008316193066, SO-VMHNI64 -202008316193112, SO-VMHNI48-202009016193491. Retrieve order information, information of lucky customers and the amount of money the customer is refunded. The required information includes: order code, store code, store name, time of purchase, customer code, full name, customer name, order value, customer refund amount again.
select * from [dbo].[store]
select * from [dbo].[customer]
select top 100 * from [dbo].[pos_sales_header]

select p.document_code, s.id, s.code, s.name, p.transaction_date, c.id, c.full_name, c.first_name, p.total_amount,
(case when p.total_amount/2 > 1000000 then 1000000 else p.total_amount/2 end ) as promotion_amount
from [dbo].[pos_sales_header] p
join [dbo].[store] s on p.store_id = s.id
join [dbo].[customer] c on p.customer_id = c.id
where p.document_code in ('SO-VMHNI4-202009034389708', 'SO-VMHNI109-202008316193214', 'SO-VMHNI51-202008316193066', 'SO-VMHNI64-202008316193112', 'SO-VMHNI48-202009016193491')
order by promotion_amount desc

-- Summarize sales and average number of products purchased each time a customer buys the product “Cháo Yến Mạch, Chà Là Và Hồ Đào | Herritage Mill, Úc (320 G)” in 2020.
select * from [dbo].[product_sku]
select * from [dbo].[customer]
select top 100 * from [dbo].[pos_sales_line]

select s.product_sku_id, s.customer_id, sum(s.line_amount) as purchase_amount, sum(s.quantity), count(*) as nb_purchases, 
cast(sum(s.quantity)/cast(count(*) as decimal (18,2)) as decimal (18,2)) as avg from [dbo].[pos_sales_line] s
join [dbo].[product_sku] p on s.product_sku_id = p.id
join [dbo].[customer] c on s.customer_id = c.id
where s.product_sku_id = 91 and YEAR(s.transaction_date) = 2020
group by s.product_sku_id, s.customer_id
order by s.customer_id asc


-- Get a list of the top 20 best-selling instant noodles products in 2019 and 2020. Consider products in the instant food group (sub_category_id=19) and the product name has the word "Mì" or the word "Mỳ" (spelling variation for 'noodle' in Vietnamese). Information returned includes year, product code, product name, country of origin, brand, selling price, quantity sold, sales rating by year. The returned list is sorted by year and by product rating.
select top 100 * from [dbo].[pos_sales_line]

select top 20 YEAR(s.transaction_date) as year, s.product_sku_id, p.code, p.name, p.country, p.brand, p.price, sum(s.quantity) as quantity,
dense_rank() over (order by sum(s.quantity) desc) as rk from [dbo].[pos_sales_line] s
join [dbo].[product_sku] p on s.product_sku_id = p.id
where p.product_category_id = 4 and p.product like '%Mì%'
group by s.product_sku_id, YEAR(s.transaction_date), s.product_sku_id, p.code, p.name, p.country, p.brand, p.price

-- Query information about employees working the afternoon shift on June 13, 2020 at the store.
select top 100 * from [dbo].[emp_shift_schedule]
select top 100 * from [dbo].[sales_person]
select top 100 * from [dbo].[store]

select e.day_work, e.store_id, st.name, e.shift_name, s.code, s.full_name, s.first_name, s.gender from [dbo].[emp_shift_schedule] e
join [dbo].[sales_person] s on e.sales_person_id = s.id
join [dbo].[store] st on e.store_id = st.id
where e.day_work = '2021-06-13' and e.shift_name = N'Chiều' and st.address = N'Cụm 6, Xã Sen Chiểu, Huyện Phúc Thọ, Hà Nội'

-- Query the average number of customers who come to buy at each store per day according to each time frame of the day. Sales data is limited to the last 6 months of 2020. Let's assume a staff to serve 8 customers/1 hour, and calculate how many employees each store needs at the peak time.
select top 100 * from [dbo].[pos_sales_header];

with store_hour as (
  select s.id, s.code, s.name, DATEPART(HOUR, p.transaction_date) as hour, CAST(p.transaction_date  as date) as date, count(p.customer_id)*1.00 as count  
  from [dbo].[store] s
  join [dbo].[pos_sales_header] p on s.id = p.store_id
  where s.id = 1 and p.transaction_date between '2020-06-01' and '2020-12-31'
  group by s.id, s.code, s.name, DATEPART(HOUR, p.transaction_date), CAST(p.transaction_date  as date)
)
select id, code, name, hour, cast(AVG(count) as decimal(18,2)) as average
from store_hour
group by id, code, name, hour
order by id, code, name, hour asc;

-- Currently, the chain is trading in 4 types of tea products: trà khô, trà túi lọc, trà hòa tan, trà chai (dried tea, filtered tea, instant tea, and bottled tea). Tea products have sub_category_id=27. Based on the product field can be classified into 4 product types 1, 2, 3, and 4. Calculate the ratio of sales of trà hòa tan to total sales of tea products in 2018, 2019, 2020
select top 100 * from [dbo].[pos_sales_line]
select * from [dbo].[product_sku]
where product like N'%trà%'

with tea_category as (
  select YEAR(s.transaction_date) as year, p.id as id, SUM(s.line_amount) as sales_amount_tea,
  case 
    when product like N'Trà khô%' then 1
    when product like N'Trà túi lọc%' then 2
    when product like N'Trà hòa tan%' then 3
    when product like N'Trà chai%' then 4
  end as product_type,
    case 
    when product like N'Trà khô%' then N'Trà khô'
    when product like N'Trà túi lọc%' then N'Trà túi lọc'
    when product like N'Trà hòa tan%' then N'Trà hòa tan'
    when product like N'Trà chai%' then N'Trà chai'
  end as product_type_name
  from [dbo].[product_sku] p
  join [dbo].[pos_sales_line] s on p.id = s.product_sku_id
  where product like N'%Trà%' and YEAR(s.transaction_date) in (2018, 2019, 2020)
  group by YEAR(s.transaction_date),p.id, p.product
), sum_by_p as(
  select year, product_type, product_type_name, SUM(sales_amount_tea) as sum
  from tea_category
  group by year, product_type, product_type_name
  --order by year, product_type, product_type_name 
), sum_by_y as (
  select year, SUM(sum) as sum_year
  from sum_by_p
  group by year
)
select p.year, p.sum/y.sum_year as ratio
from sum_by_p p
join sum_by_y y on p.year = y.year
where p.product_type_name = N'Trà hòa tan'

-- Based on sales in 2020, classify products into 3 groups A, B, C (ABC Analysis). Sort products by sales descending. Product group A is the products that account for 70% of total revenue, product group B is the products that account for 20% of total revenue, and product group C is the products that account for the remaining 10% of revenue. Query a list of products categorized by ABC group. Sort by line code and product group code, sales descending.
select top 100 * from [dbo].[pos_sales_line]
order by unit_price desc -- p.transaction_date, p.line_amount 
select * from [dbo].[product_category] -- c.id, c.name
select * from [dbo].[product_subcategory] -- s.id, s.name
select top 100 * from [dbo].[product_sku]; -- sku.id, sku.name

with rev_by_p as (
  select YEAR(p.transaction_date) as year, c.id as product_category_id, 
  c.name as product_category_name, s.id as product_subcat_id, s.name as product_subcat_name, 
  sku.id as product_sku_id, sku.name as product_sku_name, sum(p.line_amount) as revenue
  from [dbo].[product_sku] sku
  join [dbo].[pos_sales_line] p on sku.id = p.product_sku_id
  join [dbo].[product_subcategory] s on sku.product_subcategory_id = s.id
  join [dbo].[product_category] c on sku.product_category_id = c.id
  where YEAR(p.transaction_date) = 2020
  group by YEAR(p.transaction_date), c.id, c.name, s.id, s.name, sku.id, sku.name
), total_rev as (
  select SUM(revenue) as tot_revenue from rev_by_p
), cummulative_ratio as (
  select *, revenue/tot_revenue*100 as ratio, SUM(revenue/tot_revenue*100) OVER (ORDER BY revenue/tot_revenue*100 DESC) as cummulative_ratio
  from rev_by_p, total_rev
)
select *,
CASE 
  WHEN cummulative_ratio < 70 THEN 'A'
  WHEN cummulative_ratio between 70 and 90 THEN 'B'
  WHEN cummulative_ratio > 90 THEN 'C'
END as type
from cummulative_ratio
order by cummulative_ratio asc 



-- Get the TOP 3 stores by sales in Hanoi to award the store of the month of October 2020. Know that stores in Hanoi have city_id=24.
select top (3) s.id as store_id, s.code as store_code, s.name as store_name, sum(p.line_amount) as sales_amount_10_2022 from [dbo].[store] s
join [dbo].[pos_sales_line] p on s.id = p.store_id
join [dbo].[city] c on s.city_id = c.id 
where s.city_id = 24 and YEAR(p.transaction_date) = 2020 and MONTH(p.transaction_date) = 10
group by s.id, s.code, s.name;




