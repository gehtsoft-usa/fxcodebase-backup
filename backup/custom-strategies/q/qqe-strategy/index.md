# QQE Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=9147  
> Forum: 31 · Topic 9147 · 28 post(s)


---

## QQE Strategy

**Apprentice** · Thu Dec 08, 2011 7:36 am

![QQE Strategy.png](images/19960/QQE%20Strategy.png)



Buy
QQE, signal line, crossover.

Sell
QQE, signal line, crossunder.

 [QQE Strategy.lua](files/19960/QQE%20Strategy.lua)

Indicator must be downloaded [here](https://fxcodebase.com/code/viewtopic.php?f=17&t=1347).


---

## Re: QQE Strategy

**MERNISSI** · Thu Dec 08, 2011 12:26 pm

Thank you very much for your quick response thanks and appreciate your cooperation.


---

## Re: QQE Strategy

**jackfx09** · Fri Dec 09, 2011 6:03 am

This Strategy is working well! Nice work Apprentice and Co.

sjc


---

## Re: QQE Strategy

**cersoz** · Thu Dec 29, 2011 1:49 pm

can u add this strategy a filter

buy : qqe > fast trail stop and qqe >50
sell : qqe < fast trail stop and qqe <50

thanks


---

## Re: QQE Strategy

**Apprentice** · Thu Dec 29, 2011 6:48 pm

Your request is added to the developmental cue.


---

## Re: QQE Strategy

**cersoz** · Wed Jan 11, 2012 11:34 am

any news ?:)


---

## Re: QQE Strategy

**Apprentice** · Wed Sep 12, 2012 2:42 pm

![QQE Strategy.png](images/40174/QQE%20Strategy.png)



QQE Strategy with confirmation line.
Long
QQE > Trail stop and QQE >50
Short
QQE < Trail stop and QQE <50

 [QQE Strategy.lua](files/40174/QQE%20Strategy.lua)

Same strategies with price Smoothing.

 [QQE Strategy with HPF Smoothing.lua](files/40174/QQE%20Strategy%20with%20HPF%20Smoothing.lua)

