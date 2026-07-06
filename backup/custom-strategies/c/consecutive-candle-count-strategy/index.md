# Consecutive candle Count Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63734  
> Forum: 31 · Topic 63734 · 2 post(s)


---

## Consecutive candle Count Strategy

**Apprentice** · Thu Aug 04, 2016 11:58 am

![EURUSD H1 (08-04-2016 1807).png](images/107476/EURUSD%20H1%20%2808-04-2016%201807%29.png)



Based on Consecutive candle Count.lua
[viewtopic.php?f=17&t=60884&p=94827#p94827](https://fxcodebase.com/code/viewtopic.php?f=17&t=60884&p=94827#p94827)
Buy
Consecutive candle Count is equal to Entry Period

Sell
Consecutive candle Count is equal to Entry (-1)* Period

Exit (Optinal)
Exit Long
Consecutive candle Count <= (-1)*Exit Period

Exit Short
Consecutive candle Count >= Exit Period

 [Consecutive candle Count Strategy.lua](files/107476/Consecutive%20candle%20Count%20Strategy.lua)

Note, signals are delayed for Period candles if compared with Consecutive candle range.lua.
Similarly as indicator lines are delayed.

The Strategy was revised and updated on December 18, 2018.


---

## Re: Consecutive candle Count Strategy

**Apprentice** · Sat Dec 17, 2016 8:08 am

Strategy was revised and updated.
