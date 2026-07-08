# Multitimeframe Ehler's Center of Gravity heat map.

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=1617  
> Forum: 17 · Topic 1617 · 13 post(s)

---

## Multitimeframe Ehler's Center of Gravity heat map.

**Alexander.Gettinger** · Fri Jul 30, 2010 2:31 am

![EURUSD H1 (01-27-2017 0954).png](images/3201/EURUSD%20H1%20%2801-27-2017%200954%29.png)

 [Ehlers_CG_Heat_Map.lua](files/3201/Ehlers_CG_Heat_Map.lua)

Ehlers_CG.lua is available here.
[viewtopic.php?f=17&t=1262&hilit=John+Ehler%27s+indicators](https://fxcodebase.com/code/viewtopic.php?f=17&t=1262&hilit=John+Ehler%27s+indicators)

MT4/MQ4 version.
[viewtopic.php?f=38&t=64099](https://fxcodebase.com/code/viewtopic.php?f=38&t=64099)

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**zekelogan** · Fri Jul 30, 2010 8:56 am

So very cool Thanks much.

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**zekelogan** · Fri Jul 30, 2010 9:43 am

Not to be too picky , but is it possible to be able to toggle the labels on/off ?

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**Alexander.Gettinger** · Mon Aug 02, 2010 1:52 am

You want on/off top or right labels?

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**zekelogan** · Mon Aug 02, 2010 12:36 pm

Right labels. They cover the most recent 'print.'

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**zekelogan** · Tue Aug 03, 2010 7:15 am

Thx Alexander!

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**one2share** · Tue Aug 17, 2010 5:24 pm

hey guys, i'm trying download, and I did however it tell me the request indicator is not found....so it does not display anything...can you guys help?

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**Alexander.Gettinger** · Wed Aug 18, 2010 8:22 pm

Sorry.
For work this indicator must be installed Ehlers_CG.lua ([viewtopic.php?f=17&t=1262&p=2398&hilit=ehler#p2398](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=1262&p=2398&hilit=ehler#p2398)).

```lua
function Init()
    indicator:name("Ehlers CG Oscillator");
    indicator:description("Ehlers CG Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addInteger("Length", "Length", "", 10);

    indicator.parameters:addColor("clr_buff1", "Color of Buff1", "Color of Buff1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr_buff2", "Color of Buff2", "Color of Buff2", core.rgb(0, 128, 0));
end

local first;
local source = nil;
local Length;
local Price;
local Buff1=nil;
local Buff2=nil;

function Prepare()
    source = instance.source;
    Length=instance.parameters.Length;
    Price = instance:addInternalStream(0, 0);
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ")";
    instance:name(name);
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr_buff1, first);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr_buff2, first);
    Buff1:addLevel(0);
end

function Update(period, mode)
    if (period>first+Length) then
     local Num=0.;
     local Demon=0.;
     Price[period]=(source.high[period]+source.low[period])/2.;
     for i=0,Length-1,1 do
      Num=Num+(i+1)*Price[period-i];
      Demon=Demon+Price[period-i];
     end
     if Demon~=0. then
      Buff1[period]=-Num/Demon+(Length+1.)/2.;
     else
      Buff1[period]=0.;
     end
     Buff2[period]=Buff1[period-1];
    end
end
```

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**one2share** · Wed Aug 25, 2010 1:23 pm

thanks it is working now....I do have a signal request...I use this along with the MTF moving average indicator....it is possible to have a signal alert me when both the mtf moving averages indicator and mtf ehler center of gravity heat map are the same color? for example when all are red it indicates a time to sell and green for buy. I still like the option of time frames you have but a signal would be nice, is this possible? i'm thinking adding sound option would be nice

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**one2share** · Fri Sep 03, 2010 5:10 am

does any one know when my requested signal will be ready?

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**one2share** · Fri Sep 17, 2010 5:10 pm

Can someone please, please, please, help me with this signal..

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**Apprentice** · Fri Oct 15, 2010 6:29 pm

Sabrina
Finally, after a long wait, your signal is finished.
Was written after the close on Friday, so I have not tested it.
[viewtopic.php?f=31&t=2420&p=5253#p5253](https://fxcodebase.com/code/viewtopic.php?f=31&t=2420&p=5253#p5253)

---

## Re: Multitimeframe Ehler's Center of Gravity heat map.

**Apprentice** · Mon Feb 05, 2018 8:51 am

The Indicator was revised and updated.
