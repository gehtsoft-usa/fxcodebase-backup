# Constant Break Entry

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4926  
> Forum: 31 · Topic 4926 · 12 post(s)


---

## Constant Break Entry

**vstrelnikov** · Thu Jun 30, 2011 4:35 pm

The strategy just constantly creates 2 OCO entry orders above and below market with given Stop/Limit parameters.

 [ConstantBreakEntry.lua](files/12215/ConstantBreakEntry.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Constant Break Entry

**AMARTIAL** · Thu Jun 30, 2011 6:30 pm

Good work! thanks


---

## Re: Constant Break Entry

**ancient-school** · Mon Jul 04, 2011 2:45 am

Hi,

In Parameters "Trade Type" there are 2 Options:

1 - Against Trend
2 - Along with Trend

This I understand as follows, and please correct me if I am wrong ...

Assuming Market is going down "Against Trend" will Sell at the High of the Previous Period
------------------------------------ "Against Trend" will Buy at the Low of the Previous Period

Assuming Market is going down "Along with Trend" will Sell at the Low of the Previous Period
------------------------------------ "Along with Trend" will Buy at the High of the Previous Period

**Similarly**

Assuming Market is going up, "Against Trend" will Buy at the Low of the Previous Period
------------------------------------ "Against Trend" will Sell at the High of the Previous Period

Assuming Market is going up, "Along with Trend" will Buy at the High of the Previous Period
------------------------------------ "Along with Trend" will Sell at the Low of the Previous Period

If this is what this Strategy does, it would be helpful if the user could specify the preferred direction to trade ... i.e. Long Only, Short Only as follows:

**Long Only:** True / False
Against Trend: Yes / No
Along with Trend: Yes /No

**Short Only:** True / False
Against Trend: Yes / No
Along with Trend: Yes /No

**Further Option would be to Trade a Pivot Level of the Previous Period i.e.**

**Long Only:**True / False
On Cross Over
On Touch
Pivot Level: 50% or 20% or 80% etc...

**Short Only:**True / False
On Cross Under
On Touch
Pivot Level: 50% or 20% or 80% etc...

Also, by default the minimum default settings for "Above Distance" and "Below Distance" should be the Spread of the Instrument it is attached too, (Not sure if the Spread can be read from the quotes table and updated into the Strategy Parameters Field so as one can view when setting up parameters) + a setting for "X" greater than Spread as a permitted tolerance...

Regards
Ancient-School


---

## Re: Constant Break Entry

**mfoste1** · Fri Dec 02, 2011 12:28 pm

Hello,

Im wondering if someone could modify this to

"allow X number of OCO orders with a distance of X pips above and below the market"

add parameters
1. allowed number of positions
2. distance of orders (space in between orders) from market bid and ask

thanks


---

## Re: Constant Break Entry

**Apprentice** · Fri Dec 02, 2011 6:19 pm

Your request is added to the developmental cue.


---

## Re: Constant Break Entry

**irbica** · Mon Dec 05, 2011 7:22 am

Is there anyway this can be changed to generate only 1 OCO after closing of a position either via stop or limit, instead og generating 2 OCOs?


---

## Re: Constant Break Entry

**irbica** · Mon Dec 05, 2011 8:30 pm

Apprentice,

Can the ConstantBreakEntry be change to open only 1 OCO after the position closes (immediatly or at end of period)?

Also it will be beneficial to have an option to INCREASE Lot amounts by a multiplier every time a new OCO is ordered (let say x1.5 or x2) and a MAXIMUM amount of lots allowed.

Can this be modified to have this features? If so I would like to get it updated to include this features.


---

## Re: Constant Break Entry

**edioquino** · Thu Apr 28, 2016 7:45 pm

Good day,

Is it possible to add the feature were in the current position is close when the candle closes and another OCO opens when a new candle starts?

Thanks!

-Ed


---

## Re: Constant Break Entry

**Apprentice** · Sun May 01, 2016 9:07 am

Your request is added to the development list.


---

## Re: Constant Break Entry

**mechanicjon** · Sat Sep 10, 2016 11:32 am

Any updates or added features yet?


---

## Re: Constant Break Entry

**Apprentice** · Fri Sep 16, 2016 6:52 am

Minor update.


---

## Re: Constant Break Entry

**Apprentice** · Sat Dec 17, 2016 10:27 am

Strategy was revised and updated.
