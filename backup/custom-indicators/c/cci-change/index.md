# CCI Change

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63019  
> Forum: 17 · Topic 63019 · 6 post(s)


---

## CCI Change

**Apprentice** · Fri Jan 08, 2016 6:56 am

![CCI Change.png](images/104175/CCI%20Change.png)



Based on request.
[viewtopic.php?f=27&t=62875#p103317](https://fxcodebase.com/code/viewtopic.php?f=27&t=62875#p103317)

Indicator will give Color / Audio / Email / PopUp notification.
If CCI changes for current period is greater than specified.

 [CCI Change.lua](files/104175/CCI%20Change.lua)


---

## Re: CCI Change

**7510109079** · Fri Jan 08, 2016 9:46 am

excellent. Many thx


---

## Re: CCI Change

**7510109079** · Tue Mar 15, 2016 7:43 am

Hi Apprentice, may i ask for an enhancement to help visually gauge scalping profitabilities:

Can the user specify a 'look forward' time period value.

this value will be used to check a number of chart periods ahead to see if the initial CCI change/momentum has managed to keep price moving in the same direction for a profit.

Variables and logic:

Xt = time of signal
Xp = price at time of signal
Xn = no. of time periods forward to look from Xt
Yp = price at Xt+Xn

For an initial negative CCI change signal (red bar)
 If Yp<Xp place a coloured dot (representing a profit) on the centre of the original red signal bar
 If Yp>Xp place a coloured dot (representing a loss) on the centre of the original red signal bar

For an initial positive CCI change signal (green bar)
 If Yp>Xp place a coloured dot (representing a profit) on the centre of the original green signal bar
 If Yp<Xp place a coloured dot (representing a loss) on the centre of the original green signal bar

This way at a glance i will be able to see which signals are profitable or not for any given look forward period.

Obviously there are no predictive qualities here. It is the historic performance of this indicator is what is useful as a guide to future profitability

thx in advance


---

## Re: CCI Change

**Apprentice** · Wed Mar 16, 2016 6:09 am

Try my implementation.


---

## Re: CCI Change

**7510109079** · Fri Mar 18, 2016 12:21 pm

many thx


---

## Re: CCI Change

**Apprentice** · Fri Oct 19, 2018 4:29 am

The indicator was revised and updated.