You can find HPF indicator here.
[viewtopic.php?f=17&t=3024&hilit=HPF](https://fxcodebase.com/code/viewtopic.php?f=17&t=3024&hilit=HPF)


---

## Re: QQE Strategy

**Coondawg71** · Wed Sep 12, 2012 3:50 pm

Thanks Apprentice!

sjc


---

## Re: QQE Strategy

**Coondawg71** · Tue Sep 18, 2012 8:34 am

Please check this attached illustration to see if Strategy is working properly. Strategy Trading parameters are all set accordingly but I am not getting signals or open positions. Is the Strategy designed open when a candle closes above/below IN CONJUNCTION with the crossover of the QQE signals??? If so, then my concept of using the HPF to smooth the QQE crossovers will not prove beneficial. Maybe an adjustment to the strategy code is needed?

Thanks,

sjc


---

## Re;HPF

**Nick Marinita** · Wed Nov 21, 2012 3:08 am

I like this HPF indicator is it available to download in Code Base or is something that you created?


---

## Re: QQE Strategy

**Apprentice** · Wed Nov 21, 2012 3:33 am

Both.
You can find HPF indicator here.
[viewtopic.php?f=17&t=3024&hilit=HPF](https://fxcodebase.com/code/viewtopic.php?f=17&t=3024&hilit=HPF)


---

## Re: QQE Strategy

**evgeniyn** · Sat Jan 26, 2013 5:31 pm

Thanks Apprentice!
One question, I tried to use "QQE Strategy with HPF Smoothing.lua", see url [http://www.fxcodebase.com/code/download/file.php?id=7380](http://www.fxcodebase.com/code/download/file.php?id=7380),
But result of QQE stream crosses is different from indicator QQE that uses HPF as data. Do you know why?


---

## Re: QQE Strategy

**Apprentice** · Mon Jan 28, 2013 1:44 pm

HPF is primarily an analytical tool, not for trader, Reason Indicator will repaint itself after each turn.


---

## Re: QQE Strategy

**evgeniyn** · Mon Jan 28, 2013 5:57 pm

You mean the Indicator will repaint itself after each call his "Update(period, mode)". If yes, why in strategy after call of HPF:update(core.UpdateLast) we can't use his datastream? Call of update function should recalculate HPF stream or no?


---

## Re: QQE Strategy

**RunVert** · Wed Jan 30, 2013 1:24 am

Is it possible to add the option to NOT show the fast trailing stop?


---

## Re: QQE Strategy

**Apprentice** · Wed Jan 30, 2013 4:09 am

Unfortunately, I do not understand your request, can you describe it with more details.


---

## Re: QQE Strategy

**RunVert** · Wed Jan 30, 2013 12:27 pm

I am referring to the Green colored "TS Fast" line.

 In the QQE properties there is a "yes" or "no" drop down option to show SLOW trailing stop (the blue line). However there is no "yes" or "no" drop down option to show the FAST trailing stop.

Basically I want to have the option to remove both the fast and slow trailing stops and show only the red QQE line.

....does that help explain?


---

## Re: QQE Strategy

**RunVert** · Wed Jan 30, 2013 12:29 pm

....Need to add, I am referring to the QQE Indicator, not the strategy.


---

## Re: QQE Strategy

**Apprentice** · Thu Jan 31, 2013 5:30 am

Please ReDownload The Indicator.


---

## Re: QQE Strategy

**mulligan** · Thu Feb 07, 2013 2:59 pm

The strategy is very usefull. I prefer the option of the slow trailing stop. When I choose that option, the "show alert" comes up, but rather than buy or sell, the message is [string"QQE Strategy.lua"]:310:attempt to index global'Icore' (a nil value). Also the alert does not register in the alert log. Could you possibly fix as the slow trailing stop option does a great job of filtering noise. Thanks for any assistance.


---

## Re: QQE Strategy

**mulligan** · Thu Feb 07, 2013 3:05 pm

A further note when the slow trailing stop option is used. As soon as the alert for a pair goes off once, it switces the strategy from "on" to "paused", so basically not functional.


---

## Re: QQE Strategy

**Apprentice** · Fri Feb 08, 2013 4:00 am

The reason was a minor bug, please redownload.


---

## Re: QQE Strategy

**fxcatty** · Thu Jul 25, 2013 7:09 pm

Hello, I am searching and trying to make myself, a QQE Strategy that will give alerts when the Pbuff (Line) crosses over a level. I'd like Give an alert if QQE crosses over 60 line and also give an alert if it goes below the 30 line. I'd like to be able to input the number levels. I tried looking at this code from this strategy to use as a template, but it only has '1' level, that is the 50 confirmation level. I tried running the strategy to see if I can just switch it but I receive a QQE;63 error. Any helps would be appreciated, thanks,


---

## Re: QQE Strategy with HPF Smoothing

**mulligan** · Fri Jul 26, 2013 11:18 am

I have QQE and HPF loaded. When I try to set up the QQE Strategy with HPF Smoothing I get this message. QQE Strategy with HPF Smoothing.lua 200: QQE.lua:63: The first parameter must be an indicator source. Also, is there a QQE with HPF smoothing indicator or just the strategy?

Thanks


---

## Re: QQE Strategy

**Apprentice** · Thu Aug 01, 2013 2:18 am

can you post used indicators and strategies here please.


---

## Re: QQE Strategy

**jaricarr** · Fri Feb 19, 2016 1:34 pm

Hi Apprentice,

I'm having an issue with QQE.Lua strategy.. The optimization and backtesting works fine but when using the strategy on live trading (demo acc) it will not close my position(s). I did check the trailing stop box (slow or fast) but it is not exiting when the QQE line crosses the trailing stop line.

Basically it is turning winning trades into losing trades.
I'm thinking maybe it needs the option to "close on opposite", or maybe im missing something.
Please let me know.

Thanks,
jaricarr


---

## Re: QQE Strategy

**Apprentice** · Thu Feb 25, 2016 12:31 pm

Major update of All above strategys.
Please test updated versions.
Will add "close on opposite" if needed.


---

## Re: QQE Strategy

**Apprentice** · Sun Jan 21, 2018 7:29 am

The strategy was revised and updated.
