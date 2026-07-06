# Fractal Bar Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61341  
> Forum: 17 · Topic 61341 · 22 post(s)


---

## Fractal Bar Indicator

**Apprentice** · Sat Oct 18, 2014 11:50 am

![Fractal Bar Indicator.png](images/96601/Fractal%20Bar%20Indicator.png)



Based on request.
[viewtopic.php?f=27&t=61340](https://fxcodebase.com/code/viewtopic.php?f=27&t=61340)

GREEN
PRICE> FRACTAL
RED
PRICE< FRACTAL

 [Fractal Bar Indicator.lua](files/96601/Fractal%20Bar%20Indicator.lua)

 

![Fractal Bar Indicator.png](images/96601/Fractal%20Bar%20Indicator%20%282%29.png)



 [MTF MCP Fractal Bar Heat Map.lua](files/96601/MTF%20MCP%20Fractal%20Bar%20Heat%20Map.lua)

 

![MTF MCP Fractal Bar List.png](images/96601/MTF%20MCP%20Fractal%20Bar%20List.png)



 [MTF MCP Fractal Bar List.lua](files/96601/MTF%20MCP%20Fractal%20Bar%20List.lua)

The indicator was revised and updated


---

## Re: Fractal Bar Indicator

**Apprentice** · Tue Feb 10, 2015 6:39 am

MTF MCP Fractal Bar Heat Map Added.


---

## Re: Fractal Bar Indicator

**Alexander.Gettinger** · Mon Mar 09, 2015 3:51 pm

MQL4 version of Fractal Bar indicator: [viewtopic.php?f=38&t=61980](https://fxcodebase.com/code/viewtopic.php?f=38&t=61980).


---

## Re: Fractal Bar Indicator

**mulligan** · Tue Jun 02, 2015 7:15 am

Quick question. Does the fractal bar indicator repaint any bars in the history?

Thanks


---

## Re: Fractal Bar Indicator

**Apprentice** · Sun Jun 07, 2015 4:02 am

Yes.
If the current price exceeds the previous Up or Down fractal.


---

## Re: Fractal Bar Indicator

**Apprentice** · Tue Mar 07, 2017 7:25 am

Indicator was revised and updated.


---

## Re: Fractal Bar Indicator

**Avignon** · Tue Mar 14, 2017 8:16 am

Hello,

Why there is signal ?

 

![Capture.png](images/111449/Capture.png)



Best regards.


---

## Re: Fractal Bar Indicator

**Apprentice** · Wed Mar 15, 2017 4:10 am

Try it now.


---

## Re: Fractal Bar Indicator

**Avignon** · Wed Mar 22, 2017 5:28 pm

It's alright It works !

(Sorry for the response time, I'm on long time units)


---

## Re: Fractal Bar Indicator

**Avignon** · Sun Apr 15, 2018 12:46 pm

MTF MCP Fractal Bar List with Alert.

 [MTF MCP Fractal Bar List with Alert.lua](files/118678/MTF%20MCP%20Fractal%20Bar%20List%20with%20Alert.lua)


---

## Re: Fractal Bar Indicator

**Avignon** · Wed May 12, 2021 2:40 am

At times, if you scroll down, you get this.

 

![Capture.png](images/142027/Capture.png)



It is not a really problem, you can put it in low priority.


---

## Re: Fractal Bar Indicator

**Apprentice** · Wed May 12, 2021 4:48 am

Your request is added to the development list.
Development reference 466.


---

## Re: Fractal Bar Indicator

**Apprentice** · Thu May 13, 2021 5:00 am

[MTF MCP Fractal Bar Heat Map.lua](files/142064/MTF%20MCP%20Fractal%20Bar%20Heat%20Map.lua)

I failed to reproduce it.
This will happen if you use too much Spacing.
Additionally, I applied some optimizations.


---

## Re: Fractal Bar Indicator

**Avignon** · Fri May 14, 2021 10:25 am

Still the same.

If I can help you with the diagnosis. Screen size perhaps?


---

## Re: Fractal Bar Indicator

**Avignon** · Fri May 14, 2021 1:40 pm

![Capture.png](images/142097/Capture.png)



It's not specific. I took another one at random, it's the same.


---

## Re: Fractal Bar Indicator

**Apprentice** · Sat May 15, 2021 7:45 am

The screen size will be great.


---

## Re: Fractal Bar Indicator

**GKAY2122** · Fri Nov 24, 2023 12:14 pm

Can a buy order only and sell order selection be added to the input menu?


---

## Re: Fractal Bar Indicator

**Apprentice** · Tue Nov 28, 2023 9:40 am

To only show Long or Short Signals or Both?


---

## Re: Fractal Bar Indicator

**GKAY2122** · Tue Nov 28, 2023 12:05 pm

It's more about entering a position. If the market is up I want a buy signal and a long position triggered. I wouldn't want a short position triggered on a sell signal if the market was up.


---

## Re: Fractal Bar Indicator

**ahmedalhosenyy** · Thu Mar 13, 2025 8:20 am

May we have a 1 bar shift " to give signal next bar after close above or below the fractal .

Thansk


---

## Re: Fractal Bar Indicator

**Apprentice** · Sun Mar 16, 2025 3:14 pm

We have added your request to the development list.
Development reference 207


---

## Re: Fractal Bar Indicator

**Apprentice** · Thu Jun 05, 2025 1:49 pm

[MTF_MCP_Fractal_Bar_Heat_Map.lua](files/159498/MTF_MCP_Fractal_Bar_Heat_Map.lua)

Shift option added.
