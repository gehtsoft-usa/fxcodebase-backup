# ATR_Stop_Dots_Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65654  
> Forum: 31 · Topic 65654 · 7 post(s)


---

## ATR_Stop_Dots_Strategy

**Apprentice** · Sun Jan 21, 2018 6:00 am

Based on the request.
[viewtopic.php?f=17&t=63153](https://fxcodebase.com/code/viewtopic.php?f=17&t=63153)

 [ATR_Stop_Dots_Strategy.lua](files/117161/ATR_Stop_Dots_Strategy.lua)


---

## Re: ATR_Stop_Dots_Strategy

**Apprentice** · Mon Jan 22, 2018 5:04 am

Minor bug fixed.


---

## Re: ATR_Stop_Dots_Strategy

**spinemaligna** · Tue Jan 23, 2018 6:15 am

Hi Apprentice,

Slight tweak required. The strategy is trailing the profit (blue) dot instead of the stop {red} dot. I hope this can be fixed.

Ross


---

## Re: ATR_Stop_Dots_Strategy

**Apprentice** · Sun Jan 28, 2018 9:11 am

Try it now.
Please re-download both files, ATR_Stop_Dots_Strategy & ATR_Stop_Dots.


---

## Re: ATR_Stop_Dots_Strategy

**spinemaligna** · Wed Jan 31, 2018 4:11 pm

Great work Apprentice.

I understand that the lot size option is impossible until this strategy is integrated with another one. That will be the next step once this is performing well.
What is now missing is the option to trail the stop in line with the red dot. Is this feasible?

Ross


---

## Re: ATR_Stop_Dots_Strategy

**spinemaligna** · Tue Feb 06, 2018 7:57 am

Nearly there.

As far as I can see the only problem remaining is the fact that the strategy trails the stop dot in both directions at the close of every candle instead of acting like a ratchet and only moves the stop one way.
Hope this can be fixed.

Ross


---

## Re: ATR_Stop_Dots_Strategy

**spinemaligna** · Thu Jan 24, 2019 11:40 am

Hi All,
Nearly a year on and the Trailing Stop loss is still not working properly. It is still moving the S/L in both directions at the candle close. It also moves the stop loss to the red dot of the new candle instead of the recently closed one. Can this be fixed as it is really useful if working correctly.

Ross
