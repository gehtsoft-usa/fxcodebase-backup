# Two Moving Average Cross Expert Advisor

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=64500  
> Forum: 38 · Topic 64500 · 29 post(s)


---

## Two Moving Average Cross Expert Advisor

**Apprentice** · Sat Mar 04, 2017 7:32 am

Expert Advisor Entry Rules:
- Go Long when Fast MA crosses above the Slow MA
- Go Short when Fast MA crosses below the Slow MA

Where:
- MA can be any of 17 different Moving Averaging methods
- Price Type, MA Method and MA Period for each MA can be changed

Notes:
- Two_MA_Cross_Indicator.mq4 required (installed in the Indicators folder)

EA Features:
- Distance of Price with Slow MA to approve Entry (if too far away, trade is not executed)
- More than 1 trade can be opened at once
- Minutes to Wait for Next Open Trade
- Stop Loss, Take Profit and Trailing Stop Loss options
- AutoLots or Manual
- Trade Both Sides or only one direction
- Comments Displayed on Screen
- Optional Email and Sound Alerts

For further development (if requested):
- Lookback feature: check the crossing event looking back at n number of bars - For this, only the default MT4 moving averages could be used.

 [Two_MA_Cross_Indicator.mq4](files/111320/Two_MA_Cross_Indicator.mq4)

 [Two_MA_Cross_EA.mq4](files/111320/Two_MA_Cross_EA.mq4)


---

## Re: Two Moving Average Cross Expert Advisor

**Ehab.Ali** · Sat Mar 04, 2017 9:12 am

thanks Apprentice


---

## Re: Two Moving Average Cross Expert Advisor

**Ehab.Ali** · Sat Mar 04, 2017 6:20 pm

i found a problem while testing it

trailing stop working with buy orders only not working with sell
 can you pls fix it


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Mon Mar 06, 2017 5:02 am

Fixed.


---

## Re: Two Moving Average Cross Expert Advisor

**Ehab.Ali** · Mon Mar 06, 2017 7:22 am

> **Apprentice wrote:**
> Fixed.

still not working with sell orders


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Thu Mar 16, 2017 4:45 am

Update.


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Tue Mar 21, 2017 4:23 am

This is a major update to the following Expert Advisors:

- Multi Indicator EA
- Two MA Cross EA
- MA Cross with Exit EA

The following improvements have been made:

