# Ichimoku ATR Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=12424  
> Forum: 31 · Topic 12424 · 2 post(s)


---

## Ichimoku ATR Strategy

**Apprentice** · Sun Jan 29, 2012 12:52 pm

![Ichimoku ATR Strategy.png](images/24527/Ichimoku%20ATR%20Strategy.png)



1.ichimokov with default settings
2.atr period 14
multiplier for entry 2.0
multiplier for stop loss 1.0
multiplier for take profit 1.5

buy:

1. price cross under SB of the period of price(perod of SB-x) and
2. SA ( period ) > SB (period )
3.SA(period ) - SB ( period ) > multiplier for entry (2.0) * ATR

sell:
1. price cross under SB (perod-x) and
2. SB ( period) > SA (period)
3.SB(period x) - SA( period ) > multiplier for entry (2.0) * ATR

close buy:

1. price reaches price for take profit [ entry price + multiplier for take profit [1.5]* atr]
2. price reaches price for stop loss [entry price - multiplier for stop loss[1.0]* atr]

close sell:

1. price reaches price for take profit [ entry price - multiplier for take profit [1.5]* atr]
2. price reaches price for stop loss [entry price+ multiplier for stop loss[1.0]* atr]

 [Ichimoku ATR Strategy.lua](files/24527/Ichimoku%20ATR%20Strategy.lua)

The Strategy was revised and updated on November 22, 2018.


---

## Re: Ichimoku ATR Strategy

**Apprentice** · Sun Dec 04, 2016 9:01 am

Bump up.
