# Time-frame trade management strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=60359  
> Forum: 31 · Topic 60359 · 7 post(s)


---

## Time-frame trade management strategy

**moomoofx** · Thu Feb 27, 2014 6:08 am

As requested on: [viewtopic.php?f=27&t=60233](https://fxcodebase.com/code/viewtopic.php?f=27&t=60233)

This strategy allows you to define a set of actions to take place when the price closes above or below a specified price value for any timeframe.

Any combination of the following set of actions are permitted
- Enter Long
- Enter Short
- Close Long
- Close Short
- Alert
- Stop Strategy

Stop Strategy is recommended unless you would like the action to keep happening if the price stays above/below the specified price value.

Happy Trading.

Cheers,
MooMooFX

The Strategy was revised and updated on December 11, 2018.


---

## Re: Time-frame trade management strategy

**Kyriakos** · Mon Mar 03, 2014 12:53 pm

Hi,

Thank you for the strategy. I tested it in small time-frames and it works great. I will let you know if i find any issues in bigger time-frames especially on daily charts.


---

## Re: Time-frame trade management strategy

**kankatrader** · Tue Sep 30, 2014 12:46 pm

Hi moomoofx,

if i select only below a specified price value, in combination with enter short or long
the strategy does not open any position.

Entry Signal for Ma Parameters: "Above " works well
Entry Signal for Ma Parameters: "below" has no function.

Can you fix it

Best Regards

kankatrader


---

## Re: Time-frame trade management strategy

**moomoofx** · Tue Sep 30, 2014 6:27 pm

Works for me. Please send me a screenshot of your configuration.

Thank you,
MooMooFX


---

## Re: Time-frame trade management strategy

**kankatrader** · Wed Oct 01, 2014 2:38 pm

> **moomoofx wrote:**
> Works for me. Please send me a screenshot of your configuration.
>
> Thank you,
> MooMooFX

Here is my settings:


---

## Re: Time-frame trade management strategy

**moomoofx** · Thu Oct 02, 2014 8:40 am

EURUSD hasn't dropped below 1.2 in the last 2 years so it isn't surprising it isn't trading?

If I backtest that configuration with a value of 1.3000 instead, it trades when expected.

Cheers,
MooMooFX


---

## Re: Time-frame trade management strategy

**Apprentice** · Sun Dec 11, 2016 6:32 am

Strategy was revised and updated.
