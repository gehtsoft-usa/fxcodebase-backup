# The Ultimate Smoother

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=74838  
> Forum: 17 · Topic 74838 · 9 post(s)


---

## The Ultimate Smoother

**Apprentice** · Sat May 04, 2024 3:13 am

![EURUSD m1 (05-04-2024 1011).png](images/155238/EURUSD%20m1%20%2805-04-2024%201011%29.png)



 This script presents an implementation of the digital smoothing filter introduced by John Ehlers in his article "The Ultimate Smoother" from the April 2024 edition of TASC's Traders' Tips.

█ CONCEPTS

The UltimateSmoother preserves low-frequency swings in the input time series while attenuating high-frequency variations and noise. The defining input parameter of the UltimateSmoother is the critical period, which represents the minimum wavelength (highest frequency) in the filter's pass band. In other words, the filter attenuates or removes the amplitudes of oscillations at shorter periods than the critical period.

According to Ehlers, one primary advantage of the UltimateSmoother is that it maintains zero lag in its pass band and minimal lag in its transition band, distinguishing it from other conventional digital filters (e.g., moving averages). One can apply this smoother to various input data series, including other indicators.

█ CALCULATIONS

Ehlers derived the UltimateSmoother using inspiration from the design principles he learned from his experience with analog filters, as described in the original publication. On a technical level, the UltimateSmoother's unique response involves subtracting a high-pass response from an all-pass response. At very low frequencies (lengthy periods), where the high-pass filter response has virtually no amplitude, the subtraction yields a frequency and phase response practically equivalent to the input data. At other frequencies, the subtraction achieves filtration through cancellation due to the close similarities in response between the high-pass filter and the input data.

 [The Ultimate Smoother.lua](files/155238/The%20Ultimate%20Smoother.lua)

MT4 version.
[https://fxcodebase.com/code/viewtopic.p ... 13#p155913](https://fxcodebase.com/code/viewtopic.php?f=38&t=75007&p=155913#p155913)


---

## Re: The Ultimate Smoother

**Apprentice** · Sat May 04, 2024 4:02 am

![EURUSD m1 (05-04-2024 1102).png](images/155239/EURUSD%20m1%20%2805-04-2024%201102%29.png)



█ OVERVIEW

This script, inspired by the "Ultimate Channels and Ultimate Bands" article from the May 2024 edition of TASC's Traders' Tips, showcases the application of the UltimateSmoother by John Ehlers as a lag-reduced alternative to moving averages in indicators based on Keltner channels and Bollinger Bands®.

█ CONCEPTS

The UltimateSmoother, developed by John Ehlers, is a digital smoothing filter that provides minimal lag compared to many conventional smoothing filters, e.g., moving averages. Since this filter can provide a viable replacement for moving averages with reduced lag, it can potentially find broader applications in various technical indicators that utilize such averages.

This script explores its use as the smoothing filter in Keltner channels and Bollinger Bands® calculations, which traditionally rely on moving averages. By substituting averages with the UltimateSmoother function, the resulting channels or bands respond more quickly to fluctuations with substantially reduced lag.

Users can customize the script by selecting between the Ultimate channel or Ultimate bands and adjusting their parameters, including lookback lengths and band/channel width multipliers, to fine-tune the results.

 [Ultimate Channels and Ultimate Bands.lua](files/155239/Ultimate%20Channels%20and%20Ultimate%20Bands.lua)


---

## Re: The Ultimate Smoother

**nathanvbasko** · Tue May 21, 2024 3:20 pm

I hope there will be an MQL4 version... If none... I kindly request—many thanks.


---

## Re: The Ultimate Smoother

**Apprentice** · Wed May 22, 2024 1:44 pm

We have added your request to the development list.
Development reference 412


---

## Re: The Ultimate Smoother

**nathanvbasko** · Mon Jun 10, 2024 2:57 pm

> **Apprentice wrote:**
> We have added your request to the development list.
> Development reference 412

Thanks Apprentice!


---

## Re: The Ultimate Smoother

**Apprentice** · Tue Jun 25, 2024 12:37 pm

MT4 version.
[https://fxcodebase.com/code/viewtopic.p ... 13#p155913](https://fxcodebase.com/code/viewtopic.php?f=38&t=75007&p=155913#p155913)


---

## Re: The Ultimate Smoother

**Danery69** · Mon Jul 01, 2024 4:28 am

> **Apprentice wrote:**
> MT4 version.
> [https://fxcodebase.com/code/viewtopic.p ... 13#p155913](https://fxcodebase.com/code/viewtopic.php?f=38&t=75007&p=155913#p155913)

Ultimate-Channels-and-Ultimate-Bands, does not work with Trade station erreur 80.


---

## Re: The Ultimate Smoother

**Apprentice** · Mon Aug 05, 2024 2:46 am

![AUDUSD D1 (08-05-2024 0945).png](images/156323/AUDUSD%20D1%20%2808-05-2024%200945%29.png)



Make sure to install The Ultimate Smoother.lua


---

## Re: The Ultimate Smoother

**Ariel19** · Mon Dec 16, 2024 10:08 pm

> **Apprentice wrote:**
> MT4 version.
> [https://fxcodebase.com/code/viewtopic.p ... 3#p155913/](https://fxcodebase.com/code/viewtopic.php?f=38&t=75007&p=155913#p155913/)[Retro Bowl](https://retrobowl25.com)

Thank you very much!
