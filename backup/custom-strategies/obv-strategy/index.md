# OBV Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62140  
> Forum: 31 · Topic 62140 · 7 post(s)


---

## OBV Strategy

**Apprentice** · Thu Apr 23, 2015 11:20 am

![OBV Strategy.png](images/100006/OBV%20Strategy.png)



Based on request.
[viewtopic.php?f=27&t=61823&start=10](https://fxcodebase.com/code/viewtopic.php?f=27&t=61823&start=10)
Long
if Fast MA CrossOver Slow MA
and OBV > MA of OBV
Short
if Fast MA CrossUnder Slow MA
and OBV < MA of OBV

Optinal Exit
Exit Long
OBV < MA of OBV
Exit Short
OBV > MA of OBV

 [OBV Strategy.lua](files/100006/OBV%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: OBV Strategy

**4x4partners** · Thu Apr 23, 2015 12:34 pm

Did you flesh out the strategy? Looks like you just reposted my function?
Maybe an error?


---

## Re: OBV Strategy

**Apprentice** · Fri Apr 24, 2015 2:17 am

Affirmative I uploaded the wrong file version.
Try it now.


---

## Re: OBV Strategy

**4x4partners** · Fri Apr 24, 2015 7:41 am

Thanks! Will give it a try.


---

## Re: OBV Strategy

**4x4partners** · Mon Apr 27, 2015 8:58 am

Thanks again for this Apprentice!

I have a quick question as I'm attempting to modify it in order for the OBV to be on a different time-frame (for example H4), while the rest of strategy triggers at a lower timeframe.

And I only want the OBV to be checked at close of every H4 bar (not live).

How would I find out at moment of starting the strategy whether the OBV is above/below its MA? Meaning before the next H4 bar closes. As I'd like to know from the very moment strategy is started if the OBV is above/below its MA, based on last closed H4 bar. And not have it wait - which could be up to 4 hours before it refreshes the OBV.

Is there a simple way to set this up in the Prepare function?

Thanks again for all your help.

Best
4x4


---

## Re: OBV Strategy

**Apprentice** · Tue Apr 28, 2015 2:47 am

You have to get different sources for different time frames.
[viewtopic.php?f=28&t=2712](https://fxcodebase.com/code/viewtopic.php?f=28&t=2712)
Consult template section for examples.
Live /End of turn Execution
End of Turn_Live Execution Strategy Template.lua
MTF Strategy
 MTF Strategy Template.lua


---

## Re: OBV Strategy

**Apprentice** · Sun Dec 11, 2016 3:50 pm

Strategy was revised and updated.
