# New PIVOT strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=22221  
> Forum: 31 · Topic 22221 · 12 post(s)


---

## New PIVOT strategy

**Ekaterina** · Thu Aug 09, 2012 5:44 am

The new Pivot Strategy is attached.

It works the following way:
if prices touches pivot, support or resistance then open position in opposite direction

Parameters:
1. open position based on tick, candle close
2. once per day (yes/no)
3.one per side (yes/no)
4.allowed side (long/short)
5. type of signal (direct/reverse)

Best regards,
Ekaterina

The Strategy was revised and updated on December 10, 2018.


---

## Re: New PIVOT strategy

**benben99** · Fri Aug 10, 2012 4:54 pm

hello,
can u please make a strategy that u can choose a timeframe that a candle closes above or below the pivot and then trade that way, it should have also a stop loss of about 20 pips or so and targets as R1 and R2 or S1 and S2 the position should open atleast 2 positions at the same time with targets R1 and R2 and stop loss of 20 pips
can u please do that?
is it possible to choose also the timeframe of the pivot ? weekly etc...
thanks alot
ben
most important is cross of the pivot on a aclosed candle normally 20 min or 15 and stops and limits wich are the targets


---

## Re: New PIVOT strategy

**benben99** · Sat Aug 11, 2012 4:36 pm

> **Ekaterina wrote:**
> The new Pivot Strategy is attached.
>
> It works the following way:
> if prices touches pivot, support or resistance then open position in opposite direction
>
> Parameters:
> 1. open position based on tick, candle close
> 2. once per day (yes/no)
> 3.one per side (yes/no)
> 4.allowed side (long/short)
> 5. type of signal (direct/reverse)
>
> Best regards,
> Ekaterina

hello
can u please help me to create a great pivot indicator?

i have some parameters if u can help me or anybody--------

1. open pos on a candle close above or below pivot
2.choose timeframe for the candle
3.one per day(yes-no)
4.1 per side(yes-no)
5.option to trade the opposite direction if the candle touched the pivot but didnt cross it the other way
6.allow side(long-short
7.stops and limts options to choose(in pips)
8.option to choose the size of the lot(from 1k and up)
9.option to choose how many lots to use
10.and most importand- option to make the strategy to use always 2 lots each trade with targets R1 and R2 for longs and targets S1 and S2 for shorts.......
--------------------------------------------------------------------
well thats alot i know but thats all in my mind , i think that way of targets and limits and stops will make anybosy trade better with better results
hope u can help me out here and im sure alot of others
thanks alot ben


---

## Re: New PIVOT strategy

**Apprentice** · Mon Aug 13, 2012 1:57 am

actually you describe the strategy.
 sure, such a strategy is possible.


---

## Re: New PIVOT strategy

**benben99** · Mon Aug 13, 2012 6:22 am

> **Apprentice wrote:**
> actually you describe the strategy.
> sure, such a strategy is possible.

thanks alot apprentice, cant wait for it!!!!!


---

## Re: New PIVOT strategy

**surfandturf** · Mon Aug 20, 2012 2:45 pm

Dear developer,
it is not clear to me what this strategy does. It opens only two trades in 8 month backtesting. I cant see that the strategy is opening trades after touching the Pivot, R1 or S1. How many lots? Exit etc
make a strategy which allows to choose the pivotlevel and the direction of the trade (opposite), amount, exit etc. I believe a lot of people would like that.


---

## Re: New PIVOT strategy

**virgilio** · Wed Sep 05, 2012 4:37 pm

The strategy does not specify how many lots are possible to trade for each trade. Also, what are the parameters? R1 and S1? Or R2 and S2?
Grazie


---

## Re: New PIVOT strategy

**stevejrigg** · Mon Oct 08, 2012 3:41 pm

Is this still being worked on?

I have tried the original strategy, however like Ben i'd moved to see a few more variables added.

The ability to test it with configurable Stop's - Limits (in PIPS) would be a great addition.

Also, if the time-frame of the Pivot (not just candle) was configurable that would make much more sense.

For example, i'd like to test the following
Take a trade when Monthly Pivot is hit, with a 20 pip stop an a 40 pip target.

But also, test the following
Take a trade when Daily Pivot is hit, with a 40pip stop and a 100pip target.
Is it possible to make these configurable?

Cheers. Steve


---

## Re: New PIVOT strategy

**guangho** · Fri Nov 02, 2012 1:10 pm

> **Ekaterina wrote:**
> The new Pivot Strategy is attached.
>
> It works the following way:
> if prices touches pivot, support or resistance then open position in opposite direction
>
> Parameters:
> 1. open position based on tick, candle close
> 2. once per day (yes/no)
> 3.one per side (yes/no)
> 4.allowed side (long/short)
> 5. type of signal (direct/reverse)
>
> Best regards,
> Ekaterina

Excuse me, this strategy was not " stop" and " limit ", nor the number, how to control the position number?


---

## Re: New PIVOT strategy

**benben99** · Sat Aug 10, 2013 5:54 pm

> **Apprentice wrote:**
> actually you describe the strategy.
> sure, such a strategy is possible.

hello sir!!!!!
 it has been 1 year since i asked you to create the pivot strategy with the parameters i wrote !!!!!!!
please make some time 4 me and 4 all the others here that are waiting for so lonf for a simple strategy
the strategy should open a position based on the pivot(daily weekly etc....) and should have targets of R1 and R2 , or S1 and S2 atleast/.......
i know that its not so hard for u to do it cause its similar to the pivot mva strategy that dosent have the limits i asked above!!!!!!!!!!!
please bud fo it for us!!!!
u made agreat job creating the kejun strategy 4 me please make that 1 too if u can and when u have time
i will try to combine both strategy when u make it or if u can make an ichimoku cloud filter in addintion to the pivots that will be great
please contact me if u can
thanks alot app im waiting


---

## Re: New PIVOT strategy

**Apprentice** · Fri Dec 09, 2016 6:37 am

Strategy was revised and updated.


---

## Re: New PIVOT strategy

**Alexander.Gettinger** · Tue Apr 02, 2019 8:38 pm

Please try this strategy:

 [Pivot_Strategy2.lua](files/125555/Pivot_Strategy2.lua)
