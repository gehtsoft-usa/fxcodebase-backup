# MA Crossover shown in price Chart

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65706  
> Forum: 17 · Topic 65706 · 10 post(s)


---

## MA Crossover shown in price Chart

**Apprentice** · Tue Feb 06, 2018 4:52 pm

![EURUSD D1 (02-06-2018 2049).png](images/117619/EURUSD%20D1%20%2802-06-2018%202049%29.png)



Based on the request.
[viewtopic.php?f=27&t=65699](https://fxcodebase.com/code/viewtopic.php?f=27&t=65699)

 [MA Crossover shown in price Chart.lua](files/117619/MA%20Crossover%20shown%20in%20price%20Chart.lua)


---

## MA Equilibrium

**Apprentice** · Tue Feb 06, 2018 5:15 pm

![EURUSD m1 (02-06-2018 2156).png](images/117621/EURUSD%20m1%20%2802-06-2018%202156%29.png)



My implementation.
Will give the price for which, the two moving average will be equalized.

 [MA Equilibrium.bin](files/117621/MA%20Equilibrium.bin)


---

## Re: MA Crossover shown in price Chart

**Apprentice** · Tue Feb 06, 2018 6:00 pm

MA Equilibrium.bin update.
Please re-download.


---

## Re: MA Crossover shown in price Chart

**robbieyoung** · Tue Feb 06, 2018 7:37 pm

Thanks for all the hard work.

Apologies, my initial calculations were completely wrong.

The first equilibrium file was very close but I noticed the equilibrium price in the current open bar moved as the price moved which it shouldn't do.

The second Equilibrium bin file gives me results very similar to mine ie prices way too high and low.

The correct formula seems to be:

(Period2*SUM(Period1-1)-Period1*SUM(Period2-1))/(Period1-Period2)

(20*SUM(10-1))-10*SUM(20-1))/(10-20)

Where Sum(Period1-1) ie Sum(10-1) is the sum of the previous 9 closes
and Sum(Period2-1) ie Sum(20-1) is the sum of the previous 19 closes

I can send an excel spreadsheet showing the calculations if you require further information.

Many thanks for all your efforts.


---

## Re: MA Crossover shown in price Chart

**robbieyoung** · Wed Feb 07, 2018 7:23 am

Hi,

I have looked again at the updated MA Equilibrium bin.

This is very close but I notice the MA Equilibrium price for the latest (Open) bar still varies as the current price varies, it should be fixed.

The attached spreadsheet gives the calculated equilibrium price using the formula given in the last post for H4 EURUSD Prices.

Substituting the equilibrium price for the close price on the same bar does equate the 2 MA's.

I hope this helps,

Thanks again.


---

## Re: MA Crossover shown in price Chart

**Apprentice** · Thu Feb 08, 2018 6:29 am

Based on / Modified
(Period2*SUM(Period1-1)-Period1*SUM(Period2-1))/(Period1-Period2)

Is calculated as
Price[-1] + (Period2* (Period-1)SUM[-1]-Period1*(Period-2)SUM[-1])/(Period1-Period2)

 [Modified MA Crossover shown in price Chart.lua](files/117636/Modified%20MA%20Crossover%20shown%20in%20price%20Chart.lua)


---

## Re: MA Crossover shown in price Chart

**robbieyoung** · Thu Feb 08, 2018 10:24 am

Many thanks for the update but I get the following error:

C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custon/Modified MA Crossover shown in price Chart.lua:65: attempt to concatenate upvalue 'Method2' (a nil value)

Sorry to be a pain but this indicator will really help me.

Thanks again.


---

## Re: MA Crossover shown in price Chart

**robbieyoung** · Thu Feb 08, 2018 12:18 pm

I managed to get the code to work by removing Method1 & Method2 from the name as they were returning nul.

The calculations are working perfectly but the results and the plotted line seems to be shifted 1 period to the right.

I tried changing the calculation to:

 Line[period-1]=source[period-1]+(Period2*Sum1-Period1*Sum2)/(Period1-Period2);

This shifts the results back 1 period but then there is no value showing the MA equilibrium price in the current open bar.

Ill try some other things to fix it but your help would be greatly appreciated (again!)

Thanks


---

## Re: MA Crossover shown in price Chart

**robbieyoung** · Thu Feb 08, 2018 12:49 pm

I changed the code to:

 local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Period1 .. ", " .. Period2 .. ")";

and:

 local Sum1=mathex.sum(source, period-Period1+1, period);
 local Sum2=mathex.sum(source, period-Period2+1, period);
 Line[period]=source[period]+(Period2*Sum1-Period1*Sum2)/(Period1-Period2);

and this seems to have done shifted the graph back 1 period and also provides a calculation for the final open bar.

I cannot thank you enough for all your work in creating this indicator.

It will be a massive help to me monitoring for potential upcoming trades.


---

## Re: MA Crossover shown in price Chart

**Apprentice** · Fri Feb 09, 2018 6:17 am

Fixed.
