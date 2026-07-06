# OCO breakout strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=64607  
> Forum: 31 · Topic 64607 · 5 post(s)


---

## OCO breakout strategy

**Apprentice** · Wed Apr 19, 2017 1:16 pm

Based on the request.
[viewtopic.php?f=27&t=64578](https://fxcodebase.com/code/viewtopic.php?f=27&t=64578)

 [Breakout_Strategy.lua](files/112055/Breakout_Strategy.lua)

 [Breakout_Strategy with GMMACD Filter.lua](files/112055/Breakout_Strategy%20with%20GMMACD%20Filter.lua)

The Strategy was revised and updated on January 19, 2019.


---

## Re: OCO breakout strategy

**Kilgharrah** · Fri Apr 21, 2017 5:15 pm

Hi, a little forgetfulness, 2 functions (exitSpecific and haveTrades) are missing so that the option works properly Mandatory Close. Regards.


---

## Re: OCO breakout strategy

**leeh111** · Thu Apr 27, 2017 6:55 am

hi

instead of the stop loss defined as a set amount of pips.. would It be possible to make the stop loss the high or low of the breakout levels ??.. i.e for a long trade the stop loss would be the low (ask) and for a short trade the stop loss would be the high (bid)..

also could an option be added to choose whether a buy or sell position could be opened ??

with those options this strategy would be perfect !!


---

## Re: OCO breakout strategy

**chai88888** · Wed Jan 15, 2020 5:42 am

bump up


---

## Re: OCO breakout strategy

**Apprentice** · Mon Jan 20, 2020 9:57 am

> 1.little forgetfulness, 2 functions (exitSpecific and haveTrades) are missing so that the option works properly Mandatory Close. Regards.
>
> 2.instead of the stop loss defined as a set amount of pips.. would It be possible to make the stop loss the high or low of the breakout levels ??.. i.e for a long trade the stop loss would be the low (ask) and for a short trade the stop loss would be the high (bid)..
>
> also could an option be added to choose whether a buy or sell position could be opened ??
>
> with those options this strategy would be perfect !!

I didn't manage to get any results from this strategy (even from the strategy before the modifications).

 [Breakout_Strategy.lua](files/130818/Breakout_Strategy.lua)
