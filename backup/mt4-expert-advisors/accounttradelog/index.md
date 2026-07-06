# AccountTradeLog

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=66948  
> Forum: 38 · Topic 66948 · 3 post(s)


---

## AccountTradeLog

**Apprentice** · Wed Nov 21, 2018 9:04 am

Based on TS2/Lua version.
[viewtopic.php?f=31&t=64933](https://fxcodebase.com/code/viewtopic.php?f=31&t=64933)

 [AccountTradeLog.mq4](files/122234/AccountTradeLog.mq4)


---

## Re: AccountTradeLog

**conjure** · Thu Dec 13, 2018 6:53 am

Hi Apprentice .
Thank you for converting the code.
I only found one problem.
The strategy does not show the pips okey.

Code: [Select all](https://fxcodebase.com/code/)
`Symbol,  Amount, S/B,  P/L,            Gross P/L,  Limit,       Stop
EURGBP,  0.01,     S,   -1428166.1,    -0.15,        0.00000,   0.00000
EURUSD,  0.01,     B,    1425522.2,    -0.16,        0.00000,   0.00000`

Code: [Select all](https://fxcodebase.com/code/)
`trades[arraySize - 1].PLPips = (Bid - OrderOpenPrice()) / _pipSize;`

I think that pip size is different for each instrument.
Can you fix it?


---

## Re: AccountTradeLog

**Apprentice** · Fri Dec 14, 2018 1:09 pm

Fixed.
