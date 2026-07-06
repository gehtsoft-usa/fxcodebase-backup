# Extreme_TMA_Line Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59383  
> Forum: 31 · Topic 59383 · 61 post(s)


---

## Extreme_TMA_Line Strategy

**Apprentice** · Tue Sep 03, 2013 3:35 am

![Extreme_TMA_Line Strategy.png](images/89117/Extreme_TMA_Line%20Strategy.png)



Open Long Trade
Green TMA line
Open Short Trade
Red, TMA Line

Exit (Optinal)
Close position on contrary color change, or to gray (neutral)

 [Extreme_TMA_Line Strategy.lua](files/89117/Extreme_TMA_Line%20Strategy.lua)

For this strategy, you need to, to download Extreme_TMA_Line indicator.
[download/file.php?id=6340](https://fxcodebase.com/code/download/file.php?id=6340)

 [Tick_Extreme_TMA_Line Strategy.lua](files/89117/Tick_Extreme_TMA_Line%20Strategy.lua)

For this strategy, you need to, to download Tick_Extreme_TMA_Line and Tick ATR indicators.
[viewtopic.php?f=17&t=59406&hilit=Extreme_TMA_Line+indicator](https://fxcodebase.com/code/viewtopic.php?f=17&t=59406&hilit=Extreme_TMA_Line+indicator)
[viewtopic.php?f=17&t=34094&p=57962&hilit=tick+atr#p57962](https://fxcodebase.com/code/viewtopic.php?f=17&t=34094&p=57962&hilit=tick+atr#p57962)

MT4 version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=72607](https://fxcodebase.com/code/viewtopic.php?f=38&t=72607)


---

## Re: Extreme_TMA_Line Strategy

**filoo7** · Tue Sep 10, 2013 6:15 am

Hi,

open long :
TMA grey to green
close long :
TMA green to grey

open short :
TMA grey to red
close short :
TMA grey to red

like this, possible?

Thank's


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Sep 11, 2013 3:25 am

Simple Exit ruler alternation.
Your request has been added to the development list.


---

## Re: Extreme_TMA_Line Strategy

**virgilio** · Wed Sep 18, 2013 12:14 pm

Is it possible to include in this strategy the option to trade the ATR lines instead of the TMA?


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Sep 18, 2013 1:12 pm

I do not follow, can you describe your strategy.


---

## Re: Extreme_TMA_Line Strategy

**virgilio** · Wed Sep 18, 2013 4:01 pm

Sell when the price bar goes over the top of the TRA border and buy when the price bar goes underneath the TRA border. If you really want to be nice, the strategy should specify by how many pips are required over/under before the sell/buy position is triggered.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Sep 19, 2013 10:46 am

Your request is added to the development list.


---

## Re: Extreme_TMA_Line Strategy

**filoo7** · Thu Sep 26, 2013 8:40 am

hi,
possible to create MTF ?
thanx


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Fri Sep 27, 2013 6:18 am

Can you describe such MTF strategy.


---

## Re: Extreme_TMA_Line Strategy

**alexpatrovita** · Mon Mar 31, 2014 12:45 pm

hello, this strategy is great but if i let go the strategy with the redraw true the strategy does'nt apply, doesn't go short when is it red doesn't go long when is it green
Why?
If yuo let the strategy go with redraw false everything is ok when it became green go long when it became red go short.
But i wuod like tom applicate the redraw true because is more performing.

Thanks

Alex


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Apr 02, 2014 3:29 am

I could not find anything wrong in my code.
U may have a problem with delay,
strategy is configured to execute a trade at the end of the turn,
at the beginning of the next one.

If this is your problem, a modified strategy can be implemented.


---

## Re: Extreme_TMA_Line Strategy

**alexpatrovita** · Mon Apr 07, 2014 12:47 pm

Yes this is my problem the strategy works only with the redraw false, what i can do , i can change some parameter like trend i don't know? thanks of all Alex


---

## Re: Extreme_TMA_Line Strategy

**alexpatrovita** · Wed Apr 09, 2014 7:02 pm

My question is the strategy works with the redraw true?


---

## Re: Extreme_TMA_Line Strategy

**moomoofx** · Fri Jun 06, 2014 6:09 pm

Alexpatrovita,

What is the problem if redraw is true? What do you mean it only works when redraw is false?

You have to remember that if redraw is true, the indicator redraws values **in the past** that have already happened. Therefore, it is common to see the following situation that do not look correct but actually are:

1) A value in the past that triggered a trade, could be re-drawn later to not trigger a trade. It will be too late though because the trade has already been executed.
2) A value in the past did not trigger a trade, but could be re-drawn later to trigger a trade. Therefore, the strategy may enter a trade "too late"

Are you complaining about one of the above two situations?

Regards,
MooMooFX


---

## Re: Extreme_TMA_Line Strategy

**Kyriakos** · Tue Oct 28, 2014 9:33 am

Hi

Can you make the strategy to work with the tick versions of the indicator?


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Oct 29, 2014 3:53 am

Tick_Extreme_TMA_Line Strategy Added
Extreme_TMA_Line Strategy.lua Update


---

## Re: Extreme_TMA_Line Strategy

**morngrym** · Sat Nov 01, 2014 10:48 pm

Hey apprentice would u be able to take this same strategy and put a alert to when the candle breaks either the upper or lower lines. or even better would be once the bar has broke the lower/upper line and then when there is a bar in the opposite direction to start a trade. I would show a picture but I don't know how to post one here.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Mon Nov 03, 2014 4:07 am

In such a strategy, central line slope, has no role or?


---

## Re: Extreme_TMA_Line Strategy

**morngrym** · Mon Nov 03, 2014 11:49 am

the center line only plays a small part to if I make larger trades but otherwise it doesn't impact on my strategy, I just use when the Bar(not the wick) breaks upper/lower line then wait for a return bar to finish in the opposite direction to buy/sell.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Nov 05, 2014 3:52 am

Can you post a detailed description of requested strategy, modifications.
Something like this.
If .. cross .. Then Open ...
If ...cros... Then ... Close


---

## Re: Extreme_TMA_Line Strategy

**morngrym** · Wed Nov 05, 2014 9:12 pm

ok well I guess if would be kinda like ....

This would all be in end of candles not just wicks but I guess you could put in a option for that.

if PRICE > UPPER then Buy
if PRICE < LOWER then Sell

thanks very much, what programming language is this in?


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Nov 06, 2014 6:41 am

Requested can be found here.
[viewtopic.php?f=31&t=61408&p=96915#p96915](https://fxcodebase.com/code/viewtopic.php?f=31&t=61408&p=96915#p96915)


---

## Re: Extreme_TMA_Line Strategy

**Kyriakos** · Thu Nov 13, 2014 5:32 am

Hi,

The tick version do not work . I get the message that the timeframe must not be tick.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Sat Nov 15, 2014 5:36 am

Tick means, strategy uses Tick_Extreme_TMA_Line and Tick ATR indicator.
It is not made for tick time frame.


---

## Re: Extreme_TMA_Line Strategy

**Kyriakos** · Wed Nov 19, 2014 3:17 pm

Is it possible to make the strategy work with the Tick Renko Candles View?


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Nov 20, 2014 3:40 am

Will post your request to my colleagues.


---

## Re: Extreme_TMA_Line Strategy

**Laventus** · Fri Dec 12, 2014 11:29 pm

Is it possible to add a fixed trailing stop to Extreme_TMA_Line Strategy?

Thanks in advance


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Dec 18, 2014 4:16 am

Can you explain.
As it is, strategy supports trailing stop


---

## Re: Extreme_TMA_Line Strategy

**Laventus** · Fri Dec 19, 2014 2:44 pm

> **Apprentice wrote:**
> Can you explain.
> As it is, strategy supports trailing stop

 Yes it supports a normal trailing stops(every .1 pips the price moves, stop follows). I want to know if it's possible to add a FIXED trailing stop as well (example, i set "X" fixed trailing to 60 pips, so the stop won't move at all until price has moved 60 pips. The stop continue moving 60 pips at a time as long as price keeps moving). I'de like to optimize both and see which one limits the most draw down. Thanks!


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Sun Dec 21, 2014 5:13 am

Your request is added to the development list.


---

## Re: Extreme_TMA_Line Strategy

**mulligan** · Wed Apr 29, 2015 10:09 pm

I would like to request a change in the strategy or create an alert. Because of the repainting associated with redraw, I don't use that function. I use the strategy as an alert only on no redraw. What happens is, since I use the trend threshold, there is a lot of TMA neutral color. As it exists, the strategy alerts every time the color changes from neutral. That means there are normally a large number of alerts when the trend remains up or down. It would be extremely helpful if the strategy could have a choice to ignore neutral and only signal when color changes from up to down or down to up. An alert with ignore neutral would also work just fine for me. I believe many users would benefit. As always, thanks for the work you do for us traders.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Fri May 01, 2015 2:53 am

Your request is added to the development list.


---

## Re: Extreme_TMA_Line Strategy

**7510109079** · Tue Jun 09, 2015 2:50 am

Any progress with Mulligan's request i.e. only enter trade when a new up/down is posted and to ignore repeat entries on the same colour??


---

## Re: Extreme_TMA_Line Strategy

**7510109079** · Mon Nov 02, 2015 8:20 am

bump.

The original post says the strategy logic is as follows:

**Open Long Trade
Green TMA line
Open Short Trade
Red, TMA Line

Exit (Optinal)
Close position on contrary color change, or to gray (neutral)**

This is not happening. Maybe the logic was modified by a subsequent user request but if so where is the original strategy logic version/link?

Can a separate download link be posted which adheres to orig criteria?
thx in advance


---

## Re: Extreme_TMA_Line Strategy

**JOKER83** · Mon Apr 25, 2016 9:57 am

PLEASE MAKE EXTREME TMA SLOPE STRATEGY
EXIT OPTIONAL


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Sun May 01, 2016 8:56 am

Something like this one?
[viewtopic.php?f=31&t=59383](https://fxcodebase.com/code/viewtopic.php?f=31&t=59383)


---

## Re: Extreme_TMA_Line Strategy

**mulligan** · Sun May 01, 2016 4:48 pm

I've been watching the recent posts with interest since I made a similar request. The strategy you noted should do as requested. However it seems to have a bug that does not allow the optional exit 'ignore grey' to work.

Thanks


---

## Re: Extreme_TMA_Line Strategy

**JOKER83** · Mon May 02, 2016 6:58 pm

REDRAW NOT CORRECT WORK


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Mon May 09, 2016 4:48 am

Set "Use Optional Exit" to yes if want the optional exit.


---

## Re: Extreme_TMA_Line Strategy

**mulligan** · Mon May 09, 2016 7:01 am

I reloaded the strategy and tested with optional exit set to yes. As an example, if a buy signal is generated and the extreme tma line changes from buy to neutral to buy 5 times, the strategy generates 5 buy signals. What I was looking for is a strategy that ignores all subsequent changes from neutral to the same direction and only signals when the opposite direction is given.

Thanks


---

## Re: Extreme_TMA_Line Strategy

**JOKER83** · Thu May 12, 2016 5:36 am

REDRAW WORKS NOT CORRECT
THE STRATEGY MAKE TRADES NOT CORRECT


---

## Re: Extreme_TMA_Line Strategy

**mulligan** · Thu May 12, 2016 7:05 am

Wanted to let you know that my testing of the strategy was done with redraw set to 'no'. I'm aware results are unpredictable with redraw on. The strategy behaves exactly the same with optional exit either on or off.


---

## Re: Extreme_TMA_Line Strategy

**BigFOX** · Thu May 12, 2016 8:23 am

> **JOKER83 wrote:**
> REDRAW WORKS NOT CORRECT
> THE STRATEGY MAKE TRADES NOT CORRECT

Hello JOKER83,
"Extreme_TMA_Line" is different from "Extreme_TMA_Slop".

"Extreme_TMA_Slop Strategy" It would be good with exit neutral.

BigFOX


---

## Re: Extreme_TMA_Line Strategy

**LearningByDoing** · Tue May 31, 2016 9:01 am

> **Apprentice wrote:**
>
>
> Extreme_TMA_Line Strategy.png
>
>
> Open Long Trade
> Green TMA line
> Open Short Trade
> Red, TMA Line
>
> Exit (Optinal)
> Close position on contrary color change, or to gray (neutral)
> ...

I expected the strategy to buy when the TMA line would go from grey to green and to sell when it would go from grey to red. Basically following the slope of the TMA line as I understand.

It's behaviour is different. It trades if price breaks the lines at the atr distance from the tma line.
how can I make it trade when the TMA line color changes?

thx in advance!

edit:
after looking a bit deeper into the re-draw issue, I have come to conclude that Signals from current indicator values are not reliable at all and not in line with the (redrawn) indicator on the chart (just try switching re-draw off in the indicator settings and you will see).
A solution would be a change to the underlying indicator(s)/the strategy to not use moving averages which re-paint (like the EMA used), but ones that dont. e.g.: LWMA (linear weighted moving average). The plotted curve would be a bit different, but the signals would be far more reliable.

Any thoughts on that?


---

## Re: Extreme_TMA_Line Strategy

**jaricarr** · Wed Jun 01, 2016 9:14 am

Hi,

Looks like the strategy is ignoring all the trading parameters.

Thanks,

Jari


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Jun 02, 2016 2:47 am

Try to set Redraw to NO.
If set to Yes, Indicator output and actual trade data will not coincide.


---

## Re: Extreme_TMA_Line Strategy

**jaricarr** · Mon Jun 06, 2016 8:28 pm

> **Apprentice wrote:**
> Try to set Redraw to NO.
> If set to Yes, Indicator output and actual trade data will not coincide.

Thank You Apprentice


---

## Re: Extreme_TMA_Line Strategy

**jaricarr** · Mon Jun 06, 2016 8:30 pm

Hi,

Can you please make this strategy compatible with the Renko Chart please.

Thanks
Jari


---

## Re: Extreme_TMA_Line Strategy

**jaricarr** · Sat Sep 03, 2016 2:11 pm

[quote="filoo7"]Hi,

open long :
TMA grey to green
close long :
TMA green to grey

open short :
TMA grey to red
close short :
TMA red to grey

Hi Aprentice, is there a strategy with this logic ?


---

## Re: Extreme_TMA_Line Strategy

**patbateman86** · Tue Sep 06, 2016 3:36 am

Hi.
i'm sorry for my english.

Is possible to create an expert advisor that uses language strings TMA EXTREME WITH ALERT .

INPUT FOR AUTOMATIC OPERATIONS TO BE INCLUDED :
OPEN POSITION long WHEN "END OF TURN"arrow IS UP.
OPEN POSITION short WHEN END OF TURN ARROW IS DOWN .

CLOSE POSITION WHEN A NEW OPPOSITE END OF TURN ARROW APPEAR.

STOP LOSS: INSERT VALUE
STOP PROFIT ( TRAILING STOP ) : INSERT VALUE

Thankyou so much
Matt


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Sep 15, 2016 5:23 am

Your request is added to the development list, Under Id Number 3628
 If someone is interested to do this task, please contact me.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Thu Oct 13, 2016 5:14 am

Try this version.
[viewtopic.php?f=31&t=63961](https://fxcodebase.com/code/viewtopic.php?f=31&t=63961)


---

## Re: Extreme_TMA_Line Strategy

**jaricarr** · Thu Oct 20, 2016 7:51 pm

Hi Aprentice, is there a TMA Line strategy with this logic ?

open long :
TMA grey to green
close long :
TMA green to grey

open short :
TMA grey to red
close short :
TMA red to grey


---

## Re: Extreme_TMA_Line Strategy

**rose123** · Fri Oct 21, 2016 4:57 am

hi apprendice

can you create a strategy based on this indicator with daily pivot

**INDICATORS:**

1. EXTREME TMA LINE WITH DEFAULT PARAMETERS
2.EXTREME TMA SLOPE
 BUY LEVEL; 0.3
 SELL LEVEL:-0.3
3.DAILY PIVOT

**BUY:**

1. EXTREME TMA SLOPE > BUY LEVEL and
2. price cross over upper line
3. and price >daily pivot AND PRICE < RESISTANCE1

**SELL;**

1.EXTREME TMA SLOPE < SELL LEVEL
2.and price cross under lower line
3and price < daily pivot AND PRICE >SUPPORT1

thank you


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Mon Oct 24, 2016 4:05 am

> Hi Aprentice, is there a TMA Line strategy with this logic ?

jaricarr you can find this strategy in the first post of this topic.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Mon Oct 24, 2016 4:35 am

Rose try this version.
[viewtopic.php?f=31&t=64023](https://fxcodebase.com/code/viewtopic.php?f=31&t=64023)


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Sun Dec 18, 2016 7:54 am

Strategy was revised and updated.


---

## Re: Extreme_TMA_Line Strategy

**Gilles** · Mon Jul 25, 2022 1:32 pm

Hi Apprentice,

The link to the Tick_Extreme_TMA_Line_strategy (LUA) file provides access to the download of a file that has that name but contains only Tick_SAR_With_Second_Time_Frame_Confirmation_Strategy. Check and correct this error.

Thank you very much.


---

## Re: Extreme_TMA_Line Strategy

**Gilles** · Fri Jul 29, 2022 5:29 am

Hi Apprentice,
Could you convert this indicator TETL_signal LUA into an expert strategy for MT4 with the following, please.
This flag is a modified version of Tick_Extreme_TMA_Line.
To determine the bands, I studied the volatility of the m15 candles on the GER30 over the last 42 months to establish the average size.
This allows me to determine the distance of the tapes.

Upper = TMA + 12
Lower = TMA - 12

Desired configurable inputs:
1. Distance
2. MaxNumberOfPositionInAnyDirection = 8 (default)

The parameters indicated for the TMA will remain unchanged.

I use the arrows to enter the position, they are simple instructions.
Green arrow = BUY
Red arrow = SELL
Stop Loss = math.floor(source * 0.25%)
Example: Stop loss = 13400 * 1% = 134 points
Limit = Stop loss * 1.618
Close on opposite

Risk Management:
Capital risk = Balance * 2%
MaxNumberOfPositionInAnyDirection = 8
So Balance * (2%/8) = 0.25% (risk per position)

Latent loss limit = Balance * 1.3%
Maximum daily loss = Balance * 1.8% (prevents the opening of other positions for the day)

Set the trend:
If a green arrow appears: uptrend = true
Open BUY
As long as uptrend = true
	If the position loses 24 pts (2 * Distance) = open BUY (2nd)
	If the 2nd position loses 24 pts (2 * Distance) = open BUY (3rd)
	etc.

If a red arrow appears: uptrend = false
Open a sale
As long as uptrend = false
	If the position loses 24 pts (2 * Distance) = open SELL (2nd)
	If the 2nd position loses 24 pts (2 * Distance) = open SELL (3rd)
	etc.

I hope you like my strategy and you'll want to convert it to MT4.
Thank you very much for the time you will give to my request.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Tue Aug 02, 2022 5:14 am

We have added your request to the development list.
Development reference 460.


---

## Re: Extreme_TMA_Line Strategy

**Apprentice** · Wed Aug 10, 2022 9:24 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=72607](https://fxcodebase.com/code/viewtopic.php?f=38&t=72607)
