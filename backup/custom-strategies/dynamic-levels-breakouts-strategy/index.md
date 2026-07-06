# Dynamic Levels Breakouts Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74261  
> Forum: 31 · Topic 74261 · 3 post(s)


---

## Dynamic Levels Breakouts Strategy

**Apprentice** · Wed Oct 18, 2023 5:07 am

![EURUSD H4 (10-18-2023 1205).png](images/152972/EURUSD%20H4%20%2810-18-2023%201205%29.png)



Dynamic Levels Breakouts.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=74251](https://fxcodebase.com/code/viewtopic.php?f=17&t=74251)
buy: price > upper line
sell : price < lower line

 [Dynamic Levels Breakouts Strategy.lua](files/152972/Dynamic%20Levels%20Breakouts%20Strategy.lua)

Please make sure to download the indicator again.


---

## Re: Dynamic Levels Breakouts Strategy

**ahmedalhosenyy** · Wed Oct 18, 2023 8:03 am

Hello ,
could you make it price break above = buy , exit = close below 100% in the market !

thanks


---

## Re: Dynamic Levels Breakouts Strategy

**forexbutton** · Wed Oct 18, 2023 2:46 pm

> if Indicator.DATA[period]>Indicator.DATA[period-1]
> then
> if Direction then
> BUY();
> else
> SELL();
> end
> LastEntry= Source:serial(period);
> Return=true;
> elseif Indicator.DATA[period]<Indicator.DATA[period-1]
> then
> if Direction then
> SELL();
> else
> BUY();
> end
> LastEntry= Source:serial(period);
> Return=true;
> end
>

i think code has error.

my request is

price > upper line then buy
price < lowe line then sell
