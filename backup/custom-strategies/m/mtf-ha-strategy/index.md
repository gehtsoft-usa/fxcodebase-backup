# MTF HA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7766  
> Forum: 31 · Topic 7766 · 11 post(s)


---

## MTF HA Strategy

**Apprentice** · Wed Nov 02, 2011 4:08 am

![MTF HA Strategy.png](images/17279/MTF%20HA%20Strategy.png)



First, the use of this strategy is for now limited to holders of the beta version of trading platform.

Long
If all time frames have HA Up Candle

Short
If all time frames have HA Down Candle

 [MTF HA Strategy.lua](files/17279/MTF%20HA%20Strategy.lua)

The Strategy was revised and updated on December 09, 2018.


---

## Re: MTF HA Strategy

**mosesnobleraj** · Wed Nov 02, 2011 8:46 am

sir,

this is very nice strategy


---

## Re: MTF HA Strategy

**chiragvanecha** · Thu Dec 08, 2011 11:16 pm

thanks , good strategy can anyone make it to close position when any 3 or 4 of 5 streams turns opposite i mean red or green


---

## Re: MTF HA Strategy

**Apprentice** · Sun Dec 11, 2011 5:48 am

Added developers cue.


---

## Re: MTF HA Strategy

**fabfxcm** · Mon Dec 12, 2011 2:32 pm

HI Apprentice,
I tested this strategy and is very interesting, but the time parameters (start time and stop time for trading) does not work!
Even when I set from 8.00 to 17.00, the strategy keep on open positions after 19.00.
Could you please fix this problem?


---

## Re: MTF HA Strategy

**briansummy** · Thu Mar 22, 2012 8:19 pm

Can you make this for the current platform and add SAR confirmation? Great job here!!!


---

## Re: MTF HA Strategy

**Apprentice** · Fri Mar 23, 2012 2:50 am

"current platform" ?


---

## Re: MTF HA Strategy

**briansummy** · Fri Mar 23, 2012 10:24 am

Oh sorry, it works on my version of the platform. Thanks! A Tick SAR Strategy combined with this would be interesting. Super job!


---

## Re: MTF HA Strategy

**p0p4ss** · Tue Oct 02, 2012 1:34 pm

Can you change this Strategy and add the AFBSR Heat Map.

For example:

MTF HA: 5m / 15m / 30m / 1h / 4h
+
AFBSR Heat Map: 5m / 15m / 30m / 1h / 4h

Go Long:
If all MTF HA and AFBSR are green
Sell:
If one of this will be red

Go Short:
If all MTF HA and AFBSR are red
Sell:
If one of this will be green

Maybe is it possible to add the folowing option:

Go Long:
If 9 of 10 (or 8 of 10 / 7 of 10 / ...) MTF HA and AFBSR are green

Go Short:
If 9 of 10 (or 8 of 10 / 7 of 10 / ...) MTF HA and AFBSR are red


---

## Re: MTF HA Strategy

**Apprentice** · Tue Oct 02, 2012 2:06 pm

Your request is added to the development list.


---

## Re: MTF HA Strategy

**Apprentice** · Wed Dec 07, 2016 4:55 am

Strategy has been revised and updated.
