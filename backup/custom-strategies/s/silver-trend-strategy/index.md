# Silver trend strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=5436  
> Forum: 31 · Topic 5436 · 5 post(s)


---

## Silver trend strategy

**Alexander.Gettinger** · Mon Jul 25, 2011 10:26 pm

Strategy based on Silver trend indicator ([viewtopic.php?f=17&t=3844](https://fxcodebase.com/code/viewtopic.php?f=17&t=3844)).

Opening/closing orders occur when switching indicator.

Download strategy:

 [Silver_Trend_Sig_Strategy.lua](files/13114/Silver_Trend_Sig_Strategy.lua)

For strategy must be installed Silver trend indicator ([viewtopic.php?f=17&t=3844](https://fxcodebase.com/code/viewtopic.php?f=17&t=3844)).

The Strategy was revised and updated on November 19, 2018.


---

## Re: Silver trend strategy

**RJH501** · Tue Jul 26, 2011 12:21 pm

Hi Alexander,

Thanks for your work on this indicator and Strategy! However there is a problem between the 2 indicators. The Silver_Trend_Sig.lua is not identifying the trend reversal properly, whereas Silver_Trend_Sig2.lua is right on the money. Please review the attached chart for a comparison.

Silver_Trend_Sig_Strategy.lua appears to be based on Silver_Trend_Sig.lua causing the trading signals to be inaccurate.

When you get time would you please change the indicator Silver_Trend_Sig_Strategy.lua is based on to Silver_Trend_Sig2.lua? It should improve the strategy results.

Thanks again for your fast turn around time and assistance!

Best regards,

Richard


---

## Re: Silver trend strategy

**RJH501** · Wed Jul 27, 2011 7:19 pm

Hello Alexander,

Thank you for the strategy and signal. Could you please check why there is a difference between STI and STI2 in the way it displays the signal with the same parameters?

This impacts the accuracy of the strategy you developed.

Chart shows what I am talking about.

Best regards,

Richard


---

## Re: Silver trend strategy

**Alexander.Gettinger** · Thu Aug 04, 2011 12:39 am

> **RJH501 wrote:**
> Could you please check why there is a difference between STI and STI2 in the way it displays the signal with the same parameters?

STI2 is a re-drawing indicator and not well suited for use in strategy.
STI is a indicator without re-drawing.


---

## Re: Silver trend strategy

**Apprentice** · Wed Nov 30, 2016 8:41 am

Bump up.
