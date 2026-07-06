# Trading Day Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62804  
> Forum: 17 · Topic 62804 · 13 post(s)


---

## Trading Day Moving Average

**Apprentice** · Thu Oct 22, 2015 5:25 am

![Trading Day Moving Average.png](images/102963/Trading%20Day%20Moving%20Average.png)



Based on request
[viewtopic.php?f=27&t=62790&p=102964#p102964](https://fxcodebase.com/code/viewtopic.php?f=27&t=62790&p=102964#p102964)
Will Provide MVA timed restart
Example.
H1 is used.
We are in the 11 to 24 hours.
MA = (Close1+ Close2 + ... + Close11) / 11

 [Trading Day Moving Average.lua](files/102963/Trading%20Day%20Moving%20Average.lua)

Indicator-based strategy.
[viewtopic.php?f=31&t=67395](https://fxcodebase.com/code/viewtopic.php?f=31&t=67395)


---

## Period Moving Average.lua

**Apprentice** · Thu Oct 22, 2015 5:50 am

![Period Moving Average.png](images/102968/Period%20Moving%20Average.png)



Example.
If H1 base unit is used.
Period is 24
Chart Time Frame is H1
MA = (Close1+ Close2 + ... + Close 24) / 24

Chart Time Frame is m30
MA = (Close1 +Close2 + ... + Close 48) / 48

 [Period Moving Average.lua](files/102968/Period%20Moving%20Average.lua)


---

## Re: Trading Day Moving Average

**SteveCee** · Mon Nov 09, 2015 4:15 pm

Dear Sirs. is it possible to turn on the High Low in the mva options . Great indicator.


---

## Re: Trading Day Moving Average

**Apprentice** · Tue Nov 10, 2015 12:41 pm

Unfortunately no.
At least until the next TS update.


---

## Re: Trading Day Moving Average

**cnikitopoulos94** · Wed Nov 18, 2015 2:48 am

do you know when this next TS update is coming out apprentice?


---

## Re: Trading Day Moving Average

**Julia CJ** · Tue Nov 24, 2015 6:33 am

Hi Cnikitopoulos94,

The nearest updating of TS will be in about two weeks.


---

## Re: Trading Day Moving Average

**Apprentice** · Thu Aug 04, 2016 12:13 pm

Minor Update.


---

## Re: Trading Day Moving Average

**trdheat** · Thu Apr 27, 2017 8:25 pm

Apprentice,

I'm confused. Lets talk about Period Moving Average, because of is generalised Trading Day Moving Average in sense of parameters.

Why the values of indicator in chart screen are different from those in table screen? Can you fix it? I want the values of chart screen (i mean the values of line of indicator) in table screen.

Other question...is it repaint or not?


---

## Re: Trading Day Moving Average

**trdheat** · Mon May 22, 2017 6:56 am

Apprentice,

Any news about my last post? Your answer is important!


---

## Re: Trading Day Moving Average

**trdheat** · Sun Jan 20, 2019 1:22 pm

Dear Apprentice, i have a question.

I have Chart Time Frame H1 and Period Moving Average with parameters:
H8 base unit is used
Period 3

This setup repaint or not in Chart Time Frame H1?

I'll wait your answer. It is crucial for me to know.
Thank you.


---

## Re: Trading Day Moving Average

**Apprentice** · Mon Jan 21, 2019 8:43 am

Yes, it will.
As you use a higher time frame, it will for higher time frame duration.


---

## Re: Trading Day Moving Average

**AEKARAOLE** · Thu Feb 28, 2019 4:14 am

Hi apprentice,

Will you be able to build a strategy with indicator Trading Day Moving Average as follows:

If EMA cross above the Trading Day Moving Average, to open a buy trade and if it cross down the Trading Day Moving Average, to open a sale trade.

request of opening multi positions at the same time with different lot sizes, stops & limits for this strategy.

parameters should be included:

Open trade 1: Yes/No
Trade 1: lot size
Set Limit for Trade 1: Yes/No’
Limit for Trade1, in pips 30
Set Stop for Trade 1 ‘Yes/No’
Stop for Trade 1: 30
Trailing Stop order for Trade 1: ‘Yes/No’
Trailing for Trade 1, in pips: 10
Breakeaven for Trade 1: ‘Yes/No’
Min Profit for Trade1: 10

The Trade 1 Logic will be repeated for the total of 5 positions.

Thank you


---

## Re: Trading Day Moving Average

**Apprentice** · Thu Feb 28, 2019 6:09 am

Try this version.
[viewtopic.php?f=31&t=67395](https://fxcodebase.com/code/viewtopic.php?f=31&t=67395)
