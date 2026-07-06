# Standard MA advisor strategy with trade time window

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=11909  
> Forum: 31 · Topic 11909 · 14 post(s)


---

## Standard MA advisor strategy with trade time window

**Alexander.Gettinger** · Wed Jan 18, 2012 4:34 am

This is a standard MA advisor strategy with the possibility specify start and end of trading session.

Download:

 [ma_advisor_time_window.lua](files/23775/ma_advisor_time_window.lua)

 [ma_advisor_time_window.lua.rc](files/23775/ma_advisor_time_window.lua.rc)

The Strategy was revised and updated on November 22, 2018.


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Sat Jan 28, 2012 3:09 pm

Dear Alexander,
I can not load this file. Something is wwrong. I can load all other Strategies without problems. Please advice.


---

## Re: Standard MA advisor strategy with trade time window

**Apprentice** · Sun Jan 29, 2012 1:52 pm

Did you download both files.
.Lua and Llua.RC


---

## Re: Standard MA advisor strategy with trade time window

**juul66** · Tue Feb 07, 2012 8:34 am

Hi,

I have downloaded both files however the strategy is not working. The extension 'rc' is not recognized by TSII.

I have uploaded a print screen.

Could you please help ? Thanks you.


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Fri Feb 10, 2012 10:51 am

Same with me!!! Please help, I even tried to review the code. Thanks for fast reply.


---

## Re: Standard MA advisor strategy with trade time window

**Apprentice** · Sun Feb 12, 2012 4:46 am

During testing i found small bug in this strategy.
But it was not your problem.
You do not need to load rc.lua.
The trading platform will do it alone,
If both files are in the same directory.
Just load. Lua file.


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Sun Feb 12, 2012 8:35 am

Hello,
it still doesn't work. Mistake :344 first parameter needs to be a number, when trying to backtest. Please, explain how to correctly download this file. Is this a standard strategy and do we have to download into the standard folder. If yes, is it sufficient to copy the file in this folder. For custom strategies I usually load them via Marketscope/Signal Custom/Signals and Strategies.

Thanks


---

## Re: Standard MA advisor strategy with trade time window

**Apprentice** · Mon Feb 13, 2012 5:49 am

2 additional Bugs Found and patched.


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Tue Feb 14, 2012 9:51 am

Dear Apprentice,
thanks! It works now. For the beauty contest you could add the new added parameters from the Time Frame also to the RC File, like this it will be translated in the according language. An option to choose the local time in the window would be nice for everybody who is not living in NY.

More importantly, I found a severe bug in the backtesting tool (only, and not in the regular charts). The columne for ask and bid in the history log is switched, as well as in the chart!!! The ask price must be always higher than the bid price, which is not the case in the backtesting tool. The calculation according to the strategy is actually correct, but since the columns are exchanged it will deliver the wrong output (equity, balance). Wow, fatal... Therefore the generated results in this strategy (or in all other strategies?) are not correct. Please, try to fix this as soon as possible.

Further, I found that there is a difference in MMR requirement depending, if I backtest in the Real or Demo account. The MMR is a factor 4 higher in the Demo account using the same settings. I have no clue why this is so, but it gives me trouble depending on which strategy I am testing, I get to early a MC.

It would also be very helpful to have the used margin by the open trades subtracted from the equity or at least also shown graphically besides the equity and balance.

Thanks, for helping


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Sat Feb 25, 2012 3:45 am

Dear Apprentice,
the MA Advisor with trade time window doesn`t work in when using it as a signal (automated mode). The error message is 344: The first parameter needs to be a number. Please correct. Before I have used it only in the backtesting modus.

Further, according to my last post on Feb. 14th there is a severe bug in the backtesting modus, can you reply, if you are are working on it and until when this problem is fixed?

Thanks


---

## Re: Standard MA advisor strategy with trade time window

**Apprentice** · Sun Feb 26, 2012 4:49 am

I sent a message to Alex.
Unfortunately I can not test during the weekends.


---

## Re: Standard MA advisor strategy with trade time window

**surfandturf** · Sun Feb 26, 2012 12:51 pm

Again me,
I have tested another strategy (CCI), there the same problem occurs, therefore it seems to be a global problem for all strategies. The backtesting tool has the ask and bid reversed, all results generated with the backtesting tool for any of the indicators are therefore meaningless. Please, forward it also to whom it may concerns, since it is not only an issue of the MA Advisor with trade window.


---

## Re: Standard MA advisor strategy with trade time window

**Alexander.Gettinger** · Fri Mar 02, 2012 4:15 pm

Strategy updated.


---

## Re: Standard MA advisor strategy with trade time window

**Apprentice** · Sun Dec 04, 2016 8:15 am

Bump up.
