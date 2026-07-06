# Price_MA Cross with RSI confirmation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63405  
> Forum: 17 · Topic 63405 · 13 post(s)


---

## Price_MA Cross with RSI confirmation

**Apprentice** · Sun Apr 24, 2016 3:35 am

![EURUSD H6 (04-24-2016 1001).png](images/105927/EURUSD%20H6%20%2804-24-2016%201001%29.png)



Based on request.
[viewtopic.php?f=27&t=63402](https://fxcodebase.com/code/viewtopic.php?f=27&t=63402)

Open Short
Price falls below MVA
and RSI is below Sell level
Or vice versa for Long.

 [Price_MA Cross with RSI confirmation.lua](files/105927/Price_MA%20Cross%20with%20RSI%20confirmation.lua)

VARMA is available here.
[viewtopic.php?f=17&t=3521&p=111301#p111301](https://fxcodebase.com/code/viewtopic.php?f=17&t=3521&p=111301#p111301)


---

## Re: Price_MA Cross with RSI confirmation

**allerner** · Sun Jul 31, 2016 1:18 pm

Hi Apprentice thanks for the indicator.
I'm getting the following error with this indicator:
An error occurred during the calculation of the indicator 'PRICE_MA CROSS WITH RSI CONFIRMATION(USD/CAD, MVA, 14, 14)'. The error details: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/Price_MA Cross with RSI confirmation.lua:412: The third parameter must be a string.
Thank you an advance


---

## Re: Price_MA Cross with RSI confirmation

**allerner** · Sun Jul 31, 2016 8:04 pm

Hi Apprentice thanks for the indicator.
I have a problem with the indicator:
An error occurred during the calculation of the indicator 'PRICE_MA CROSS WITH RSI CONFIRMATION(USD/CAD, MVA, 14, 14)'. The error details: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/Price_MA Cross with RSI confirmation.lua:412: The third parameter must be a string.
Thank you an advance


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Tue Aug 02, 2016 6:36 am

Fixed.


---

## Re: Price_MA Cross with RSI confirmation

**bobmuir** · Wed Aug 24, 2016 5:52 am

Hi
Would it be possible to adapt RSI.MA to automatic trade With respect if costs where involved I Would be able to contribute
Regards


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Wed Aug 24, 2016 6:33 am

This service is free for you.
Can you provide more detailed description of the necessary modifications.


---

## Re: Price_MA Cross with RSI confirmation

**sandrolmp** · Mon Feb 20, 2017 3:51 am

Hi Apprentice,
I would be glad if the program could send the alert only if the candle that triggers the signal, really closes beyond the chosen moving average and if the next candle opens and closes beyond the same moving average. Only in this case, when the next candle closes, the signal should be sent.
Feel free to share.
Sandrolmp


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Tue Feb 21, 2017 6:26 am

Use "End of Turn" execution, NOT "Live"


---

## Re: Price_MA Cross with RSI confirmation

**Gentle** · Thu Mar 02, 2017 10:36 am

Hi Apprentice,

Would it be possible to add VARMA at the MA options ?


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Fri Mar 03, 2017 5:00 am

VARMA option added.


---

## Re: Price_MA Cross with RSI confirmation

**HappyFox8** · Wed Aug 16, 2017 5:02 pm

Is it possible to modify this indicator so that the alert sounds only if the RSI condition is also met? At the moment the alert is sounding for all MA crosses.


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Thu Aug 17, 2017 3:08 am

"Use RSI Alert Filter" option added.


---

## Re: Price_MA Cross with RSI confirmation

**Apprentice** · Sun Oct 28, 2018 5:14 am

The Indicator was revised and updated.
