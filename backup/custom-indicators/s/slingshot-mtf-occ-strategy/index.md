# SlingShot+MTF+OCC Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66599  
> Forum: 17 · Topic 66599 · 9 post(s)


---

## SlingShot+MTF+OCC Strategy

**Apprentice** · Sat Aug 25, 2018 5:17 am

![EURUSD m1 (08-25-2018 1019).png](images/120779/EURUSD%20m1%20%2808-25-2018%201019%29.png)



Based on request.
[viewtopic.php?f=27&t=66585](https://fxcodebase.com/code/viewtopic.php?f=27&t=66585)

To work install 20 in 1 Moving Average Indicator a.k.a. Averages
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)

 [SlingShot+MTF+OCC Strategy.lua](files/120779/SlingShotMTFOCC%20Strategy.lua)


---

## Re: SlingShot+MTF+OCC Strategy

**MC. Trend Trader** · Mon Aug 27, 2018 7:39 pm

Hello,
I have tried to transform this indicator strategy into a multi-position strategy and have used existing modules from a different strategy.
Unfortunately, I get the following error message
can you fix it please?

C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/SlingShot%2BMTF%2BOCC Strategy (4).lua:1319: attempt to perform arithmetic on local 'amount' (a nil value).

Best regards


---

## Re: SlingShot+MTF+OCC Strategy

**Apprentice** · Tue Aug 28, 2018 3:41 am

Your request is added to the development list under Id Number 4240


---

## Re: SlingShot+MTF+OCC Strategy

**Apprentice** · Tue Aug 28, 2018 11:13 am

Try this version.

 [SlingShot+MTF+OCC Strategy Multi Position.lua](files/120828/SlingShotMTFOCC%20Strategy%20Multi%20Position.lua)


---

## Re: SlingShot+MTF+OCC Strategy

**MC. Trend Trader** · Tue Aug 28, 2018 1:39 pm

Hello
Thanks for the quick request

Limit prices are executed as stop prices.
I think I found the cause. please see line 392

 if trade.set_limit then
 command = command:SetPipStop(nil, trade.limit);


---

## Re: SlingShot+MTF+OCC Strategy

**MC. Trend Trader** · Wed Aug 29, 2018 12:14 am

Hello,

The strategy has opened up double the number of positions because lines 176 to 189 were available elsewhere
I deleted line 176 - until 189. Position opening is now correct
The only thing that does not work is function breakeven
can you fix it please

best regards


---

## Re: SlingShot+MTF+OCC Strategy

**Apprentice** · Wed Aug 29, 2018 5:12 am

It was a typo. Fixed.


---

## Re: SlingShot+MTF+OCC Strategy

**MC. Trend Trader** · Fri Aug 31, 2018 11:11 am

strategy works well. the only thing that does not work is the breakeven function. the stop is not moved to the entry course


---

## Re: SlingShot+MTF+OCC Strategy

**Apprentice** · Sun Sep 02, 2018 2:48 am

Fixed breakeven logic. (I replaced the original file)