- Now the trader sets the number of pips rather than points (no more thinking about how many points to set, simply write 20 for 20 pips and that's it).
- EA can be activated/deactivated to trade or not
- Auto Lots calculation has been revised and is working properly
- Comments displayed on chart give more information about risk, lots, equity, opened orders
- (By the way, trades comments can be turned off to avoid the comments area to keep growing)

Additions:

The trader can now estipulate a maximum percentage of risk for open trades. For example the risk can be 2% per trade and the maximum 7% of the equity. The user can also choose the number of opened trades at the same time, for example 5.

So the way it works is that once the SL has moved to breakeven, then the risk for that trade is no longer considered in the equity providing additional room for opening further trades if necessary. It could be, for instance, that there were 3 opened trades but the 4th one was opened when one of the prior 3 moved to B/E.

Also, the trader could decide to have the same fixed lots every time and again set a maximum number of lots traded. For example 1 lot per trade and a maximum of 4 lots in total.

One note about the trailing stop

The way the Stop Loss works is to initially protect the trade, say with 20 pips. If the user additionally sets a trailing stop (TSL) of 15 pips with a 5 pips step, it will not work until the trade is in profit. This means they are two different concepts. The TSL will be activated when the trade is 15 pips in the green and then correct itself every 5 pips (step).


---

## Re: Two Moving Average Cross Expert Advisor

**7510109079** · Fri Mar 24, 2017 1:59 pm

Does the two MA Cross indicator exist as a Marketscope lua indicator?


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Sat Mar 25, 2017 7:07 am

Try this version.
[viewtopic.php?f=31&t=60657&hilit=MA+Cross](https://fxcodebase.com/code/viewtopic.php?f=31&t=60657&hilit=MA+Cross)


---

## Re: Two Moving Average Cross Expert Advisor

**7510109079** · Mon Mar 27, 2017 8:36 am

thats good thx but doesnt have the same ability to specify the OPEN or CLOSE as the mq4 does.

Any possibility of putting together something like this:


---

## Re: Two Moving Average Cross Expert Advisor

**7510109079** · Mon Mar 27, 2017 8:40 am

thats good thx but doesnt have the same ability to specify the OPEN or CLOSE as the mq4 does.

Any possibility of putting together something like this:

this would allow the same MA period to be used with different price type

price type drop downs:

Average drop downs:


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Fri Mar 31, 2017 3:50 pm

Your request is added to the development list, Under Id Number 3771
 If someone is interested to do this task, please contact me.


---

## Re: Two Moving Average Cross Expert Advisor

**Alexander.Gettinger** · Fri Sep 29, 2017 1:37 pm

> **7510109079 wrote:**
> thats good thx but doesnt have the same ability to specify the OPEN or CLOSE as the mq4 does.

The indicator and strategy are updated.


---

## option "close when opposite"

**rocky0410** · Fri Apr 24, 2020 4:08 am

May you add option "close when opposite"?
I just want EA open only one order. When indicator has a opposite signal, EA will close current order and open a new order.
e.g EA open a sell order, after that, indicator has buy signal. EA will close sell order and open buy order.
Thanks


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Fri Apr 24, 2020 12:57 pm

Your request is added to the development list.
Development reference 1127.


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Tue Apr 28, 2020 10:46 am

Try [viewtopic.php?p=130365#p130365](https://fxcodebase.com/code/viewtopic.php?p=130365#p130365)


---

## Re: Two Moving Average Cross Expert Advisor

**Albahri65** · Mon Aug 03, 2020 4:38 am

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 1127.

Any update on this development request?


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Mon Aug 03, 2020 9:18 am

Have you tried this version?
[viewtopic.php?p=130365#p130365](https://fxcodebase.com/code/viewtopic.php?p=130365#p130365)


---

## Re: Two Moving Average Cross Expert Advisor

**Albahri65** · Tue Aug 04, 2020 7:36 am

> **Apprentice wrote:**
> Have you tried this version?
> [viewtopic.php?p=130365#p130365](https://fxcodebase.com/code/viewtopic.php?p=130365#p130365)

Yes my dear, I tried it but unfortunately it miss very important option which is trailing stop and trailing step. It will be wonderful if you could add this two options.


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Wed Aug 05, 2020 4:22 am

Your request is added to the development list.
Development reference 1832.


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Wed Aug 05, 2020 8:08 am

[Two MA Cross EA.mq4](files/136619/Two%20MA%20Cross%20EA.mq4)

Try this version.


---

## Re: Two Moving Average Cross Expert Advisor

**Albahri65** · Wed Aug 05, 2020 3:47 pm

> **Apprentice wrote:**
>
>
> Two MA Cross EA.mq4
>
>
> Try this version.

Thank you for taking our requests seriously


---

## Re: Two Moving Average Cross Expert Advisor

**richardestes** · Thu Aug 20, 2020 8:59 am

I am unable to get this to back text or trade, any help, I am using mt 4 from Oanda?


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Fri Aug 21, 2020 5:50 am

Your request is added to the development list.
Development reference 1917.


---

## Re: Two Moving Average Cross Expert Advisor

**vbravo** · Sat Aug 29, 2020 5:44 pm

Can you please add option to trade like this:

EMA 10
SMA 10 (SIMPLE)
MACD 12,26,3

BUY:
1. MA cross UP
2. Macd histogram bar ABOVE macd line
3. Put your BUY trade
TP: Opposite signal (Reverse MA cross) or custom TP and custom SL, SL default 1:2

SELL:
1. MA cross DOWN
2. Macd histogram bar UNDER macd line
3. Put your SELL trade
TP: Opposite signal (Reverse MA cross) or custom TP and custom SL, SL default 1:2

Can catch reversal on early, when MA cross always show first when market will change direction, then MACD will confirm it

When MA cross and MACD histogram bar upper/lower of line it will confirm enter trade


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Mon Aug 31, 2020 8:11 am

Your request is added to the development list.
Development reference 1947.


---

## Re: Two Moving Average Cross Expert Advisor

**vbravo** · Mon Aug 31, 2020 4:21 pm

> **Apprentice wrote:**
>
>
> The attachment **Two_MA_Cross.mq4** is no longer available
>
>
> Try this version.

Thank you so much, but no trades, got this Alert.

And no inputs for MACD confirmation has requested.

BR


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Thu Sep 03, 2020 2:48 am

Task 1947

 [EMA_SMA_And_MACD.mq4](files/137274/EMA_SMA_And_MACD.mq4)


---

## Re: Two Moving Average Cross Expert Advisor

**Apprentice** · Thu Sep 03, 2020 2:58 am

[Two_MA_Cross.mq4](files/137277/Two_MA_Cross.mq4)

Try this fix.
