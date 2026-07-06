# Zero Lag Indicator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63350  
> Forum: 31 · Topic 63350 · 10 post(s)


---

## Zero Lag Indicator Strategy

**Apprentice** · Wed Apr 06, 2016 1:35 pm

![EURUSD H1 (04-06-2016 2001).png](images/105679/EURUSD%20H1%20%2804-06-2016%202001%29.png)



When color change from green to red : close BUY position and open SELL position
When color change from Red to Green : close SELL position and open BUY position

 [Zero Lag Indicator Strategy.lua](files/105679/Zero%20Lag%20Indicator%20Strategy.lua)

Based on Zero Lag Indicator.lua
[viewtopic.php?f=17&t=2511](https://fxcodebase.com/code/viewtopic.php?f=17&t=2511)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Thu Apr 07, 2016 12:08 am

hi Apprentice,

Great stategy, thanks a lot....

Bst Rgds,
Letigre30


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Thu Apr 07, 2016 3:53 am

Hi Apprentice,

This strategy has been set today at 07:30 am, but no orders entered

see chart below

 

![Error 2 zerolag strategy.png](images/105686/Error%202%20zerolag%20strategy.png)

*no position is entered*


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Thu Apr 07, 2016 3:58 am

Sorry I forget to show strategy parameters which are used

 

![ZERO LAG STRATEGY Parameters.png](images/105687/ZERO%20LAG%20STRATEGY%20Parameters.png)


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Sat Apr 09, 2016 5:42 am

Hi Apprentice,

I Check again this strategy today Saturday April 9th with the SDK...
Always the same issue, it doesn't take positions.

I take a look at the code of the strategy for the triggers to enter an order BUY or SELL,
the lines 283 and 291 are :
283 if Indicator.DATA:colorI(period) == core.rgb(0, 255, 0) and Indicator.DATA:colorI(period-1) ~= core.rgb(0, 255, 0) then
....

291 elseif Indicator.DATA:colorI(period) == core.rgb(255, 0, 0) and Indicator.DATA:colorI(period-1) ~= core.rgb(255, 0, 0) then
...

Also, I look at the indicator, the method "colorI" is not existing in the code

I try to replace "colorI" by the streams ZL and DN which are declared in the indicator,
but the SDK sends an error when the test is launched

ERROR " attempt to call method 'ZL' (a nil value)" in file "C:/Gehtsoft/IndicoreSDK3.1.0/strategies/Custom/Zero Lag Indicator Strategy.lua" at line #283

can you help ?

Thanks for replying


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Sun Apr 10, 2016 12:43 am

Following my last posts about the non behavior of this strategy with SDK 3.1.0

I've searched where the error could be intervene
and I check all indicators and strategy with SDK 2.3.1

When Checking the strategy, I got at each tick from Quote Manager this error :

...K2/strategies/Custom/Zero Lag Indicator Strategy.lua:278: ...icoreSDK2/indicators/standard/ZERO LAG INDICATOR.lua:72: C:/Gehtsoft/IndicoreSDK2/indicators/standard/ema.lua:67: attempt to perform arithmetic on local 'sourcePeriod' (a nil value)

The codes of different lines in the error messages are :

**Zero Lag Indicator Strategy line 278** : Indicator:update(core.UpdateLast);

**ZERO LAG INDICATOR line 72** : EMAI:update(mode); //(1st line of the function update)

**ema.lua : line 67** : internal[period] = (1 - k) * value + k * sourcePeriod;

When I check the ema indicator with the SDK 2.3.1 debbuger : **no errors**

When I check the ZERO LAG INDICATOR with the SDK 2.3.1 debbuger : **an error appears (in Output tab):**

**The object does not exist (C:\Gehtsoft\IndicoreSDK2\indicators\standard\standard)**

The indicators are located in the folder
C:\Gehtsoft\IndicoreSDK2\indicators\standard

The strategiesare located in the folder
C:\Gehtsoft\IndicoreSDK2\strategies\custom

those folders are well indicated in the "Preferences" of the luaeditor of SDK 2.3.1

Thanks for help


---

## Re: Zero Lag Indicator Strategy

**Apprentice** · Sun Apr 10, 2016 5:21 am

I can not vouch for modified indicator version.

Indicator.DATA:colorI(period) will return indicator stream color, for a given period.

> ZERO LAG INDICATOR line 72 : EMAI:update(mode); //(1st line of the function update)

On line 72 you'll find

Code: [Select all](https://fxcodebase.com/code/)
`local err = source[period] - ZL[period - 1]`
Do you use the right Indicator version?


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Sun Apr 10, 2016 7:19 am

Hi Apprentice,

Yes of course, the versions come from forum


---

## Re: Zero Lag Indicator Strategy

**LeTigre30** · Mon Apr 11, 2016 4:48 am

hi, I've downloaded the version here

[url]viewtopic.php?f=17&t=2511#p5534[/url]

It seems OK now, I will try to check with SDK 3.1.0 and send feedback

Bst Rgds


---

## Re: Zero Lag Indicator Strategy

**Apprentice** · Fri Dec 16, 2016 6:06 am

Strategy was revised and updated.
