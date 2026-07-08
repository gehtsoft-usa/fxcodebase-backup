# Trend Risk Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61007  
> Forum: 17 · Topic 61007 · 15 post(s)

---

## Trend Risk Indicator

**Apprentice** · Fri Aug 01, 2014 4:13 am

![Trend Risk Indicator.png](images/95243/Trend%20Risk%20Indicator.png)

T3Trend Bands Indicator Spin-off
[viewtopic.php?f=17&t=3128&p=7347&hilit=t3+trendbands#p7347](https://fxcodebase.com/code/viewtopic.php?f=17&t=3128&p=7347&hilit=t3+trendbands#p7347)
Based on request
[viewtopic.php?f=27&t=60979](https://fxcodebase.com/code/viewtopic.php?f=27&t=60979)

Will indicate N consecutive closing Over Top line
Under The Bottom Line or Within channel.

 [TrendRisk indicator.lua](files/95243/TrendRisk%20indicator.lua)

The indicator was revised and updated

---

## Re: Trend Risk Indicator

**Fx4mt.com** · Sun Aug 03, 2014 11:06 am

Thanks a bunch Apprentice!! Excellent work. I really, really appreciate it!

I made a couple minor tweaks to get it set up most like the actual TrendRisk indicator. I will attach for those that are interested.

TrendRisk = count of bars 12
Deviation 1.8

Thanks a bunch!!

---

## Re: Trend Risk Indicator

**Fx4mt.com** · Tue Aug 12, 2014 7:04 pm

Would it be possible to have a candlestick wick color option? For example, top side wick red, bottom side wick green? This referring to wicks only, not the actual candle. Is this possible?

Thanks a bunch

---

## Re: Trend Risk Indicator

**Apprentice** · Wed Aug 13, 2014 6:13 am

You can simply paint the entire candle.
open:setColor(period, Color);

Dyeing of wicks is possible.
But it is a bit tricky and advanced programming requirements.
U can draw two vertical lines.
First from math.max (open,close) to High
Second From math.min (open,close) to Low

---

## Re: Trend Risk Indicator

**amine.dechemi** · Fri Aug 15, 2014 5:52 pm

Hello
can i have a formula please ;

---

## Re: Trend Risk Indicator

**Apprentice** · Wed Aug 20, 2014 1:16 pm

```lua
SmoothPrice[period]=(SmoothPrice[period-1]*(BandBars-1)+source.close[period])/BandBars;
    SmoothRange[period]=(SmoothRange[period-1]*(BandBars-1)+source.high[period]-source.low[period])/BandBars;
 
    Top[period]=SmoothPrice[period]+SmoothRange[period]*Deviation;
    Bottom[period]=SmoothPrice[period]-SmoothRange[period]*Deviation;

if source.close[i]< Top[i] then Color[i] = Up;
if source.close[i]> Bottom[i] then Color[i] = Down
else  Color = Neutral
```

This is a simplified version.
The complete algorithm is available within Indicator Code.

---

## Re: Trend Risk Indicator

**amine.dechemi** · Sat Aug 23, 2014 1:24 pm

very good
merci

---

## Re: Trend Risk Indicator

**Apprentice** · Thu Jan 15, 2015 6:41 am

Mq4 version is available here.
[viewtopic.php?f=38&t=61722](https://fxcodebase.com/code/viewtopic.php?f=38&t=61722)

---

## Re: Trend Risk Indicator

**Thumper** · Mon Jul 27, 2015 9:34 pm

Apprentice can you please create a third line for Trendrisk123 that is exactly between the two existing lines. Also can you make it that the user can choose a dotted line for this new middle line and have at the same time a full line for the top and bottom existing lines? Also the user can choose a different colour for each of the 3 lines. Thanks mate! Rob

---

## Re: Trend Risk Indicator

**Apprentice** · Wed Jul 19, 2017 8:37 am

The indicator was revised and updated.

---

## Re: Trend Risk Indicator

**dixonttk** · Sat Apr 04, 2020 12:06 am

Hi Apprentice, anyway I can get this Trend Risk Indicator code in TradingView PineScript version?

---

## Re: Trend Risk Indicator

**Apprentice** · Mon Apr 06, 2020 4:55 am

Your request is added to the development list.
Development reference 1012.

---

## Re: Trend Risk Indicator

**Apprentice** · Tue Apr 07, 2020 5:09 am

[TrendRisk_indicator.zip](files/132615/TrendRisk_indicator.zip)

Try this version.

---

## Re: Trend Risk Indicator

**JV2020** · Thu Apr 23, 2020 11:15 am

Hi Apprentice

We have used this your code in python earlier, but after we have changed to Go, the calculation on all 3 bands are way off. Which means that the change of trend happens too rapidly, as to what you would see in for instance trade interceptor.

Would it be possible to get a version from you in GO?

---

## Re: Trend Risk Indicator

**Apprentice** · Fri Apr 24, 2020 12:54 pm

Unfortunately no.
We need a constant flow of tasks to specialize in something.
