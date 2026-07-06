# US30 PSAR+EMA Simple Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=73580  
> Forum: 38 · Topic 73580 · 5 post(s)


---

## US30 PSAR+EMA Simple Strategy

**Tesramaestro** · Sat Apr 08, 2023 9:00 pm

Hello Good people,

Humble request to the coders here, Please code an EA with this parameters to auto trade USA30

Goal:
- 50pips/day
- Get out of the market as soon as possible.

Indicators

1. Moving Average Exponential
- Inputs: Change the length to 100.
- Style: Pick any colour

2. Parabolic SAR by everget
- Leave the settings as they are.
- Style: Change the colours as you like

Rules
Daily target: 50 pips.

Get out of market:
- IF you reach +50 pips. Dont overtrade! There will always be another opportunity the next day.
- IF you get 4 losses in a row, OR -100pips

Take profit: 50pips
Stop-loss: 25pips
Break-even: 30-40pips

Include the following and any other parameters you may deem fit to make the EA work perfectly.

Opening time
Closing time
Number of trade to take.
Lot size 0.10
Open new orders after closing on previous on profit.
Alert on new potential opening on buy/sell signal

Buy
1. Price is ABOVE EMA100.
2. Once a BUY signal appears, draw a line on the last Sell dot SAR indicator created.
3. Wait for the candle to close ABOVE the line
4. Enter the trade on the next candle > TP=50pips; SL=25pips

Sell
1. Price is BELOW EMA100.
2. Once a SELL signal appears, draw a line on the last Buy dot SAR indicator created.
3. Wait for the candle to close BELOW the line
4. Enter the trade on the next candle > TP=50pips; SL=25pips

Other
This strategy can be traded in LDN or NY session.
BEST time to trade this strategy is after 1pm London time.
IF there are news at 1:30pm - Wait for them to finish before you start!
IF there are important news that day, the market will range, especially in LDN session.
No big candles entries especially after NY open.

Much Appreciated

Thanks


---

## Re: US30 PSAR+EMA Simple Strategy

**Apprentice** · Wed Apr 12, 2023 3:33 am

We have added your request to the development list.
Development reference 317.


---

## Re: US30 PSAR+EMA Simple Strategy

**DVengeance** · Wed Apr 12, 2023 2:16 pm

Hi,

I have written something similar for myself, so you can try it and partially test your idea. It doesn't have the news filter or the entire money management you want, but it has Fixed lot or percentage risk, SL/TP and Time filter (your local time zone).

The signals are when the SAR switches (and not when a candle closes above the previous SAR signal). The entry happens on the next candle open., if the previous candle was above the EMA100.

It's not too bad as a strategy - last 4 months-> 100+ trades, 1% risk per trade,
28% Return, 8% Drawdown. FTMO would be proud

Let me know what results you get, what time frames you test etc.

The final result I'm showing is not the same system, but rather a variation of it.


---

## Re: US30 PSAR+EMA Simple Strategy

**Apprentice** · Wed Jun 07, 2023 7:38 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=73804](https://fxcodebase.com/code/viewtopic.php?f=38&t=73804)


---

## Re: US30 PSAR+EMA Simple Strategy

**samuel84** · Mon Jun 09, 2025 12:29 pm

> **Apprentice wrote:**
> Try this version.
> [https://fxcodebase.com/code/viewtopic.php?f=38&t=73804](https://fxcodebase.com/code/viewtopic.php?f=38&t=73804)

indicator can't be loaded. tried backtest the expert but also not able even after I changed the filename of inicator as per stated in expert code.
