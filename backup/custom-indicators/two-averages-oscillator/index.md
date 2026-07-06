# Two Averages Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=13963  
> Forum: 17 · Topic 13963 · 18 post(s)


---

## Two Averages Oscillator

**Apprentice** · Fri Feb 24, 2012 10:57 am

![Two Averages Oscillator.png](images/26802/Two%20Averages%20Oscillator.png)



This simple indicator is the result of the difference between two moving averages,
MA difference, MA Delta.

 [Two Averages Oscillator.lua](files/26802/Two%20Averages%20Oscillator.lua)

To work install 20 in 1 Moving Average Indicator a.k.a. Averages
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)

 

![Difference between two different indicators.png](images/26802/Difference%20between%20two%20different%20indicators.png)



Select 1. Indicator
Select 2. Indicator
Calculate difference between two.
Both are using chart price data as a source.

 [Difference between two different indicators.lua](files/26802/Difference%20between%20two%20different%20indicators.lua)

 

![Difference between two indicators of two indicators.png](images/26802/Difference%20between%20two%20indicators%20of%20two%20indicators.png)



Select Indicator 1. Source Indicator
Select Indicator 2. Source Indicator
Both are using chart price data as a source.

Select Indicator 3
Select Indicator 4
Indicator 3 is using Indicator 1. as source.
Indicator 4 is using Indicator 2. as source.
Calculate difference between two.
Both are using chart price data as a source.

 [Difference between two indicators of two indicators.lua](files/26802/Difference%20between%20two%20indicators%20of%20two%20indicators.lua)

The indicator was revised and updated


---

## Re: Two Averages Oscillator

**zmender** · Wed Mar 07, 2012 1:32 pm

Added the functionality of plotting the differences between 2 MVAs, and a moving average of itself... based on the 3/10 oscillator by LBR.

**The 3/10 OSCILLATOR**
The “3/10 oscillator” is created by subtracting a 10-period simple moving average from a
3-period simple moving average, and then creating a 16-period simple moving average of
the 3/10 oscillator. These two lines are useful in confirming wave structure or highlighting
chart formations. We call the 3/10 line as the “fast” line, and the 16-period SMA the “slow”
line or trend line.

**THE PRICE PULSE – THE MAIN PRINCIPLE BEHIND THE 3/10 OSCILLATOR**The 3/10 is a relatively sensitive oscillator and often highlights the “pulse” in the market’s
action. Tony Plummer best describes this “pulse” in his book, “Forecasting Financial
Markets”. It describes a “negative feedback” conditions that is present in the market about
80% of the time.

 [3_10.lua](files/27709/3_10.lua)


---

## Re: Two Averages Oscillator

**speakinmymind** · Thu Feb 28, 2013 1:44 pm

Hey thanks for this Oscillator, its very powerful. Can you add a fib time zone Indicator to it? I think it has the potential to help identify entry/exit zones.

If you are Long your first time zone’s color is orange, and is set from “two averages oscillator’s” previous peak to the next bottom. The second time zone is white and is set from “two averages oscillator’s” previous bottom to the next peak. Use time zone lines 2, 3, 5, 8 only. If you are short, the white time zone set is first (short/long parameter can be set using simple moving average option):
If
•	White 3 is before Orange 2:
o Signal Long Entry Opportunity Range from White 3 to Orange 2
o Signal Optimal Close Range:
 If
• Orange 5 is further than White 8 then the range is from White 8 to Orange 5
• Orange 5 is not further than White 8 then the range is from White 5 to Orange 5
o	Disregard Orange 8

If
•	Orange 3 is before White 2:
o Signal Short Entry Opportunity Range from Orange 3 to Orange 2
o Signal Optimal Close Range
 If
• White 5 is further than Orange 8 then the range is from Orange 8 to White 5
• White 5 is not further than Orange 8 then the range is from Orange 5 to White 5
o	Disregard White 8


---

## Re: Two Averages Oscillator

**Apprentice** · Fri Mar 01, 2013 5:44 am

Your request is added to the developmental list.


---

## Re: Two Averages Oscillator

**speakinmymind** · Fri Mar 01, 2013 11:07 am

Thanks, there was a slight typo in my explanation:

"If
• Orange 3 is before White 2:
o Signal Short Entry Opportunity Range from Orange 3 to WHITE 2
o Signal Optimal Close Range
 If
• White 5 is further than Orange 8 then the range is from Orange 8 to White 5
• White 5 is not further than Orange 8 then the range is from Orange 5 to White 5
o Disregard White 8"

Also, photo 2 is inconsistent and should be ignored.

Thanks again.


---

## Re: Two Averages Oscillator

**Jeffreyvnlk** · Mon May 06, 2013 4:22 pm

