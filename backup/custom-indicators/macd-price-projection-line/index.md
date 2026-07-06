# MACD price projection line

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=67269  
> Forum: 17 · Topic 67269 · 4 post(s)


---

## MACD price projection line

**Apprentice** · Mon Jan 14, 2019 5:38 am

![EURUSD m1 (01-14-2019 1328).png](images/123350/EURUSD%20m1%20%2801-14-2019%201328%29.png)



Based on request.
[viewtopic.php?f=27&t=67265](https://fxcodebase.com/code/viewtopic.php?f=27&t=67265)

 [MACD price projection line.lua](files/123350/MACD%20price%20projection%20line.lua)

 [MACD price projection line Only.lua](files/123350/MACD%20price%20projection%20line%20Only.lua)


---

## Re: MACD price projection line

**fortcentral** · Mon Jan 14, 2019 8:55 am

Dear Apprentice,
Thank you so much for the quick turnaround on this indicator request! The programmed indicator was not matching my manually calculated line and upon checking it seemed to be missing two sets of brackets in the final trendline formula (line 189 of code) outlined below:
 | | | |
--> (SIGNAL[period]-((1-k["SN"])*internal["SN"][period])+((1-k["LN"])*internal["LN"][period]))

Once put in, the indicator is working great!

I was wondering if there was an easy way to turn-off the MACD signal line and histogram display panel at the bottom and just display the MACD price projection line display on a price chart? This would help declutter the screen with one less indicator panel, when just the projection line display is required.

Regards,
Fortcentral


---

## Re: MACD price projection line

**Apprentice** · Mon Jan 14, 2019 9:20 am

So,
Projection[period+1]=(SIGNAL[period]-((1-k["SN"])*internal["SN"][period])+((1-k["LN"])*internal["LN"][period]))/(k["SN"]-k["LN"]);

we will be used?


---

## Re: MACD price projection line

**fortcentral** · Tue Jan 15, 2019 9:59 am

Yes, correct! Thank you for the update - it is working great now. Really appreciate your help with this indicator.
