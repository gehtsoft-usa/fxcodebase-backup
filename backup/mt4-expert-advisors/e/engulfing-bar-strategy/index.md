# Engulfing Bar Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=73253  
> Forum: 38 · Topic 73253 · 3 post(s)


---

## Engulfing Bar Strategy

**Steve Hoang** · Fri Jan 20, 2023 2:33 pm

Hi Apprendice

Can you create EA based on this logic

**Rules:**
 1. Long at next open bar when Bullish Engulf bar is formed above EMA30, and short at next open bar when Bearish Enguld bar is formed below EMA 30.
 2. Use Finbonacci to determine SL and TP

**Indicator:**
 1. EMA30
 2. File mql Engulfing in case you need

**Setting i want to add in EA:**

 **EMA Filter:** EA will use EMA for trade decisions

 **Open after EMA:** trades will be opened after the current bar closes above or below EMA. If EMA_Filer is False this will be ignored

 **Use pending orders:** EA will place pending orders and not instant orders

 **MA EMA:** EMA setting

 **Candle Shift:** this is a dynamic algo that will check for engulfing bars on a higher timeframe relative to the current timeframe in the current timeframe's bars. Setting this to a value of 1 (one) is equivalent to only checking the current bar and will not check on a higher timeframe.

 **Pend points:** number of points higher or lower orders will be be place from the current signal, this includes stop loss and take profit.

 **Pending Expiry:** = 14400; after xxx seconds pending order will be deleted. most brokers have 10-15 minutes minimum duration that pend. orders must stay active.

 **Fibo Level TP:** take profit will be set to the fibo level, this is static and does not change

 **Fibo Level SL:** stop loss will be set to the fibo level, this is static and does not change

 **Trade close on bar close:** trades will close on the next bar if in profit(usefull for H1 H4 ...) if true trades will get a take profit of 99 points and not the fibo level

 **Profit Trailing:** use trailing stop true/false

 **Trailing Stop:** trailing stop will kick in at these pips.

TrailingStep : stop loss will be move up when these pips have increased.

MagicNumber : magic number


---

## Re: Engulfing Bar Strategy

**Apprentice** · Mon Jan 23, 2023 11:50 am

We have added your request to the development list.
Development reference 80.


---

## Re: Engulfing Bar Strategy

**Apprentice** · Thu Jan 26, 2023 4:57 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=73272](https://fxcodebase.com/code/viewtopic.php?f=38&t=73272)
