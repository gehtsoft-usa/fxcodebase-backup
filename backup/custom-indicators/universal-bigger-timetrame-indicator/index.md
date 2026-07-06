# Universal bigger timetrame indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=4048  
> Forum: 17 · Topic 4048 · 4 post(s)


---

## Universal bigger timetrame indicator

**Alexander.Gettinger** · Wed Apr 27, 2011 10:42 pm

This indicator may draw any indicator or oscillator for bigger timeframe than current.
You choose indicator, timeframe and price type (for indicator with tick source).

Download indicator version:

 [BF_Indicator.lua](files/10131/BF_Indicator.lua)

Download oscillator version:

 [BF_Oscillator.lua](files/10131/BF_Oscillator.lua)

The indicator was revised and updated


---

## Re: Universal bigger timetrame indicator

**Nikolay.Gekht** · Thu Apr 28, 2011 10:13 am

2 all: Please note that this implementation won't work with the indicators which re-calculates historical values. And there is no reason to implement the indicator to support re-calculating indicator because of serious performance harm. BTW, we are developing bigger frame solution for upcoming Marketscope release, so this solution must be good enough until the common solution is provided in Marketscope.

2 author:
1) Since Jan 2011 release there is core.findDate function, which works bit faster than findDateFast function. Please replace.

2) You can use core.FLAG_ONLYINDICATORS or core.FLAG_ONLYOSCILLATORS flags instead of core.FLAG_INDICATOR to let the user choose only indicator in bf_indicator and only oscillators in bf_oscillator

3) You can let the Marketscope manage the source of the indicator depending on the indicator chosen by the user. Just add the following tag:
indicator:setTag("RequiredSourceParam", "IN");
where "IN" is the name of the parameter to choose the indicator (oscillator)


---

## Re: Universal bigger timetrame indicator

**Alexander.Gettinger** · Fri Apr 29, 2011 2:30 am

Indicators updated.


---

## Re: Universal bigger timetrame indicator

**Apprentice** · Wed Mar 08, 2017 5:26 pm

Indicator was revised and updated.
