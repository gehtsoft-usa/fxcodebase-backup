# Hurst Bands

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61075  
> Forum: 17 · Topic 61075 · 14 post(s)


---

## Hurst Bands

**Apprentice** · Tue Aug 26, 2014 4:36 am

![Hurst Bands.png](images/95565/Hurst%20Bands.png)



Based on request.
[viewtopic.php?f=27&t=61074](https://fxcodebase.com/code/viewtopic.php?f=27&t=61074)

 [Hurst Bands.lua](files/95565/Hurst%20Bands.lua)

The indicator was revised and updated


---

## Hurst Oscillator

**Apprentice** · Tue Aug 26, 2014 5:24 am

![Hurst Oscillator.png](images/95569/Hurst%20Oscillator.png)



Based on Hurst Bands.
Will show the fluctuation of FlowPrice around the central line of Hurst Bands.

 [Hurst Oscillator.lua](files/95569/Hurst%20Oscillator.lua)

 

![EURUSD H1 (01-13-2024 2236).png](images/95569/EURUSD%20H1%20%2801-13-2024%202236%29.png)



 [Hurst Oscillator With Alert.lua](files/95569/Hurst%20Oscillator%20With%20Alert.lua)


---

## Re: Hurst Bands

**Alexander.Gettinger** · Thu Apr 30, 2015 10:15 am

MQL4 versions of Hurst Bands and Hurst Oscillator: [viewtopic.php?f=38&t=62170](https://fxcodebase.com/code/viewtopic.php?f=38&t=62170).


---

## Re: Hurst Bands

**Apprentice** · Mon Jul 03, 2017 8:14 am

The indicator was revised and updated.


---

## Re: Hurst Bands

**mayk01** · Fri Jan 12, 2024 6:33 am

Hi Apprentice,
Is it possible to request more alarms from the oscillator so that I want to set the alarm levels?

Regards,
M.


---

## Re: Hurst Bands

**Apprentice** · Sat Jan 13, 2024 3:28 pm

We have added your request to the development list.
Development reference 66


---

## Re: Hurst Bands

**Apprentice** · Sat Jan 13, 2024 4:39 pm

Hurst Oscillator With Alert.lua added.


---

## Re: Hurst Bands

**mayk01** · Tue Jan 16, 2024 3:57 am

That's great !
One note is that level 2 is not adjustable. You can see that it is there, but you cannot give it a value.

Best regards,
M.


---

## Re: Hurst Bands

**Apprentice** · Sat Jan 20, 2024 4:39 am

We have added your request to the development list.
Development reference 86


---

## Re: Hurst Bands

**Apprentice** · Sun May 26, 2024 8:09 am

![EURUSD H1 (05-26-2024 1507).png](images/155502/EURUSD%20H1%20%2805-26-2024%201507%29.png)



The second alert level was added.

 [Hurst Oscillator With Alert.lua](files/155502/Hurst%20Oscillator%20With%20Alert.lua)


---

## Re: Hurst Bands

**mayk01** · Mon May 27, 2024 2:21 am

It's great and seems to work well.
Thanks


---

## Re: Hurst Bands

**mayk01** · Mon May 27, 2024 5:38 am

I found the error that it alarms even if I turn off the alarm.


---

## Re: Hurst Bands

**Apprentice** · Tue May 28, 2024 1:46 pm

I introduced Alert Master Switch, try to set it to false.

 [Hurst Oscillator With Alert.lua](files/155543/Hurst%20Oscillator%20With%20Alert.lua)


---

## Re: Hurst Bands

**mayk01** · Wed May 29, 2024 4:39 am

Hi,
this is a good idea, i tried it and i really like it.
Thanks
