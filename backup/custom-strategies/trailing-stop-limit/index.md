# Trailing_stop_limit

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65947  
> Forum: 31 · Topic 65947 · 12 post(s)


---

## Trailing_stop_limit

**Apprentice** · Tue Apr 17, 2018 11:37 am

Based on the request.
[viewtopic.php?f=27&t=65890](https://fxcodebase.com/code/viewtopic.php?f=27&t=65890)

 [Trailing_stop_limit.lua](files/118707/Trailing_stop_limit.lua)


---

## Re: Trailing_stop_limit

**Reymondpolanco** · Sun Apr 22, 2018 12:23 pm

can you put the option to close a percentage of the trade in each profit ?


---

## Re: Trailing_stop_limit

**Apprentice** · Mon Apr 23, 2018 5:13 am

Your request is added to the development list under Id Number 4117


---

## Re: Trailing_stop_limit

**Apprentice** · Mon Apr 30, 2018 4:56 pm

[Trailing_stop_limit.lua](files/118894/Trailing_stop_limit.lua)

Try this version.


---

## Re: Trailing_stop_limit

**eldshe** · Tue May 08, 2018 7:27 am

hey! great strategy! I needed it much.

but can you make an option that considers and add the **spread** amount to to the limit/stop pips count, so that I can choose whether to stop/TP by BUY rate pips or SELL rate pips.

for an example: now, when I adjust TP of +10, pips I will actually take profit when the price reach +7.8 pips because the spread is reduced...


---

## Re: Trailing_stop_limit

**Apprentice** · Fri May 18, 2018 6:03 am

Your request is added to the development list under Id Number 4144


---

## Re: Trailing_stop_limit

**Apprentice** · Thu May 24, 2018 4:20 am

Try this version.

 [Trailing_stop_limit.lua](files/119351/Trailing_stop_limit.lua)


---

## Re: Trailing_stop_limit

**Reymondpolanco** · Thu May 24, 2018 11:23 am

> **Apprentice wrote:**
> Try this version.
>
>
> Trailing_stop_limit.lua

1- When the price reach the level 1 the stop did't move to the Breakeven point and the strategy delete my stop and my profit.

2-Can you add the option to put the levels in price too. To use in the two ways pips and price level.


---

## Re: Trailing_stop_limit

**Reymondpolanco** · Fri Jun 01, 2018 7:08 pm

> **Reymondpolanco wrote:**
>
>
> > **Apprentice wrote:**
> > Try this version.
> >
> >
> > Trailing_stop_limit.lua
>
>
>
> 1- When the price reach the level 1 the stop did't move to the Breakeven point and the strategy delete my stop and my profit.
>
> 2-Can you add the option to put the levels in price too. To use in the two ways pips and price level.

Any news about this?


---

## Re: Trailing_stop_limit

**Reymondpolanco** · Mon Jun 18, 2018 2:53 pm

> **Apprentice wrote:**
> Try this version.
>
>
> Trailing_stop_limit.lua

1- When the price reach the level 1 the stop did't move to the Breakeven point and the strategy delete my stop and my profit.

2-Can you add the option to put the levels in price too. To use in the two ways pips and price level.


---

## Re: Trailing_stop_limit

**Apprentice** · Sat Jun 30, 2018 5:51 pm

Try this version.

 [Trailing_stop_limit_2.lua](files/119762/Trailing_stop_limit_2.lua)


---

## Re: Trailing_stop_limit

**Reymondpolanco** · Sun Jul 01, 2018 8:17 pm

> **Apprentice wrote:**
> Try this version.
>
>
> Trailing_stop_limit_2.lua

The strategy close the partial trade that works perfect in price level and pips, but when the price reach the level 1 the strategy delete my stop loss.
