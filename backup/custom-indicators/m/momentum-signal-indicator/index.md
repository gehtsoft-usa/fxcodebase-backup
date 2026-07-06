# Momentum Signal Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=4303  
> Forum: 17 · Topic 4303 · 7 post(s)


---

## Momentum Signal Indicator

**Apprentice** · Tue May 17, 2011 5:20 am

![Momentum Signal.png](images/10732/Momentum%20Signal.png)



Calculation
Signal = (MOMENTUM/ ATR + iADX) - SubtractFromSignal;
Momentum = ((ATR + CCI + RSI) /ADX) - SubtractFromIndicator;

 [Momentum Signal.lua](files/10732/Momentum%20Signal.lua)

Installation of Momemtum indicators is required.
[viewtopic.php?f=17&t=896&p=1638&hilit=momentum#p1638](https://fxcodebase.com/code/viewtopic.php?f=17&t=896&p=1638&hilit=momentum#p1638)

Elmcceen
Before I start writing signal.
Can you describe how this indicator is used.

Indicator-based strategy.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=74034](https://fxcodebase.com/code/viewtopic.php?f=31&t=74034)


---

## Re: Momentum Signal Indicator

**elmcceen** · Tue May 17, 2011 3:01 pm

Most usefull in lower timeframes. Start trading when green line crosses the red line!
I think in this picture you use very high timeframe. i will show you one screen from mt4 station.

Entry to the direction if red line crosses the blue one! Using RSI can filter some signals.

Can you create at first an indicator which shows the two lines like in example picture havin the signals on the chart? Signal/strategy can be create after testing it with rsi filter an so on...


---

## Re: Momentum Signal Indicator

**elmcceen** · Tue May 17, 2011 3:06 pm

Wanna let show the signals on chart but telling me that some indicator is missing! What to do?


---

## Re: Momentum Signal Indicator

**Apprentice** · Wed May 18, 2011 3:41 am

Installation of Momemtum indicators is required.
You can you can find it here.
[viewtopic.php?f=17&t=896&p=1638&hilit=momentum#p1638](https://fxcodebase.com/code/viewtopic.php?f=17&t=896&p=1638&hilit=momentum#p1638)


---

## Re: Momentum Signal Indicator

**Apprentice** · Wed May 18, 2011 3:44 am

To Elmcceen
Signals on the chart?
Which type of signal you are talking about.
I Can add arrows or circles on main chart

As for the indicators.
The indicator has been written.


---

## Re: Momentum Signal Indicator

**Alexander.Gettinger** · Fri Nov 21, 2014 5:18 pm

MQL4 version of Momentum Signal indicator: [viewtopic.php?f=38&t=61521](https://fxcodebase.com/code/viewtopic.php?f=38&t=61521).


---

## Re: Momentum Signal Indicator

**Apprentice** · Sun Oct 07, 2018 8:55 am

The indicator was revised and updated.
