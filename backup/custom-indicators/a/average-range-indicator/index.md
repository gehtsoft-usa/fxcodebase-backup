# Average Range Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=9374  
> Forum: 17 · Topic 9374 · 35 post(s)


---

## Average Range Indicator

**Apprentice** · Sat Dec 10, 2011 2:04 pm

![Average Daily Range Indicator.png](images/20230/Average%20Daily%20Range%20Indicator.png)



This indicator shows the average value of high / low range, severally,
for the period considered, also, shows an average value for of all time frames, collectively.

 [Average Daily Range Indicator.lua](files/20230/Average%20Daily%20Range%20Indicator.lua)

 [Average Daily Range Chart Time Frame Oscillator.lua](files/20230/Average%20Daily%20Range%20Chart%20Time%20Frame%20Oscillator.lua)


---

## Re: Average Range Indicator

**Jeffreyvnlk** · Thu Aug 21, 2014 2:58 pm

> **Apprentice wrote:**
>
>
> Average Daily Range Indicator.png
>
>
>
> This indicator shows the average value of high / low range, severally,
> for the period considered, also, shows an average value for of all time frames, collectively.
>
>
>
> Average Daily Range Indicator.lua

Can give the option that excluding today range ?


---

## Re: Average Range Indicator

**Apprentice** · Fri Aug 22, 2014 2:28 am

Exclude Active Candle Option Added.


---

## Re: Average Range Indicator

**7510109079** · Thu Mar 12, 2015 4:29 am

not sure if you can reproduce this but if i change the font size smaller, the font size stays the same but just the spacing gets smaller so the text gets crowded but the actual font size stays the same.

Can you have a quick look, thx


---

## Re: Average Range Indicator

**7510109079** · Tue Mar 17, 2015 3:57 am

some images to explain what i see...
font size seems to change line spacing rather than font size
thx


---

## Re: Average Range Indicator

**Apprentice** · Tue Mar 17, 2015 5:25 am

Updated.


---

## Re: Average Range Indicator

**7510109079** · Tue Mar 17, 2015 5:51 am

Excellent, many thx


---

## Re: Average "Daily" Range Indicator lua

**Bebbspoke** · Tue Mar 24, 2015 10:41 am

The indicator is an Average Range Indicator - but the lua implies it is an Average DAILY Range; -
Sure - it is if one uses daily candles but in reality this indicator gives the Average Range for whatever candle timeframe is active.
Much as an average candle range is a quite useful indicator - this is NOT the ADR indicator as requested some few months back elsewhere in this forum.
Please can we have an indicator that displays; -
a/ the ADR for the previous 20 days
& b/ the price range for the current day
These actual values to display regardless of selected candle timeframe.
Such an idicator is available in MT4
Thank you


---

## Re: Average "Daily" Range Indicator lua

**Bebbspoke** · Tue Mar 24, 2015 10:42 am

The indicator is an Average Range Indicator - but the lua implies it is an Average DAILY Range; -
Sure - it is if one uses daily candles but in reality this indicator gives the Average Range for whatever candle timeframe is active.
Much as an average candle range is a quite useful indicator - this is NOT the ADR indicator as requested some few months back elsewhere in this forum.
Please can we have an indicator that displays; -
a/ the ADR for the previous 20 days
& b/ the price range for the current day
These actual values to display regardless of selected candle timeframe.
Such an idicator is available in MT4
Thank you


---

## Re: Average Range Indicator

**7510109079** · Tue Mar 24, 2015 11:24 am

Just set the Datasource period to 'D1' and it will give you daily (22h-22h GMT.) pip movements regardless of what TF your chart is set to.

Set Exclude active candle to 'No' and set the '1.Period' to 1 and that will give you current day's range

Set '2.Period' to 20 and you have your 20 day range

Its all there


---

## Re: Average Range Indicator

**Bebbspoke** · Tue Mar 24, 2015 2:43 pm

Hi number[i]; -

Thank you for your response. I'm not certain the operations you suggest procure the desired function:

I require values for

a/the ADR(20) of the [i]previous 20 days

& b/ the present day range

