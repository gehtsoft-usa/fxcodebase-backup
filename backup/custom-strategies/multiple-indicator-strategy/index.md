# Multiple Indicator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63107  
> Forum: 31 · Topic 63107 · 2 post(s)


---

## Multiple Indicator Strategy

**Apprentice** · Thu Feb 04, 2016 6:05 am

![EURUSD H1 (02-04-2016 1129).png](images/104609/EURUSD%20H1%20%2802-04-2016%201129%29.png)



Based on request.
[viewtopic.php?f=27&t=63083](https://fxcodebase.com/code/viewtopic.php?f=27&t=63083)

To Short the FX pair:

ALL of the following conditions must be met:

WILLIAMSR% >= -5
AND
STOCHRSI 14 = 100
AND
STOCHRSI 3 => 95
AND
AROON14HIGH >= 100
AND
AROON14LOW < 50
AND
STOCHFULL >= 65
AND
STOCHFAST 14 >= 90
AND
STOCHFAST 3 >=90
AND
BOLLINGER BAND WIDTH >= 0.0050

When Entering Market:
Limit = EntryPrice – (BOLLINGER BAND WIDTH * 1.25)
StopLoss = EntryPrice + (BOLLINGER BAND WIDTH * 0.75)

To Long the FX pair:

ALL of the following conditions must be met:

WILLIAMSR% <= -95
AND
STOCHRSI 14 = 0
AND
STOCHRSI 3 <= 10
AND
AROON14HIGH <= 50
AND
AROON14LOW = 100
AND
STOCHFULL <= 35
AND
STOCHFAST 14 <= 10
AND
STOCHFAST 3 <=10
AND
BOLLINGER BAND WIDTH >= 0.0050

When Entering Market:
Limit = EntryPrice + (BOLLINGER BAND WIDTH * 1.25)
StopLoss = EntryPrice - (BOLLINGER BAND WIDTH * 0.75)

 [Multiple Indicator Strategy.lua](files/104609/Multiple%20Indicator%20Strategy.lua)

Stochastic RSI can be found here.
[viewtopic.php?f=17&t=451&hilit=StochRSI](https://fxcodebase.com/code/viewtopic.php?f=17&t=451&hilit=StochRSI)
BB-Bandwidth can be found here.
[viewtopic.php?f=17&t=237&p=339#p339](https://fxcodebase.com/code/viewtopic.php?f=17&t=237&p=339#p339)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Multiple Indicator Strategy

**Apprentice** · Wed Dec 14, 2016 7:19 am

Strategy was revised and updated.
