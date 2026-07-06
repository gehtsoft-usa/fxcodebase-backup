# Simple adaptive strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2759  
> Forum: 31 · Topic 2759 · 3 post(s)


---

## Simple adaptive strategy

**Alexander.Gettinger** · Mon Nov 22, 2010 3:08 am

At first strategy open order with [FirstOrder] type.
After closing order strategy analyses last [OrdersNumber] orders and open next order in dependencies on types and result this orders.
For instance:
if OrdersNumber=3 and 3 last BUY orders were unprofitable, next order will SELL.

The Strategy was revised and updated on November 19, 2018.


---

## Re: Simple adaptive strategy

**Apprentice** · Thu Jun 16, 2011 7:16 am

I removed a few bugs.
The algorithm may differ from the original.

 [SimpleAdaptiveStrategy.lua](files/11794/SimpleAdaptiveStrategy.lua)


---

## Re: Simple adaptive strategy

**Apprentice** · Wed Nov 30, 2016 8:27 am

Bump up.
