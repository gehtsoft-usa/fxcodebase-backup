# Candles Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63251  
> Forum: 31 · Topic 63251 · 4 post(s)


---

## Candles Strategy

**Apprentice** · Sun Mar 13, 2016 12:21 pm

![EURUSD H1 (03-13-2016 1747).png](images/105276/EURUSD%20H1%20%2803-13-2016%201747%29.png)



Based on request.
[viewtopic.php?f=27&t=63176](https://fxcodebase.com/code/viewtopic.php?f=27&t=63176)

**Long**
- Candle (N) : Close > Open
...
- Candle (-1) : Close > Open
- Candle ( 0) : Close > Open

Stop Order
Pips +/- from Entry Level
High/Low
Stop is set to Low(-1)
Open / Close
Stop is set to Open(-1)

**Vice versa for Short**

Duration of order with a number of candle
Duration = 1
Order is closed with candle closure

 [Candles Strategy.lua](files/105276/Candles%20Strategy.lua)

 HA Candles Strategy will use HA Candles instead of Price Candles.

 [HA Candles Strategy.lua](files/105276/HA%20Candles%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Candles Strategy

**cpc_cs** · Tue Mar 15, 2016 8:49 pm

Dear Apprentice,

Is it possible to have an option to use HA Candles instead of Price Candles?

Thanks and Regards

S. Joseph


---

## Re: Candles Strategy

**Apprentice** · Wed Mar 16, 2016 3:36 am

HA Candles Strategy added.


---

## Re: Candles Strategy

**Apprentice** · Wed Dec 14, 2016 6:32 am

Strategy was revised and updated.
