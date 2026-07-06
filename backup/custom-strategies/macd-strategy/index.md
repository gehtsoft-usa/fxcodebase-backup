# MACD Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4100  
> Forum: 31 · Topic 4100 · 14 post(s)


---

## MACD Strategy

**Apprentice** · Tue May 03, 2011 3:40 am

![MACD Strategy.png](images/10276/MACD%20Strategy.png)



In comparing with the standard strategy, this strategy provides several new features.
HAve Allow Short / Long / Both Positions Option.
Have Separate Exit / Entry Algorithms.
Support the MACD / Zero Line Cross, along with standard MACD / Signal Line.

 [MACD Strategy.lua](files/10276/MACD%20Strategy.lua)

 [HA Close MACD Strategy.lua](files/10276/HA%20Close%20MACD%20Strategy.lua)

HA Close MACD Strategy.lua use HA close as a source.
HA Close = (Open+Close+High+Low)/4

If Signal Filter is ON.
The MACD signal should be greater than a specific value and less than a specific

The Strategy was revised and updated on January 21, 2019.


---

## Re: MACD Strategy

**arindam89** · Sun Jan 08, 2012 12:28 am

> **Apprentice wrote:**
>
>
> MACD Strategy.png
>
>
>
> In comparing with the standard strategy, this strategy provides several new features.
> HAve Allow Short / Long / Both Positions Option.
> Have Separate Exit / Entry Algorithms.
> Support the MACD / Zero Line Cross, along with standard MACD / Signal Line.
>
>
>
> MACD Strategy.lua

hi apprentice
can u add PROFIT/LOSS CARE to this strategy plz
thanks
by
arindam


---

## Re: MACD Strategy

**Apprentice** · Mon Jan 09, 2012 2:36 am

I'm not sure what you mean.
Stop / Limit functionality already exists.
Can you define what you mean in more detail.


---

## Re: MACD Strategy

**arindam89** · Mon Jan 09, 2012 5:24 am

> **Apprentice wrote:**
> I'm not sure what you mean.
> Stop / Limit functionality already exists.
> Can you define what you mean in more detail.

hi
what i meant is in DMACD [strategyhttp://fxcodebase.com/code/search.php?t=1985](strategyhttp://fxcodebase.com/code/search.php?t=1985)
plz add that parameter to this straegy
thanks
by


---

## Re: MACD Strategy

**ronald3rg** · Mon Jan 09, 2012 1:18 pm

Great Strategy, suggestion

Could you add the open above and close below feature and the confirm move by MA. when line crosses open by distance and the confirm move options like in the macd-sample strategy. The macd sample strategy has a flaw that makes it skip entry and exit signals

right place at the right time

3rg


---

## Re: MACD Strategy

**Apprentice** · Tue Jan 10, 2012 12:46 pm

Your request is added to the developmental cue.


---

## Re: MACD Strategy

**Chris40** · Wed Oct 08, 2014 11:24 am

hello,

 I would like the MACD opens a position at the opening of the second candle after the crossing of the MACD and its signal

 kind regards

 Chris40


---

## Re: MACD Strategy

**Apprentice** · Thu Oct 09, 2014 3:20 am

Signal delay, parameter introduced.
I have also completely re-write strategy code,
in order to introduce some additional functionality.


---

## Re: MACD Strategy

**Chris40** · Thu Oct 09, 2014 10:52 pm

thank you for quick work

 Chris40


---

## Re: MACD Strategy

**Apprentice** · Sun Dec 11, 2016 9:46 am

Strategy was revised and updated.


---

## Re: MACD Strategy

**Santoine** · Tue Sep 19, 2017 12:48 am

> **Apprentice wrote:**
>
>
> MACD Strategy.png
>
>
>
> In comparing with the standard strategy, this strategy provides several new features.
> HAve Allow Short / Long / Both Positions Option.
> Have Separate Exit / Entry Algorithms.
> Support the MACD / Zero Line Cross, along with standard MACD / Signal Line.
>
>
>
> MACD Strategy.lua
>
>
>
>
>
> HA Close MACD Strategy.lua
>
>
>
> HA Close MACD Strategy.lua use HA close as a source.
> HA Close = (Open+Close+High+Low)/4

I am trying to add a filter to avoid when HA signal is near 0 (for instance from -0.15 to +0.15) . That condition on SIGNALDATA doesn't work . Can you help me out to add that filter? Thanks


---

## Re: MACD Strategy

**Apprentice** · Fri Sep 29, 2017 7:38 am

HA signal or MACD signal?


---

## Re: MACD Strategy

**Santoine** · Tue Oct 03, 2017 5:19 am

> **Apprentice wrote:**
> HA signal or MACD signal?

The MACD signal with a condition to be more than a specific value and less than a specific in order to avoid the non trending hours Thanks


---

## Re: MACD Strategy

**Apprentice** · Thu Oct 12, 2017 4:09 am

MACM Signal Min. Filter added.
