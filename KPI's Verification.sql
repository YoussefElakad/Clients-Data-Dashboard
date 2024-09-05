insert into CODES_PER_TEAM
(select * from CODES_PER_TEAM_C1 union select * from CODE_PER_TEAM_C2);
------------

--C1 validation
update validksa set country = 'KSA';
update validksa set Month = 'Feb';
update validksa set NO_OF_ORDERS = 0 where NO_OF_ORDERS is null;
update validksa set sales_value = 0 where sales_value is null;

update VALIDUAE set country = 'UAE';
update VALIDUAE set Month = 'Feb';
update VALIDUAE set NO_OF_ORDERS = 0 where NO_OF_ORDERS is null;
update VALIDUAE set sales_value = 0 where sales_value is null;

insert into validated_c1
(select* from validuae union select * from validksa);

--C2 Integration and validation
update VALIDATED_C2 set Month = 'mar';

insert into validated_c22
(select coupon,count(order_id),sum(sales_value),country,month from validated_c2
group by Coupon,country,month);

--Full Validation
insert into validated
(select * from validated_c1 union select*from validated_c2);

--Managing Currency and adding KPIs
update validated set sales_value = sales_value*0.27;

update validated set revenue = sales_value*0.1 where month='Feb';
update validated set payout = sales_value*0.06 where month ='Feb';
update validated set profit = revenue-payout where month='Feb';
update validated set profit_margin = ((revenue-payout)/revenue)*100 where month ='Feb' and revenue != 0;

update validated set revenue = sales_value*0.16 where month='mar';
update validated set payout = sales_value*0.08 where month ='mar';
update validated set profit = revenue-payout where month='mar';
update validated set profit_margin = ((revenue-payout)/revenue)*100 where month ='mar' and revenue != 0;

update validated set profit_margin = 40 where month='Feb' and profit_margin is not null;
update validated set profit_margin = 50 where month ='mar' and profit_margin is not null;
update validated set profit_margin = null;
----------------------------------------------------

--charts
select round(avg(profit_margin)) from validated;

select sum(revenue) from validated;

select sum(payout) from validated;

select BU_DISCREPTION,sum(sales_value) ss
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code)
group by BU_DISCREPTION
union
select '(Blank)',((select sum(sales_value) from validated)- (select sum(sales_value)
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code))) ss from dual 
order by ss desc;

select BU_DISCREPTION,sum(profit) pp
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code)
group by BU_DISCREPTION
union
select '(Blank)',((select sum(profit) from validated)- (select sum(profit)
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code))) pp from dual 
order by pp desc;

select BU_DISCREPTION,sum(NO_OF_ORDERS) orders
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code)
group by BU_DISCREPTION
union
select '(Blank)',((select sum(NO_OF_ORDERS) from validated)- (select sum(NO_OF_ORDERS)
from BU_lookup b join Codes_per_team c on(lower(b.BU) = lower(c.BU))
     join validated v on(v.coupon = c.code))) orders from dual 
order by orders desc;

select Team_leader,count(coupon) orders
from Codes_per_team c join validated v on(v.coupon = c.code)
group by Team_leader
union
select '(Blank)',((select count(coupon) from validated)- (select count(coupon)
from Codes_per_team c join validated v on(v.coupon = c.code))-2) orders from dual 
order by orders desc;

select coupon, sum(profit) from validated
group by coupon
order by sum(profit) desc
fetch first 5 rows only;

select month,sum(revenue),sum(profit) from validated
group by month;

select Team_member,count(coupon) orders
from Codes_per_team c join validated v on(v.coupon = c.code)
group by Team_member
union
select '(Blank)',((select count(coupon) from validated)- (select count(coupon)
from Codes_per_team c join validated v on(v.coupon = c.code))-2) orders from dual 
order by orders desc;