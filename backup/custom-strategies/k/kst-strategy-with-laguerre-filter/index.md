# KST Strategy with Laguerre Filter

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59596  
> Forum: 31 · Topic 59596 · 8 post(s)


---

## KST Strategy with Laguerre Filter

**Apprentice** · Sun Sep 29, 2013 8:40 am

![kst strategy with laguerre filter.png](images/89771/kst%20strategy%20with%20laguerre%20filter.png)



Written according to request.
[viewtopic.php?f=27&t=59594](https://fxcodebase.com/code/viewtopic.php?f=27&t=59594)

Open Long
KST Cross Over BB Buttom Line
And Price is under the laguerre filter (Optional)
Open Short
KST Cross Under BB Top Line
And Price is over the laguerre filter (Optional)

Exit Long (Optional)
Price Cross Over Laguerre Filter
Exit Short (Optional)
Price Cross Under Laguerre Filter

 [kst strategy with laguerre filter.lua](files/89771/kst%20strategy%20with%20laguerre%20filter.lua)

Install KST Indicator
[viewtopic.php?f=17&t=64518](https://fxcodebase.com/code/viewtopic.php?f=17&t=64518)

Laguerre Filter
[viewtopic.php?f=17&t=331&p=8660&hilit=laguerre+filter#p8660](https://fxcodebase.com/code/viewtopic.php?f=17&t=331&p=8660&hilit=laguerre+filter#p8660)

The Strategy was revised and updated on January 21, 2019.


---

## Re: KST Strategy with Laguerre Filter

**amorgos89** · Sun Sep 29, 2013 2:40 pm

Thank you for your help but the strategy that i wish

is this:
the condition for Open Long:
KST Cross Over BB Buttom Line
the condition for open short
KST Cross Under BB Top Line

Exit Long
Price Cross Over Laguerre Filter

Exit Short
Price Cross Under Laguerre Filter

thanks


---

## Re: KST Strategy with Laguerre Filter

**virgilio** · Sun Sep 29, 2013 7:08 pm

In my humble opinion the LONG position should close when the price crosses UNDER. Similarly, a SELL positions should close when price crosses ABOVE. The way the strategy is working right now is exactly the opposite. It should be reversed.


---

## Re: KST Strategy with Laguerre Filter

**Apprentice** · Mon Sep 30, 2013 1:50 am

I disagree.
The strategy is written to the original strategy specification.
As an extension, now you can turn off Price Filter.
Also Price / Exit Laguerre filter is now optional.


---

## Re: KST Strategy with Laguerre Filter

**amorgos89** · Mon Sep 30, 2013 3:31 am

in my original question the conditions of the strategy are:

Open Long
KST Cross Over BB Buttom Line
And Price is under the laguerre filter
Open Short
KST Cross Under BB Top Line
And Price is over the laguerre filter

exit Long
Price Cross Over Laguerre Filter
Exit Short
Price Cross Under Laguerre Filter

thank you


---

## Re: KST Strategy with Laguerre Filter

**Apprentice** · Mon Sep 30, 2013 5:32 am

Obvious misunderstanding.
Try updated version.


---

## Re: KST Strategy with Laguerre Filter

**amorgos89** · Mon Sep 30, 2013 7:37 am

that's right thank you


---

## Re: KST Strategy with Laguerre Filter

**Apprentice** · Tue Dec 19, 2017 8:57 am

The strategy was revised and updated.