Value "a/" must Exclude tha Active candle (and of course all candles of the active day, whereas value "b/" should observe the Active Candle if appropriate.

A further point; - to have these values linked to the cursor would be most useful...


---

## Re: Average Range Indicator

**7510109079** · Thu Mar 26, 2015 7:12 am

Not sure about the linking to a cursor but use the settings below:

set data source time period to D1 (daily)

set calculation periods 1. & 2. to '1' and '20' respectively. Exclude set to 'No'. Any other values for other periods

1 minute chart but shows current **daily**range = 93.4pips, 20 days daily average movement as 162.14 pips etc. Final average is an average of the 1, 20, 30 & 60 daily averages


---

## Re: Average Range Indicator

**gnarlyarbitrage** · Thu Apr 02, 2015 2:13 am

Would like to be able to use this for the even small TF's such as the 5m or the 1m. Smallest I get is the 1h.

Thank you.


---

## Re: Average Range Indicator

**7510109079** · Thu Apr 02, 2015 4:37 am

works on all TFs for me.
sometimes it randomly disappears altogether but i get it back by resetting the screen position


---

## Re: Average Range Indicator

**gnarlyarbitrage** · Thu Apr 02, 2015 7:32 pm

i just checked it again and i see the smaller TF's. weird. thanks, however.

on another note: i would like to be able to see the average spread of a pair. maybe just a simple tool, or something that would include the open,hi,lo,close of a candle. of course, tick charts don't have those, but would still like to see the tick spread as well.

thank you


---

## Re: Average Range Indicator

**Apprentice** · Fri Apr 03, 2015 6:06 am

You can use one of these indicator.
Chart Info
[viewtopic.php?f=17&t=61866&p=98821&hilit=spread#p98821](https://fxcodebase.com/code/viewtopic.php?f=17&t=61866&p=98821&hilit=spread#p98821)
Spread List
[viewtopic.php?f=17&t=8525&p=96943&hilit=spread#p96943](https://fxcodebase.com/code/viewtopic.php?f=17&t=8525&p=96943&hilit=spread#p96943)
BidAskSpread Overlay
[viewtopic.php?f=17&t=3164&p=65768&hilit=spread#p65768](https://fxcodebase.com/code/viewtopic.php?f=17&t=3164&p=65768&hilit=spread#p65768)


---

## Re: Average Range Indicator

**gnarlyarbitrage** · Sun Apr 05, 2015 3:17 am

i dont think i actually can. im asking to see the average, meaning over time, spread. not just simply what it currently is.

thank you


---

## Re: Average Range Indicator

**Apprentice** · Wed Apr 08, 2015 3:13 am

You mean one of these two.

Candle Range
[viewtopic.php?f=17&t=61561&p=97430&hilit=high+low+range#p97430](https://fxcodebase.com/code/viewtopic.php?f=17&t=61561&p=97430&hilit=high+low+range#p97430)
Average Period Range
[viewtopic.php?f=17&t=38110&p=63087&hilit=high+low+range#p63087](https://fxcodebase.com/code/viewtopic.php?f=17&t=38110&p=63087&hilit=high+low+range#p63087)


---

## Re: Average Range Indicator

**rtsayers** · Mon May 04, 2015 12:57 pm

I keep getting error's with the period D1 time frame settings?


---

## Re: Average Range Indicator

**7510109079** · Tue May 05, 2015 5:22 am

me too. Like the Trading History indicator, this one is fine for a while then gives 'Error' in the legend. A refresh works to correct this temporarily but it reverts to error after 5 mins or so.

Any ideas anyone?


---

## Re: Average Range Indicator

**Apprentice** · Wed May 06, 2015 7:00 am

Try it now.


---

## Re: Average Range Indicator

**Bebbspoke** · Wed May 06, 2015 8:51 am

Hi Apprentice; - "try it now" - wouldn't it be nice if there was a direct link? - or am I being totally incompetent?...
I'm sure there are many useful indicators on this site but the finding thereof is nigh on as bad as ensuring a profit on the Forex.
Please can we have a link to an indexed source of Custom indicators preferably referring only to those that are known to be bug free? Thank you.


---

## Re: Average Range Indicator

**rtsayers** · Wed May 06, 2015 11:39 am

I am still getting a error and where is the new indicator or updated indicator? I reinstalled and still the same!!!


---

## Re: Average Range Indicator

**Apprentice** · Fri May 08, 2015 5:01 am

Refers to first file of this topic.
Or u can use this link.
[download/file.php?id=5226](https://fxcodebase.com/code/download/file.php?id=5226)


---

## Re: Average Range Indicator

**Bebbspoke** · Fri May 08, 2015 5:36 am

Apprentice - thank you for the link!


---

## Re: Average Range Indicator

**rtsayers** · Sat May 09, 2015 2:00 pm

Still getting errors when setting to daily time period??


---

## Re: Average Range Indicator

**rtsayers** · Wed May 13, 2015 7:34 pm

Just wondering when you are going to fix this problem??


---

## Re: Average Range Indicator

**rtsayers** · Mon Jun 01, 2015 4:05 pm

Problem still there when put on Daily period!!!


---

## Re: Average Range Indicator

**Apprentice** · Sun Oct 28, 2018 5:17 am

The indicator was revised and updated.


---

## Re: Average Range Indicator

**chai88888** · Tue Jun 30, 2020 4:43 am

hi there can you make a dash board for this indicator

like this

thanks


---

## Re: Average Range Indicator

**Apprentice** · Tue Jun 30, 2020 8:49 am

Your request is added to the development list.
Development reference 1596.


---

## Re: Average Range Indicator

**Apprentice** · Wed Jul 01, 2020 8:26 am

Try this version.
[viewtopic.php?f=17&t=70111](https://fxcodebase.com/code/viewtopic.php?f=17&t=70111)


---

## Re: Average Range Indicator

**chai88888** · Mon Jul 13, 2020 5:19 am

it has a different output form its original indicator


---

## Re: Average Range Indicator

**chai88888** · Mon Jul 13, 2020 5:25 am

here an example of different output


---

## Re: Average Range Indicator

**Apprentice** · Wed Aug 05, 2020 6:17 am

![EURUSD H1 (08-05-2020 1126).png](images/136614/EURUSD%20H1%20%2808-05-2020%201126%29.png)



Multiplicator 1 was used.
The time frame was set to chart the time frame.
