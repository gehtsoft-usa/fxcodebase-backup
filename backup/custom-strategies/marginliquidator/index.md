# MarginLiquidator

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3964  
> Forum: 31 · Topic 3964 · 4 post(s)


---

## MarginLiquidator

**Apprentice** · Tue Apr 19, 2011 10:46 am

[MarginLiquidator.lua](files/9826/MarginLiquidator.lua)

What's the strategy to.

If usable margin falls below XX% this strategy will liqudate X lots to maintain XX% usable margin.

Warning.
I have not wrote or tested this strategy.

The Strategy was revised and updated on January 19, 2019.


---

## Re: MarginLiquidator

**Apprentice** · Wed Nov 30, 2016 5:48 am

Bump up.


---

## Re: MarginLiquidator

**syncoopate** · Wed Jan 04, 2017 7:08 am

you can place upper margin limit to Buy N_lots for decrease margin of xx%

this is idea for strategy :
-------------------------------------------------------------------
INPUT
-Account N°
- Price to open Position (Buy or Sell) or Date/Time To open Position
-Lot_Multiple = 1 ( example if Increase 10 Lot's Open 10 * 1lot ; not 1*10Lot )
-level UsableMargin Start = 70%
-level UsableMarginLiquidator = 60%
-level UsableMarginIncreaseLots = 80%
-%ProfitEquity = 200% .....( equity/InitialBalance)*100
-%StopEquity = 20%.....( equity/InitialBalance)*100
-CriteriaClosePosition = LessGain or MaxLost

-------------------------------------------------------------------------

1) Target Price OK
2) open N_lots for decrease (100%UsableMargin ) at ("UsableMargin Start" 70%)

3) if UsableMargin <= UsableMarginLiquidator then
 Decrease N_Lot for Increase UsableMargin at "UsableMargin Start"

4) if UsableMargin >= UsableMarginIncreaseLots then
 Increase N_Lot for Decrease UsableMargin at "UsableMargin Start"

5) if Equity => "%ProfitEquity" then
CloseAll Position and stop Strategy

6)if Equity =< "%StopEquity" then
CloseAll Position and stop Strategy

 ok???


---

## Re: MarginLiquidator

**Apprentice** · Sun Jan 08, 2017 6:21 am

Your request is added to the development list, Under Id Number 3708
 If someone is interested to do this task, please contact me.
