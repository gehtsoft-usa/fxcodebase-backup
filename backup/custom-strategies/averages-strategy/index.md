# Averages Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3859  
> Forum: 31 · Topic 3859 · 26 post(s)


---

## Averages Strategy

**Apprentice** · Thu Apr 07, 2011 5:37 am

![Averages Strategy.png](images/9454/Averages%20Strategy.png)



The strategy supports two types of signals.
Slope-Change Trend
Cross - Price / MA Cross

 [Averages Strategy.lua](files/9454/Averages%20Strategy.lua)

To work, you must install AVEREGES Indikcator.
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Averages Strategy

**davetherave110179** · Fri Apr 15, 2011 5:03 am

Apprentice,

I would like to request that a 'HPF Smoothing' parameter be added to this great stratagy. I know that stratagies CANNOT add datasources, but they can use another indicator as a smoothing option should not be a problem. I hope.

Nikolay is working on the 'AVERAGES (with HPF Smoothing)' indicator for me so with any luck, i'll have both the stratagy and indicator fairly soon.

Many thanks and Happy Easter to everyone!
davetherave110179


---

## Re: Averages Strategy

**Apprentice** · Fri Apr 15, 2011 6:36 am

When and if, Nikolay complete its work only then can rewrite strategy.
The reason, Averages indicator is used by the strategy.


---

## Re: Averages Strategy

**PipGrabber** · Wed Sep 28, 2011 11:31 am

Does this work? I did used the averages indicator then this strategy. It doesn't trade in backtesting even its set to. May it be slope or that MA/Cross. Equity remains flat,not trading.

Also, what's that "allow multiple" parameter for? thanks


---

## Re: Averages Strategy

**Apprentice** · Wed Sep 28, 2011 1:41 pm

First. Have you set Allow strategy to trade to Yes?
Second. If you set Allow Multiple to Yes.
Then you let strategy to open more than one position in the same direction.
This option is supported by a template that I use.
It is not always supported by stretegy algorithm.


---

## Re: Averages Strategy

**PipGrabber** · Wed Sep 28, 2011 8:26 pm

> **Apprentice wrote:**
> First. Have you set Allow strategy to trade to Yes?
> Second. If you set Allow Multiple to Yes.
> Then you let strategy to open more than one position in the same direction.
> This option is supported by a template that I use.
> It is not always supported by stretegy algorithm.

Hi Apprentice, yes I did. But the strategy is not trading. I downloaded the average indicator and strategy elsewhere. Maybe that's the reason, but I saw them on the customs folder already after it has been loaded. Its still not trading even if I remove and add up again the average strategy.

Ah ok. No, who wants multiple position on the same direction. Allow multiple is set to NO.


---

## Re: Averages Strategy

**Supes05** · Wed Dec 28, 2011 4:43 am

Hi Apprentice. Love the Averages strategy! Is there any way to add a higher timeframe to work as a filter. Or maybe have the chart set on one timeframe, and the strategy set on a different. When the strategy tries to initiate a trade, it checks with the chart first? I have been doing this manually and have had great success. If I could just get it to trade that way automatically would be perfect. Hope this is do-able!


---

## Re: Averages Strategy

**Apprentice** · Wed Dec 28, 2011 5:34 am

Basically, you need confirmation signals from the two time frames.
Up / Down Slope on Both or Cross in the same direction on both.


---

## Re: Averages Strategy

**kgsmith69** · Mon Jan 30, 2012 1:52 am

Can someone please explain this "[peroid]"

if indicator.DATA[period]> indicator.DATA[period-1] and indicator.DATA[period-2]> indicator.DATA[period-1]

Which one is the current bar, previous bar ...etc

Thanks


---

## Re: Averages Strategy

**Hug Coder** · Mon Jan 30, 2012 6:54 am

period == current period (basically current candle) from the source that called ExUpdate function.

if indicator.DATA[period]> indicator.DATA[period-1] and indicator.DATA[period-2]> indicator.DATA[period-1]
==
if currentAverage > previousAverage and previouspreviousAverage > previousAverage.

What this means is basically that it looks for a reversal a reverse-"^" pattern in the average. A bull pattern.


---

## Re: Averages Strategy

**kgsmith69** · Mon Jan 30, 2012 9:58 am

Thanks Hug Coder,

