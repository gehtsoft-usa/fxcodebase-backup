# Volume Trend and Price Trend

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62389  
> Forum: 17 · Topic 62389 · 12 post(s)


---

## Volume Trend and Price Trend

**Apprentice** · Thu Jul 02, 2015 8:44 am

![Price Trend.png](images/101256/Price%20Trend.png)



Based on request.
[viewtopic.php?f=27&t=62374](https://fxcodebase.com/code/viewtopic.php?f=27&t=62374)
Indicator will add X pips, up or down from last valur of linear regression line, in the direction of the trend.
Target Line color will color code trend strength information.
Strong Trend - increasing Volume
Weakened trend - declining Volume.

 [Price Trend.lua](files/101256/Price%20Trend.lua)

 [Volume Trend.lua](files/101256/Volume%20Trend.lua)


---

## Re: Volume Trend and Price Trend

**nookie** · Tue Aug 25, 2015 3:37 am

First thanks a lot! A few points here: Can we make those trend lines not crossing price/trend highs/lows ? A trend line should be by default measured from high to low.

And secondly is it possible to be chosen an indicator on which those thend lines are drawn ? For example I would like to see a trend line on MACD or RSI, is this for a new indicator build from scratch ?


---

## Re: Volume Trend and Price Trend

**Apprentice** · Wed Aug 26, 2015 9:58 am

Your request is added to the development list.


---

## Re: Volume Trend and Price Trend

**Stance** · Sun Sep 27, 2015 4:30 pm

Hi,

Can a strategy be made for this to buy with the price trend is sloping up and confirmed by volume and sell with the price trend is sloping down and confirmed by volume.

Thankyou,


---

## Re: Volume Trend and Price Trend

**Apprentice** · Mon Sep 28, 2015 2:34 am

By confirmed, you mean up slope, for volume.


---

## Re: Volume Trend and Price Trend

**Stance** · Mon Sep 28, 2015 3:35 am

Price line slope up, horizontal volume line (slope2 in the code) turns green to confirm a BUY.

A reverse for a sell.


---

## Re: Volume Trend and Price Trend

**Apprentice** · Wed Sep 30, 2015 3:54 am

Your request is added to the development list.


---

## Re: Volume Trend and Price Trend

**gezisLV** · Sun Oct 25, 2015 10:29 am

Hi,can you create volume trend indicator like stairway indicator so we could choose start and end point? for example to see how was the volume on previous price movements


---

## Re: Volume Trend and Price Trend

**Apprentice** · Tue Oct 27, 2015 3:41 am

How we will define the area of our interest?
N periods back from current period?


---

## Re: Volume Trend and Price Trend

**gezisLV** · Tue Oct 27, 2015 8:15 am

like here [viewtopic.php?f=17&t=61593&p=97705&hilit=stairway#p97705](https://fxcodebase.com/code/viewtopic.php?f=17&t=61593&p=97705&hilit=stairway#p97705)
by defining start and end point


---

## Re: Volume Trend and Price Trend

**Apprentice** · Thu Oct 29, 2015 5:30 am

Try this version.
[viewtopic.php?f=17&t=62838](https://fxcodebase.com/code/viewtopic.php?f=17&t=62838)


---

## Re: Volume Trend and Price Trend

**Apprentice** · Mon Feb 05, 2018 10:08 am

The indicator was revised and updated.
