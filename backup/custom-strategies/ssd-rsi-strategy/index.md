# SSD RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70549  
> Forum: 31 · Topic 70549 · 12 post(s)


---

## SSD RSI Strategy

**Apprentice** · Tue Oct 20, 2020 7:17 am

![EURUSD m1 (10-20-2020 1416).png](images/138355/EURUSD%20m1%20%2810-20-2020%201416%29.png)



Based on request.
[viewtopic.php?f=27&t=70537](https://fxcodebase.com/code/viewtopic.php?f=27&t=70537)

 [SSD RSI Strategy.lua](files/138355/SSD%20RSI%20Strategy.lua)

Please download X-RSIOMA.lua
[viewtopic.php?f=17&t=69965](https://fxcodebase.com/code/viewtopic.php?f=17&t=69965)


---

## Re: SSD RSI Strategy

**Brightspark** · Tue Nov 03, 2020 2:11 am

Hey Apprentice,
Works well can you add a filter on the SSD timeframe
For sells to be out of the set 0B area but must be above a set limit 50% of the SSD to trigger a sell signal
For buys to be out of the set 0S area but must be below a set limit 50% of the SSD to trigger a buy
signal
thanks in advance
Brightspark


---

## Re: SSD RSI Strategy

**Apprentice** · Tue Nov 03, 2020 5:49 am

[SSD RSI Strategy.lua](files/138635/SSD%20RSI%20Strategy.lua)

Try this version.


---

## Re: SSD RSI Strategy

**Brightspark** · Fri Nov 06, 2020 2:39 am

Hi Apprentice,
Having problems with the SSD filter
when using the filter need to be at SSD filter level and K line to have crossed D line biased to the signal can you fix
thanks in advance
Brightspark


---

## Re: SSD RSI Strategy

**Apprentice** · Sat Nov 07, 2020 6:45 am

Can you please write down all the rules that need to be implemented?


---

## Re: SSD RSI Strategy

**Brightspark** · Sun Nov 08, 2020 2:13 am

Hey Apprentice 
Sorry for my lack of explanation if you can add following to ignore buy/sell when in the overbought/oversold areas for both SSD timeframe and RSI timeframe, to be able to turn both off or just one off the filters.
The filter in Overbought area
Not to take buy signals when in 0B area if one or both (depending on filter setting on) SSD or RSI timeframes in 0/B area. 
IF already in buy trade Not to exit buys unless SSD/RSI  crosses below 0/B area.

The filter in Oversold area
Not to take sell signals when in 0/S area if one or both (depending on filter setting on) SSD or RSI timeframes in 0/S area.
IF already in sell trade Not to exit sells unless SSD/RSI crosses above 0/S  area.

To allow signal if one of the TF filters is in 0B/0S and the one is not in 0B/0S and filter is turned off.
Hope this explains better
thanks
Brightspark


---

## Re: SSD RSI Strategy

**Apprentice** · Sun Nov 08, 2020 10:53 am

Your request is added to the development list.
Development reference 2273.


---

## Re: SSD RSI Strategy

**Apprentice** · Mon Nov 09, 2020 5:18 pm

[SSD RSI Strategy.lua](files/138770/SSD%20RSI%20Strategy.lua)

Try this version.


---

## Re: SSD RSI Strategy

**Brightspark** · Tue Nov 10, 2020 8:58 am

Hey Apprentice,
The ﻿0B/0S not taking trades seems to work well thankyou. Regarding  Not to exit open trades in 0B/0S area if the trade was opened b4 entering 0B/0S area on backtesting still closing can you check (still testing on live price). Regarding the SSD filter to work as 2nd chance trigger entry or add to positions If had a deeper pullback.

**IF already in buy trade b4 entering the 0/B area**Not to exit buys unless SSD/RSI  crosses below 0/B area ( please check)

**IF already in sell trade b4 entering the 0/S area**Not to exit sells unless SSD/RSI crosses above 0/S  area ( please check)

**2nd chance trigger for buys**
SSD to have been below SSD filter level (in the current SSD swing)  B4 checking ssd k line is above d line and X-RSIOMA rsi to be above ma_rsioma  so instead of above 0/B needs to have been below filter

**2nd chance trigger for sells** SSD to have been above SSD filter level(in the current SSD swing) B4 checking ssd k line is below d line and  X-RSIOMA rsi to be below ma_rsioma  so instead of below 0/B needs to have been above filter

thanks for all the work already gone into this task
Brightspark


---

## Re: SSD RSI Strategy

**Apprentice** · Wed Nov 11, 2020 2:37 pm

Your request is added to the development list.
Development reference 2283.


---

## Re: SSD RSI Strategy

**Apprentice** · Thu Nov 12, 2020 4:55 am

It already works like that. Or I do not understand the request.


---

## Re: SSD RSI Strategy

**Brightspark** · Thu Nov 12, 2020 9:08 am

Hey Apprentice,
Was testing different periods on the X- RSIOMA setting and was getting same results so put, rsi to 0 ma_rsioma 0  got same results if using the default setting, it seems the X-RSIOMA  is not connected to the strategy and just using the SSD for signals only. as per screenshots also when using the 0B/0S filter just blocks all signals between 0B/0S and if using the SSD filter gives the same results On or Off
ps; for screenshot purpose was using default settings and same time frame

screenshot 1. No Filters 
Screenshot 2. With Filters 
Hope you can fix 
thanks again Brightspark 

 

![Screenshot 1. No 0B-0S Filters.jpeg](images/138843/Screenshot%201.%20No%200B-0S%20Filters.jpeg)



 

![Screenshot 2. With 0B-0S Filters .jpeg](images/138843/Screenshot%202.%20With%200B-0S%20Filters.jpeg)