> **zmender wrote:**
> Added the functionality of plotting the differences between 2 MVAs, and a moving average of itself... based on the 3/10 oscillator by LBR.
>
> **The 3/10 OSCILLATOR**
> The “3/10 oscillator” is created by subtracting a 10-period simple moving average from a
> 3-period simple moving average, and then creating a 16-period simple moving average of
> the 3/10 oscillator. These two lines are useful in confirming wave structure or highlighting
> chart formations. We call the 3/10 line as the “fast” line, and the 16-period SMA the “slow”
> line or trend line.
>
> **THE PRICE PULSE – THE MAIN PRINCIPLE BEHIND THE 3/10 OSCILLATOR**The 3/10 is a relatively sensitive oscillator and often highlights the “pulse” in the market’s
> action. Tony Plummer best describes this “pulse” in his book, “Forecasting Financial
> Markets”. It describes a “negative feedback” conditions that is present in the market about
> 80% of the time.

When I saw Linda trading , i wondered where can i get "3/10 MA oscillator" version for FXCM's TS and i thought i could not find anywhere even in fxcodebase. Amazing.Thanks


---

## Re: Two Averages Oscillator

**gianpierobn** · Thu May 09, 2013 4:27 am

would be possible plot this indicator as line on the chart?

And woud be possibile create a second indicators as diference between Tow average oscillator?
like this Two av. osc. (period t ) - Tow Av. Osc. ( t-1)?We could have two indicators on the chart, Two average oscilator and its velocity....
Thanks


---

## Re: Two Averages Oscillator

**Apprentice** · Sat May 11, 2013 2:22 am

Your request is added to the development list.


---

## Re: Two Averages Oscillator

**Alexander.Gettinger** · Mon Sep 15, 2014 12:14 pm

MQL4 version of Two Averages Oscillator: [viewtopic.php?f=38&t=61150](https://fxcodebase.com/code/viewtopic.php?f=38&t=61150).


---

## Re: Two Averages Oscillator

**Jeffreyvnlk** · Wed Dec 10, 2014 3:47 am

Can you customize 3/10 Linda oscillator like this ? This taken from Linda website


---

## Re: Two Averages Oscillator

**Apprentice** · Thu Dec 11, 2014 4:47 am

Can you clarify your request.


---

## Re: Two Averages Oscillator

**spinemaligna** · Tue Jan 06, 2015 6:07 am

Firstly Happy New Year to all.

I have a request to modify the oscillator so that it will change the colour of bar once the difference between the averages reaches a certain level. I use it along with the Woodies CCI and would like it to display a neutral colour bar until the difference reaches a certain level when it would display either red or green depending on direction. Could a signal also be incorporated once the difference has reached a certain level.
If this is not possible then could the oscillator be changed to allow level lines to be drawn as on the Woodies CCI.
This would make scanning several charts much easier.

Thanks in advance,

Ross


---

## Re: Two Averages Oscillator

**Apprentice** · Sun Jan 25, 2015 1:22 pm

Difference between two different indicators Added.


---

## Re: Two Averages Oscillator

**Apprentice** · Fri Aug 19, 2016 4:04 am

Minor update.


---

## Re: Two Averages Oscillator

**Kilgharrah** · Wed Nov 09, 2016 4:49 pm

Hi development team,

Is there a possibility to develop an strategy based on [3_10.lua](https://fxcodebase.com/code/viewtopic.php?f=17&t=13963&p=61705&hilit=diference#p27709) ? with all the usual options of any strategy, taking care of properly functioning options Start & Stop Time, and if not much work Is it possible to add a Stop order in pips based on the value of [ATR](https://fxcodebase.com/code/viewtopic.php?f=17&t=4971&hilit=atr#p12287) (Price source, period and multiplier) and would be spectacular if it is possible that the limit also had this feature.

Thanks in advance


---

## Re: Two Averages Oscillator

**Apprentice** · Fri Nov 11, 2016 1:38 pm

Try this version.
[viewtopic.php?f=31&t=64089](https://fxcodebase.com/code/viewtopic.php?f=31&t=64089)


---

## Re: Two Averages Oscillator

**Kilgharrah** · Fri Nov 11, 2016 7:42 pm

Hi **[Apprentice](https://fxcodebase.com/code/memberlist.php?mode=viewprofile&u=437)**, once again I have no words, only admiration for the speed and efficiency. Additionally I feel a little embarrassed to ask the functioning of the fields **Cap Position** and **Position Exit**, could you please explain to me a little.

And if not too much to ask if you can add an entry field that functions as target to compare it with the profit / loss reached in the day and once reached or exceeded stop strategy. Or if you recommend combining this strategy with some other existing strategy that already perform this task.

thank you very much

**Note:** a misspelling in the second line should read **Limit Multiplier**


---

## Re: Two Averages Oscillator

**Apprentice** · Sat Nov 12, 2016 3:03 pm

Use Position Cap - if set to false/no
Max Number Of Open Position In Any Direction / Max Number Of Position In One Direction limit will not be used.

Use Position Instrument in Position Exit true/yes
Use Position CustomID in Position Exit true/yes
Should be set to true
Strategy will only close Positions with same CustomID & Instrument as strategy.

Use Position Instrument in Position Exit false
Use Position CustomID in Position Exit true
Strategy will close all Positions with same CustomID as strategy.

Use Position Instrument in Position Exit true
Use Position CustomID in Position Exit false
Strategy will close all Positions with same Instrument as strategy.

Typo is fixed now.
