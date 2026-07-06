# Currency Correlation (Majors)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=987  
> Forum: 17 · Topic 987 · 34 post(s)


---

## Currency Correlation (Majors)

**Apprentice** · Sat May 08, 2010 10:27 am

![Currency  Correlation.png](images/1833/Currency%20Correlation.png)



As I promised I have brought together all the individual Currency indexes in one currency Correlation indicator.

Indicator provides insight in the movement of individual currencies in relation to other Majors.

To work, you must be subscribed to...
EUR/USD, USD/JPY, GBP/USD, USD/CHF, EUR/JPY, EUR/GBP, EUR/CHF, GBP/JPY, CHF/JPY, GBP/CHF, AUD/USD, NZD/USD, USD/CAD.

AUD, NZD & CAD indexes have reduced accuracy, indicator show only their correlation to the USD.

 [Currency Correlation.lua](files/1833/Currency%20Correlation.lua)

As requested version with Overbouth / Oversold levels added.

 [Currency Correlation Levels.lua](files/1833/Currency%20Correlation%20Levels.lua)

The indicator was revised and updated


---

## Re: Currency Correlation (Majors)

**wizardpro** · Mon Oct 25, 2010 3:23 am

Hi,Great product.
But neverless I would like to remove some ofthe currently or colour as I just wanan see Eur/USD and USD/CHF .The rest I do not want to see it ,any way to remove the colour or parameter as I try changing the rest of the currency pair to black to match my background colour,but it will distore the indicator .
2)Can this indicator add such as when A and B pair cross, send an emails/sound alert?


---

## Re: Currency Correlation (Majors)

**Apprentice** · Mon Oct 25, 2010 8:03 am

I'll try to find time to add this functionality.

Indicators can not send signals.
But we can write the signal.


---

## Re: Currency Correlation (Majors)

**lucky777** · Mon Oct 25, 2010 10:58 am

Currency correlation Majors.
Hi apprentice,
Great indicator, You are doing great work for all of us.
!. could you PLEASE add the function when Aud or Eur crossover the green line of the USD signal alert should come on the screen going up mean buy and going down mean sell.
2.In the Major currency index could you please add or write the function where It could be changed the curerncy line into two colours as YOU HAVE DONE IN THE SUPER TREND.(it will be very helpful to know the trend)
It would be very very much appreicated.
Thanks in advance.
Lucky 777

You have promised to write but I know for due to overload you could not. Could you please Please write as you get the time. It will be really appreciated. It will help . Thanks again.
As to the first request, the indicator supports this feature.
Hopefully tomorrow I'll find time to write the required signal.
Apprentice
FXCodeBase: Confirmed User

Posts: 1060
Joined: Fri Jan 01, 2010 3:29 am
Location: Zagreb, Croatia
Private messageE-mail


---

## Re: Currency Correlation (Majors)

**wizardpro** · Mon Oct 25, 2010 12:24 pm

Hi ,
Great, it would be good such as to edit such as taking or add currency pair instead of loading all the different currency pair with different time frames.
I would like just to have Eur/USD vis USD/CHF with select time frames with soung and emails alert :p


---

## Re: Currency Correlation (Majors)

**Apprentice** · Thu Oct 28, 2010 2:11 pm

As to the first request, the indicator supports this feature.
Hopefully tomorrow I'll find time to write the required signal.


---

## Re: Currency Correlation (Majors)

**vstrelnikov** · Thu Oct 28, 2010 4:50 pm

Fixed "index out of range" error.


---

## Re: Currency Correlation (Majors)

**lucky777** · Tue Jan 18, 2011 10:28 am

Hi Apprentice,
Well done job.
 I can edit the usd/Eur Aud/USD or Usd/CHF.
 But
Could you please add the multiplier or write the function where I could change the line in the index into two colors like EUR/USD. As soon as the trend change USD line green going up and red going down,
EUR is red color going up is red and going down is green.
Pound is purple line going up mean purple and down mean red
It would be really appreicated.
Thanks


---

## Re: Currency Correlation (Majors)

**Apprentice** · Tue Jan 18, 2011 3:07 pm

[Currency Correlation.lua](files/7557/Currency%20Correlation.lua)

I wrote the adaptation.
I asked you to send me the colors you use in RGB format,
for all currencies (up and down).

For example, RGB (255, 0, 0) for red.


---

## Re: Currency Correlation (Majors)

**lucky777** · Tue Jan 18, 2011 8:04 pm

Hi Apprentice,
Thanks for writing the Adaptation. It is working very well now . It is exactly the way I wanted to see.
God Bless you.
Thanks again.
Lucky777


---

## Re: Currency Correlation (Majors)

**LeTigre30** · Wed Feb 23, 2011 6:12 pm

Hi Apprentice,

Can you say me how to use the "Currency Correlation" indicator ?

Many thanks.


---

## Re: Currency Correlation (Majors)

**Apprentice** · Wed Feb 23, 2011 7:06 pm

Unlike currency pairs, this indicator shows the movement of individual currencies.

Answer to the question whether certain currencies have a positive or negative correlation.

Also, there is also spread. When two currencies have a large spread it is expected that spread will decrease.

It is not for trader tool, is it analytical tool.


---

## Re: Currency Correlation (Majors)

**LeTigre30** · Wed Feb 23, 2011 8:34 pm

Hi Apprentice,

When I've charged this strategy, Marketscope returns me an error :
pls see the picture

 [3211](files/8401/Error%20line%20357%20Currency%20Correlation.JPG)


---

## Re: Currency Correlation (Majors)

**Apprentice** · Thu Feb 24, 2011 3:55 am

