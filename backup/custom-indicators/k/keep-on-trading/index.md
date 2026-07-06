# Keep On Trading

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=760  
> Forum: 17 · Topic 760 · 39 post(s)


---

## Keep On Trading

**Apprentice** · Fri Apr 23, 2010 12:29 pm

![Keep On Trading.png](images/1399/Keep%20On%20Trading.png)

*Keep On Trading*



 [KOT.lua](files/1399/KOT.lua)

 [KOT with Alert.lua](files/1399/KOT%20with%20Alert.lua)

Compatibility issue fixed.
_Alert Helper is not longer needed.

 

![Keep On Trading Overlay.png](images/1399/Keep%20On%20Trading%20Overlay.png)



 [Keep On Trading Overlay.lua](files/1399/Keep%20On%20Trading%20Overlay.lua)

The indicator was revised and updated


---

## Re: Keep On Trading

**Caihouela** · Fri Apr 23, 2010 3:45 pm

Merci beaucoup pour votre travaille


---

## Re: Keep On Trading

**michaelwen** · Sat Apr 24, 2010 3:42 am

good job as usually^_^. so it is same as GHLA only show the color change when it is cross with price bar, right? thanks


---

## Re: Keep On Trading

**Prof8t** · Wed Jul 21, 2010 10:36 am

Hello,

I would like to know if there is an equivalent indicator (that shows the green and red) available for the MT4 platform?

Thnaks in advance


---

## Re: Keep On Trading

**one2share** · Mon Jul 26, 2010 4:30 pm

Hey Guys,
 are you able to develop a signal that would tell me when the keep on trading crosses an ema? in my case I use the ema 28. Please, please, help

thanks

Sabrina


---

## Re: Keep On Trading

**Nikolay.Gekht** · Mon Jul 26, 2010 4:38 pm

Yes, it's possible. Just let us to clean up at least the most of the already existed requests.


---

## Re: Keep On Trading

**one2share** · Mon Jul 26, 2010 7:31 pm

thanks for responding...what else would be great is when the keep on trading changes color..I appreciate it...thanks again


---

## Re: Keep On Trading

**Apprentice** · Tue Dec 11, 2012 9:12 am

Keep On Trading Overlay Added.
Old Keep On Trading Indicator Update.
New Version of KOT added.


---

## Re: Keep On Trading

**Apprentice** · Tue Dec 11, 2012 11:10 am

MQ4 version can be found here.
[viewtopic.php?f=38&t=27620](https://fxcodebase.com/code/viewtopic.php?f=38&t=27620)


---

## Re: Keep On Trading

**satejchaudhary** · Sun Dec 16, 2012 3:21 am

hi
Can someone elaborate on how this indicator Keep on trading works?
ie. What is the logic for flagging an up trend or down trend?


---

## Re: Keep On Trading

**Apprentice** · Sun Dec 16, 2012 4:35 am

In this case I can not help you, I'm just a programmer.
In my trading, I do not use indicators.


---

## Re: Keep On Trading

**Paul W** · Mon Apr 01, 2013 1:46 pm

I like this alert, works well to confirm price direction when scalping. Could you add a show and play sound feature.

Thanks


---

## Re: Keep On Trading

**Apprentice** · Tue Apr 02, 2013 7:08 am

Your request is added to the development list.


---

## Re: Keep On Trading

**Apprentice** · Wed Apr 03, 2013 4:43 am

Keep On Trading with Alert Added.


---

## Re: Keep On Trading

**Paul W** · Thu Apr 04, 2013 12:36 pm

can you add a user option to select the alerts trigger source - i.e. open/close of candle

that would be great

thanks


---

## Re: Keep On Trading

**Apprentice** · Sat Apr 06, 2013 4:29 am

Your request is added to the development list.


---

## Re: Keep On Trading

**dslickone** · Thu Apr 11, 2013 11:12 am

Is there a Strategy for this indicator?


---

## Re: Keep On Trading

**Apprentice** · Fri Apr 12, 2013 4:25 am

No, as far I know


---

## Re: Keep On Trading

**crazymonkey** · Thu Apr 18, 2013 12:14 am

I know this indicator will repaint history based on its calculation methods, but I was curious if it was possible to disallow repainting?


---

## Re: Keep On Trading

**Apprentice** · Thu Apr 18, 2013 5:08 am

KOT will not repaint.
Will Only change value for the current period.
Not for the former ones.


---

## Re: Keep On Trading

**crazymonkey** · Mon Apr 22, 2013 12:35 pm

If you look at the images I attached you can see the candles that repainted Apprentice.

First image shows original 5 minute time frame. I had this window open on this time frame for about 8 hours.

I then went up to 15 minute time frame (for a quick glance at a higher time range), then back down to 5 minute.

Second image highlights candles that changed color.

Any ideas?


---

## Re: Keep On Trading

**crazymonkey** · Mon Apr 22, 2013 6:54 pm

Apprentice, I also just noticed that the Keep on Trading overlay, does not adjust when you alter the LWMA period and the ATR period. Regardless of the numeric value/period you set, it doesn't alter the candle color. The original KOT works fine, but the candle overlay does not.

The setting of 10,30,0.1 looks the same as the setting of 20,50,0.1 and so on.


---

## Re: Keep On Trading

**Apprentice** · Tue Apr 23, 2013 5:42 am

Thank you for info about this issue.
Unfortunately, we have bug in the overlay version.


---

## Re: Keep On Trading

**crazymonkey** · Tue Apr 23, 2013 9:32 am

Thanks Apprentice.

Please let me know if/when you have a chance to try and fix it.


---

## Re: Keep On Trading

**Apprentice** · Tue Apr 23, 2013 2:32 pm

Problem has been fixed.


---

## Re: Keep On Trading

**crazymonkey** · Tue Apr 23, 2013 4:30 pm

Thanks Apprentice.

Ill test it out tonight and let you know if there are any problems.


---

## Re: Keep On Trading

**crazymonkey** · Wed Apr 24, 2013 10:31 am

Apprentice,

Its working much better now...

..However, there are a few things I noticed:

1) If you have for example 1 tab open showing 5 min USD/JPY and then open another window an hour later of the same currency in the same 5 min period, the most recent candles in the new window do not match 100% those shown in the older window (usually several of the most recent 5-10 candles).

