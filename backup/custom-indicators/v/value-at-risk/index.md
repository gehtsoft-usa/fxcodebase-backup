# Value-at-Risk

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=21843  
> Forum: 17 · Topic 21843 · 3 post(s)


---

## Value-at-Risk

**gmiller** · Wed Aug 01, 2012 8:02 pm

In addition to Probability Bands there is another interesting application for Historic Volatility: Value-at-Risk.

Value of Risk (VaR) is the loss, in value terms, due market, that we are reasonably confident will not be exceeded if the position is held static over certain period of time. We cannot say anything for certain about a position PnL because it is a random variable, but we can associate a confidence level with any loss. In more intuitive form we can say VaR is a worse loss over a target horizon with a given level of confidence.

More details are on wiki :[Value-at-Risk](https://fxcodebase.com/wiki/index.php/Indicator_within_Indicator_(VaR))

Requires [HV_TICK.lua](https://fxcodebase.com/code/viewtopic.php?f=17&t=21021#p36829)

The indicator was revised and updated


---

## Re: Value-at-Risk

**mjf1288** · Wed Aug 01, 2012 9:55 pm

shouldnt Var be calculated upon your balance or equity curve instead of an instrument?


---

## Re: Value-at-Risk

**Apprentice** · Thu Apr 06, 2017 3:31 pm

Indicator was revised and updated.
