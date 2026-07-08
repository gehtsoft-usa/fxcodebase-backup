# Average Daily Range (ADR) Projection

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2799  
> Forum: 17 · Topic 2799 · 47 post(s)

---

## Average Daily Range (ADR) Projection

**Apprentice** · Thu Nov 25, 2010 7:30 am

![ADR Projection.png](images/6370/ADR%20Projection.png)

ADR Projections Up = low[period] + ADR[period];
ADR Projections Down = high[period] - ADR[period];

Daily Range
DR = High[period] - Low [Period];
ADR = AVG ( DR, Period);
ATR is also supported, but is basically the same as ATR.

 [ADR Projection.lua](files/6370/ADR%20Projection.lua)

Multi Time Frame Version.
Allows selection of Time Frame

 [MTF ADR Projection.lua](files/6370/MTF%20ADR%20Projection.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=66195](https://fxcodebase.com/code/viewtopic.php?f=38&t=66195)

---

## Re: Average Daily Range (ADR) Projection

**luigifx** · Thu Sep 01, 2011 5:25 pm

Thanks a lot for your work apprentice !

This is a great indicator but I would like, instead of a line, have a zone called "confidence interval" around the ADR line.
By example for a confidence interval of 68% : [ADR-(SD/squareroot(N)) ; ADR-(SD/squareroot(N))]
where SD = Standard deviation on the period
and N = number of period
[http://fr.wikipedia.org/wiki/Intervalle_de_confiance](https://fr.wikipedia.org/wiki/Intervalle_de_confiance) this link is in french but you can see formula in example 1
here is the link in english : [http://en.wikipedia.org/wiki/Confidence_interval](https://en.wikipedia.org/wiki/Confidence_interval)

I would like to use this indicator on MTF ADR Projection and :
. be able to chose which confidence interval to set
. show the ADR line or not
.set up the color of upward and downward zone (as we already have in marketscope for the box draw)
.set up the color of line (as we already have in marketscope for the box draw)

Please tell me if you can develop this indicator
Thanks

---

## Re: Average Daily Range (ADR) Projection

**a1afx1111** · Tue Sep 13, 2011 8:00 am

I downloaded the indicator and all I got on the chart was two green lines.
How do I get the text that is shown in your screen shot?

---

## Re: Average Daily Range (ADR) Projection

**sunshine** · Tue Sep 13, 2011 8:14 am

Please try to move chart "in future" to see the text. For me this works.

---

## Re: Average Daily Range (ADR) Projection

**emjay-short** · Wed Sep 14, 2011 4:41 pm

The MTF version is nice. Thanks.
Showing Daily Range projection on a 15m chart.

---

## Re: Average Daily Range (ADR) Projection

**sabrumea** · Mon Oct 24, 2011 7:33 am

is it possible to add an option to display it historically???

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Mon Oct 24, 2011 4:40 pm

Your request is added to the developmental cue.

---

## Re: Average Daily Range (ADR) Projection

**sabrumea** · Sat Oct 29, 2011 12:56 pm

thank you Apprentice, looking forward to have it. it is very useful indicator!

---

## Re: Average Daily Range (ADR) Projection

**sabrumea** · Sat Oct 29, 2011 1:08 pm

Apprentice, sorry once you will do the historical option could you also fix the font of the text to make it a bit smaller? i was trying to do that myself but can not understand where is it in the code

---

## Re: Average Daily Range (ADR) Projection

**sabrumea** · Sat Oct 29, 2011 1:46 pm

Apprentice,

i have created font

```lua
local font;
function Prepare() 
   ...
   font = core.host:execute("createFont", "Verdana", 10, false, false);   
   ...
```

how should i call it now in the DrawLable1 function??

```lua
if TR[1] >TR[2] then
            core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5, "TR "..tostring( round( TR[1]* M,0)).. " (+)" );
            elseif  TR[1] < TR[2] then
            core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5, "TR "..tostring( round( TR[1]* M,0)) .." (-)" );
            else
            core.host:execute ("drawLabel", 1, source:date(source:size()-1) + 3*size , MAX + 2*(MAX-MIN)/5, "TR "..tostring( round( TR[1]* M,0)) .." (0)" );
            end
```

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Sun Oct 30, 2011 7:01 am

method host:execute("drawLabel", ...)
It does not support font size.

Instead, you can use.
host method: Execute ("drawLabel1", ...)

A complete description can be found here.
[http://www.fxcodebase.com/documents/Ind ... abel1.html](http://www.fxcodebase.com/documents/IndicoreSDK/host.execute_drawLabel1.html)

---

## Re: Average Daily Range (ADR) Projection

**sabrumea** · Wed Nov 02, 2011 7:22 am

oh well i tried that, friend, it is not working for me can you help me with it? could you fix the font option too when you would be doing historical version of this indicator?... the historical option would be very very useful! this is a good indicator especially on daily basis and with averaging for 8 periods! and the font option is necessary because right now you did this indicator in such a way that lines are not extended till the end of the period so it clatters the chart can not see my candles well .... so if you could either extend the lines till the end of the period or make the font option it would be really great!!!

---

## Re: Average Daily Range (ADR) Projection

**currencytrader** · Tue Nov 08, 2011 4:40 pm

this ADR calculates the last 5 days excluding the current active day? it makes it base of calculation from which point?

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Wed Nov 09, 2011 6:14 pm

From the current high / low,
Plus / Minus, ADR value for last N periods.

---

## Re: Average Daily Range (ADR) Projection

**Sepp64** · Thu Apr 26, 2012 8:40 am

Hello Apprentice,

Ref.: MTF ADR Projection.lua

In the ATR Projections calculations it seams to me, that in the formula you do include the current day in the calculation. ATR calculations should be done excluding the current day or candle!

Ej, For ATR5 you should use the last 5 already CLOSED daily candles for calcs. If the current day is taken into account then there is an ADR value based on an open candle and this value can anything from 0 upwards. This distorts the real ADR Projection for the Day which should be the same value for the entire day.

Can you please make the changes or let me know any comments you have on this,

Thanks

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Fri Apr 27, 2012 2:36 am

I guess that option can be added, which would enable the selection,
between these two possibilities.

---

## Re: Average Daily Range (ADR) Projection

**Sepp64** · Mon Apr 30, 2012 12:50 pm

Good,

would you please so kind and add this option.

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Tue May 01, 2012 8:26 am

I already put this on our list.

---

## Re: Average Daily Range (ADR) Projection

**Alexander.Gettinger** · Fri Jun 15, 2012 10:38 am

MQL4 version of this indicator: [viewtopic.php?f=38&t=20224](https://fxcodebase.com/code/viewtopic.php?f=38&t=20224)

---

## Re: Average Daily Range (ADR) Projection

**SuperTrader** · Mon Aug 13, 2012 3:09 am

This is a very useful indicator Apprentice, thank you for that. But can we please have the 4 text strings (on the screenshot) on the left side of the chart instead ? Or in one of the left corners (top/bottom). Or at least a user option for all the text positioned either on left or right side. This way we can use all that space on the right of the chart for more price bars (by shifting the chart all the way to the right extreme). Thank you very much in advance !

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Tue Aug 14, 2012 1:57 am

Your request is added to the development list.

---

## Re: Average Daily Range (ADR) Projection

**Jeffreyvnlk** · Sat May 04, 2013 8:20 pm

Could you shorten the projected horizontal lines ? thank you

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Sun May 05, 2013 6:10 am

Shorten, in what way ...
On left side of chart?

---

## Re: Average Daily Range (ADR) Projection

**Jeffreyvnlk** · Mon May 06, 2013 1:04 am

> **Apprentice wrote:**
> Shorten, in what way ...
> On left side of chart?

For example, if ADR for 1 week, the line just limited on that week

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Tue May 07, 2013 5:50 am

ADR Projection and MTF ADR Projection have been modified accordingly.

---

## Re: Average Daily Range (ADR) Projection

**Jeffreyvnlk** · Tue May 07, 2013 7:12 am

> **Apprentice wrote:**
> ADR Projection and MTF ADR Projection have been modified accordingly.

That perfect.Thank you very much

---

## Re: Average Daily Range (ADR) Projection

**Jeffreyvnlk** · Tue May 07, 2013 4:44 pm

> **Apprentice wrote:**
> ADR Projection and MTF ADR Projection have been modified accordingly.

Glad to have it.Very neat, many thanks

---

## Re: Average Daily Range (ADR) Projection

**BTrade** · Wed Nov 12, 2014 6:04 pm

Hi Apprentice,

I placed the MTF indicator on the chart ... the green lines starts at 12 o'clock. is it possible this indicator to work with the actual daily candle starts at 5 pm? I'm referring to Eastern Standard Time, New York.

Thanks,

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Thu Nov 13, 2014 2:14 am

Will consider it, when I find time.

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Tue Nov 18, 2014 3:00 pm

Any way to code this to so that it's optional of when to calculate the ADR i.e., 1700 to 1700. Can you put in a "Start Hour" option?

---

## Re: Average Daily Range (ADR) Projection

**rtsayers** · Fri Jan 02, 2015 2:28 am

I was wonder if you could add a thicker line setting and to be able to remove projection letters and numbers and just leave lines

Thanks

---

## Re: Average Daily Range (ADR) Projection

**rtsayers** · Fri Jan 02, 2015 2:30 am

Oh I forgot to mention I wanted to extend the lines and for the MTF version

Thanks

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Mon Jan 05, 2015 4:16 am

Required modifications added.

---

## Re: Average Daily Range (ADR) Projection

**rtsayers** · Mon Jan 05, 2015 9:50 pm

Thank you very much!!!

---

## Re: Average Daily Range (ADR) Projection

**BTrade** · Tue Jan 06, 2015 2:41 am

Hi Apprentice,

I have downloaded the MTF version and I don't see any modification related to the request from Nov 12 about the start and end location of the lines. please let me know if this was implemented.

Thanks

---

## Re: Average Daily Range (ADR) Projection

**gezisLV** · Tue Jan 06, 2015 10:31 am

hi can you create version that is not repainting?because it''s repainting heavily

---

## Re: Average Daily Range (ADR) Projection

**kashix** · Tue Jan 06, 2015 1:56 pm

Only bug I see is that once ADR is reached, the range somehow shrinks. Let's say it's looking for an ADR of 90. Once TR > ADR, the distance between the high and low line shrinks to something like 55. How about having the lines lock in place where they are and changing color or line style once TR > ADR?

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Sun Oct 25, 2015 9:17 am

Is there an ATR projection indicator that starts at 5pm EST? or allows you to chose when to start the calculation?

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Tue Oct 27, 2015 3:43 am

Not that I'm aware of.

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Sun Dec 06, 2015 2:12 pm

Can you develop one? Or modify the ATR_Pips indicator to have those options?

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Sun Dec 06, 2015 2:14 pm

I meant to develop one or modify the Average Daily Range (ADR) Projection indicator to use those options?

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Thu Dec 10, 2015 6:16 am

Your request is added to the development list.

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Sat Mar 12, 2016 4:28 am

Any update for this indicator? It would be greatly appreciated

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Sun Aug 27, 2017 6:34 am

The indicator was revised and updated.

---

## Re: Average Daily Range (ADR) Projection

**smookem** · Fri Sep 29, 2017 12:09 am

Any way this could be converted to MT4 with the updated options to select when to start the ADR calcuations?

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Fri Sep 29, 2017 4:47 am

Your request is added to the development list under Id Number 3904

---

## Re: Average Daily Range (ADR) Projection

**Apprentice** · Thu Jun 14, 2018 8:07 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=66195](https://fxcodebase.com/code/viewtopic.php?f=38&t=66195)
