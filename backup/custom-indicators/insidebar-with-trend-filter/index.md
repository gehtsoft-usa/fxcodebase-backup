# InsideBar with Trend Filter

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64575  
> Forum: 17 · Topic 64575 · 6 post(s)


---

## InsideBar with Trend Filter

**Apprentice** · Fri Apr 07, 2017 4:11 pm

![EURGBP m1 (04-07-2017 2117).png](images/111879/EURGBP%20m1%20%2804-07-2017%202117%29.png)



Based on the request.
[viewtopic.php?f=27&t=64573](https://fxcodebase.com/code/viewtopic.php?f=27&t=64573)

 [InsideBar with Trend Filter.lua](files/111879/InsideBar%20with%20Trend%20Filter.lua)

The indicator was revised and updated


---

## Re: InsideBar with Trend Filter

**baccicin** · Fri Apr 07, 2017 4:44 pm

Many thanks Apprentice, great job. Just a couple of implementations:
- is it possible customize the arrow size?
- **"the range of the current candles is < than 50% (customizable)"**... I mean the range is calculated for both, high/low as well as the body. if the range high low (yesterday) is for example 100, the range of the current candle must be more than 50%... i mean from 50,01 to 99.99 and the same must be for the body of the current calculated on the body of the yesterday candle. Customizable.
if the ratio is less than 50, the signal is invalidated
Many thanks for your great job as usual.
Ciao. Fab


---

## Re: InsideBar with Trend Filter

**Apprentice** · Mon Apr 10, 2017 7:13 am

Can you to write this in pseudo code.

HighLowRange [-1]
HighLowRange [0]

OpenCloseRange [-1]
OpenCloseRange [0]

and f ...> ... then
if ... <... then
and so on.

Or try to skype me on Thursday.


---

## Re: InsideBar with Trend Filter

**Apprentice** · Wed Apr 19, 2017 2:51 pm

Something like this.

HL range of the current is less than previous candle HL Range
OC range of the current is less than previous candle OC Range
Both ranges are greater than 50 percent of the previous candle ranges.

Can you confirm.


---

## Re: InsideBar with Trend Filter

**baccicin** · Wed Apr 19, 2017 3:11 pm

Ciao, exactly, and less than 99,999% as per inside bar definition.
The ratio, 50-99.999 should be customizable.
Conditions for Ema34 remain the same.
Many thanks, ciao, have a nice evening.
Fabio


---

## Re: InsideBar with Trend Filter

**Apprentice** · Wed Apr 19, 2017 3:50 pm

Try this version.
