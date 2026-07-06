# Heikin-Ashi Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4148  
> Forum: 31 · Topic 4148 · 47 post(s)


---

## Heikin-Ashi Strategy

**Apprentice** · Sun May 08, 2011 6:19 am

![HA Strategy.png](images/10416/HA%20Strategy.png)



With a simple HA signals,
strategy supports the definition of Trigger Level,
in either a PIP or as a percentage, on price or Heikin-Ash indicator.

If the trigger level is not reached, the strategy will not enter the trade.

 [HA Strategy.lua](files/10416/HA%20Strategy.lua)

 [HA with smoothing Strategy.lua](files/10416/HA%20with%20smoothing%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: Heikin-Ashi Strategy

**forexdezert** · Mon May 09, 2011 8:50 pm

1. Please add the option for the strategy to trade on a 2 minute time frame. (m2)

2. Also please add the parameter Option "Act on Close/Break Out" The option determines should the strategy open a new position when candle closes after a color change, or upon the instant of HA color change (or breakout). (See the trading parameters of ATRStrategy for example. [viewtopi](http://www.fxcodebase.com/code/viewtopi) ... =31&t=3861)

Right now when trading on shorter time spans the indicator waits for another candle to close, and by that time it has missed the window of profitability.


---

## Re: Heikin-Ashi Strategy

**FXJPGH** · Wed May 11, 2011 5:57 pm

Apprentice, thank you for this strategy it really help me to make faster and more accurate decisions. However i tried to select a stop loss whenever the strategy opens a new order and it does not work.

Is there any way to add this.

best regards.


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Thu May 12, 2011 4:55 am

Are You From U.S. or have an open U.S. Based trading account.
If this is the case, these functionalities is not available.


---

## Re: Heikin-Ashi Strategy

**FXJPGH** · Thu May 12, 2011 10:11 am

I am from Nicaragua but my account is from FXCM UK.

best regards


---

## Re: Heikin-Ashi Strategy

**sithuat** · Mon May 16, 2011 4:25 pm

Hi Apprentice,

I think I am going to ask you a lame question, well I am still a newbie in forex. I tried to install your strategy in the Trading Station II and I got this message. "[string "HA Strategy.lua"] :155: The indicator with id HA is not found." I've installed Heikin-Ashi Smoothed i found in this forum. Or do I need to install different indicator? Thanks in million!


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Tue May 17, 2011 4:03 am

Very unusual
Heikin-Ashi Smoothed not required for this strategy.
And Heikin-Ashi indicator is a standard pre-installed one.

Which broker you use.
have you delete some standard ones.


---

## Re: Heikin-Ashi Strategy

**sithuat** · Tue May 17, 2011 12:07 pm

Well, I am with FXCM USA though I'm from Singapore. The problem is, I can't find Heikin-Ashi in pre-installed indicators list. Btw I am using FXCM Trading Station II ver 01.10.041211. Sigh I still can't install your strategy. I also can't install TDI strategy I found in this forum too.

Anyway thanks for your fast reply. You really are helpful and idol for newbie like me


---

## Re: Heikin-Ashi Strategy

**forexdezert** · Fri May 27, 2011 8:49 am

> **forexdezert wrote:**
> 1. Please add the option for the strategy to trade on a 2 minute time frame. (m2)
>
> 2. Also please add the parameter Option "Act on Close/Break Out" The option determines should the strategy open a new position when candle closes after a color change, or upon the instant of HA color change (or breakout). (See the trading parameters of ATRStrategy for example. [viewtopi](http://www.fxcodebase.com/code/viewtopi) ... =31&t=3861)
>
> Right now when trading on shorter time spans the indicator waits for another candle to close, and by that time it has missed the window of profitability.

Can you guys add these parameters please?


---

## Re: Heikin-Ashi Strategy

**forexdezert** · Tue Jun 14, 2011 8:51 am

Hello guys,
I trade on very short time frames. Specifically the 2 minute. Never long term and I have been trying to get a workable strategy for me to use.
In my trading I use the HA Indicator as well as the Regression and Supertrend indicators. Neither this strategy, or the Regression Supertrend Strategy work on short time frames for one very specific reason.... Mainly because these Strategy's wait for the candle to close upon the conditions of change, then it continues to wait until a second candle closes to confirm before the strategies will place a new trade or close an open trade and open a new trade in the opposite direction.

Please, please, For this strategy AND the (Regression Supertrend Strategy)

1. Add the option for the strategy to trade on a 2 minute time frame. (m2)

2. Also please add the parameter Option "Act on Close/Break Out" The option determines should the strategy open a new position when candle closes after a color change, or upon the instant of HA color change (or breakout). (See the trading parameters of ATRStrategy for example. viewtopi ... =31&t=3861)

Right now when trading on shorter time spans the indicator waits for another candle to close, and by that time it has missed the window of profitability.

Or if the Regression Supertrend and HA Strategy can be combined into one strategy that would be awesome!

Thank you.


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Wed Jun 15, 2011 1:18 pm

Stop/Limit Bug Fixed.


---

## Re: Heikin-Ashi Strategy

**nookie** · Fri Jul 08, 2011 5:01 am

Hello Apprentice,

It looks like this strategy has an open position all the time. Is it possible that after a position is triggered it is closed by some rule - for example if a buy is triggered then position is closed on a 7 pip short candle. Then a position is not opened until the initial rule is met - a 9 pip candle in whichever direction?

Also I noticed that "heikin ashi trigger level" part of the strategy has a part "trigger level" - cool feature but would be great for me if candles are measured without the wigs - only bodies for their pip length - unfortunately now this cant be chosen. Could it be changed ?

Thanks

nookie


---

## Re: Heikin-Ashi Strategy

**amazon1a** · Tue May 22, 2012 3:48 pm

Hi Apprentice, I am very interested in HA candles. I find 2 basic HA Strategies with the same .lua file format. They load separately. Are both active? What is the functional Difference, if any, between them? I also see a HA Smoothed Strategy. This HA Strategy has a different input field that I suspect I will be interested in. But I do not understand what the parameters in this Heikin-Ashi Trigger Level input field refer to or how to use them. Can you help?
 Trigger
 Trigger Level
 Price/HA
 Percentage/PIP

Attached a screen shot. Thanks for all your help. Bob


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Wed May 23, 2012 1:19 am

All activ strategies are equal in execution.
By default, Trades are executed on HA Slope Change.
If Triger is on.
Trade is executed only if the defined minimum Triger Level is reached.
This difference may be in percentage or in pips.
It is calculated as the difference between current price and previous trading price.
As a basis we use, Price or HA.


---

## Re: Heikin-Ashi Strategy

**amazon1a** · Wed May 23, 2012 10:30 am

Sorry, but it is still not clear. Is it possible to show me an example with the input fields filled in??


---

## Re: Heikin-Ashi Strategy

**BabyBull** · Mon Jul 23, 2012 9:45 am

Good morning, I am a little confused. I installed the HA Strategy on a NZD/USD chart and selected the same symbol, however the strategy opened a position on the EUR/USD.
Your assistance is appreciated. I will pose the same question here as I did in another post. Is there a way to filter trades to only trade in the direction of a higher time frame and can time filters be added.


---

## Re: Heikin-Ashi Strategy

**BabyBull** · Mon Jul 23, 2012 9:50 am

One other question, instead of the supertrend, DMI and SAR could the HA strategy and Supertrend strategy be combined? It seems to me in looking at charts this could work out well.The ability to limit the times in which it trades, being able to trade in the direction of a higher time frame, and only when the volatility is adequate would be helpful. Thank you


---

## Re: Heikin-Ashi Strategy

**lisa_baby_xx** · Tue Jul 24, 2012 7:37 am

Hi Everybody,

What does parameter "Wick Filtering" mean???

Much love to everyone. X
lisa_baby_xx


---

## Re: Heikin-Ashi Strategy

**lisa_baby_xx** · Mon Aug 06, 2012 10:21 am

Hi,

Could someone convert this to MT4 please??

Much love to all.
lisa_baby_fx


---

## Re: Heikin-Ashi Strategy

**geofanin** · Wed Mar 13, 2013 12:05 am

Hello, I love the way the strategy scalps in the direction of the trend but because of the pullbacks on short time frames, I was wondering if a filter can be added with Exponentail Moving Averages?

 For example:
 a short trade would only open if the fast EMA is below the slow EMA, any bullish candles that appear would only close the trade.

a long trade would only open if the fast EMA is above the slow EMA, any bearish candles would close the trade,

this way we scalp with the trend.
 Thank You


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Wed Mar 13, 2013 7:49 am

Your request is added to the developmental list.


---

## Re: Heikin-Ashi Strategy

**geofanin** · Thu Mar 14, 2013 9:04 pm

Thank You. Looking forward to using it


---

## Re: Heikin-Ashi Strategy

**sartas** · Thu Apr 04, 2013 3:50 am

good idea , like this strategie for confirm
[viewtopic.php?f=31&t=27285](https://fxcodebase.com/code/viewtopic.php?f=31&t=27285)
 but need HA parameters

can u also add a reverse Mode?

Thx a lot


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Sat Apr 06, 2013 4:37 am

Can you give a detailed explanation.
uses
if () then () else
logic ...


---

## Re: Heikin-Ashi Strategy

**oisin12** · Sun May 19, 2013 7:19 pm

Hi,

Is it possible to have this same strategy but using SAR? I'd like to run a comparison

Thanks,
Oisin


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Tue May 21, 2013 5:27 am

Your request is added to the development list.


---

## Re: Heikin-Ashi Strategy

**rtsayers** · Thu Sep 26, 2013 1:09 am

Could you please add smoothing with this strategy? With 1 to 100.

Thanks a million


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Thu Sep 26, 2013 3:00 am

Purpose of this MA will be?
To smooth the source data, or to act as a filter.
Can you provide a more detailed description.


---

## Re: Heikin-Ashi Strategy

**rtsayers** · Thu Sep 26, 2013 9:23 pm

Yeh to smooth the source data so I can smooth out the HA.

ThANKS


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Fri Sep 27, 2013 6:40 am

HA with smoothing Strategy added.


---

## Re: Heikin-Ashi Strategy

**rtsayers** · Fri Sep 27, 2013 12:00 pm

Thanks for the smoothing but I wanted to be able to put in the amount of smoothing like the indicator from 1 to 100 parameters.

Thanks


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Sun Sep 29, 2013 3:02 am

Smoothing period added.


---

## Re: Heikin-Ashi Strategy

**amazon1a** · Sun Sep 29, 2013 7:03 am

Hi Apprentice, This is fantastic!! Now can you do the same for MTF HA? Thanks for all your hard work, AG


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Sun Sep 29, 2013 7:36 am

I need a bit more info,
which MTF HA, provide a link...


---

## Re: Heikin-Ashi Strategy

**amazon1a** · Mon Sep 30, 2013 11:35 am

Hi Apprentice, Here is the one that I am using. I typically smooth the HA indicator n_1 or 2.

[viewtopic.php?f=31&t=24198&hilit=MTF+HA+Strategy](https://fxcodebase.com/code/viewtopic.php?f=31&t=24198&hilit=MTF+HA+Strategy)

Thanks, AG


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Wed Oct 02, 2013 3:38 am

Your request is added to the development list.
As for combo, can you specify the rules.


---

## Re: Heikin-Ashi Strategy

**oisin12** · Wed Oct 23, 2013 9:47 am

Hi, do you think it would be possible to add the option to close a position when the candle reverses but not open a new position?

At the moment if the strategy is set to trade on both directions a reversed position will open when the candle closes in the opposite colour but if the strategy is set to trade in only one direction and the candle reverses before it hits either the stop of limit the position stays open.

Thanks,
Oisin


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Thu Oct 24, 2013 1:56 am

Such an option is possible.


---

## Re: Heikin-Ashi Strategy

**Outside_The_Box** · Sun Nov 17, 2013 4:23 am

I almost hate to ask this because I'm really getting the hang of Strategy Wizard, but can someone add a moving average based filter to this? I'd like to use 2 daily EMA's, one fast, one slow. As long as the daily fast EMA is above the daily slow EMA then longs are allowed. Reverse for shorts. Entry is based on H4 Heiken Ashi candle.

Here's the logic I have in Strategy Wizard for the entry:

> HeikenAshi_H4.open( 0 ) < HeikenAshi_H4.close( 0 ) .and. HeikenAshi_H4.open( 1 ) > HeikenAshi_H4.close( 1 )

Here's the logic from the HA Strategy

Code: [Select all](https://fxcodebase.com/code/)
`if  indicator.open[period] <   indicator.close [period] and indicator.open[period-1] >  indicator.close [period-1]  then
BUY= true;`

It's exactly the same logic as the HA Strategy (from this site) but for some reason it isn't working on my strategy. I am at a loss.


---

## Re: Heikin-Ashi Strategy

**oisin12** · Wed May 14, 2014 1:34 pm

> **Apprentice wrote:**
>
>
> HA Strategy.png
>
>
>
> With a simple HA signals,
> strategy supports the definition of Trigger Level,
> in either a PIP or as a percentage, on price or Heikin-Ash indicator.
>
> If the trigger level is not reached, the strategy will not enter the trade.
>
>
>
> HA Strategy.lua
>
>
>
>
> HA with smoothing Strategy.lua

Hi, Any chance there is a version of the strategy (without smoothing) that actually does the opposite? Open a long on the close of a red candle and opens a short on the close of a green candle

Thanks,
Oisin


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Thu May 15, 2014 4:29 am

[HA Strategy.lua](files/94020/HA%20Strategy.lua)

Try this version.
Reverse Direction parameter is Introduced.


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Mon Oct 20, 2014 11:15 am

HA Strategy.lua & HA with smoothing Strategy.lua Update
See First, Topmost post in Topic.


---

## Re: Heikin-Ashi Strategy

**cmpblsmith** · Wed Dec 03, 2014 12:32 am

Hi Apprentice, I was wondering if you could add an option for reverse signals for this strategy,

Thanks,
Cam


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Wed Dec 03, 2014 5:41 am

This version have reverse option.
[download/file.php?id=11746](https://fxcodebase.com/code/download/file.php?id=11746)


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Sun Dec 11, 2016 10:11 am

Strategy was revised and updated.


---

## Re: Heikin-Ashi Strategy

**easytrading** · Wed Aug 30, 2023 5:48 pm

Hello Apprentice,

If you please, could we have MT4 version of HA Strategy.lua as an Expert Adviser.

with highly appreciation.


---

## Re: Heikin-Ashi Strategy

**Apprentice** · Sat Sep 02, 2023 4:38 am

We have added your request to the development list.
Development reference 783.