Thats exactley what I needed to know.


---

## Re: Averages Strategy

**aricanderson** · Fri Mar 30, 2012 11:02 am

hello apprentice.

I have successfully loading this strategy and backtested it although all of my buy and sell trades are coming out backwards on the backtest. Is there anyway to reverse the trade signals??

When i look at the backtest on the chart i noticed it says for example:

"\241": Buy at 1.57371
Open long

"\242": Sell at 1.57336
Close Long

thanks


---

## Re: Averages Strategy

**Apprentice** · Sat Mar 31, 2012 3:54 am

Currently this functionality is not supported (in this strategy).


---

## Re: Averages Strategy

**crazymonkey** · Tue May 28, 2013 1:43 pm

Hi Apprentice,

I'm running the averages strategy as a test on my account, but even though its set to trade (trade : Yes) , the strategy isn't trading.

It works in back testing and optimization, but not in a live setting. I receive the email notifications of change of trend direction, but thats it. No trades are opened.

Again, allow trades is set to YES but the strategy dashboard is blank where it says ALLOW TRADING.

Any ideas


---

## Re: Averages Strategy

**JOKER83** · Thu Jan 01, 2015 5:24 pm

HI
CAN YOU MAKE A PARAMETER

CLOSE TRADES -YES-NO-
THX


---

## Re: Averages Strategy

**Apprentice** · Fri Jan 02, 2015 3:16 am

Your request is added to the development list.


---

## Re: Averages Strategy

**JOKER83** · Fri Jan 02, 2015 1:11 pm

PARAMETER

MAX NUMBER OF OPEN POSITON IN ANY DIRECTION
AND
MAX NUMBER OF POSITION IN ONE DIRECTION
AND
VALID INTERVAL FOR OPERATION IN SECONDS
THANKS


---

## Re: Averages Strategy

**hadrak** · Fri Jan 08, 2016 6:55 am

Hi Apprentice,

Can you add " time parameter" to this strategy: Start time for trading/ Stop time for trading?.
Like is in strategy builder.

Thank you


---

## Re: Averages Strategy

**Apprentice** · Sun Jan 10, 2016 6:47 am

Time parameters added.


---

## Re: Averages Strategy

**Silver23** · Thu Jan 28, 2016 7:45 am

Thank you very much for helping me to stay in the game. It is highly appreciated. Is it possible to add the ADX filter to this great strategy? It should only trigger an entry signal when a candle closes above/below the average line and ADX is above 25.


---

## Re: Averages Strategy

**Avignon** · Thu Jan 28, 2016 2:04 pm

> **Silver23 wrote:**
> Thank you very much for helping me to stay in the game. It is highly appreciated. Is it possible to add the ADX filter to this great strategy? It should only trigger an entry signal when a candle closes above/below the average line and ADX is above 25.

[viewtopic.php?f=29&t=845](http://www.fxcodebase.com/code/viewtopic.php?f=29&t=845) ?


---

## Re: Averages Strategy

**Silver23** · Fri Jan 29, 2016 5:43 am

Thank you very much, highly appreciated. New to the forum but have read quite a bit. Have you used this strategy by any chance?


---

## Re: Averages Strategy

**Avignon** · Fri Jan 29, 2016 2:14 pm

Maybe, I do not remember, I have used so much !

Anyway all strategies are "good", they all give a "good" entry point after is to know what you do from this point of grafted, this is where things get complicated.


---

## Re: Averages Strategy

**dandee** · Mon Feb 01, 2016 5:01 am

How do you know what delta of the slope is and how can the user change it for either a steeper or less steeper slope? And why would we want to add adx filter to this, is it not best to k.i.s.s-----p
I notice a lot of nice simple strategies that are put on here then they all get requested to put some form of moving average or other osc on it which render it useless then. does the majority of people who use these strategies just set them and then sit on the beach with their hands behind their head? I always watch my position to see if the conditions changes


---

## Re: Averages Strategy

**Silver23** · Tue Feb 02, 2016 1:49 pm

Hi Dandee,

I understand what you are saying about K.I.S.S., however the ADX would help to keep me out of trades where the market isn't moving.


---

## Re: Averages Strategy

**Apprentice** · Wed Dec 14, 2016 7:21 am

Strategy was revised and updated.
