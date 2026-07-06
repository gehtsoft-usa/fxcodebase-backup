# Ichimoku Kinko Hyo crosser EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=64091  
> Forum: 38 · Topic 64091 · 4 post(s)


---

## Ichimoku Kinko Hyo crosser EA

**MickersMod** · Fri Nov 11, 2016 10:50 pm

I have an EA I have been customizing using the Ichimoku and I feel like I need to get some community help for back testing and such. I was looking for an Ichimoku EA to use as a base and found the one on the earnforex website; the Ichimoku Chinkou Cross. It looked promising as it was very well constructed but doing some testing I found that it wasn't profitable. After studying the code I realized that the way it closed positions was very poor, it almost seemed unfinished so I went in and modified it for better closes.
Specifically I added two more ways to close positions and I also added a 14 period RSI to filter out some of the bad trade setups. First, I added a hard stop loss which calculates a pip value based on a risk percentage that the user inputs. Second, I use the Kijun-Sen to close also. When the closing price crosses the Kijun-Sen it closes the position.
The RSI I added filters out some of the bad setups, it has to be >70 or overbought for long positions and < 30 for short. I have found the trends tend to stay in the overbought and oversold areas for up and down trends respectively.

My backtesting showed promising results right away on the ~/jpy pairs as it should, and testing on demo seems to confirm. My backtesting is limited and it has only been running on a demo for about a month which is why I need some community help in testing this thing, and suggestions of course.

For testing purposes I keep all the settings at default (except for stopLossRisk)and test it over multiple JPY pairs to get a better benchmark on its performance.
Thanks in advance!


---

## Re: Ichimoku Kinko Hyo crosser EA

**MickersMod** · Sun Nov 13, 2016 7:28 pm

I added the kumo size and the slope of the tenkan-sen to the order algorithm. I ran a bunch of back tests on the eur/jpy gbp/jpy and usd/jpy and found that the size of the kumo affects the signal quality. the profit margin peaked out on all three pairs at about 275 - 325 so I set the default value at 300. the tenkan-sen slope was less effective but the profit margin bumped a few points at around 10 on all three pairs so thats where I set the default value. it was a four month back test same settings on all three pairs.
I got a profit margin on H1 of USD/JPY: 2.17, GBP/JPY: 1.96, EUR/JPY: .77


---

## Re: Ichimoku Kinko Hyo crosser EA

**MickersMod** · Tue Nov 22, 2016 2:00 am

Updated version,
I added a scale out for take profits, and a break even stoploss.

After a trade is opened if the price falls below the Tenkin-Sen line the EA will move the stoploss to breakeven if possible. It moves it to the order open price plus the value set in the failsafe input parameter. It then proceeds to close a portion of the orders lots every bar until the price moves away from the Tenkin-Sen.

Like wise if the trade immediately moves toward the stoploss it will begin to scale out until the stoploss is reached or the price begins to move in the desired direction.

These scale outs greatly reduces draw down, increases winning trades and a slightly better profit margin. The reduction of draw down is a great stress reliever.

you can also set the failsafe and stoploss to 0 to turn them off - more for testing purposes or if you like to live on the edge.


---

## Re: Ichimoku Kinko Hyo crosser EA

**MickersMod** · Sun Dec 04, 2016 10:09 pm

My final final. I dropped the RSI as I found that the kumo size was a better filter and allowed for earlier entry trades, and I removed some of the input clutter.
settings for November optimization: USDJPY H1 - kumo threshold 120, failsafe 0, orderstoplossrisk .02, atr multiplier 2, risk 2
