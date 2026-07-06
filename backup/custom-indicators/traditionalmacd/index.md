# TraditionalMACD

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70389  
> Forum: 17 · Topic 70389 · 13 post(s)


---

## TraditionalMACD

**Apprentice** · Mon Sep 07, 2020 3:09 am

![AUDJPY D1 (09-07-2020 1008).png](images/137374/AUDJPY%20D1%20%2809-07-2020%201008%29.png)



Based on request.
[viewtopic.php?f=27&t=70378](https://fxcodebase.com/code/viewtopic.php?f=27&t=70378)

 [TraditionalMACD.lua](files/137374/TraditionalMACD.lua)


---

## Re: TraditionalMACD

**jorgelg93** · Mon Sep 07, 2020 4:36 pm

Hello, thanks for the help, but the MACD doesn't show the signal Line, and it doesn't react to changes in the settings of the Signal EMA period MACD; also the "display MACD histogram" and "display MACD and signal lines settings don't do anything


---

## Re: TraditionalMACD

**Apprentice** · Tue Sep 08, 2020 2:43 am

Fixed.


---

## Re: TraditionalMACD

**jorgelg93** · Tue Sep 08, 2020 9:00 am

Sir, something is still wrong with the MACD settings, changing the Signal EMA period doesn't do anything, also the histogram indicator looks quite different to another MACD histograms


---

## Re: TraditionalMACD

**Apprentice** · Wed Sep 09, 2020 2:02 am

Signal line fixed.


---

## Re: TraditionalMACD

**jorgelg93** · Wed Sep 09, 2020 9:02 am

Sir, thanks for your help but I noticed something else, the histogram looks a little behind, exactly one bar behind compared to the original in MT4 and to other macds! please take a look and compare


---

## Re: TraditionalMACD

**Apprentice** · Thu Sep 10, 2020 1:26 am

The histogram looks ok to me.


---

## Re: TraditionalMACD

**jorgelg93** · Thu Sep 10, 2020 7:48 am

Please check the attached images, my bad, I should have sent them before. Both MACD indicators, same instruments, same settings 12 26 9 ; but still they look very different. The last file attached is the MACD indicator that I'm using as comparison


---

## Re: TraditionalMACD

**jorgelg93** · Thu Sep 10, 2020 6:02 pm

The attached images show 2 examples, the difference between the original MACD traditional in Tradingstation and MT4; there is a desphase/gap between both. Instrument: SPX500, 1h timeframe, macd settings 12 26 9


---

## Re: TraditionalMACD

**Apprentice** · Fri Sep 11, 2020 2:44 am

[TraditionalMACD.lua](files/137538/TraditionalMACD.lua)

Try this version.
"Close" price is used.
Are you using the same price sever?


---

## Re: TraditionalMACD

**jorgelg93** · Fri Sep 11, 2020 3:53 am

I'm not sure; but now it has improve a lot!

Thanks for all your help; the indicator is almost perfect! there is something wrong with the "cancelled divergences" but it does not have major importance; one thing I would like to add: the "Look back this many bars for divergences", but that does not so important either. Thanks for all your work for the community


---

## Re: TraditionalMACD

**Apprentice** · Sat Sep 12, 2020 8:41 am

Your request is added to the development list.
Development reference 2019.


---

## Re: TraditionalMACD

**Apprentice** · Mon Sep 14, 2020 7:16 am

[TraditionalMACD.lua](files/137588/TraditionalMACD.lua)

Try this version.
