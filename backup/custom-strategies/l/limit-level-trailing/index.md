# Limit level trailing

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=19945  
> Forum: 31 · Topic 19945 · 9 post(s)

---

## Limit level trailing

**Alexander.Gettinger** · Tue Jun 05, 2012 3:21 pm

The strategy for take profit trailing.

User can define limit level and trailing step.

Download:

 [Trailing_Limit.lua](files/35124/Trailing_Limit.lua)

 [Trailing_Limit_All.lua](files/35124/Trailing_Limit_All.lua)

---

## Re: Limit level trailing

**peterpap** · Mon Jun 03, 2013 12:51 pm

Nice idea!
It works with all the orders for the selected pair!
But I would like a limit order to be more dynamic moving back and forward ready to close your position with max profits or less losses.
I tried to connect the limit order with a parameter like the Fractal. So I made a limit order stradegy which follows the Up Fractal with limit order going up and down (if you wish) similar to FractalStop stradegy which follows the Down Fractal.
I think that I' m gonna be rich!!!

Best Regards

---

## Re: Limit level trailing

**LordTwig** · Sat Nov 02, 2013 9:27 pm

Why not just add this 'Trailing Limit' and 'Trailing Step' features CODE to the lua codebase instead and like totally uncomplicate it.

Then there is no reason to have this whole strategy to do this simple task.

So this would work for LIMITS ........

```lua
strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", true);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 1000, 1, 10000);
    strategy.parameters:addBoolean("TrailingLimit", "Trailing Limit order", "", false);
    strategy.parameters:addInteger("TrailingLimitStep", "Trailing Limit step", "", 1, 1, 500);
.....
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit;
        TrailingLimit = instance.parameters.TrailingLimit;
        TrailingLimitStep = instance.parameters.TrailingLimitStep;
.....
   -- Create limit order using specified pip offset
   if SetLimit then
      valuemap.PegTypeLimit = "O";
      if BuySell == "B" then
         valuemap.PegPriceOffsetPipsLimit = Limit;
      else
         valuemap.PegPriceOffsetPipsLimit = -Limit;
      end
      if TrailingLimit then
         valuemap.TrailStepLimit = TrailingLimitStep;
      end
   end
```

Just as this does for STOPS .....

```lua
strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", true);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 100, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addInteger("TrailingStopStep", "Trailing stop step", "", 1, 1, 500);
.....
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop;
        TrailingStop = instance.parameters.TrailingStop;
        TrailingStopStep = instance.parameters.TrailingStopStep;

.....
    -- Create stop order using specified pip offset
   if SetStop then
      valuemap.PegTypeStop = "O";
      if BuySell == "B" then
         valuemap.PegPriceOffsetPipsStop = -Stop;
      else
         valuemap.PegPriceOffsetPipsStop = Stop;
      end
      if TrailingStop then
         valuemap.TrailStepStop = TrailingStopStep;
      end
   end
```

So as long as they added to the LUA CODE BASE they are easy to implement...... in the same way as are the Stops.
Please implement this.....

---

## Re: Limit level trailing

**LordTwig** · Sun May 04, 2014 1:04 am

Has this been implemented into lua codebase yet?

---

## Re: Limit level trailing

**LordTwig** · Tue Sep 09, 2014 11:42 pm

So can this be done??
Can it be added to the lua codebase?
If so why not do it?
Aren't we after simpler rather than complicated?

Cheers
Lordtwig

---

## Re: Limit level trailing

**Apprentice** · Sun Dec 11, 2016 6:24 am

Strategy was revised and updated.

---

## Re: Limit level trailing

**conjure** · Sun Jul 22, 2018 8:04 am

this is almost what i need.
Except one thing.
is it possible for the strategy to automatically search and find LimitLevel
for every new trade that opens?
and trail as it does?
even if i move the limit manual after position has opened?

---

## Re: Limit level trailing

**Apprentice** · Sat Aug 04, 2018 6:52 am

Your request is added to the development list under Id Number 4211

---

## Re: Limit level trailing

**Apprentice** · Mon Aug 06, 2018 9:15 am

Trailing_Limit_All.lua
