# STARC Bands

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=228  
> Forum: 17 · Topic 228 · 7 post(s)

---

## STARC Bands

**TonyMod** · Wed Jan 06, 2010 1:58 pm

Hello Everybody,

Here is the STARC Bands indicator that was developed by user's request. Original topic with the request: **[http://www.fxcodebase.com/code/viewtopic.php?f=18&t=159](http://www.fxcodebase.com/code/viewtopic.php?f=18&t=159)**

Description on how to use this indicator you can find here:
**[http://www.investopedia.com/terms/s/starc.asp](http://www.investopedia.com/terms/s/starc.asp)**

**Screenshot:**

 

![STARC Band.jpg](images/321/STARC%20Band.jpg)

*Screenshot from MarketScope.*

**Download:**

 [STARC.lua](files/321/STARC.lua)

 [Customizable STARC.lua](files/321/Customizable%20STARC.lua)

**Source:**

```lua
--- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("STARC Band");
    indicator:description("Indicates upper and lower limits of price movement.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
    indicator.parameters:addInteger("USM", "Multiplier", "The deviation multiplier", 2);
    indicator.parameters:addInteger("SMA_N", "Number of MVA periods", "The number of periods used in the Moving Average calculation", 6);
    indicator.parameters:addInteger("ATR_N", "Number of ATR periods", "The number of periods used in the Average True Range calculation", 14);
   
    indicator.parameters:addColor("UB_color", "Upper line color", "The color of the upper line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LB_color", "Lower line color", "The color of the lower line", core.rgb(255,0,0));
    indicator.parameters:addColor("AL_color", "Average line color", "The color of the average line", core.rgb(192,192,192));
end

-- Parameters block
local USM;

local first;
local source = nil;

-- internal indicators
local SMA = nil;
local ATR = nil;

-- Streams block
local UB = nil;
local LB = nil;
local AL = nil;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
function Prepare()
    USM = instance.parameters.USM;
    source = instance.source;   
    local SMA_N = instance.parameters.SMA_N;
    local ATR_N = instance.parameters.ATR_N;
    local PriceType = instance.parameters.SMA_source;
   
    local name = profile:id() .. "(" .. source:name() .. ", ".. USM .. ", ".. SMA_N .. ", ".. ATR_N .. ")";
    instance:name(name);   
   
    local pricestream = source.close;
   
    SMA = core.indicators:create("MVA", pricestream, SMA_N);
    ATR = core.indicators:create("ATR", source, ATR_N);
    first = math.max(SMA.DATA:first(), ATR.DATA:first());
    UB = instance:addStream("UB", core.Line, name, "Uppper Band", instance.parameters.UB_color, first);   
    LB = instance:addStream("LB", core.Line, name, "Lower Band", instance.parameters.LB_color, first);
    AL = instance:addStream("AL", core.Line, name, "Average", instance.parameters.AL_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    SMA:update(mode);
    ATR:update(mode);

    if period >= first and source:hasData(period) then
        local smaVal = SMA.DATA[period];
        local atrVal = USM * ATR.DATA[period];

        UB[period] = smaVal + atrVal;
        LB[period] = smaVal - atrVal;
        AL[period] = smaVal;
    end
end
```

Respond to this topic if you have questions.

---

## Re: STARC Bands

**ausjus18** · Sun May 30, 2010 6:29 am

This is a really useful indicator. Is there a way of allowing multipliers that are 0.1 increments, not just limited to 1,2,3 etc. Thanks.

---

## Re: STARC Bands

**Nikolay.Gekht** · Mon May 31, 2010 11:30 am

Yes, it is very easy. Only one line must be replaced
 indicator.parameters:add**Integer**("USM", "Multiplier", "The deviation multiplier", 2);
with
 indicator.parameters:add**Double**("USM", "Multiplier", "The deviation multiplier", 2);

Download the modified version.

---

## Re: STARC Bands

**ausjus18** · Tue Jun 01, 2010 8:14 pm

That's fantastic! Thank you Nikolay! Really appreciate your help.
Jürgen

---

## Re: STARC Bands

**Thecity** · Sun Apr 26, 2015 4:02 pm

Hello, It would be nice to have the possibility to choose from differents type of the moving average (Ema for example).

The concept "MA + ATR*multiplier" it's really interesting, thank you.

---

## Re: STARC Bands

**Apprentice** · Mon Apr 27, 2015 2:55 am

Customizable STARC.lua Added.

---

## Re: STARC Bands

**Apprentice** · Mon Oct 29, 2018 7:33 am

The indicator was revised and updated.
