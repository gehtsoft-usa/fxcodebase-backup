# Absolute Strength Indicator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3848  
> Forum: 31 · Topic 3848 · 13 post(s)


---

## Absolute Strength Indicator Strategy

**Apprentice** · Wed Apr 06, 2011 2:33 am

![ASI Strategy.png](images/9404/ASI%20Strategy.png)



You have to distinguish
Strategy Mode
Signal - Show each CrossOver Signal
Strategy - For Trading Mode

Signal Type
Indicator / Signal Line CrossOver - Trade if we have Indicator / Signal Line CrossOver
Indicator / Indicator Line CrossOver - Trade if we have Indicator / Indicator Line CrossOver

 [ASI Strategy.lua](files/9404/ASI%20Strategy.lua)

To make this work, please install.
[viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205](https://fxcodebase.com/code/viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205)

The Strategy was revised and updated on December 09, 2018.


---

## Re: Absolute Strength Indicator Strategy

**eMPGee** · Tue May 03, 2011 1:47 pm

Hi Apprentice,
You do great work. I have been using the ASI indicator for several months with great sucess. I am pleased to see that you have developed the ASI strategy.

Today I used the statagey and had several good trades, the only issue I am having; My stop and limit orders are not benig executed. I have all parameters set in the stratagey to place trailng stop and limit order. Any advice?

Thank you very much for all that you do? Great Work!


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Tue May 03, 2011 2:15 pm

I'm not sure, I have to check.
I personally do not use strategies or indicators.

Are you from U.S.


---

## Re: Absolute Strength Indicator Strategy

**eMPGee** · Tue May 03, 2011 3:00 pm

> **Apprentice wrote:**
> I'm not sure, I have to check.
> I personally do not use strategies or indicators.
>
> Are you from U.S.

Yes, I am from the U.S.


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Wed May 04, 2011 2:53 am

As far as I know, U.S. trader can not set a stop order.
Due to regulatory restrictions.

"Close, Stop and Limit orders on individual trades for all United States based accounts are not functional as they are not compliant with the National Futures Association (NFA) Compliance Rule 2-43 (b)."

[http://www.nfa.futures.org/news/PDF/CFT ... 112408.pdf](http://www.nfa.futures.org/news/PDF/CFTC/CR2_43_ForexPriceAdj_112408.pdf)


---

## Re: Absolute Strength Indicator Strategy

**sfrohock** · Sun May 08, 2011 5:23 pm

I just downloaded this strategy and it tells me I need an Absolute Indicator to run it. I've looked all over this site and am unable to find the correct Indicator. Help Please.
SteveF


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Mon May 09, 2011 3:54 am

Link for it, you can find on the top most post in this topic.

Or Here
[viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205](https://fxcodebase.com/code/viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205)


---

## Re: Absolute Strength Indicator Strategy

**arindam89** · Wed Oct 03, 2012 10:29 pm

> **Apprentice wrote:**
>
>
> ASI Strategy.png
>
>
>
> You have to distinguish
> Strategy Mode
> Signal - Show each CrossOver Signal
> Strategy - For Trading Mode
>
> Signal Type
> Indicator / Signal Line CrossOver - Trade if we have Indicator / Signal Line CrossOver
> Indicator / Indicator Line CrossOver - Trade if we have Indicator / Indicator Line CrossOver
>
>
>
> ASI Strategy.lua
>
>
>
> To make this work, please install.
> [viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205](https://fxcodebase.com/code/viewtopic.php?f=17&t=2987&p=7205&hilit=Absolute+Strength+Indicator+Strategy#p7205)

hi apprentice
this is a great indicator
it can be used both in trending as well as range markets
but there is a small loophole in the strategy
**loophole**
for example when both signal and indicator line is bearish(on top)
and when there is crossover of indicator line and signal line it is opening a short position which i fell is wrong please make a correction

**correction**[u]
for example when both signal and indicator line is bearish(on top)
and when there is crossover of **signal line** and **indicator line** it must open a short position
thanks
by
arindam


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Thu Oct 04, 2012 5:37 am

Your request is added to the development list.


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Wed Dec 07, 2016 4:36 am

Bump up.


---

## Re: Absolute Strength Indicator Strategy

**khanatd** · Thu Oct 23, 2025 11:44 pm

Hi sir plz make mt4 version of it with non repaint arrows , with mt4 ea and buffers numbers written for buy and sell too indicator +EA mt4 with tp sl in $ too, trailing ,etc

thanks
khan


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Wed Oct 29, 2025 5:54 am

We have added your request to the development list.
Development reference 702


---

## Re: Absolute Strength Indicator Strategy

**Apprentice** · Thu Nov 06, 2025 7:09 am

[AbsoluteStrengthIndicator_with_Alert_Arrow.mq4](files/161144/AbsoluteStrengthIndicator_with_Alert_Arrow.mq4)

 [AbsoluteStrengthIndicator_with_Alert Arrow_EA_v1.00.mq4](files/161144/AbsoluteStrengthIndicator_with_Alert%20Arrow_EA_v1.00.mq4)
