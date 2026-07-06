# Previous candle RangeBreakOut Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=72470  
> Forum: 31 · Topic 72470 · 4 post(s)


---

## Previous candle RangeBreakOut Strategy

**Apprentice** · Fri Jul 08, 2022 11:43 am

![EURUSD H1 (07-08-2022 1836).png](images/146659/EURUSD%20H1%20%2807-08-2022%201836%29.png)



Open Long
Close > max(Close[-1], Open[-1]) + ABS(Close[-1] - Open[-1])/2
Price > MA

Close Long
Price < MA

Vice Versa for Short

 [Previous candle RangeBreakOut Strategy.lua](files/146659/Previous%20candle%20RangeBreakOut%20Strategy.lua)


---

## Re: Previous candle RangeBreakOut Strategy

**Avignon** · Mon Jul 11, 2022 5:30 am

What is ABS?


---

## Re: Previous candle RangeBreakOut Strategy

**Apprentice** · Tue Jul 12, 2022 12:56 am

math.abs
Return the absolute, or non-negative value, of a given value.


---

## Re: Previous candle RangeBreakOut Strategy

**Avignon** · Tue Jul 12, 2022 1:16 am

Thanks!
