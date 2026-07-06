# Bear and Bull volume indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72345  
> Forum: 17 · Topic 72345 · 7 post(s)


---

## Bear and Bull volume indicator

**Apprentice** · Mon Jun 06, 2022 10:34 am

![EURUSD H4 (06-06-2022 1746).png](images/146293/EURUSD%20H4%20%2806-06-2022%201746%29.png)



 [Bear and Bull volume indicator.lua](files/146293/Bear%20and%20Bull%20volume%20indicator.lua)


---

## Re: Bear and Bull volume indicator

**Mountaintrader** · Mon Jul 18, 2022 11:52 pm

Hi Apprentice,

Studying this indicator, I find the sum of the Bearish and Bullish volume values of most closed Bearish candles is generally of a negative value, and its closing price normally below its open price.

However the screenshot shows four closed BEARISH m5 candles labeled 1,2,3 &4 The sum of the numerical Bearish and Bullish volume value of these four candles is greater than +1

Example - Bearish Price Action Candle Labeled No1 at time stamp 09:10:
Bullish volume value is +958.8
Bearish volume value is -700.24
 Total +258.56 (Positive)

So candle No1 could be described as having Bearish Price Action with Positive Volume Action. The same goes for the candles labeled 2,3 & 4

Could the .Lua Bear and Bull Indicator be adapted to provide a chart indication (RGB horizontal line or Arrow) and sound files to play when the candle Price action closes:
 1) BEARISH but the sum of the Bear/Bull volume is GREATER than +1 ?
 2) BULLISH but the sum of the Bear/Bull volume is LESS than -1 ?

Thank you

Regards
MT


---

## Re: Bear and Bull volume indicator

**Apprentice** · Wed Jul 20, 2022 7:14 am

We have added your request to the development list.
Development reference 434.


---

## Re: Bear and Bull volume indicator

**Apprentice** · Tue Aug 15, 2023 11:59 am

![EURUSD H1 (08-15-2023 1858).png](images/152046/EURUSD%20H1%20%2808-15-2023%201858%29.png)



 [Bear_and_Bull_volume_indicator.lua](files/152046/Bear_and_Bull_volume_indicator.lua)


---

## Re: Bear and Bull volume indicator

**fxlion** · Thu Aug 24, 2023 12:48 am

hi apprendice,

can u create a MTF HISTOGRAM INDICATOR based on this indicator

TIME FRAMES: H1,H4,D1

IN H1 TIME FRAME
IF BULL VOLUME > BEAR VOLUME IN H1 TIME FRAME THEN HISTOGRAME CREDIT POINT IS +1
IF BEAR VOLUME > BULL VOLUME IN H1 TIME FRAME THEN HISTOGRAME CREDIT POINT IS -1
OTHER WISE CREDIT POINT IS 0
A= H1 CREDIT POINT

IN H4 TIME FRAME
IF BULL VOLUME > BEAR VOLUME IN H4 TIME FRAME THEN HISTOGRAME CREDIT POINT IS +1
IF BEAR VOLUME > BULL VOLUME IN H4 TIME FRAME THEN HISTOGRAME CREDIT POINT IS -1
OTHER WISE CREDIT POINT IS 0
B=H4 CREDIT POINT

IN D1 TIME FRAME
IF BULL VOLUME > BEAR VOLUME IN D1 TIME FRAME THEN HISTOGRAME CREDIT POINT IS +1
IF BEAR VOLUME > BULL VOLUME IN D1 TIME FRAME THEN HISTOGRAME CREDIT POINT IS -1
OTHER WISE CREDIT POINT IS 0
C=D1 CREDIT POINT

HISTOGRAME VALUE=A+B+C

THANK U


---

## Re: Bear and Bull volume indicator

**Apprentice** · Mon Aug 28, 2023 5:20 am

We have added your request to the development list.
Development reference 777.


---

## Re: Bear and Bull volume indicator

**Apprentice** · Tue Aug 29, 2023 4:56 am

![EURUSD H1 (08-29-2023 1155).png](images/152281/EURUSD%20H1%20%2808-29-2023%201155%29.png)



 [MTF Bear and Bull volume Histogram.lua](files/152281/MTF%20Bear%20and%20Bull%20volume%20Histogram.lua)
