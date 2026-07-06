# Range Bar

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=1338  
> Forum: 17 · Topic 1338 · 5 post(s)


---

## Range Bar

**Apprentice** · Tue Jun 15, 2010 3:50 am

![Range Bar.png](images/2553/Range%20Bar.png)

*Range Bar*



Period Range is difference between the period maximum and minimum.

Generates a signal when Up or Down bar appear.

**Up Bar**
Open[period] < 1/3 of Periods Range
Close[period] > 2/3 of Periods Range

**Down Bar**
Open[period] > 2/3 of Periods Range
Close[period] < 1/3 of Periods Range

I made two versions an oscillator and an indicator.

 [Range Bar.lua](files/2553/Range%20Bar.lua)

 [Range Bar Oscillator.lua](files/2553/Range%20Bar%20Oscillator.lua)

The indicator was revised and updated


---

## Re: Range Bar

**Apprentice** · Tue Jun 15, 2010 4:44 am

**Advanced Range Bar**
If the Period Range is set to 1, behaves as a standard Range Bar.

If Not.
Range for a certain time frame, is calculated as the difference between the maximum and minimum for the Time frame.

 [Advanced Range Bar.lua](files/2555/Advanced%20Range%20Bar.lua)


---

## Re: Range Bar

**Apprentice** · Mon Feb 05, 2018 6:42 am

The Indicator was revised and updated.


---

## Re: Range Bar

**hadenfx** · Sun Feb 25, 2018 9:06 pm

Hi Apprentice, I couldn't see your latest file since you've mentioned "the indicator is revised and updated".
you've mentioned if i changed the perriod ='1', it will behave a range bar. does this refer to range bar by tick?

thanks for your help.


---

## Re: Range Bar

**Apprentice** · Mon Feb 26, 2018 4:48 pm

> I couldn't see your latest file since you've mentioned "the indicator is revised and updated".

All old post files are updated.
Have NOT post any new file.

> you've mentioned if i changed the perriod ='1', it will behave a range bar. does this refer to range bar by tick?

Timeframe reverses to how many candles will be used in the calculation.
1 - Only current candle
2 - the last two candles
and so on
