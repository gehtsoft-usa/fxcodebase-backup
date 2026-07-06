# CSV Lines Helper Tool

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64603  
> Forum: 17 · Topic 64603 · 7 post(s)


---

## CSV Lines Helper Tool

**Apprentice** · Tue Apr 18, 2017 11:25 am

[CSV Lines Helper Tool.lua](files/112041/CSV%20Lines%20Helper%20Tool.lua)

 [test.csv](files/112041/test.csv)

This indicator will take .csv file data and plot lines.
Line is defined by two points.

The indicator was revised and updated


---

## Re: CSV Lines Helper Tool

**Cactus** · Wed Apr 19, 2017 7:25 pm

Amazing work. One question, the time, what time zone is it? I don't see it to be corresponding to UTC or my Local GMT (currently BST)


---

## Re: CSV Lines Helper Tool

**Cactus** · Wed Apr 19, 2017 8:19 pm

So, this is a great start for drawing trendlines from your own .csv file date/time points.

However, after playing around with it for a while I notice the lines are actually "wobbly", that is, they don't stay in the same place when you move the chart around or zoom in/out. I don't know what constitutes to this behavior but because the lines move around they are not as reliable.

I see that other indicators which draw diagonal lines like ZigZag channel with output or Trend line helper do not suffer this problem, is it because they output a value? I understand making outputs for such indicator as this can be problematic as it would slow down with lots of lines, and the whole point is to make it easy to plot as many lines as you want automatically quickly

If the draw method can make sure lines do not move and slope is the same all the time (currently they can be many pips away from a normal marketscope line object plotted on same points (using high/low magnet) sometimes) if not for this problem it would be ideal.


---

## Re: CSV Lines Helper Tool

**Cactus** · Wed Apr 19, 2017 10:10 pm

I am not sure but perhaps some inspiration to make this better can be taken from this indicator code:
This is a CSV line drawer but only for horizontal lines. Maybe if it is edited it can also be used to plot diagonal lines like this indicator, but without the lines moving around?

Code: [Select all](https://fxcodebase.com/code/)
`core.host:execute("drawLine", id, source:date(first), Price, source:date(source:size()-1), Price, Color, Style, Width);`


---

## Re: CSV Lines Helper Tool

**Apprentice** · Fri Apr 21, 2017 3:01 am

.csv does not contain information about the time zone.
Chart time frame will be used.


---

## Re: CSV Lines Helper Tool

**Cactus** · Sat Jul 08, 2017 7:57 am

I understand the CSV does not hold any timezone information. Must be the indicator then.
You see, whatever time I enter in the .csv, it is only appearing correct on the chart if I subtract 5 hours from the time. Do you know why that is?

For example. In the csv I have
04/04/2017 12:30,1.06565,04/04/2017 17:32,1.06734

But the start time (12:30 and 17:32) are not appearing correctly when applied on chart.
When I change it to (7:30 and 12:32), which is 5 hours less, only then they are drawn where they should... Do you know how to fix this? I'm in the UK so currently local time is using British Summer Time (BST)


---

## Re: CSV Lines Helper Tool

**Cactus** · Sat Jul 08, 2017 8:06 am

Furthermore I see this corresponds to New York time zone
