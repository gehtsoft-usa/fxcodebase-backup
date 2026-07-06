# Currency Pair Correlation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=951  
> Forum: 17 · Topic 951 · 7 post(s)


---

## Currency Pair Correlation

**Apprentice** · Tue May 04, 2010 2:30 pm

![Currency pair correlation.png](images/1745/Currency%20pair%20correlation.png)

*Currency pair correlation*



The indicator shows how much Currency Pair have grow or decline in percentage terms,
 from initial (first) period, shows the relative change.

At this point, all currencies start with 100.

To work, for now, an indicator is requesting to be subscribed to all the currency pairs that are used.
"EUR/USD","USD/JPY","GBP/USD","USD/CHF","EUR/JPY","EUR/GBP","EUR/CHF",
"GBP/JPY","CHF/JPY","GBP/CHF","NZD/USD","AUD/USD","USD/CAD"

For AUD, NZD, CAD calculation was simplified
Comparison is only against USD.
While the comparison of other currencies against a basket of currencies.

 [Currency Correlation.lua](files/1745/Currency%20Correlation.lua)

Currency Correlations Indikator
[http://fxcodebase.com/code/viewtopic.php?f=17&t=843#p1501](https://fxcodebase.com/code/viewtopic.php?f=17&t=843#p1501)

The indicator was revised and updated


---

## Re: Currency Pair Correlation

**Apprentice** · Sat Dec 04, 2010 5:37 pm

Update.


---

## Re: Currency Pair Correlation

**4xtr8r** · Sat Dec 11, 2010 10:51 pm

How can i get this indicator to work? I attached it to my chart, but nothing shows up.

thx.


---

## Re: Currency Pair Correlation

**Apprentice** · Sun Dec 12, 2010 9:13 am

I have update subscription list.
This is probably the cause of your problems.

Adaptive,
version is much more complex,
but can probably make a simplified version.


---

## Re: Currency Pair Correlation

**4xtr8r** · Sun Dec 12, 2010 7:01 pm

Hi Apprentice,

I still don't understand how to get it to work. I opened a chart with EURUSD and tried to add the indicator and all i get is the option to turn a "dollar" on/off and color option, "yen" on/off, color option, etc.

When I click "ok"... the indicator window is blank.. is just says "dollar, euro, jen, pound.." and a blank window.


---

## Re: Currency Pair Correlation

**Apprentice** · Mon Dec 13, 2010 6:15 am

![Subcription List.PNG](images/6734/Subcription%20List.PNG)



To this indicator could work,
you must be subscribed to all of these currency pairs,
In my case, it is the first 13 currency pairs, from the subscription list.


---

## Re: Currency Pair Correlation

**Apprentice** · Wed Feb 01, 2017 7:37 am

Indicator was revised and updated.
