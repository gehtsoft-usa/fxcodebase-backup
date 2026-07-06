# Tick Volume

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61127  
> Forum: 17 · Topic 61127 · 17 post(s)


---

## Tick Volume

**Apprentice** · Fri Sep 12, 2014 12:19 pm

![Tick Volume.png](images/95834/Tick%20Volume.png)



This is my attempt to rethink the buildin tick volume.

I'm not sure which algorithm is used on FXCM servers for tick volume calculation.
Therefore, certain deviations are possible.

Will provide three presentations.
Separated / Cumulative / Cumulative Absolute.

Can provide information about true nature of price action within the candle.

If u like this implementation.
Write to your congressman, FXCM, representative ...
Lobby for availability of Up & Down Tick data on FXCM servers.

 [Tick Volume.lua](files/95834/Tick%20Volume.lua)

 

![Tick Volume Divergence.png](images/95834/Tick%20Volume%20Divergence.png)



Tick ​​Volume Divergence will only sort out the candles for which Candle & Tick Volume direction is different.

 [Tick Volume Divergence.lua](files/95834/Tick%20Volume%20Divergence.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=69019](https://fxcodebase.com/code/viewtopic.php?f=38&t=69019)


---

## Re: Tick Volume

**Apprentice** · Mon Sep 15, 2014 8:46 am

![Tick Volume.png](images/95891/Tick%20Volume.png)

*Real live example from my Trading Station.*



While Buildin Tick volume for the last candle is growing,
Indicating that the down move, is supported by increasing the Tick Volume,
suggesting a reversal.
Cumulative Tick Volume indicates that down move does not have real strength,
suggesting a trend continuation.
Increase in Tick volume is the result of increased volatility.
However for for the time being, neither side has the upper hand.


---

## Re: Tick Volume

**kitefrog** · Fri Sep 19, 2014 6:06 am

Nice work on your tick volume indicator. Can you
make a change to this, and show the 'cumulative tick
volume divergences' ?

As you probably know:

When it is set in the cumulative mood, when the
net total of the tick is different from the candle
sentiment it is a tick volume divergence (TVD).

Your NGAS 1HR chart from that posting had two
strong 'tick volume divergences' (TVD) at the low in
your chart. This was added confirmation of a reversal.

[http://i.imgur.com/HWHJzOh.png](http://i.imgur.com/HWHJzOh.png)

Nice analysis by the way, and great call on NGAS
I've annotated these two strong signals in the linked
chart above. Can you improve the indicator and make it;

A) show BOTH cumulative tick volume divergences
B) only strong strongest TVD.

Just like with delta divergences, there are two strengths of
these cumulative TVD.

At a day high, or near the top of range, the strongest
is the bullish bar with negative tick cumulative; the
weaker of the two signal is the other way around;
a bearish bar near highs plus a positive cumulative tick.

(the opposite at lows of course)

I've heard somewhere that the cumulative tick volume
is 90% correlated with the delta divergence, as per
Market Delta; so your indicator will be a good reversal
indicator when combined with other signals.

I've emailed FXCM and asked them to improve the data stream
to include this fed as you've requested, and until they
improve this stream, I fully appreciate that you
might not see the benefit in also making this a strategy
file to signal. If you did make the strategy signal, you'll
need a Boolean to 'only show strongest TVD', otherwise
it could just signal both the TVD strengths.

I've been comparing your signals to the market delta charts
and their delta divergences, they seem to line up pretty good.

Here's some NT7 code for the delta divergence, and a MD
video about delta divergence so its perfectly clear.

