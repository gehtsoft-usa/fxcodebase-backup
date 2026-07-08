# Logarithmic regression strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4050  
> Forum: 31 · Topic 4050 · 4 post(s)

---

## Logarithmic regression strategy

**Alexander.Gettinger** · Wed Apr 27, 2011 11:59 pm

Strategy based on Logarithmic regression indicator ([viewtopic.php?f=17&t=3716](https://fxcodebase.com/code/viewtopic.php?f=17&t=3716)).

BUY condition: price exceeds upper line by [Distance] number of pips.
SELL condition: price exceeds bottom line by [Distance] number of pips.

Download:

 [LogarithmicRegression_Strategy.lua](files/10135/LogarithmicRegression_Strategy.lua)

For this strategy must be installed Logarithmic regression indicator ([viewtopic.php?f=17&t=3716](https://fxcodebase.com/code/viewtopic.php?f=17&t=3716)).

The Strategy was revised and updated on November 19, 2018.

---

## Re: Logarithmic regression strategy

**Exolon** · Fri Jul 08, 2011 8:40 am

Backtesting this on EUR/USD, H1 caused an infinite loop (or at least hung Marketscope/FTS for about two minutes until I killed the whole thing). I'm not sure how, since there only seems to be one loop in the program, unless "enum:next()" doesn't actually advance the enumerator?

---

## Re: Logarithmic regression strategy

**Exolon** · Fri Jul 29, 2011 10:00 am

Just a quick note; I was trying to debug this strategy and the size was a bit overwhelming. Every line of code we don't write is by definition correct, and makes the program easier to debug.

So the following long if/else construct in the strategy...

```lua
Price=instance.parameters.Price;
    if Price=="close" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.close, instance.parameters.Period, instance.parameters.Deviation);
    elseif Price=="open" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.open, instance.parameters.Period, instance.parameters.Deviation);
    elseif Price=="high" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.high, instance.parameters.Period, instance.parameters.Deviation);
    elseif Price=="low" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.low, instance.parameters.Period, instance.parameters.Deviation);
    elseif Price=="typical" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.typical, instance.parameters.Period, instance.parameters.Deviation);
    elseif Price=="median" then
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.median, instance.parameters.Period, instance.parameters.Deviation);
    else
     LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source.weighted, instance.parameters.Period, instance.parameters.Deviation);
    end
```

...is functionally equivalent to this much shorter code:

```lua
Price = instance.parameters.Price or 'weighted'
    LR = core.indicators:create("LOGARITHMIC_REGRESSION", Source[Price], instance.parameters.Period, instance.parameters.Deviation)
```

---

## Re: Logarithmic regression strategy

**Apprentice** · Wed Nov 30, 2016 8:43 am

Bump up.
