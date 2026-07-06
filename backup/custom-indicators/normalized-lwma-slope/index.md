# Normalized LWMA Slope

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62214  
> Forum: 17 · Topic 62214 · 7 post(s)


---

## Normalized LWMA Slope

**Apprentice** · Tue May 12, 2015 9:47 am

![Normalized LWMA Slope.png](images/100427/Normalized%20LWMA%20Slope.png)



Based on request.
[viewtopic.php?f=27&t=59374&p=100428#p100428](https://fxcodebase.com/code/viewtopic.php?f=27&t=59374&p=100428#p100428)
Normalized LWMA= (LWMA-LWMA[-1])/ATR

 [Normalized LWMA Slope.lua](files/100427/Normalized%20LWMA%20Slope.lua)

 [MTF Normalized LWMA Slope.lua](files/100427/MTF%20Normalized%20LWMA%20Slope.lua)

The indicator was revised and updated


---

## Re: Normalized LWMA Slope

**mulligan** · Tue May 12, 2015 1:59 pm

The MTF version is exactly what I've been working with without the benefit of this combined indicator. The combined 3 time frames works extremely well. The only problem is endless hours watching the computer screen. I request what ever is the easiest, alert, signal, or strategy with the following parameters:
Buy - all three time frames in up trend
Sell - all three time frames in down trend
Exit - any contradiction

Note - Up in uptrend and down in uptrend are both considered uptrend. Same with down trend.

Thanks very much for coding this indicator. The results of trading the combined 3 time frames is really extraordinary. I hope the time to code some kind of alert is available.

Thanks for your consideration


---

## Re: Normalized LWMA Slope

**Apprentice** · Fri May 15, 2015 2:56 am

Your request is added to the development list.


---

## Re: Normalized LWMA Slope

**mulligan** · Wed Jul 15, 2015 8:31 am

Could you please check the mtf version. The numbers on the right for the 3 different time frames are not responding. Seem to be stuck. Tried removing and reloading the indicator, but no luck.

Thanks


---

## Re: Normalized LWMA Slope

**Apprentice** · Thu Jul 16, 2015 4:48 am

Fixed.


---

## Re: Normalized LWMA Slope

**superleo** · Thu Nov 10, 2016 5:28 am

hi apprendice,

can you create mtf lwma slope strategy

**indicators:**

**1. NORMALIZED LWMA SLOPE INDICATOR WITH DEFAULT PARAMETERS**

TIME FRAME;M15
BUY LEVEL: 0
SELL LEVEL:0

**2.NORMALIZED LWMA SLOPE INDICATOR WITH DEFAULT PARAMETERS:**

TIME FRAME: H4
BUY LEVEL :0
SELL LEVEL: 0

**BUY:**

1 NORMALIZED LWMA SLOPE IN H4> BUY LEVEL AND
2. NORMALIZED LWMA SLOPE IN M15 CROSS OVER BUY LEVEL

**SELL:**

1.NORMALIZED LWMA SLOPE IN H4< SELL LEVEL AND
2. NORMALIZED LWMA SLOPE IN M15 CROSS UNDER SELL LEVEL


---

## Re: Normalized LWMA Slope

**Apprentice** · Fri Nov 11, 2016 12:50 pm

Try this version.
[viewtopic.php?f=31&t=64088](https://fxcodebase.com/code/viewtopic.php?f=31&t=64088)
