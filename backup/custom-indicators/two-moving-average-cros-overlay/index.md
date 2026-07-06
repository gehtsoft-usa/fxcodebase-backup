# Two Moving Average CROS Overlay

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2385  
> Forum: 17 · Topic 2385 · 13 post(s)


---

## Two Moving Average CROS Overlay

**Apprentice** · Tue Oct 12, 2010 11:55 am

![TWO_MA_ CROS_Overlay.png](images/5148/TWO_MA_%20CROS_Overlay.png)



When the shorter moving average is above the long, Candles are Green
And vice versa.

 [TWO_MA_ CROS_Overlay.lua](files/5148/TWO_MA_%20CROS_Overlay.lua)

The indicator was revised and updated
MT4/MQ4 version
[viewtopic.php?f=38&t=66150](https://fxcodebase.com/code/viewtopic.php?f=38&t=66150)


---

## Re: Two Moving Average CROS Overlay

**Jigit Jigit** · Sat Feb 04, 2012 5:20 pm

Could you possibly add VAMA to this indicator, please?


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Sun Feb 05, 2012 2:55 am

I can, I will.


---

## Re: Two Moving Average CROS Overlay

**Jigit Jigit** · Sun Feb 05, 2012 5:35 am

Thanks a million Apprentice. I'll be much obliged.

Also, while you'll be at it, perhaps you could add VAMA option to the existing MA cross signal?

Code: [Select all](https://fxcodebase.com/code/)
`function Init()
    strategy:name(resources:get("R_Name"));
    strategy:description(resources:get("R_Description"));
    strategy:setTag("group", "Moving Averages");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:type(core.Signal);

    strategy.parameters:addGroup(resources:get("R_ParamGroup"));

    strategy.parameters:addInteger("FastN", resources:get("R_FastN"), "", 5);
    strategy.parameters:addInteger("SlowN", resources:get("R_SlowN"), "", 20);

    strategy.parameters:addString("Method", resources:get("R_Smooth"), "", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");

    strategy.parameters:addString("Type", resources:get("R_PriceType"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Bid"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Ask"), "", "Ask");

    strategy.parameters:addString("Period", resources:get("R_PeriodType"), "", "t1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup(resources:get("R_SignalGroup"));

    strategy.parameters:addBoolean("ShowAlert", resources:get("R_ShowAlert"), "", true);
    strategy.parameters:addBoolean("PlaySound", resources:get("R_PlaySound"), "", false);
    strategy.parameters:addBoolean("RecurrentSound", resources:get("R_RecurrentSound"), "", false);
    strategy.parameters:addFile("SoundFile", resources:get("R_SoundFile"), "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", resources:get("R_SENDEMAIL"), "", false);
    strategy.parameters:addString("Email", resources:get("R_EMAILADDRESS"), resources:get("R_EMAILADDRESSDESCR"), "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile;
local RecurrentSound;
local FastMA, SlowMA;
local BUY, SELL;
local gSource = nil;        -- the source stream
local SendEmail, Email;

function Prepare(onlyName)
    local FastN, SlowN;

    -- collect parameters
    FastN = instance.parameters.FastN;
    SlowN = instance.parameters.SlowN;
   
    --set name
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. FastN  .. "," .. SlowN .. ")";
    instance:name(name);
    if onlyName then
        return;
    end

    assert(FastN < SlowN, resources:get("R_MvaParamError"));

    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), resources:get("R_SoundFileError"));

    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), resources:get("R_EmailAddressError"));

   
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");

    FastMA = core.indicators:create(instance.parameters.Method, gSource, FastN);
    SlowMA = core.indicators:create(instance.parameters.Method, gSource, SlowN);

   
    --localization
    BUY = resources:get("R_BUY")
    SELL = resources:get("R_SELL")
    ExtSetupSignal(resources:get("R_Name") .. ":", ShowAlert);
    ExtSetupSignalMail(name);       
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    FastMA:update(core.UpdateLast);
    SlowMA:update(core.UpdateLast);

    if period < 1 or not(SlowMA.DATA:hasData(period - 1)) then
        return ;
    end

   if core.crossesOver(FastMA.DATA, SlowMA.DATA, period) then
        ExtSignal(gSource, period, BUY, SoundFile, Email, RecurrentSound);               
   elseif core.crossesOver(SlowMA.DATA, FastMA.DATA, period) then
        ExtSignal(gSource, period, SELL, SoundFile, Email, RecurrentSound);
   end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");`


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Sun Feb 05, 2012 12:18 pm

VAMA Average Added.

As for MA cross signal This is standard MA cross signal?


---

## Re: Two Moving Average CROS Overlay

**Jigit Jigit** · Sun Feb 05, 2012 12:56 pm

Hi Apprentice.
Thank you once again.

As for the code I pasted above (MA cross) - I found it in the "standard" folder in you know C:ProgramFiles/FXTS2/Strategies

But I would be happy with any signal alerting me of desired VAMA crossings.

Cheers


---

## Re: Two Moving Average CROS Overlay

**Jigit Jigit** · Mon Feb 06, 2012 5:42 am

Hello
I'm sorry guys for generating so much traffic around such petty things here...
but could you please add colour selection to the Two Moving Average Cross Overlay (the one with VAMA), i.e. I would like to be able to choose the colour of the indicator overlaying the normal candles.

Thanks a million.


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Tue Feb 07, 2012 4:32 am

Color option Added.


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Sun Mar 26, 2017 4:29 pm

Indicator was revised and updated.


---

## Re: Two Moving Average CROS Overlay

**TrendingEddie** · Mon Mar 02, 2020 10:51 am

Hi, Apprentice
I have a issue. Maybe you can help me? I tried to add indicator to the chart, but error appears.
Not sure why?


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Mon Mar 02, 2020 1:59 pm

Your request is added to the development list.
Development reference 805.


---

## Re: Two Moving Average CROS Overlay

**Apprentice** · Wed Mar 04, 2020 5:59 am

Try it now.


---

## Re: Two Moving Average CROS Overlay

**TrendingEddie** · Wed Mar 04, 2020 10:44 am

> **Apprentice wrote:**
> Try it now.

It works Thank you!
