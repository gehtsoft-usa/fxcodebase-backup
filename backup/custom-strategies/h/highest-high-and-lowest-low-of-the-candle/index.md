# highest high and lowest low of the candle

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70209  
> Forum: 31 · Topic 70209 · 8 post(s)


---

## highest high and lowest low of the candle

**Apprentice** · Wed Jul 22, 2020 8:00 am

![EURUSD H1 (07-22-2020 1314).png](images/136198/EURUSD%20H1%20%2807-22-2020%201314%29.png)



Based on request.
[viewtopic.php?f=27&t=70199](https://fxcodebase.com/code/viewtopic.php?f=27&t=70199)

 [highest high and lowest low of the candle.lua](files/136198/highest%20high%20and%20lowest%20low%20of%20the%20candle.lua)


---

## Re: highest high and lowest low of the candle

**chai88888** · Wed Sep 09, 2020 1:41 am

the strategy is haywire

ema is just a filter for buy or long position. buy above ema the red whole body candle should not be touching the ema

Buy : Price is above the EMA, you place a buy stop order highest high the RED candle. Stop is is lowest low of the candle. now if the order is not hit and another RED candle appear cancel the previous order and make a new order on the newest RED candle. limit is the size of the candle.

Sell : Price is below the EMA, you place a sell stop order lowest low of the GREEN candle. Stop is is highest high of the candle. now if the order is not hit and another GREEN candle appear cancel the previous order and make a new order on the newest GREEN candle. limit is the size of the candle.


---

## Re: plus haut et plus bas de la bougie

**bruno2017** · Fri Sep 11, 2020 11:53 am

I have already asked but the team did not get to do this task


---

## Re: highest high and lowest low of the candle

**Apprentice** · Sat Sep 12, 2020 8:47 am

I'm sorry sometimes you have to wait.
The output is a function of developer/funds availability.

Your request is added to the development list.
Development reference 2021.


---

## Re: highest high and lowest low of the candle

**Apprentice** · Mon Sep 14, 2020 7:13 am

[highest high and lowest low of the candle.lua](files/137587/highest%20high%20and%20lowest%20low%20of%20the%20candle.lua)

Try this version.


---

## Re: highest high and lowest low of the candle

**chai88888** · Tue Sep 15, 2020 2:15 am

it does not move your order to the newest candle and it not make a target and stop loss base on the candle


---

## Re: highest high and lowest low of the candle

**Apprentice** · Tue Sep 15, 2020 7:51 am

Your request is added to the development list.
Development reference 2036.


---

## Re: highest high and lowest low of the candle

**Apprentice** · Wed Sep 16, 2020 11:07 am

Can't repeat. It does move the order.
