# Multiple position OCO

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65793  
> Forum: 31 · Topic 65793 · 4 post(s)


---

## Multiple position OCO

**Apprentice** · Thu Mar 01, 2018 6:23 am

Based on the request.
[viewtopic.php?f=27&t=65762](https://fxcodebase.com/code/viewtopic.php?f=27&t=65762)

 OCO will be capable of opening multiple positions at the same time with different lot sizes, stops & limits.

 [multi_oco.lua](files/117960/multi_oco.lua)


---

## Re: Multiple position OCO

**amazon1a** · Thu Mar 01, 2018 5:55 pm

Hi Apprentice,

This looks great. Basically, it looks like we have a Multiple Entry/ Multiple Exit (ME/ME) basket type of Strategy. Exits are either by variable SLs, TPs or opening an Entry in the opposite direction via OCO at the predetermined level. This is exactly what I had hoped for.

I do not know if it would be possible with the OCO logic to specify which Side to Trade for the basket, or do we just have to set the opposite side at a Level far enough away to avoid getting hit by a wild spike?

Many thanks as always, AG


---

## Re: Multiple position OCO

**Apprentice** · Mon Mar 05, 2018 11:23 am

Can you give me an actual example of such a trade?


---

## Re: Multiple position OCO

**amazon1a** · Mon Mar 05, 2018 3:00 pm

Thanks for your response,

For example, for the past month for the CADJPY the side to have been on was the Short side. At almost any Level a basket short would have been in profit, and we would not have wanted Long trades triggered. If that was our BIAS then Long positions by OCO would need to be far away.

I know that once open, we can go back and delete opposing orders, but that is a bit of a bother and for me so prone to error.

The PartialAmountStrategy( [viewtopic.php?f=31&t=64940&hilit=partialamountstrategy](http://www.fxcodebase.com/code/viewtopic.php?f=31&t=64940&hilit=partialamountstrategy)) has a provision to select a side but not both. Maybe something along these lines might be possible with the option to chose Long, Short or Both to preserve the original OCO function.

I am thinking the choice would apply for the whole 5 Trade basket - not each Trade separately.

But please know that I am very happy with what I have, and this Tweak may be too much.

AG
