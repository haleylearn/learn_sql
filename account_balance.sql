use db_assignment;
/*
create table account_balance
(
    account_no          varchar(20),
    transaction_date    date,
    debit_credit        varchar(10),
    transaction_amount  decimal
);
insert into account_balance values ('acc_1', str_to_date('2022-01-20', '%Y-%m-%d'), 'credit', 100);
insert into account_balance values ('acc_1', str_to_date('2022-01-21', '%Y-%m-%d'), 'credit', 500);
insert into account_balance values ('acc_1', str_to_date('2022-01-22', '%Y-%m-%d'), 'credit', 300);
insert into account_balance values ('acc_1', str_to_date('2022-01-23', '%Y-%m-%d'), 'credit', 200);
insert into account_balance values ('acc_2', str_to_date('2022-01-20', '%Y-%m-%d'), 'credit', 500);
insert into account_balance values ('acc_2', str_to_date('2022-01-21', '%Y-%m-%d'), 'credit', 1100);
insert into account_balance values ('acc_2', str_to_date('2022-01-22', '%Y-%m-%d'), 'debit', 1000);
insert into account_balance values ('acc_3', str_to_date('2022-01-20', '%Y-%m-%d'), 'credit', 1000);
insert into account_balance values ('acc_4', str_to_date('2022-01-20', '%Y-%m-%d'), 'credit', 1500);
insert into account_balance values ('acc_4', str_to_date('2022-01-21', '%Y-%m-%d'), 'debit', 500);
insert into account_balance values ('acc_5', str_to_date('2022-01-20', '%Y-%m-%d'), 'credit', 900);

https://www.youtube.com/watch?v=6UAU79FNBjQ

Question: Return account_no and the transaction date when account balance reach 1000. 
Pls include only those account whose balance current is 1000
*/

select * from account_balance;

with cte_getBalanceByAccount as 
(
	select 
	account_no
    , transaction_date
    , transaction_amount
    , debit_credit
	, sum(case
				when debit_credit = 'credit' then transaction_amount
				else -transaction_amount
				end) over(partition by account_no rows between unbounded preceding and current row) as amount
	, sum(case
				when debit_credit = 'credit' then transaction_amount
				else -transaction_amount
				end) over(partition by account_no) as total
	from account_balance
)

select  account_no
	, min(transaction_date)
from cte_getBalanceByAccount
where amount >= 1000 and total >= 1000
group by account_no
 



















