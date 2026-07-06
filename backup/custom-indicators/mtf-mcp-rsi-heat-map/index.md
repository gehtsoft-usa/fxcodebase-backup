# MTF MCP RSI Heat Map

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60277  
> Forum: 17 · Topic 60277 · 8 post(s)


---

## MTF MCP RSI Heat Map

**Apprentice** · Tue Feb 04, 2014 10:37 am

![AUDCAD H1 (09-18-2017 0914).png](images/92485/AUDCAD%20H1%20%2809-18-2017%200914%29.png)



One of the three filters can be applied.
Slope - Color reflects the value of the RSI compared to the previous value.
Central Line Position - Color reflects the value of RSI relative to the center line.
RSI Value - Color reflects the value of the RSI within 0-100 Range

 [MTF MCP RSI Heat Map.lua](files/92485/MTF%20MCP%20RSI%20Heat%20Map.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=65105](https://fxcodebase.com/code/viewtopic.php?f=38&t=65105)


---

## Re: MTF MCP RSI Heat Map

**Jacques** · Sun Feb 09, 2014 1:47 am

Thanks for making this indicator, Apprentice.

Best regards,
Jacques


---

## Re: MTF MCP RSI Heat Map

**mstreck** · Thu Mar 20, 2014 5:10 pm

Hi Apprentice,

I have not yet studied the new sync feature of multiple streams, so I apologise for asking a basic question. Still, I would like to know whether it is true that the history part of this indicator updates each value of a stream only once per its own time frame close, and in live part, all streams are updated on the lowest time frame. Visually, it appears to be the case. Can you explain / confirm?

Thanks,
Martin


---

## Re: MTF MCP RSI Heat Map

**Apprentice** · Sat Mar 22, 2014 3:06 am

U can only choose time frames equivalent to or greater than the chart time frame.
All data is updated every time, chart time frame is changed.


---

## Re: MTF MCP RSI Heat Map

**mstreck** · Sat Mar 22, 2014 7:07 am

Thanks, Apprentice.

I am not sure I entirely understood your answer.

Example, I select H1 and H4 on a H1 chart.

I see that the updates of live price feed happen for both H1 and H4 streams each hour.

The question is whether the history plot updated the H4 line each hour as well, or only on each H4 bar close?

It looks to me that the history part updated the H4 line only on each H4 bar close.

Cheers,
Martin


---

## Re: MTF MCP RSI Heat Map

**leguennecdavid74** · Fri Sep 08, 2017 6:36 am

Hey Apprentice,
Is it possible to create a strategy with the MTF MCP RSI Heat Map. I would like to choose my different time frame and open a position when the time frame select have the same color and close my position when one of them change.
Thanks !
David


---

## Re: MTF MCP RSI Heat Map

**Apprentice** · Sun Sep 10, 2017 6:07 pm

What do you want "RSI Value" to be handled?
As it is coded we will hardly ever have same color.


---

## Re: MTF MCP RSI Heat Map

**Apprentice** · Sun Feb 04, 2018 8:32 am

The indicator was revised and updated.
