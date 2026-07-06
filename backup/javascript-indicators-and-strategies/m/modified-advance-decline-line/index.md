# Modified Advance Decline Line

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=67098  
> Forum: 48 · Topic 67098 · 1 post(s)


---

## Modified Advance Decline Line

**Alexander.Gettinger** · Fri Dec 07, 2018 2:48 pm

Formula:
MAD[i] = MAD[i-1]+(2*Close-High-Low)/(High-Low)*(Volume+MA), where
MA - MVA(Volume) with [Length] number of periods.

 

![Modified AdvanceDecline Line.PNG](images/122609/Modified%20AdvanceDecline%20Line.PNG)



Download:

 [Modified AdvanceDecline Line_JS.jsl](files/122609/Modified%20AdvanceDecline%20Line_JS.jsl)
