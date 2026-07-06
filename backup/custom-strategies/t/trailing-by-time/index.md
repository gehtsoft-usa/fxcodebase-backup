# Trailing by time

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2804  
> Forum: 31 · Topic 2804 · 8 post(s)


---

## Trailing by time

**Alexander.Gettinger** · Fri Nov 26, 2010 1:47 am

This strategy moves stop on [StepTrailing] points each [TimeInterval] minutes in order direction (up for BUY and down for SELL).
Initial stop must be given.

Download:

 [TrailingByTime.lua](files/6393/TrailingByTime.lua)

The Strategy was revised and updated on January 18, 2019.


---

## Re: Trailing by time

**[email protected]** · Tue Dec 21, 2010 4:07 am

core.host:execute("isTableFilled", "trades")
core.host:execute("isReadyForTrade")
why I did not find this two functions in Indicore SDK help document？
Can you explain the two functions for us？


---

## Re: Trailing by time

**Nikolay.Gekht** · Wed Dec 22, 2010 10:26 am

These functions are documented in beta SDK ([viewtopic.php?f=28&t=2178](https://fxcodebase.com/code/viewtopic.php?f=28&t=2178)). This SDK will be released with new TS (Jan, 07)

In short, the first function returns true in case the table specified is completely filled (it can be not filled right after the login or if the user call "Refresh" command in TS).

The second function returns true is all the tables are filled and TS can trade with no limitations (the same logic as used to enable/disable BUY/SELL buttons of the trading station).


---

## Re: Trailing by time

**colajam1979** · Mon Oct 03, 2016 7:15 am

Hello all.
Is it me or is this not working?

I put in the details to run the stop on the last 5minute candle.

It doesnt appear that the strategy can link to the trade.


---

## Re: Trailing by time

**Alexander.Gettinger** · Wed Oct 05, 2016 11:58 am

With your settings the strategy will move the stop on the 1 point every 5 minutes.


---

## Re: Trailing by time

**colajam1979** · Wed Oct 05, 2016 12:37 pm

I see. Thanks for explaining.

Could you make a new stop strategy ?

The user picks the candle time.for example 5 minute.
If the trade is short = The stop is the high of the previous candle.
If the trade is long = The stop is the Bottom of the previous candle.

To use the exit strategy the use must link it to the trade as in existing stop strategys.


---

## Re: Trailing by time

**Apprentice** · Wed Oct 12, 2016 3:40 am

Your request is added to the development list, Under Id Number 3648
 If someone is interested to do this task, please contact me.


---

## Re: Trailing by time

**Apprentice** · Sun Dec 18, 2016 4:34 am

Strategy was revised and updated.
