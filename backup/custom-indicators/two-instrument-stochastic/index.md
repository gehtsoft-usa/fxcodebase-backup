# Two Instrument Stochastic

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=4906  
> Forum: 17 · Topic 4906 · 24 post(s)


---

## Two Instrument Stochastic

**Apprentice** · Wed Jun 29, 2011 2:11 pm

![Two Instrument Stochastic.png](images/12178/Two%20Instrument%20Stochastic.png)



 [Two Instrument Stochastic.lua](files/12178/Two%20Instrument%20Stochastic.lua)

 

![AUDUSD m5 (05-27-2020 1312).png](images/12178/AUDUSD%20m5%20%2805-27-2020%201312%29.png)



 [Two Instrument Stochastic Cross.lua](files/12178/Two%20Instrument%20Stochastic%20Cross.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=69998](https://fxcodebase.com/code/viewtopic.php?f=38&t=69998)


---

## Re: Two Instrument Stochastic

**zagalaj** · Wed Jun 29, 2011 9:45 pm

Thank you Sir

this is money!

regards,

John


---

## Re: Two Instrument Stochastic

**rhodia16** · Thu Jun 30, 2011 12:47 am

Dear Apprentice,

I am a great fan of the indicators made by you and your colleagues.
This one is also great. Thank you!

I am wondering if it is possible to subtract "one instrument stochastic" from the other.

For example:
Output = [stochastic EURUSD] - [stochastic USDCHF]

The out put will be one curved line having the range between -100 and +100.

This can be highly useful if the "stochastic subtraction" is applied to two negatively correlated pairs.

It would be even better if not only subtraction but also other calculations such as addition, multiplication or division can be performed for stochastics.

I would be most grateful if you could examine the possibility to make the above.

Thanks in advance. Have a nice day!

Rhodia


---

## Re: Two Instrument Stochastic

**Apprentice** · Thu Jun 30, 2011 1:43 am

![Two Instrument Stochastic Difference.png](images/12191/Two%20Instrument%20Stochastic%20Difference.png)



This indicator calculates the difference between two Stochastic indicators on two time frames.

 [Two Instrument Stochastic Difference.lua](files/12191/Two%20Instrument%20Stochastic%20Difference.lua)


---

## Re: Two Instrument Stochastic

**rhodia16** · Thu Jun 30, 2011 2:21 am

Dearest Apprentice,

Thank you!!!

That was quick! It took only one hour after my post!

I downloaded the difference indicator, installed and had a look at it.
It is working perfectly at this moment.

I really really thank you for this.

If necessary, I will report you how this could be useful etc etc in future as I explore its potential.

Thank you again! Today is definitely a good day.

Rhodia


---

## Re: Two Instrument Stochastic

**rhodia16** · Fri Jul 15, 2011 9:44 am

Dear Apprentice,

I am enjoying "Two Instrument Stochastic Difference" a lot. It is really useful.

Thank you.

I have found that "Indicator_Divergence" cannot be applied to "Two Instrument Stochastic Difference".

Whenever I try, "Indicator_Divergence" gives the following error message:

[string "Indicator_Divergence":80: The stream identifier must contain English letters or digits only and must begins with a letter

"Indicator_Divergence" itself works OK for other indicators on my platform. So I guess "Two Instrument Stochastic Difference" has a small problem.

Could you have a look at it?

Thank you in advance!

Rhodia


---

## Re: Two Instrument Stochastic

**Apprentice** · Sat Jul 16, 2011 3:40 am

I or someone from the team will look at this problem.


---

## Re: Two Instrument Stochastic

**aymanattia** · Sat Aug 27, 2011 4:57 pm

> **zagalaj wrote:**
> Thank you Sir
>
> this is money!
>
> regards,
>
> John

please ,could anyone explain this indicator , really i can not follow you.
how to use it and what is the signals i can collectt from this indicator


---

## Re: Two Instrument Stochastic

**emjay-short** · Mon Aug 29, 2011 11:59 am

The **Two Instrument Stochastic**, my first guess, would be best used with two pairs, but only three currencies. ie EURJPY EURUSD. Thus you could see, without looking at a separate currency strength/correlation chart ([viewtopic.php?f=17&t=987&hilit=currency+correlation](https://fxcodebase.com/code/viewtopic.php?f=17&t=987&hilit=currency+correlation)) (other form [viewtopic.php?f=30&t=3093#p7209](https://fxcodebase.com/code/viewtopic.php?f=30&t=3093#p7209)), whether or not the EUR is strong when both pairs rise or that JPY and USD both are weak. This is an abstract correlation instrument so to speak. It doesn't show price, it shows their Stochastic.

Technically, look for divergences, oversold and overbought.


---

## Re: Two Instrument Stochastic

**TMos1124** · Tue Feb 28, 2012 10:34 am

Can a strategy be made for this indicator (the stochastic)? For the stochastic if the two pairs cross to buy the one going up and sell the pair going down with exits at fixed stochastic levels. Another strategy would be overbought/oversold (buying the oversold and selling the overbought) with exits also at fixed stochastic levels.


---

## Re: Two Instrument Stochastic

**Apprentice** · Wed Feb 29, 2012 5:13 am

Your request is added to the development list.


---

## Re: Two Instrument Stochastic

**TMos1124** · Thu Mar 08, 2012 1:05 pm

It seems like the differential would be better suited than the stochastic (it is my error).


---

## Re: Two Instrument Stochastic

**Coondawg71** · Tue Nov 19, 2013 5:55 pm

Can we please add alert function to this indicator. Alert would be triggered upon 1) crossing of 50 line 2) Overbought Oversold zones and more importantly 3) crossing of currency pairs values. Alerts would be colorized with up trend/downtrend markers for each crossing.

Thanks!

sjc


---

## Re: Two Instrument Stochastic

**Apprentice** · Tue Sep 30, 2014 12:46 pm

Update.


---

## Re: Two Instrument Stochastic

**Apprentice** · Mon Jun 26, 2017 4:24 am

The indicator was revised and updated.


---

## Re: Two Instrument Stochastic

**scandisk** · Tue May 26, 2020 4:16 pm

Hi Apprentice

I would like to be able to have a corresponding dot customizable sizable and colorable on my chart where the stochastic crosses and also dot on stochastic. I would like the feature to hide the stochastic indicator and still have the corresponding cross dot on my chart..

Awesome thanks so much!!


---

## Re: Two Instrument Stochastic

**Apprentice** · Wed May 27, 2020 4:55 am

Your request is added to the development list.
Development reference 1366.


---

## Re: Two Instrument Stochastic

**Apprentice** · Wed May 27, 2020 8:03 am

Two Instrument Stochastic Cross.lua added.


---

## Re: Two Instrument Stochastic

**scandisk** · Wed May 27, 2020 12:55 pm

Awesome thanks Apprentice works beautiful and thanks for adding inverse too!!
Is it possible to ask one more request is to add the addition of colored dots/circles that are sizable and colors just like the arrows but dots with inverse because the arrows screw me up! lol

Thanks a ton!


---

## Re: Two Instrument Stochastic

**Apprentice** · Wed May 27, 2020 3:56 pm

Your request is added to the development list.
Development reference 1378.


---

## Re: Two Instrument Stochastic

**Tomoso** · Thu May 28, 2020 6:50 am

Could you create this in MT4 version?


---

## Re: Two Instrument Stochastic

**Apprentice** · Thu May 28, 2020 10:23 am

Dot option added.


---

## Re: Two Instrument Stochastic

**Apprentice** · Thu May 28, 2020 10:26 am

Your request is added to the development list.
Development reference 1390.


---

## Re: Two Instrument Stochastic

**Apprentice** · Thu Jun 11, 2020 5:48 am

MT4/MQ4 version
[viewtopic.php?f=38&t=69998](https://fxcodebase.com/code/viewtopic.php?f=38&t=69998)
