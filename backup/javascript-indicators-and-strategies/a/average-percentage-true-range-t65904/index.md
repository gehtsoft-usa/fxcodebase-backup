# Average Percentage True Range

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=65904  
> Forum: 48 · Topic 65904 · 1 post(s)


---

## Average Percentage True Range

**Alexander.Gettinger** · Wed Apr 11, 2018 1:57 pm

Formula:
APTR = MVA(PTR) with [Period] number of periods,
PTR - maximum value for S1, S2, S3, where
S1 = 2*(High[i]-Low[i])/(High[i]+Low[i]),
S2 = 2*(High[i]-Close[i-1])/(High[i]+Close[i-1]),
S3 = 2*(Low[i]-Close[i-1])/(3*Low[i]-Close[i-1]).

 

![APTR_MA.PNG](images/118567/APTR_MA.PNG)



Download:

 [APTR_MA_JS.jsl](files/118567/APTR_MA_JS.jsl)
