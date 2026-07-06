# Magic Trend Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=6681  
> Forum: 31 · Topic 6681 · 16 post(s)


---

## Magic Trend Strategy

**Apprentice** · Wed Sep 21, 2011 3:55 am

![Magic Trend Strategy.png](images/15210/Magic%20Trend%20Strategy.png)



This is a simple implementation Magic trend strategy.

Version 1
Long
On Price / Trend Magic Crossover
Short
On Price / Magic Ttrend Crossunder

 [Magic Trend Strategy.lua](files/15210/Magic%20Trend%20Strategy.lua)

Version 2

Green
Open Long Position
Red
Open Short Position

 [Magic Trend Strategy.lua](files/15210/Magic%20Trend%20Strategy%20%282%29.lua)

The strategy requires the Trend magic indicator which can be found in this topic:
[viewtopic.php?f=17&t=3144&start=0&hilit=magic+trend](https://fxcodebase.com/code/viewtopic.php?f=17&t=3144&start=0&hilit=magic+trend)


---

## Re: Magic Trend

**69zl1l88** · Fri Oct 14, 2011 2:55 pm

When I try to load this strategy I get an error:
[string "Magic Trend Strategy.lua"]:106: Please, download and install MAGIC TREND.lua indicator.
I'm guessing there's something else I need but don't see where to get it. I would appreciate a little help please....and thank you!


---

## Re: Magic Trend

**sunshine** · Fri Oct 14, 2011 11:53 pm

Please download and install the trend magic indicator to be able to run the strategy:
[viewtopic.php?f=17&t=3144&start=0&hilit=magic+trend](https://fxcodebase.com/code/viewtopic.php?f=17&t=3144&start=0&hilit=magic+trend)


---

## Re: Magic Trend

**filoo7** · Mon Sep 02, 2013 9:16 am

Hi apprentice,

very interesting this indicator! but when the color changes the trade is not closed ...

possible to alternate open/close when the color changes?

thank's


---

## Re: Magic Trend

**Apprentice** · Tue Sep 03, 2013 2:01 am

It was not planned, it is possible to implement this as a option.


---

## Re: Magic Trend

**Apprentice** · Tue Sep 03, 2013 5:48 am

Just to be sure.
For Your algororitam, price action is not relevant.
Only Magic Trend Indicator Color change is.
Long on Green,
Short on Red


---

## Re: Magic Trend

**filoo7** · Thu Sep 05, 2013 7:07 am

exactly,

alternate open / close when the color change

red:
close long open short
green:
close short/open long

like this


---

## Re: Magic Trend

**Apprentice** · Fri Sep 06, 2013 3:50 am

Your request is added to the development list.


---

## Re: Magic Trend

**Apprentice** · Fri Sep 06, 2013 6:37 am

Please redownload and reinstall the Magic Trend indicator,
and then try the second version of strategy.


---

## Re: Magic Trend Strategy

**filoo7** · Wed Sep 11, 2013 2:26 am

good work! thank's


---

## Re: Magic Trend Strategy

**jamrocktrader** · Mon Sep 28, 2015 9:42 am

Hey Apprentice,

Could you add the 10 minute timeframe (m10) to Version 2 of the strategy.

Thank you


---

## Re: Magic Trend Strategy

**Apprentice** · Wed Sep 30, 2015 7:49 am

[Magic Trend Strategy.lua](files/102617/Magic%20Trend%20Strategy.lua)

Try this version.
Dropdown menu is not available.
You have to enter m10 yourself.


---

## Re: Magic Trend Strategy

**jamrocktrader** · Mon Oct 26, 2015 9:46 am

Hi Apprentice,

Is it possible to add an alert to version 2 of the Magic Trend Strategy that gives an alarm whenever the line is not horizontal.

Thanks very much for your work


---

## Re: Magic Trend Strategy

**Apprentice** · Tue Oct 27, 2015 4:26 am

Your request is added to the development list.


---

## Re: Magic Trend Strategy

**jamrocktrader** · Wed Dec 02, 2015 3:25 pm

Hi Apprentice,

The strategy does not execute trades in sync with the indicator. I tested it on standard timeframe and m10 timeframe. Could you adjust the strategy so trades are executed only when the indicator cross. Also, there are times when the account window closes after a trade is executed. Lastly, could you add a 'live/end' of turn option.

Thank you very much for your work
Jamrocktrader


---

## Re: Magic Trend Strategy

**Apprentice** · Mon Jan 29, 2018 7:07 am

The strategy was revised and updated.
