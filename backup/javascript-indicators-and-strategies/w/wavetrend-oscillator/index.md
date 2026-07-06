# Wavetrend Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=66467  
> Forum: 48 · Topic 66467 · 1 post(s)


---

## Wavetrend Oscillator

**Alexander.Gettinger** · Tue Aug 07, 2018 12:14 pm

Formulas:
wt1 = EMA(Raw2) with [Average_Length] number of periods,
wt2 = MVA(wt1) with [Signal_Length] number of periods,
wt3 = wt1-wt2, where
Raw2 = (TP-EMA1)/(0.015*EMA2),
TP - typical price,
EMA1 = EMA(Typical price) with [Channel_Length] number of periods,
EMA2 = EMA(Raw1) with [Channel_Length] number of periods,
Raw1 = Abs(TP-EMA1),
Abs - absolute value.

 

![Wavetrend Oscillator.PNG](images/120424/Wavetrend%20Oscillator.PNG)



Download:

 [Wavetrend Oscillator_JS.jsl](files/120424/Wavetrend%20Oscillator_JS.jsl)