To work, you must be subscribed to...
EUR/USD, USD/JPY, GBP/USD, USD/CHF, EUR/JPY, EUR/GBP, EUR/CHF, GBP/JPY, CHF/JPY, GBP/CHF, AUD/USD, NZD/USD, USD/CAD.


---

## Re: Currency Correlation (Majors)

**MoonValley** · Wed Jun 22, 2011 6:49 am

By subscription, do you mean that you have the currency pairs' symbols available in the Trading Station's rate window and in the Marketscope's currency pairs drop-down menu?


---

## Re: Currency Correlation (Majors)

**Apprentice** · Wed Jun 22, 2011 1:45 pm

Yes


---

## Re: Currency Correlation (Majors)

**zagalaj** · Tue Jun 28, 2011 8:38 am

Hi Sir,

Is it possible to have the graphs calculate from a fixed point? The reason why I ask is because when you zoom in / zoom out on an exisiting graph, the lines "flip" due to the re-calculation and this is problematic when trying to perform time based analysis.

thank you Sir!

John


---

## Re: Currency Correlation (Majors)

**Apprentice** · Tue Jun 28, 2011 8:45 am

I will add this additional functionality as an option.


---

## Re: Currency Correlation (Majors)

**zagalaj** · Sun Jul 03, 2011 6:29 pm

Hello Sir,

Were you able to add the functionality to calculate from a fixed point to this indicator?

thank you

John


---

## Re: Currency Correlation (Majors)

**zaphod** · Sat Jul 09, 2011 1:28 pm

Hi, I am new to this and I have no programming skills. I loaded your Currency Correlation add-on into MarketScope 2.0 and when I ran the add-on I got an error message that says: see attachment.

I have loaded another add-on with no problems. What am I doing wrong?

Thanks.

Don


---

## Re: Currency Correlation (Majors)

**zaphod** · Sun Jul 10, 2011 3:34 pm

Sorry, I didn't have all the pairs loaded-works now--Thanks


---

## Re: Currency Correlation (Majors)

**t1982t** · Wed Jul 20, 2011 10:04 am

Hello Apprendice
I wondering if it is possible do this indicator like a table, with numbers. With a correlation from -1 to 1, like the traditional table of correlation.
Example: [http://fxtrade.oanda.com/lang/es/analys ... orrelation](http://fxtrade.oanda.com/lang/es/analysis/currency-correlation)
Thank you
Kind regards


---

## Re: Currency Correlation (Majors)

**Apprentice** · Wed Jul 20, 2011 1:49 pm

Your request is added to the developmental cue.


---

## Re: Currency Correlation (Majors)

**flem_wad** · Tue Feb 14, 2012 3:02 pm

Hi,

Had an idea to improve this indicator!

1) A zero line could be added. And:
2) User-defined overbought and oversold levels.

That would be cool. I am going to try and code the mod myself. Wish me luck.


---

## Re: Currency Correlation (Majors)

**Apprentice** · Wed Feb 15, 2012 7:08 am

Your request is added to the development list.


---

## Re: Currency Correlation (Majors)

**Apprentice** · Thu Feb 16, 2012 2:54 pm

As requested, Overbouth / Oversold Levels added.


---

## Re: Currency Correlation (Majors)

**flem_wad** · Mon Mar 05, 2012 2:19 pm

Hi,

Could a strategy be written for this indicator?

If so, thanks.
flem_wad


---

## Re: Currency Correlation (Majors)

**Apprentice** · Tue Mar 06, 2012 4:26 am

Yes.Can you describe an algorithm for this strategy.


---

## Re: Currency Correlation (Majors) Strategy Request

**flem_wad** · Tue Mar 06, 2012 9:09 am

Hi Apprentice,

Example Trades/Trading Logic (please refer to screenshot.png)

Whenever one currency crosses another, a trade is executed. This depends, however; on the index/base currency that the EA is using (default: USD) and this will be user-definable.

For example: In the screenshot, the USD (Green line) is going up and passes through NZD; GBP; AUD and CAD. In this case, we enter a long trade.

Equally, the USD passes through JPY going down and in this case we enter a short trade (because the base currency is USD.)

I hope this is not too difficult.
Take care.
flem_wad


---

## Re: Currency Correlation (Majors)

**izzatilla** · Tue Jul 23, 2013 12:46 pm

I have a following problem please help me in resolving

An error occurred during the calculation of the indicator 'CURRENCY CORRELATION LEVELS'. The error details: Currency Correlation Levels.lua:342: Incorrect instrument name..


---

## Re: Currency Correlation (Majors)

**Apprentice** · Sun Jul 28, 2013 2:10 am

U do not have a subscription to all specified, required currency pairs.


---

## Re: Currency Correlation (Majors)

**daniel.kovacik** · Thu Aug 14, 2014 6:57 pm

Hi, this indicator doest work... Same issue like second post before...
I was trying that indicator with dollar and Jen on USD/JPY... I ve tried it on all timeframes...

Could you help solve this issue. Or is there any indicator called currency strenght index with all major currencies?

**An error occurred during the calculation of the indicator 'CURRENCY CORRELATION (1)'. The error details: Currency Correlation (1).lua:370: Incorrect instrument name.**


---

## Re: Currency Correlation (Majors)

**Apprentice** · Fri Aug 15, 2014 12:54 am

U do not have a subscription to all specified, required currency pairs.

To work, you must be subscribed to...
EUR/USD, USD/JPY, GBP/USD, USD/CHF, EUR/JPY, EUR/GBP, EUR/CHF, GBP/JPY, CHF/JPY, GBP/CHF, AUD/USD, NZD/USD, USD/CAD.

If 20 subscription limit is a problem for you.
Ask FXCM to remove this restriction for your account.


---

## Re: Currency Correlation (Majors)

**Apprentice** · Tue Jul 11, 2017 1:56 pm

The indicator was revised and updated.
