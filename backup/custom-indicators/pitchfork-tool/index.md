# Pitchfork Tool

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61065  
> Forum: 17 · Topic 61065 · 25 post(s)


---

## Pitchfork Tool

**Apprentice** · Fri Aug 22, 2014 11:35 am

![Pitchfork Tool.png](images/95502/Pitchfork%20Tool.png)



Based on the request
[viewtopic.php?f=27&t=15577&p=95501#p95501](https://fxcodebase.com/code/viewtopic.php?f=27&t=15577&p=95501#p95501)

 [Pitchfork Tool.lua](files/95502/Pitchfork%20Tool.lua)

 [Auto Pitchfork Tool.bin](files/95502/Auto%20Pitchfork%20Tool.bin)


---

## Re: Pitchfork Tool

**7510109079** · Tue Aug 26, 2014 9:22 am

thx for working on this and I note that it is still in dev phase, however i cant draw ANY pitchforks with the GUI. Does this .lua modify the functionality of the existing PF button in Marketscope or are these PFs drawn independently of the inbuilt PF functionality?

If the latter, when does the user draw the PF. Not sure my ver is working at all. Can you clarify thx


---

## Re: Pitchfork Tool

**Apprentice** · Tue Aug 26, 2014 10:44 am

After you add Pitchfork Tool to your chart.
You must define Pitchfork,
you can do it via, three points, menu available via Left mouse button.
Set A Point , Set B Point , Set C Point.


---

## Re: Pitchfork Tool

**7510109079** · Tue Aug 26, 2014 2:22 pm

got it. many thx


---

## Re: Pitchfork Tool

**shipmark33** · Fri Oct 03, 2014 5:54 am

however i cant draw ANY pitchforks with the GUI. Does this .lua modify the functionality of the existing PF button in Marketscope or are these PFs drawn independently of the inbuilt PF functionality?


---

## Re: Pitchfork Tool

**Apprentice** · Sat Oct 04, 2014 2:30 am

This indicator is independently entity from inbuilt PF tool.


---

## Re: Pitchfork Tool

**Apprentice** · Tue Nov 07, 2017 4:36 pm

The indicator was revised and updated.


---

## Re: Pitchfork Tool

**Apprentice** · Tue Nov 07, 2017 5:45 pm

Auto Pitchfork Tool.bin added.


---

## Re: Pitchfork Tool

**Cactus** · Tue Nov 07, 2017 9:41 pm

Nice work with the auto pitchfork mister

Can you make versions with:
- Multiple pitchforks drawn from one indicator (show historical), with output streams for each?
- Draw the pitchforks based on A (handle), B (high), C(low) points defined from .csv file? Similar to "ZigZag Channel" and "Auto Trend Lines" or "Diagonal lines from file" threads really...


---

## Re: Pitchfork Tool

**Apprentice** · Thu Nov 09, 2017 6:45 am

Fixed.


---

## Re: Pitchfork Tool

**papynou34** · Thu Nov 09, 2017 7:28 am

Thanks Apprentice.
You only deliver the .bin version?


---

## Re: Pitchfork Tool

**Apprentice** · Thu Nov 09, 2017 8:03 am

Yes.
.bin is used in the same way as .lua.


---

## Re: Pitchfork Tool

**papynou34** · Thu Nov 09, 2017 9:05 am

Thanks Appendice.
I know that, but even for a small modification, we have to asked you.
However, thanks a lot.


---

## Re: Pitchfork Tool

**Cactus** · Thu Nov 09, 2017 4:20 pm

> **Apprentice wrote:**
> Fixed.

I appreciate your efforts but it suffers two problems:
Lines disappear when zooming in
- If points on which pitchfork is defined are not in view, all lines disappear even if extended
Lines are wobbly and moving around when stretching the chart
- Not sure what is used for drawing line (Draw method, host:execute ("drawLine", pen) or something else but it is likely that which causes this behavior isn't it

Would be nice if a version which accepts csv file still can be made to draw the pitchforks


---

## Re: Pitchfork Tool

**Apprentice** · Fri Nov 10, 2017 5:25 am

Have use draw function.
This is the result of performance, optimization.
Will try to re-write using other methods.

Your request is added to the development list under Id Number 3948


---

## Re: Pitchfork Tool

**Apprentice** · Fri Dec 01, 2017 6:58 am

[Pitchfork Tool.lua](files/116310/Pitchfork%20Tool.lua)

 [example_usd_jpy.csv](files/116310/example_usd_jpy.csv)

-fix extend line mode
-add csv support


---

## Re: Pitchfork Tool

**Apprentice** · Mon Feb 05, 2018 11:04 am

The Indicator was revised and updated.


---

## Re: Pitchfork Tool

**logicgate** · Sun Apr 26, 2020 8:43 am

Hi there dear friend Apprentice, hope all is good and you are safe.

I wonder if you could code this pitchfork indicator for MT4? The one in MT4 is a bit limited.

These are the extras I wanted to see:

-being able to show extra levels in standard deviations of the median line where you could choose the size: 50% - 100% - 200%, etc... You could activate those lines in indicator settings, to show or hide them. I think that 6 extra levels are good enough.

-that you could also configure it with fibonacci levels on it (like in the fibo channel tool)

[https://www.metatrader5.com/en/terminal ... bo_channel](https://www.metatrader5.com/en/terminal/help/objects/fibo/fibo_channel)

Best regards


---

## Re: Pitchfork Tool

**Apprentice** · Mon Apr 27, 2020 4:27 am

Your request is added to the development list.
Development reference 1150.


---

## Re: Pitchfork Tool

**Apprentice** · Tue Apr 28, 2020 10:38 am

MT4 doesn't support custom tools.
We can only input time/date and value via parameters.
Will this be satisfactory?


---

## Re: Pitchfork Tool

**logicgate** · Mon May 11, 2020 3:59 pm

> **Apprentice wrote:**
> MT4 doesn't support custom tools.
> We can only input time/date and value via parameters.
> Will this be satisfactory?

Hi my friend! thanks for looking into it.

Nah, forget it. I will use tradingview for pitchfork analysis, the tool is very good there.

All the best


---

## Re: Pitchfork Tool

**spinemaligna** · Sun Apr 18, 2021 4:20 am

Hi All,

Not sure if I am asking for the impossible but there are a couple of modifications which would make this much easier to use.
I find it impossible to get the tool to draw on exact mouse click positions. It is always out to the left. Would it be possible to add the facility to drag the points?
I add the Fib Channel along the B-C chord to give me levels to work from. Can this be incorporated into the tool to save countless set ups each morning and if so can I request colour options as per Fib Retracement.
The other big bug bear as that the Fractal arrows are too close to the candle which prevents the ABC mouse clicks from hitting the correct spot. All it does is bring up the fractal properties panel.

Thanks

Ross


---

## Re: Pitchfork Tool

**Apprentice** · Mon Apr 19, 2021 2:15 am

Your request is added to the development list.
Development reference 374.


---

## Re: Pitchfork Tool

**Apprentice** · Tue Apr 20, 2021 3:58 pm

This is the best we can do.


---

## Re: Pitchfork Tool

**spinemaligna** · Sat Apr 24, 2021 3:20 am

OK. Thanks anyway.
