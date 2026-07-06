# Average Sentiment Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=65518  
> Forum: 48 · Topic 65518 · 1 post(s)


---

## Average Sentiment Oscillator

**Alexander.Gettinger** · Sat Jan 06, 2018 12:09 pm

Formulas:
Bulls = MA(Bu) with [Smoothing_Length] number of periods and [MA_Method] type,
Bears = MA(Be) with [Smoothing_Length] number of periods and [MA_Method] type, where
For Combined Mode:
Bu = (IBu+GBu)/2,
Be = (IBe+GBe)/2,
For Intra-bar Mode:
Bu = IBu,
Be = IBe,
For Group Algorithm Mode:
Bu = GBu,
Be = GBe.
For All Modes:
IBu = 50*(Close-Low+High-Open)/(High-Low),
IBe = 50*(High-Close+Open-Low)/(High-Low),
GBu = 50*(Close-GL+GH-GO)/(GH-GL),
GBe = 50*(GH-Close+GO-GL)/(GH-GL),
GO[i] = Open[i-Range_Length],
GL[i] - minimum value of High price at range from (i-Range_Length+1) to (i),
GH[i] - maximum value of Low price at range from (i-Range_Length+1) to (i).

 

![ASO_JS.PNG](images/116797/ASO_JS.PNG)



Download:

 [ASO_JS.jsl](files/116797/ASO_JS.jsl)
