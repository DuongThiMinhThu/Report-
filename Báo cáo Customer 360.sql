

With Customer_Growth as(
select count(distinct(ID)) as NewCustomer , cast(Created_date as date) as Date , LocationID , BranchCode 
from dbo.Customer_Registered cr 
group by cast(Created_date as date) , locationID , BranchCode ),
Customer_Loss as(
select count(distinct(ID)) as LostCustomer , cast(Stopdate as date) as Date, LocationID , BranchCode  
from dbo.Customer_Registered cr 
where stopdate is not null 
group by cast(stopdate as date) , LocationID,BranchCode),
Growth_Lose as (
select G.Date,NewCustomer,LostCustomer,G.LocationID,G.BranchCode from Customer_Growth G
left join Customer_Loss L on  G.Date = L.Date
union 
select L.Date,NewCustomer,LostCustomer,L.LocationID,L.BranchCode from Customer_Growth G
right join Customer_Loss L on  G.Date = L.Date)
select Date , isNull(NewCustomer,0) as TotalNewCustomers , isNull(LostCustomer,0) as TotalLostCustomer,BranchFullName,LocationName 
from Growth_Lose G
left join location L on L.LocationID  = G.LocationID and L.BranchCode  = G.BranchCode 
order by Date desc 


select CustomerID, count (ID)as frequency,datediff(day,max(cast(Purchase_Date as Date)),GETDATE()) as recency, sum(GMV) as nonetary 
from Customer_Transaction ct 
WHERE CustomerID !=0
GROUP by CustomerID 

select CustomerID,recency,frequency,monetary,
NTILE(4) over (order by recency desc) as R,
NTILE(4) over (order by frequency desc) as F,
NTILE(4) over (order by monetary desc) as M from dbo.CRM_RFM_SUMMARY
order by R desc 

select concat(R,F,M) as RFM , count(*) as total_customers from (				
select CustomerID, recency ,frequency , monetary , case when recency >= 9 and recency < 40 then '4'				
				     when recency >= 40 and recency < 68 then '3'
				     when recency >= 68 and recency < 80 then '2'
				     else '1' end as R , 
				     case when frequency >= 1 and frequency < 2 then '1'
				     when frequency >= 2 and frequency < 3 then '2'
				     when frequency >= 3 and frequency < 4 then '3'
				     else '4' end as F,
				     case when monetary >= 0 and monetary < 50000 then '1'
				     when monetary >= 50000 and monetary < 100000 then '2'
				     when monetary >= 100000 and monetary < 1000000 then '3'
				     else '4' end as M
				     from dbo.CRM_RFM_SUMMARY crs  ) A 
group by concat(R,F,M)
ORDER by total_customers desc

select min(frequency),max(frequency),avg(frequency) from dbo.CRM_RFM_SUMMARY crs 
