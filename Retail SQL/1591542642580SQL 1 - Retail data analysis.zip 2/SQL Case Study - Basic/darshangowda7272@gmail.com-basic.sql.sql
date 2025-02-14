--DATA PREPARATION AND UNDERSTANDING
--1)
	(select COUNT(*) from Customer 
	union
	select COUNT(*) from Transactions
	union
	select count(*) from prod_cat_info

	--2)
	select distinct(COUNT(*)) as [Returned items' Transactions] from Transactions t1
	where t1.Qty<0
	
	--3)
	 select CONVERT(date,tran_date,105) as [transaction date]
	 from Transactions
	
	--4)
	select DATEDIFF(year,min(tran_date),max(tran_date)) as [by year] ,
	DATEDIFF(month,min(tran_date),max(tran_date)) as [by month],
	DATEDIFF(day,min(tran_date),max(tran_date)) as [by year] from Transactions

	--5)
	select prod_cat from prod_cat_info
	where prod_subcat='diy'


--DATA ANALYSIS

--1)
select top 1 t1.Store_type,COUNT(*) as cnt from Transactions t1
group by t1.Store_type
order by cnt desc

--2)
select  gender,COUNT(*) as [of genders] from customer
group by gender

--3)
select top 1 city_code,COUNT(*) as tc from customer
group by city_code 
order by tc desc

--4)
select t1.prod_cat,count(t1.prod_sub_cat_code) as [total sub category] from prod_cat_info as t1
where t1.prod_cat='books'
group by t1.prod_cat


--5)
select top 1 Transaction_id,qty from Transactions
order by Qty desc

--6)
select SUM(total_amt) as total_sales from Transactions as t1
left join prod_cat_info as t2 on t2.prod_cat_code=t1.prod_cat_code
where t2.prod_cat in ('books','electronics')

--7)
select COUNT(*) as totalcustomer from (
select t1.cust_id as customerID,APPROX_COUNT_DISTINCT(t1.transaction_id) as c1 from Transactions t1
where Qty<0
group by t1.cust_id
having APPROX_COUNT_DISTINCT(t1.transaction_id)>10) as b

--8)
select sum(total_amt) as [total Revenue] from prod_cat_info as t1
join Transactions as t2
on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
where prod_cat in ('Electronics','Clothing') and Store_type='Flagship store'

--9)
select t3.prod_subcat, sum(total_amt) as [total revenue] from Customer t1
join Transactions t2
on t1.customer_Id=t2.cust_id
join prod_cat_info t3 
on t2.prod_cat_code=t3.prod_cat_code and t2.prod_subcat_code=t3.prod_sub_cat_code
where Gender='M' and t3.prod_cat='Electronics'
group by t3.prod_subcat


--10)percentage of sales
select t6.prod_subcat,perc_sales,perc_returns from 
(select top 5 prod_subcat,(sum(t1.total_amt)/(select sum(total_amt) from Transactions where Qty>0)) as perc_sales from Transactions as t1
join prod_cat_info t2
on t2.prod_cat_code=t1.prod_cat_code and t1.prod_subcat_code=t2.prod_sub_cat_code
group by prod_subcat
order by perc_sales desc) as t7
join
--percentage of returns
(select  prod_subcat,(sum(t1.total_amt)/(select sum(total_amt) from Transactions where Qty<0)) as perc_returns from Transactions as t1
join prod_cat_info t2
on t2.prod_cat_code=t1.prod_cat_code and t1.prod_subcat_code=t2.prod_sub_cat_code
where Qty<0
group by prod_subcat)as t6
on t6.prod_subcat=t7.prod_subcat


--11)
select cid,totrev,age,td from (
select * from (
select cid,totrev,DATEDIFF(year,dob,max_Date) as age from (
select t1.customer_Id as cid,t1.DOB,MAX(convert(date,tran_date,105)) as max_date,sum(t2.total_amt)as totrev from Customer t1
join Transactions t2 
on t1.customer_Id=t2.cust_id
group by t1.customer_Id,t1.DOB) as a
) as b
where age between 25 and 35) as c  
join
(select cust_id,tran_date as td from Transactions
group by cust_id,tran_date
having tran_date>=(select DATEADD(day,-30,max(convert(date,tran_date,105))) as cutdate from Transactions)) as d
on c.cid=d.cust_id


--12)
select top 1 prod_cat,SUM(retqty) as retpd from (
select prod_cat ,qty as retqty from Transactions t1
join prod_cat_info t2
on t1.prod_cat_code=t2.prod_cat_code
where Qty<0
group by prod_cat,tran_date,qty
having tran_date>=(select DATEADD(day,-90,max(convert(date,tran_date,105))) from Transactions) 
)as a
group by prod_cat
order by SUM(retqty)


--13)
--by value of sales
select top 1 Store_type,sum(total_amt) as revenue from Transactions
where total_amt>0
group by Store_type
order by revenue desc

--by volume
select top 1 Store_type,sum(Qty) as volume from Transactions
where Qty >0
group by Store_type
order by volume desc

--14)

select prod_cat,avg(total_amt) as averagesale from Transactions t1
join prod_cat_info t2 
on t1.prod_cat_code=t2.prod_cat_code
where total_amt>0
group by prod_cat
having AVG(total_amt)>=(select AVG(total_amt) from Transactions where total_amt>0)

--15)
select t2.prod_subcat ,AVG(T1.total_amt)subavg,sum(T1.total_amt) as subsum from Transactions T1
join prod_cat_info t2
on T1.prod_cat_code=t2.prod_cat_code
where Qty>0 and t1.prod_cat_code in (select top 5 prod_cat_code from Transactions
group by prod_cat_code
order by SUM(qty) desc)
group by t2.prod_subcat


