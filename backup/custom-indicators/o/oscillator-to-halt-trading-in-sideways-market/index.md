# Oscillator to Halt trading in sideways market

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64325  
> Forum: 17 · Topic 64325 · 3 post(s)


---

## Oscillator to Halt trading in sideways market

**mikeinvaldosta** · Mon Jan 23, 2017 9:27 pm

![EURUSD H1 (01-24-2017 1816).png](images/110676/EURUSD%20H1%20%2801-24-2017%201816%29.png)



I have created an oscillator for use with EUR/USD to determine a sideways market. It is fairly straightforward and measures deviation of different moving averages.

It has provides a graphical signal of when not to trade.

I have attempted to incorporate this into a strategy I am working on. The strategy has a high failure rate when the oscillator is within a range of .999 to 1.001, and a fairly decent success rate when outside of this range.

As a beginner, I do not have a grasp on how to call upon the indicator to allow trading or disallow. I attempted to place the entire indicator logic within the strategy, but it does not appear to be as precise.

My logic was simple "if indicator > 1.001 allow trading" and "if indicator < 0.999 allow trading".

Can some assist me with calling on this indicator from within my strategy as opposed to re-programming this into the strategy itself?

Thanks!

 [mike_mva2.lua](files/110676/mike_mva2.lua)

 [Sideways Market Filter.lua](files/110676/Sideways%20Market%20Filter.lua)

The indicator was revised and updated


---

## Re: Oscillator to Halt trading in sideways market

**Steve0001** · Tue Jan 24, 2017 3:36 pm

I would phrase it like this: "if indicator > 1.001 or indicator < 0.999 then allow trading."


---

## Re: Oscillator to Halt trading in sideways market

**Apprentice** · Wed Jan 25, 2017 6:04 am

Try this version.
[viewtopic.php?f=31&t=64331](https://fxcodebase.com/code/viewtopic.php?f=31&t=64331)
