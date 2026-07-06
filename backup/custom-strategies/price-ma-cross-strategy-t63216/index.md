# Price MA Cross Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63216  
> Forum: 31 · Topic 63216 · 7 post(s)


---

## Price MA Cross Strategy

**Apprentice** · Fri Mar 04, 2016 7:26 am

![EURUSD H1 (03-04-2016 1247).png](images/105117/EURUSD%20H1%20%2803-04-2016%201247%29.png)



Based on request.
[viewtopic.php?f=27&t=62962](https://fxcodebase.com/code/viewtopic.php?f=27&t=62962)

"Close Strategy after first Trade Executions" -Yes
Strategy will terminate itself after the first trade.
"Close Strategy after first Trade Executions" - No
Strategy will remain active after the first trade.

1. Algorithm
Open Long
Close + Delta> MA + Delta
Close[-1] + Delta <= MA[-1] + Delta

Open Short
Close - Delta< MA - Delta
Close[-1] - Delta >= MA[-1] - Delta

SignalMode== 2)
2. Algorithm

Open Long
Close > MA + Delta
Close[-1] <= MA[-1] + Delta

Open Short
Close< MA - Delta
Close[-1] >= MA[-1] - Delta

 [Price MA Cross Strategy .lua](files/105117/Price%20MA%20Cross%20Strategy%20.lua)


---

## Re: Price MA Cross Strategy

**sk8ordie** · Fri Apr 22, 2016 3:27 pm

how can i use tick ? (t1)

now i use m1 but i dont want to wait 1 min

error :155: The time frame must not be tick

thx!


---

## Re: Price MA Cross Strategy

**baleze** · Mon May 23, 2016 1:08 am

Hi

I tried to backtest this strategy but it not takes any trade.

Thnx


---

## Re: Price MA Cross Strategy

**Apprentice** · Thu Jun 02, 2016 2:55 am

![EURUSD H1 (06-02-2016 0923).png](images/106574/EURUSD%20H1%20%2806-02-2016%200923%29.png)



Strategy is designed to open a trade.
Strategy will terminate itself after the first trade.


---

## Re: Price MA Cross Strategy

**Apprentice** · Mon Jan 22, 2018 8:54 am

The strategy was revised and updated.


---

## Re: Price MA Cross Strategy

**enotikos** · Sat Jul 10, 2021 12:41 am

Hi apprentice,
Can you add a parameter in this strategy?

Open trade :  (end of turn / live)

Thank you


---

## Re: Price MA Cross Strategy

**Apprentice** · Mon Jul 12, 2021 12:58 pm

"End of Turn / Live" It is already available.
