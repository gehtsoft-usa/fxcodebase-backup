# Bollinger Band Polynomial regression with Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63874  
> Forum: 17 · Topic 63874 · 11 post(s)


---

## Bollinger Band Polynomial regression with Alert

**Apprentice** · Fri Sep 16, 2016 7:31 am

![EURJPY m1 (03-15-2016 2333).png](images/108144/EURJPY%20m1%20%2803-15-2016%202333%29.png)



Based on the request.
[viewtopic.php?f=27&t=63872#p108124](https://fxcodebase.com/code/viewtopic.php?f=27&t=63872#p108124)

 [Bollinger Band Polynomial regression with Alert.lua](files/108144/Bollinger%20Band%20Polynomial%20regression%20with%20Alert.lua)

Polynomial_Regression.lua is available here.
[viewtopic.php?f=17&t=3715&hilit=Polynomial_Regression.lua](https://fxcodebase.com/code/viewtopic.php?f=17&t=3715&hilit=Polynomial_Regression.lua)


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Fri Sep 16, 2016 7:58 am

Stunning thx!

It is difficult to backtest of course with the poly reg repaint.

 Could we have the added option of using the static version here:
[http://fxcodebase.com/code/viewtopic.php?f=17&t=3715&start=10#p39036](https://fxcodebase.com/code/viewtopic.php?f=17&t=3715&start=10#p39036)
 but with the outer static bands also added?

many thx in advance


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Fri Sep 16, 2016 10:20 am

audio alert doesnt seem to be working. can you check thx


---

## Re: Bollinger Band Polynomial regression with Alert

**Apprentice** · Mon Sep 19, 2016 3:36 am

Fixed.


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Mon Sep 19, 2016 8:34 am

Now no symbols appear unless F5 chart refresh is performed. Still no sound??


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Tue Sep 20, 2016 10:26 am

Mario,
 i see you worked on this polynomial regression MA which is the same line plot as the 'static' one i mention above. Is there any way to code it so the user can also see the outer bands for any user specified std.dev value?


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Tue Sep 20, 2016 11:23 am

e.g. something like this:


---

## Re: Bollinger Band Polynomial regression with Alert

**Apprentice** · Wed Sep 21, 2016 4:20 am

To add Polynomial regression to Bollinger Band?
Can you explain your request in more detail.


---

## Re: Bollinger Band Polynomial regression with Alert

**7510109079** · Wed Sep 21, 2016 9:15 am

the above screen shot was of your Polynomial Regression Moving Average indicator (the thick pink line). I photoshopped in its outer bands (light blue dotted lines) just to show its outer bands as an example. They also would be static versions of the real outer bands. They would plot a constant distance from the MA centreline based on a user specified deviation value and would stretch back as far as chart history goes.

If you could code the Polynomial Regression Moving Average indicator to show these static bands, then this indicator could then be combined with the bollinger band indicator. Any dots outside both Regression and Bollinger bands would signal and alert.

To make the alert simpler to code you only need to have the crossing out alert and not the cross-back-inside alert


---

## Re: Bollinger Band Polynomial regression with Alert

**Apprentice** · Thu Sep 22, 2016 3:25 am

Your request is added to the development list, Under Id Number 3634
 If someone is interested to do this task, please contact me.


---

## Re: Bollinger Band Polynomial regression with Alert

**Apprentice** · Tue Sep 18, 2018 6:50 am

The indicator was revised and updated.
