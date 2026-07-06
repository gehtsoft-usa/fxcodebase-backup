# Quantitative Return Oscillator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63670  
> Forum: 31 · Topic 63670 · 15 post(s)


---

## Quantitative Return Oscillator Strategy

**Apprentice** · Fri Jul 15, 2016 8:28 am

![EURUSD H1 (07-15-2016 1453).png](images/107142/EURUSD%20H1%20%2807-15-2016%201453%29.png)



Based on/ Install Quantitative Return Oscillator.lua
[viewtopic.php?f=17&t=63240&p=107136&hilit=Quantitative+Return+Oscillator#p107136](https://fxcodebase.com/code/viewtopic.php?f=17&t=63240&p=107136&hilit=Quantitative+Return+Oscillator#p107136)
Open Long
Buy Level Cross
Open Short
Sell Level Cross

 [Quantitative Return Oscillator Strategy.lua](files/107142/Quantitative%20Return%20Oscillator%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Fri Jul 15, 2016 10:07 am

It returns an error message,

it's possible change strategy with the following options:

sell -> touch +50 (quantitative returns oscillator data source high) = 10000 * natural log (high / high (n previous))
buy -> touch -50 (quantitative returns oscillator data source low) 10000 * natural log (low / low (n previous))

thank you!!

sorry for my english

Alessandro


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Fri Jul 15, 2016 11:28 am

Can you specify error message.


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Fri Jul 15, 2016 3:09 pm

this is the error message
C:\Program Files (x86)\Candleworks\FXTS2\strategies\Custom/Quantitative Return Oscillator strategy.lua:289: C:\Program Files (x86)\Candleworks\FXTS2\strategies\Custom/Quantitative Return Oscillator.lua (71,-1) : E19 - Specified index is out of range


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Sat Jul 16, 2016 11:28 am

Please re-downlod Quantitative Return Oscillator.
I have made minor changes to Indicator.
This should fix things.


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Sun Jul 17, 2016 12:50 pm

This is my indicators, with 3 parameter in to one view -->
White = close
Green = low
red = high
with line level important for me.[https://1drv.ms/i/s!AhVp3M_1Q4UaicRf10zEZUs1__okeA](https://1drv.ms/i/s!AhVp3M_1Q4UaicRf10zEZUs1__okeA)]

it is possibile create this indicator for marketscope? and create strategy or signal when cross under and over level?

Thank you very much!


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Sun Jul 17, 2016 1:27 pm

Can you define the entry / exit rules.


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Sun Jul 17, 2016 3:00 pm

Entry long when oscillator LOW ( 10000* LN(LOW/LOW(n) ) cross under the level - x
Stop loss variable in pips and take profit variable in pips

Entry short when oscillator HIGH ( 10000* LN(HIGH/HIGH(n) ) cross over the level + x
Stop loss variable in pips and take profit variable in pips

Or entry long oscillator low cross under -x and exit oscillator high cross over +x

And entry short oscillator high cross over +x and exit oscillator low cross under -x

Thank you!


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Sun Jul 17, 2016 3:13 pm

When the position is profit of X pips --> stop loss break even --> traling stop dinamic or take profit --> close position

Thanks


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Mon Jul 18, 2016 5:47 am

Your request is added to the development list,
Under Bugzilla Id Number 3571

Bugzilla is developer internal requests database.
If someone is interested to do any task from this list please contact me.


---

## Re: Quantitative Return Oscillator Strategy

**Mattia** · Mon Jul 18, 2016 8:09 am

To me it does not work the strategy and backtest.
The system gives me an error.

Mattia


---

## Re: Quantitative Return Oscillator Strategy

**ale91veyron** · Thu Jul 21, 2016 5:39 am

need change parameters entry --> entry long only when oscillator (low) cross under -50 (or other) and not entry if cross over -50 (or other).

while

entry short only when oscillator (high) cross over +50 (or other) and not entry if cross under +50 (or other)

the strategy has need two parameter, now entry long and short on close (10000* LN(close1/close2)),

--> then entry long when cross over -50 and entry short when cross under +50 <-- NO!

Alessandro


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Mon Aug 08, 2016 6:31 am

Mattia Install Quantitative Return Oscillator.lua


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Mon Aug 08, 2016 6:32 am

Your request is added to the development list, Under Id Number 3593
 If someone is interested to do this or any task other from list please contact me.


---

## Re: Quantitative Return Oscillator Strategy

**Apprentice** · Sat Dec 17, 2016 8:00 am

Strategy was revised and updated.
