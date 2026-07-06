# Normalized CCI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73352  
> Forum: 17 · Topic 73352 · 6 post(s)


---

## Normalized CCI

**Apprentice** · Wed Feb 08, 2023 9:27 am

![EURUSD m1 (02-08-2023 1526).png](images/149560/EURUSD%20m1%20%2802-08-2023%201526%29.png)



[https://fxcodebase.com/code/viewtopic.php?f=17&p=149549](https://fxcodebase.com/code/viewtopic.php?f=17&p=149549)

 [Normalized CCI.lua](files/149560/Normalized%20CCI.lua)


---

## Re: Normalized CCI

**Gilles** · Tue Feb 14, 2023 1:27 pm

Hi Apprentice,

In one of your messages, you specified the following:
"For normalization, I use period Min, Max. Is there another method you would like to use? "

However, I believe normalization should be done following these guidelines:

The normalized Commodity Channel Index (CCI) is calculated by dividing the CCI by its standard deviation over a given period (14).

The formula I suggest using to calculate the normalized CCI is as follows:
Normalized CCI = (CCI - CCI's simple moving average) / (0.015 x CCI's standard deviation)

where:

CCI is the Commodity Channel Index.
CCI's simple moving average is the simple moving average of the CCI over a given period (usually 14 periods).
CCI's standard deviation is the standard deviation of the CCI over the same period as the moving average.

Thank you very much, Apprentice! :)


---

## Re: Normalized CCI

**Apprentice** · Wed Feb 15, 2023 3:02 am

We have added your request to the development list.
Development reference 150.


---

## Normalized CCI

**Apprentice** · Wed Feb 15, 2023 3:42 am

![EURUSD H1 (02-15-2023 0941).png](images/149627/EURUSD%20H1%20%2802-15-2023%200941%29.png)



Try this version.

 [Normalized CCI.lua](files/149627/Normalized%20CCI.lua)


---

## Adaptive Normalized CCI

**Gilles** · Tue Feb 28, 2023 1:32 pm

Hi Apprentice,

Would it be possible for you to create an Adaptive version of the Normalized CCI indicator ?
I suggest using the calculation method used for the AMA (Adaptive Moving Average) indicator.

Thanck you !


---

## Re: Normalized CCI

**Apprentice** · Wed Mar 01, 2023 6:40 am

We have added your request to the development list.
Development reference 205.
