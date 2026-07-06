# TrailingStopStrategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65091  
> Forum: 31 · Topic 65091 · 41 post(s)


---

## TrailingStopStrategy

**Apprentice** · Fri Sep 15, 2017 4:03 pm

Based on the request.
[viewtopic.php?f=27&t=65067](https://fxcodebase.com/code/viewtopic.php?f=27&t=65067)

 [TrailingStopStrategy.lua](files/114919/TrailingStopStrategy.lua)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Fri Sep 15, 2017 5:13 pm

Perfect, the strategy only allow to put profit levels in pips, can you put the option to put a specific price level in each profit level i mean the two options: price level and pips.


---

## Re: TrailingStopStrategy

**papynou34** · Sat Sep 16, 2017 12:16 pm

Hello,
Thanks for your great job.
Is it possible to add a percent of total Lot to be closed after Tp1, tp2, and so on?
That means i would like to close for example 50% of the order after 10 pips of profit.

Thanks in advance


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Wed Sep 20, 2017 7:00 pm

Can you put the option to use the strategy with the "entry orders" too, and put the option to place a target price in the take profit plus pips too.


---

## Re: TrailingStopStrategy

**Apprentice** · Fri Sep 29, 2017 7:36 am

Your request is added to the development list under Id Number 3907


---

## Re: TrailingStopStrategy

**Alexander.Gettinger** · Thu Oct 12, 2017 11:58 am

> **Reymondpolanco wrote:**
> Can you put the option to use the strategy with the "entry orders" too, and put the option to place a target price in the take profit plus pips too.

Please, try this strategy:

 [TrailingStopStrategy2.lua](files/115406/TrailingStopStrategy2.lua)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Thu Oct 12, 2017 11:06 pm

i dont see the option to put the levels in price and the order doesn´t appear in the list


---

## Re: TrailingStopStrategy

**Daveatt** · Sat Nov 25, 2017 8:22 pm

Hi Apprentice

Could we add the option to sell half of the position once each TP is achieved ?

Thanks
David


---

## Re: TrailingStopStrategy

**Daveatt** · Thu Nov 30, 2017 8:10 am

Hi

I was testing TrailingStopStrategy2.lua

I'm getting the following error message when entering a trade at market with stop loss = -10 and TP1/TP2/TP3/TP4/TP5 defined at 2 pips each

"Failed create/change stop Cannot place more than one order of this type for each trade."

Does anyone else have the issue ?

Thanks
David


---

## Re: TrailingStopStrategy

**Apprentice** · Mon Dec 04, 2017 6:36 am

Try it now.


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Tue Dec 26, 2017 6:37 pm

Perfect, the strategy only allow to put profit levels in pips, can you put the option to put a specific price level in each profit level i mean the two options: price level and pips.


---

## Re: TrailingStopStrategy

**Apprentice** · Tue Jan 02, 2018 8:27 am

Your request is added to the development list under Id Number 3993


---

## Re: TrailingStopStrategy

**Apprentice** · Wed Jan 03, 2018 5:28 am

Try this version.

 [TrailingStopStrategy.lua](files/116729/TrailingStopStrategy.lua)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Wed Jan 03, 2018 8:44 am

I dont see the option to put a price level, please check.


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Sun Jan 07, 2018 12:04 pm

> **Alexander.Gettinger wrote:**
>
>
> > **Reymondpolanco wrote:**
> > Can you put the option to use the strategy with the "entry orders" too, and put the option to place a target price in the take profit plus pips too.
>
>
>
> Please, try this strategy:
>
>
> The attachment **TrailingStopStrategy2.lua** is no longer available

i dont see the option to put the levels in price and the order doesn´t appear in the list. Wich is the function of the trade profit $h!t ? (check the image i attached the red square)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Fri Feb 09, 2018 12:08 pm

Hi can you check the last post y made about the price levels


---

## Re: TrailingStopStrategy

**Apprentice** · Mon Feb 12, 2018 8:24 am

Try this version.

 [TrailingStopStrategy.Reymondpolanco.lua](files/117729/TrailingStopStrategy.Reymondpolanco.lua)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Tue Feb 20, 2018 12:38 am

> **Apprentice wrote:**
> Try this version.
>
>
> TrailingStopStrategy.Reymondpolanco.lua

I only see the open trades in the option to chose the trade but not the entry orders


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Fri Mar 02, 2018 9:57 am

hi, the modifycaton of the price level is ok, but can you put the option to chose price level or pips in each parameters and the entry orders doesn"t appear yet the strategy only show the open trades.


---

## Re: TrailingStopStrategy

**Apprentice** · Mon Mar 05, 2018 11:19 am

Your request is added to the development list under Id Number 4062


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Thu Mar 08, 2018 11:23 am

Can you add the option to close an amount of the trade in each TP


---

## Re: TrailingStopStrategy

**alienmole** · Fri Mar 09, 2018 10:14 am

This is something like Im after except it would great if you could just put pips instead of the price and also allow the choice of where your stop moves to in relation to each target.

The Strategy called "Stage Stop" is what Id love to have, except I've found it doesn't seem to work correctly


---

## Re: TrailingStopStrategy

**alienmole** · Sat Mar 10, 2018 6:34 am

Hi

Just as feedback I set this to 10,20,30,40,50, which as I understand it means, at +10 the stop goes to break even and then at +20 the stop goes to +10 etc etc

When I tried it out The Stop loss actually went to Break even as expected and then it moved to +10 when price got to +20, again as expected, but after that it didn't move at all, even though price advanced further.

Thanks


---

## Re: TrailingStopStrategy

**Apprentice** · Tue Mar 13, 2018 5:57 am

Try this version (previous request)

 [TrailingStopStrategy.Reymondpolanco.lua](files/118162/TrailingStopStrategy.Reymondpolanco.lua)


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Tue Mar 13, 2018 10:07 am

> **Apprentice wrote:**
> Try this version (previous request)
>
>
> The attachment **TrailingStopStrategy.Reymondpolanco.lua** is no longer available

Please verify all parameters because the strategy doesn´t work propely, for example when i put the strategy for an entry order when the entry order execute the strategy doeest work because the selector stay in the Order option.

Check the attached photo, when i saw that the entry order was executed i went to the strategy option and change the selector to the option "trade" and when the trade was so far from the TP1, TP2, TP3 move the stop to the BE not to the correct TP


---

## Re: TrailingStopStrategy

**Apprentice** · Thu Mar 15, 2018 2:10 pm

Fixed.


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Thu Mar 15, 2018 2:49 pm

I try but when the order execute the strategy give me an error of trade disapear and start but when the price reach the TP1 the strategy put in pause and the label in the chart stay showing ORD00000088 not TRD00000089 and in the properties the strategy stay showing Order in the selector.

When i put the strategy in a active trade the strategy put in pause and the plataform give me an error saying the trade has been disapear and this is not correct the trade still active.


---

## Re: TrailingStopStrategy

**Apprentice** · Sat Mar 17, 2018 8:17 am

I can't repeat that. It works fine in my case.
Can you post exact file version?


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Tue Mar 20, 2018 11:57 am

> **Apprentice wrote:**
> Try this version (previous request)
>
>
> TrailingStopStrategy.Reymondpolanco.lua

I use this version i was trying now and i have the same error "Trade Disapear" when i use in entry order option and when the order active and convert in a trade the selector stay in Order option


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Sun Apr 22, 2018 12:09 pm

I have this error over and over and over again


---

## Re: TrailingStopStrategy

**Apprentice** · Mon Apr 23, 2018 5:15 am

Then you choose trade or order "(non-FIFO) Choose Trade" strategy will be active while strategy/order is present.


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Mon Apr 23, 2018 8:53 am

Now im getting this error


---

## Re: TrailingStopStrategy

**Apprentice** · Tue Apr 24, 2018 1:32 am

You use 141585 on GBP/USD
missed the "."
1.41585


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Tue Apr 24, 2018 2:37 pm

Check now i put all price levels correctly and i get tha same error 3 times check the blue square and the strategy i think is taking a wrong price level check the red square


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Sun May 13, 2018 10:18 am

> **Reymondpolanco wrote:**
> Check now i put all price levels correctly and i get tha same error 3 times check the blue square and the strategy i think is taking a wrong price level check the red square

Any news about this error ?


---

## Re: TrailingStopStrategy

**Apprentice** · Sun May 20, 2018 11:23 am

Try it now.


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Sun May 20, 2018 12:12 pm

> **Apprentice wrote:**
> Try it now.

I try this version the error dont come again but when the price touch the 1 level the stop perfectly move to the break even but when the price reach the 2 level the stop did't move to the 1 level and do the same thing with the other levels, in conclusion the stop only move when the price reach the level 1


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Thu May 24, 2018 2:53 pm

> **Reymondpolanco wrote:**
>
>
> > **Apprentice wrote:**
> > Try it now.
>
>
>
> I try this version the error dont come again but when the price touch the 1 level the stop perfectly move to the break even but when the price reach the 2 level the stop did't move to the 1 level and do the same thing with the other levels, in conclusion the stop only move when the price reach the level 1

Please solve this i really need that


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Fri Jun 01, 2018 7:07 pm

> **Reymondpolanco wrote:**
>
>
> > **Apprentice wrote:**
> > Try it now.
>
>
>
> I try this version the error dont come again but when the price touch the 1 level the stop perfectly move to the break even but when the price reach the 2 level the stop did't move to the 1 level and do the same thing with the other levels, in conclusion the stop only move when the price reach the level 1

Any news about this error ?


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Mon Jun 18, 2018 2:54 pm

> **Apprentice wrote:**
> Try it now.

I try this version the error dont come again but when the price touch the 1 level the stop perfectly move to the break even but when the price reach the 2 level the stop did't move to the 1 level and do the same thing with the other levels, in conclusion the stop only move when the price reach the level 1


---

## Re: TrailingStopStrategy

**Reymondpolanco** · Sat Jun 23, 2018 9:28 pm

I have this strategy but when the price touch the 1 level the stop perfectly move to the break even but when the price reach the 2 level the stop did't move to the 1 level and do the same thing with the other levels, in conclusion the stop only move when the price reach the level 1.