2 ) Also, altering **anything** with the indicator (even the color of the candles) changes some of the past candles.

3) The neutral trend setting does not work at all. Unless you set the LWMA to 500 and over, only then do the grey candles show - in fact all the candles turn grey/neutral. I don't know if this is a problem with the actual design of the KOT, or an error , as this occurs with the original KOT as well.

Either way it works much better and very helpful. I don't know if any other those were items that needed fixing, but i wanted to give some feedback.

Thanks


---

## Re: Keep On Trading

**Paul W** · Wed Apr 24, 2013 4:11 pm

KOT is triggered by a price cross and the final up or down trend is not determined until the period close. Therefore you will see, at times, trend switching during open periods – this also includes price alert triggers.

note: I am using KOT with Alert.lua, and have not observed this problem - will test further


---

## Re: Keep On Trading

**crazymonkey** · Wed Apr 24, 2013 4:30 pm

Apprentice,

I test ran the KOT overlay today to see if any errors came up. I had 2 windows open all day, same currency, same time frame, same KOT settings and no other indicators.

The error below happened about 5 times today, where one window shows a red candle, and the other shows a green. Below is one example. The color change happens about 1-2 candles later. It would make sense if it was repainting, but it occurs randomly on each screen, and both screens had the same indicator setting and were open for the same period of time (about 6 hours).


---

## Re: Keep On Trading

**Paul W** · Mon May 20, 2013 11:53 am

On Sat May 18 there was an update to Trading Station and KOT can no longer be loaded on to a TIC chart.

 FXCM explanation

“There is a new property in LUA indicators files in which you specify what chart type the indicator is for - either tick or time based charts. If you a tick based chart and open the add indicator box you will only see indicators that are allowed on tick charts”.

I have adjusted the LWMA (300) period and multiplier (2.0) which allows KOT to function on a TIC chart – It can be used it to identify price breakouts on CFD's.

Could you enhance KOT so it can again be used on a TIC chart

Thanks,


---

## Re: Keep On Trading

**Apprentice** · Tue May 21, 2013 5:32 am

Existing version will not work for Tick Chart.
Indicator should be re-written, can you submit formula fot it.


---

## Re: Keep On Trading

**mulligan** · Tue May 21, 2013 5:24 pm

A strategy for this indicator would be greatly appreciated. Thanks for all you do.


---

## Re: Keep On Trading

**Apprentice** · Fri May 24, 2013 3:22 am

Down Trend
(close[period] < low[period-1] and close[period] < low[period-2])

Up Trend
(close[period] > high[period-1] and close[period] >high[period-2])


---

## Re: Keep On Trading

**mulligan** · Fri Jun 21, 2013 10:03 am

This is a fantastic indicator and I depend heavily upon it for trading. I have used the alert funtion available. The alert funtion is very difficult to manage if you wish to monitor, as I do, a large number of pairs. In my case, 12. A simple strategy with the normal "show alert", "sound and recurrent sound" with the sound options style, would make things extremely simple and easy. If you can find the time, a strategy vs. the current alert would be greatly appreciated.


---

## Re: Keep On Trading

**Apprentice** · Sun Jun 23, 2013 2:29 pm

Your request is added to the development list.


---

## Re: Keep On Trading

**Jamwal Suriya** · Thu Jun 27, 2013 12:59 am

I would like to know if there is an equivalent indicator
 (that shows the green and red) available for the MT4 platform?


---

## Re: Keep On Trading

**Apprentice** · Fri Jun 28, 2013 2:34 am

Lines or candles?


---

## Re: Keep On Trading

**Apprentice** · Sun Dec 06, 2015 4:56 am

Compatibility issue fixed.
_Alert Helper is not longer needed.


---

## Re: Keep On Trading

**Apprentice** · Fri Jul 21, 2017 9:16 am

The indicator was revised and updated.