Delta Divergence indicator
[http://youtu.be/m2K5w7ha-RI](https://youtu.be/m2K5w7ha-RI) (6min)

Code: [Select all](https://fxcodebase.com/code/)
`CODE for NT7

// Condition set 1: Delta Divergence Down
if (Close[0] < Open[0]
&& GomDeltaVol_UpDown().UpVolume[0] > 0)
{
DrawTriangleDown("My triangle down" + CurrentBar, true, 0, High[0] + 2 * TickSize, Color.Black);
}
// Condition set 2: Delta Divergence Up
if (Close[0] > Open[0]
&& GomDeltaVol_UpDown().DownVolume[0] > 0)
{
DrawTriangleUp("My triangle up" + CurrentBar, true, 0, Low[0] + -2 * TickSize, Color.Gold);
}`

Thanks so much !!
David


---

## Re: Tick Volume

**Apprentice** · Fri Sep 19, 2014 7:47 am

Tick Volume Divergence Added.
Tick Volume minor bug Fix.


---

## Re: Tick Volume

**SavvyStrategist** · Mon Jun 08, 2015 12:48 pm

I very much like this indicator and greatly appreciate the workaround to circumvent the lack of up/down tick volume availability. However, I did notice one rather major flaw. There seems to be a distinct difference between how real time and past data is interpreted and hence displayed. To clarify this point, I will upload a screenshot.

In essence, past data (talking absolute cumulative model) is always proportional to actual tick volume. New data, that is to say data that is read and displayed after the indicator is first loaded, is half of what it should be. This results in new data being practically unreadable, as it always ends up being too small to notice; comparisons, in turn, are nigh impossible to make. The screenshot below demonstrates this point. I loaded the indicator twice and placed my cursor at the exact time the indicator was loaded last.

There appears to be no flaw whatsoever with past data, so I would suggest retaining that model to display new data. New data, in turn, would be displayed after the candle closes, so the same calculation can be used, thus ensuring consistency and continuity.

P.S. The colors are different but pay no attention to it. It's the same indicator, as the label suggests.


---

## Re: Tick Volume

**SavvyStrategist** · Tue Jun 09, 2015 12:23 pm

Actually, it would appear my first observations weren't entire accurate. The greatest drawback to this indicator is the disparity between tick volume displayed, as per the indicator, and actual tick volume. It is most noticeable when volume prior to the indicator being loaded is greater than volume after it is loaded. Additionally, and for whatever reason, it seems that the last 30m-1hr of data is almost always, if not always, reduced in magnitude. My best guess is that the data mining occurs right to left and not left to right. In either case, my suggestion would be to make tick volume (indicator) always equal to actual tick volume for the specified period, then utilize whatever calculation is used to determine up/down volume and apply it proportionally to create the indicator.

The image below, as before, is a screenshot of the same indicator having been loaded twice, taken when it was last loaded.


---

## Re: Tick Volume

**Apprentice** · Wed Jun 10, 2015 3:28 am

Write to your congressman, FXCM, representative ...
Lobby for availability of Up & Down Tick data on FXCM servers.
Internal availability of Tick & Real Volume, not that real volume indicator ...


---

## Re: Tick Volume

**SavvyStrategist** · Wed Jun 24, 2015 11:43 am

Fair enough.


---

## Re: Tick Volume

**Apprentice** · Mon Feb 05, 2018 10:03 am

The indicator was revised and updated.


---

## Re: Tick Volume

**lumanauw** · Sun Sep 29, 2019 11:11 am

Hi, Apprentice,

This is good indicator

Is it possible to change the criteria to just only 2 for live/forward data?
Currently there are 4 criteria,
If bid>prevbid up++,
If bid<prevbid down++,
if ask>prevask up++,
If bid<prevbid down++.

Modified to just 2 criteria,
 if (ask+bid) /2 > prev((ask+bid) /2) up++, down=prevdown
 If (ask+bid) /2< prev((ask+bid) /2) down++, up=prevup

Also add line chart option, line[0] = line[1]+current data

Thank you


---

## Re: Tick Volume

**Apprentice** · Mon Sep 30, 2019 12:33 pm

Your request is added to the development list.
Development reference 143.


---

## Re: Tick Volume

**Apprentice** · Wed Oct 09, 2019 12:48 pm

Try this version.
[viewtopic.php?f=17&t=68993](https://fxcodebase.com/code/viewtopic.php?f=17&t=68993)


---

## Re: Tick Volume

**paulcarissimo** · Sun Oct 13, 2019 9:00 am

> **Apprentice wrote:**
>
>
> Tick Volume.png
>
>
> This is my attempt to rethink the buildin tick volume.
>
> I'm not sure which algorithm is used on FXCM servers for tick volume calculation.
> Therefore, certain deviations are possible.
>
> Will provide three presentations.
> Separated / Cumulative / Cumulative Absolute.
>
> Can provide information about true nature of price action within the candle.
>
>
> If u like this implementation.
> Write to your congressman, FXCM, representative ...
> Lobby for availability of Up & Down Tick data on FXCM servers.
>
>
>
> Tick Volume.lua
>
>
>
>
>
> Tick Volume Divergence.png
>
>
> Tick ​​Volume Divergence will only sort out the candles for which Candle & Tick Volume direction is different.
>
>
> Tick Volume Divergence.lua

May I request these indicators as well to be converted to MQ4 as well? Thanks.


---

## Re: Tick Volume

**Apprentice** · Mon Oct 14, 2019 5:00 am

Your request is added to the development list.
Development reference 189.


---

## Re: Tick Volume

**paulcarissimo** · Tue Oct 15, 2019 12:41 pm

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 189.

Thank you Apprentice.


---

## Re: Tick Volume

**Apprentice** · Tue Oct 15, 2019 1:33 pm

MT4/MQ4 version.
[viewtopic.php?f=38&t=69019](https://fxcodebase.com/code/viewtopic.php?f=38&t=69019)


---

## Re: Tick Volume

**Apprentice** · Wed Oct 16, 2019 8:44 am

MT5/MQ5 version.
[viewtopic.php?f=38&t=69019](https://fxcodebase.com/code/viewtopic.php?f=38&t=69019)
