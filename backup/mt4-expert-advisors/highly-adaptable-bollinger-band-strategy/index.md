# Highly adaptable Bollinger Band Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=64536  
> Forum: 38 · Topic 64536 · 13 post(s)


---

## Highly adaptable Bollinger Band Strategy

**Apprentice** · Wed Mar 22, 2017 5:22 pm

Description:

This expert advisor will trade according to Price crossing the Bollinger Bands Lines.

For each possible crossing:

- Top Line Cross Over
- Top Line Cross Under
- Center Line Cross Over
- Center Line Cross Under
- Bottom Line Cross Over
- Bottom Line Cross Under

The following actions can be selected:

- No action
- Buy
- Sell
- Close Buy Positions
- Close Sell Positions
- Close All Positions
- Alert

The crossings are compared with the current price and either the Close of the previous bar or checking if any part of the previous bar was at the other side of the crossing (High/Low). So this is an option the trader can choose from.

For a consolidated market the actions which make sense would be:

- Top Line Cross Over: Close Buy Positions
- Top Line Cross Under: Sell
- Center Line Cross Over: No Action
- Center Line Cross Under: No Action
- Bottom Line Cross Over: Buy
- Bottom Line Cross Under: Close Sell Positions

For a trending market the actions which make sense would be:

- Top Line Cross Over: Buy
- Top Line Cross Under: No Action
- Center Line Cross Over: No Action or Close Sell Positions
- Center Line Cross Under: No Action or Close Buy Positions
- Bottom Line Cross Over: No Action
- Bottom Line Cross Under: Sell

EA Features:

- Activate/Deactivate Expert Advisor
- Trader can set Take Profit, Stop Loss, Trailing Stop Loss (with Step) and Slippage in pips
- The TSL is activated when the trade is in profit
- Trader can set the maximum number of opened orders
- Trader can set the risk per trade to be calculated automatically or manual lots
- Trader can set the maximum risk of opened orders (a trade in profit liberates its risk for incoming orders)
- Optional Email and Sound Alerts for Orders

 [Highly_Adaptable_Bollinger_Band_EA.mq4](files/111630/Highly_Adaptable_Bollinger_Band_EA.mq4)


---

## Re: Highly adaptable Bollinger Band Strategy

**NuftyEas** · Mon Sep 25, 2017 7:45 am

Hi

Just a quick thankyou for the code

I downloaded it from somewhere off the net, and am glad it still had the owners details in the header as I could come here and say thanks

Appreciate the effort from the author

Nufty


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Mon Sep 25, 2017 3:56 pm

You're welcome.


---

## Re: Highly adaptable Bollinger Band Strategy

**easetup** · Sun May 20, 2018 7:37 am

A great work, could it be possible to add a trading hour like start 00:00 Stop: 00:00?
It would be very much appreciated!


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Thu May 24, 2018 4:25 am

Your request is added to the development list under Id Number 4151


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Thu Jun 14, 2018 7:40 am

Try this version.


---

## Re: Highly adaptable Bollinger Band Strategy

**Sufiki** · Thu Mar 04, 2021 10:01 am

> **Apprentice wrote:**
> Try this version.

is it possible to add more prce order type such as

1. buy limit
2. sell limit
3. buy stop
4. sellstop
5. and also add price combination, for example buy + sell limit, or sell + buy stop, or other combination

Setup in limit = Current price + X Point (X defined by user). Stoploss and Takeprofit follow existing rule.

Thanks mario


---

## Re: Highly adaptable Bollinger Band Strategy

**Sufiki** · Thu Mar 04, 2021 10:20 am

is it possible to modify this ea?


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Thu Mar 04, 2021 12:17 pm

Your request is added to the development list.
Development reference 250.


---

## Re: Highly adaptable Bollinger Band Strategy

**Sufiki** · Thu Mar 04, 2021 2:07 pm

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 250.

one thing i forgot to write above, please also delete or modify price to current price + X pip. This is only if any new candle close outside line.

thanks mr


---

## Re: Highly adaptable Bollinger Band Strategy

**fortesan9** · Tue May 04, 2021 2:38 pm

Can this strategy be done on lua ?


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Tue May 04, 2021 3:46 pm

Highly Adaptable Bollinger Band Strategy.lua is written in lua.


---

## Re: Highly adaptable Bollinger Band Strategy

**Apprentice** · Thu May 27, 2021 4:34 am

[Highly_Adaptable_Bollinger_Band_EA.mq4](files/142309/Highly_Adaptable_Bollinger_Band_EA.mq4)

Try this version.
