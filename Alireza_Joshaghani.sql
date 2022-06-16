With Members as(
Select Distinct block_user.user_id, first_name, last_name, hashed_email, create_date 
From block_user 
Inner Join contact on block_user.user_id=contact.user_id
Inner Join email on block_user.user_id=email.user_id),

Invalid_members as(
Select * from Members
Where hashed_email ilike '%blockrenovation%' OR user_id IS NULL OR first_name ilike '%test%' OR last_name ilike '%test%'
),

Valid_members as(
Select members.user_id, members.first_name, members.last_name, members.hashed_email, members.create_date, to_char(members.create_date, 'Month') as month from members
Left Join invalid_members on members.user_id=invalid_members.user_id
where invalid_members.user_id is null),

valid_deal as(
Select *,to_char(closed_won_date, 'Month') as month from deal
where closed_won_date is not null
),

City as (
Select upper(property_city) as property_city, closed_won_date
From valid_deal
Join deal_contact on valid_deal.deal_id=deal_contact.deal_id
Join contact on deal_contact.contact_id=contact.contact_id
Join valid_members on contact.user_id=valid_members.user_id
Where property_city IS NOT Null
),

Recog_Rev as(
SELECT generate_series(closed_won_date, closed_won_date+interval '6 MONTH',interval '3 MONTH') as months, generate_series (1,3) as d, deal_value_usd
From valid_deal)

/* Question (1)
Select month, Count(*) From valid_members
Group By month
Order by count(*) desc
Limit 1
*/

/* Question (2)
Select month, sum(deal_value_usd) From Gross_deal
Group By month
Order by count(*) desc
Limit 1
*/

/* Question (3)
Select Distinct property_city, count(property_city) over (partition by property_city)/(Select count(*) From City)::float*100 as percentage
From City
Order By property_city
*/

/* Recognized Revenue
Select date_trunc('Month',months) as month, sum(deal_value_usd* Case when d=1 then 0.2 when d=2 then 0.4 when d=3 then 0.4 end) as Monthly_Revenue
from Recog_Rev
group by month
order by month
*/
 
