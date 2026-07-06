# Signal: Margin alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2442  
> Forum: 31 · Topic 2442 · 8 post(s)


---

## Signal: Margin alert

**Nikolay.Gekht** · Mon Oct 18, 2010 11:11 am

Update:
1) Percentage calculation is fixed
The signal checks up to five conditions and shows alerts/plays sound and/or sends email when the chosen account (or any of the available accounts) available margin falls below the specified level. The level can be specified either in absolute value or in percents to the account equity.

The signal checks margin every N seconds, where N is the interval chosen in the parameters.

Download signal:

The discussion on how to configure the email alerts in Trading Station/Marketscope can be found here:
[viewtopic.php?f=29&t=2232](https://fxcodebase.com/code/viewtopic.php?f=29&t=2232)

The author of this signal is Alexander Samolov (uglock on this forum).

 [Margin_Alert_2.lua](files/5298/Margin_Alert_2.lua)

The Strategy was revised and updated on December 17, 2018.


---

## Re: Signal: Margin alert

**uglock** · Mon Oct 25, 2010 11:03 am

I've created a version of the signal that will work without Autotrading Patch (MarginAlert091010.lua). Updates in this version are based on ticks rather than on timer, so if there are no price updates - signal will not recalc the margin levels.

 [MarginAlert091010.lua](files/5512/MarginAlert091010.lua)

Also I've fixed the problem with percentage margin levels in the initial indicator. Please update to the attached version (MarginAlert.lua in the first post).


---

## Re: Signal: Margin alert

**uglock** · Wed Nov 03, 2010 6:56 pm

The new version of strategy is uploaded. Minor bug with start of strategy after Trading Station was restarted is fixed.

 [MarginAlert.lua](files/5794/MarginAlert.lua)


---

## Re: Signal: Margin alert

**4x4partners** · Thu Apr 23, 2015 12:47 pm

Hi there - I know this an old thread, but would either of you mind to let me know which of these is the most recent - and if there's a difference between the original and "MarginAlert091010.lua."

Do either (or both) work on today's TradeStation?

I'm actually looking for something that would manage the number of open positions I have in a given strategy, based on available margin. Does anything like that exist?

Thanks a lot
4x4


---

## Re: Signal: Margin alert

**Apprentice** · Mon Apr 27, 2015 3:06 am

All old code should be compatible.

Position sizing algorithm can be incorporated to any given strategy.
Another approach would be to have strategy that will constantly check the number of open positions by any given strategy.


---

## Re: Signal: Margin alert

**paololuigi** · Mon Jun 22, 2015 4:47 pm

> **Apprentice wrote:**
> All old code should be compatible.
>
> Position sizing algorithm can be incorporated to any given strategy.
> Another approach would be to have strategy that will constantly check the number of open positions by any given strategy.

Hi Apprentice,

do you think is possible to have strategy that will constantly check the number of open positions by any given strategy?

thanks in advance
p


---

## Re: Signal: Margin alert

**Apprentice** · Wed Jun 24, 2015 6:48 am

Conditional yes.

A prerequisite is that any position open by strategy is tagged.
An example is the "Custom Identifier" for Laguerre_Filter Strategy
[viewtopic.php?f=31&t=62331](https://fxcodebase.com/code/viewtopic.php?f=31&t=62331)


---

## Re: Signal: Margin alert

**Apprentice** · Tue Dec 13, 2016 4:09 pm

Strategy was revised and updated.
