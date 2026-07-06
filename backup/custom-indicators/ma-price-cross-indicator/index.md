# MA Price Cross indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2451  
> Forum: 17 · Topic 2451 · 24 post(s)


---

## MA Price Cross indicator

**Apprentice** · Tue Oct 19, 2010 3:08 am

![MA Price Cross.png](images/5328/MA%20Price%20Cross.png)



The indicator will generate a signal when the price touches the moving average.
The signal has two types of signals, Touch and Cross.
Allows selection of the moving average, the Data source, type of prices.

 [MA Price Cross.lua](files/5328/MA%20Price%20Cross.lua)

 [MA Price Cross with Alert.lua](files/5328/MA%20Price%20Cross%20with%20Alert.lua)

MQ4/MT4 version
[viewtopic.php?f=38&t=64128](https://fxcodebase.com/code/viewtopic.php?f=38&t=64128)


---

## Re: MA Price Cross indicator

**balmy66012** · Tue Oct 19, 2010 5:49 am

Thank you very much.


---

## Re: MA Price Cross indicator

**Apprentice** · Mon Jan 30, 2017 3:50 am

Indicator was revised and updated.


---

## Re: MA Price Cross indicator

**enotikos** · Sat Sep 11, 2021 9:30 am

Hi,
can you add Email Alert in real time (live)?
Thank you.


---

## Re: MA Price Cross indicator

**Apprentice** · Mon Sep 13, 2021 11:48 am

Your request is added to the development list.
Development reference 821.


---

## Re: MA Price Cross indicator

**Apprentice** · Tue Sep 14, 2021 11:54 am

MA Price Cross with Alert.lua added.


---

## Re: MA Price Cross indicator

**Sospool** · Wed Sep 29, 2021 12:59 pm

Hello, I have an error with this indicator.

C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/MA Price Cross with Alert.lua:604: Specified index is out of range.

 Thank you


---

## Re: MA Price Cross indicator

**Apprentice** · Thu Sep 30, 2021 4:54 am

Try it now.


---

## Re: MA Price Cross indicator

**Sospool** · Thu Oct 07, 2021 3:08 am

Sorry Mario, i tried the update but there is still this error that appears when launching the platform :

C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/MA Price Cross with Alert.lua:573: Specified index is out of range.

Thank you


---

## Re: MA Price Cross indicator

**Apprentice** · Thu Oct 07, 2021 11:06 am

Your request is added to the development list.
Development reference 893.


---

## Re: MA Price Cross indicator

**Apprentice** · Tue Oct 26, 2021 8:10 am

I failed to reproduce.
Have added additional checks.

Please use another browser, to prevent retrieving the file from the buffer.


---

## Re: MA Price Cross indicator

**mistertrade** · Mon Jan 31, 2022 8:56 pm

Hello,
I want to adapt the indicator 'MA_PRICE_CROSS.lua' by adding a new timeframe to filter the signals.
The principle would be as follows: In addition to the main timeframe (which already exists in the indicator), the user will enter a validation timeframe (this will be a parameter). This new timeframe will serve to filter the signals currently detected, by taking only those meeting the following condition:
1- For a bullish signal: The high of the current candle of the validation timeframe must be higher than the high of the previous candle
2- For a bearish signal: The low of the current candle of the validation timeframe must be lower than the low of the previous candle

Example: The main timeframe is 5 minutes (m5) and the validation timeframe (used to filter the signals) is 30 minutes (m30).
If I have a bullish signal on the 5', then I have to validate this signal by looking if the high of the 30' candle is higher than the high of the previous candle in 30'.

Can you help me please?
Thank you...


---

## Re: MA Price Cross indicator

**Apprentice** · Tue Feb 01, 2022 3:57 am

Your request is added to the development list.
Development reference 75.


---

## Re: MA Price Cross indicator

**bartwas1** · Thu Feb 03, 2022 4:18 am

Hi

I've been browsing the forum and noticed this indicator and the idea posted by mistertrade regarding MA price cross.
This gave me a concept for a simple system with two filtering options - two bands based on high/low prices. First band's setting would be 12, second one 50. I also would add fractals for support and resistance. Last thing it would be two HMAs set at 22 and 90 to illustrate trending biases.

Trading decisions would be based on alignment with slower band (50) and both HMAs being the same colour. Secondly a candle needs to close above (long trade) or below (short trade) faster band (12). Then we have our trading window.
Countertrading possibility - trading towards the slower band if both HMAs are aligned and obviously the rule with the candle remains the same. Quick peek into smaller time frame may reveal trend following opportunity.

Sideways market. It happens unfortunately. Therefore faster band needs to stay away from slower band and none of its MAs can be found inside of slower band. This is a filter for sideways market. When faster filter will remerge from the slower band trading can resume anew.

The system may look different depending on MAs being used - marketscope offers several options.

Good trading - Bart.


---

## Re: MA Price Cross indicator

**mistertrade** · Wed Feb 16, 2022 12:44 am

Hello Apprentice,
I know you are very busy. But could you tell me around what date you will be able to program the development whose reference number is 75.
Thank you


---

## Re: MA Price Cross indicator

**bartwas1** · Tue Feb 22, 2022 6:31 am

Hi

This post is sort of continuation of my idea presented on this forum in early February.

So, I've analyzed relation of both bands (12 and 50) and it seems that more dynamic approach could be better. First - slower high/low band will get a new setting between 30 and 35, but faster will remain the same.
Secondly, as stated before if the slower band stays below faster one (set at 12) you are looking for long position and if situation is reversed you do the opposite - go short.

When faster band will enter the territory of slower band the price intends to be going sideways or ready to break in opposite direction or continue with the same. And here is next change.
With more dynamic approach you won't need to wait for a fast band (12) leaving completely slower band. It's enough for long positions when higher moving average (12) will make it clear from slower band's area and for short position obviously opposite is true - a lower moving average (12) needs to get free.

Key support and resistant places are represented by fractals for current chart. They are important, because if the first entry fails a second one is possible when the price closes around the fractal (better above it). Then a new open price is a prompt to enter a new trade.

An expansion so to speak in this trading idea is a zigzag (12,5,3) and slower one (36,5,3). They illustrate faster and slower/long term trend. Colours refer also to price tendencies: red - downward direction, green - upwards one.

Slope change indicators could be added also if necessary - HMA, for example (settings for faster and slower: 22-20, 70-90)

To sum up: a key here is to have an alignment of indicators telling the same thing which is direction either up or down.

Visual presentation added also.

Good trading - B.


---

## Re: MA Price Cross indicator

**mistertrade** · Tue Feb 22, 2022 8:40 pm

Hello,
Can someone help me to adapt the indicator 'MA_PRICE_CROSS.lua' ?
Thank you

**********************************************************************************************************************
I want to adapt the indicator 'MA_PRICE_CROSS.lua' by adding a new timeframe to filter the signals.
The principle would be as follows: In addition to the main timeframe (which already exists in the indicator), the user will enter a validation timeframe (this will be a parameter). This new timeframe will serve to filter the signals currently detected, by taking only those meeting the following condition:
1- For a bullish signal: The high of the current candle of the validation timeframe must be higher than the high of the previous candle
2- For a bearish signal: The low of the current candle of the validation timeframe must be lower than the low of the previous candle

Example: The main timeframe is 5 minutes (m5) and the validation timeframe (used to filter the signals) is 30 minutes (m30).
If I have a bullish signal on the 5', then I have to validate this signal by looking if the high of the 30' candle is higher than the high of the previous candle in 30'.
*************************************************************************************************************************


---

## Re: MA Price Cross indicator

**Apprentice** · Wed Feb 23, 2022 3:46 am

Your request is added to the development list.
Development reference 119.


---

## Re: MA Price Cross indicator

**Apprentice** · Wed Feb 23, 2022 7:40 am

Task 75

 [MA_Price_Cross.lua](files/145142/MA_Price_Cross.lua)

Something like this?


---

## Re: MA Price Cross indicator

**mistertrade** · Wed Feb 23, 2022 9:20 pm

Hello,

Thank you for Task 75.
I will test it today and let you know if it is ok.

Have a good day...


---

## Re: MA Price Cross indicator

**mistertrade** · Sat Feb 26, 2022 9:03 am

That is exactly what I needed. It works perfectly.
Thank you very much...


---

## Re: MA Price Cross indicator

**mistertrade** · Sun Sep 04, 2022 2:53 am

Hello,

In the latest version of the 'MA_Price_Cross.lua' indicator (task 75), would it be possible to add a new filter to the signals?

This new filter will use the "ZEROLAGMACD" indicator on the 2 already existing time units (main time unit and validation time unit).

Signals additional filter condition:

1- To validate the 'UP' signals, it is necessary that 'The Macd is above its Signal Line' for the 2 time units (main and validation).

2- To validate the 'DOWN' signals, it is necessary that 'The Macd is under its Signal Line' for the 2 time units (main and validation).

Thank you for your help...


---

## Re: MA Price Cross indicator

**Apprentice** · Mon Sep 05, 2022 4:13 am

We have added your request to the development list.
Development reference 534.


---

## Re: MA Price Cross indicator

**Apprentice** · Thu Oct 27, 2022 4:32 am

![TSLA.us m30 (10-27-2022 1130).png](images/148059/TSLA.us%20m30%20%2810-27-2022%201130%29.png)



 [MA Price Cross wilth Filter.lua](files/148059/MA%20Price%20Cross%20wilth%20Filter.lua)
