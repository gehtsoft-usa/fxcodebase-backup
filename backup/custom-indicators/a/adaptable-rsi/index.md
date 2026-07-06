# Adaptable RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=9358  
> Forum: 17 · Topic 9358 · 4 post(s)


---

## Adaptable RSI

**Apprentice** · Sat Dec 10, 2011 9:15 am

![Adaptable RSI.png](images/20209/Adaptable%20RSI.png)



This RSI indicator allows you to select, Averaging method for raw data.

diff = source[period] - source[period - 1]

if diff > 0 then
 Average Gain = diff;
else
 Average Loss = -diff;
end

RS = Average Gain / Average Loss

RSI = 100 - (100 / ( 1 + RS))

 [Adaptable RSI.lua](files/20209/Adaptable%20RSI.lua)

The indicator was revised and updated


---

## Re: Adaptable RSI

**zmender** · Tue Mar 06, 2012 9:22 pm

Apprentice, I played with your Adaptable RSI indicator and came up with this: LBR RSI, it is the Mometum Pinball of Linda Raschke's book Street Smarts.

Plot a 3-period RSI of a 1 period ROC. However the default ROC indicator has a minimum period of 2, so that's what I use below.


---

## Re: Adaptable RSI

**Alexander.Gettinger** · Tue Nov 18, 2014 5:13 pm

MQL4 version of Adaptable RSI oscillator: [viewtopic.php?f=38&t=61478](https://fxcodebase.com/code/viewtopic.php?f=38&t=61478).


---

## Re: Adaptable RSI

**Apprentice** · Wed Jun 28, 2017 5:19 am

The indicator was revised and updated.
