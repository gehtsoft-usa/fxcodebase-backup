# Heikin-Ashi Delta

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=22967  
> Forum: 17 · Topic 22967 · 22 post(s)


---

## Heikin-Ashi Delta

**Apprentice** · Mon Sep 03, 2012 2:45 pm

![HA Delta.png](images/39585/HA%20Delta.png)



Delta = HA.Close[period]- HA.Close[period-1]
Average = MVA of Delta

 [HA Delta.lua](files/39585/HA%20Delta.lua)

Dan Valcu Heikin-Ashi Delta = HA.Close[period]- HA.Open[period]

 [Dan Valcu HA Delta.lua](files/39585/Dan%20Valcu%20HA%20Delta.lua)

 

![Dan Valcu HA Delta Modification.png](images/39585/Dan%20Valcu%20HA%20Delta%20Modification.png)



 [Dan Valcu HA Delta Modification.lua](files/39585/Dan%20Valcu%20HA%20Delta%20Modification.lua)

The indicator was revised and updated


---

## Re: Heikin-Ashi Delta

**Tradingaquemarropa** · Tue May 14, 2013 2:42 am

This is the indicator that uses Dan Valu with Heikin Ashi candles?. (The crosses confirm market entrants?.

Thanks, greetings


---

## Re: Heikin-Ashi Delta

**Apprentice** · Wed May 15, 2013 3:08 am

Unfortunately I do not understand your post (first part).
Can you elaborate further.


---

## Re: Heikin-Ashi Delta

**Alexander.Gettinger** · Wed Aug 14, 2013 3:14 pm

MQL4 version of Heikin-Ashi Delta: [http://www.fxcodebase.com/code/viewtopi ... 38&t=59132](http://www.fxcodebase.com/code/viewtopic.php?f=38&t=59132).


---

## Re: Heikin-Ashi Delta

**Lestat39a** · Mon Jan 27, 2014 1:02 pm

Would it be possible to program another version of the Heikin-Ashi Delta indicator?

I would like to calculate Heikin-Ashi Delta as follows: HA Delta = HA Close - HA Open (as it was intended to be calculated by the author of the book "Heikin-Ashi How to trade without candlestick patterns", Dan Valcu).

This would be really great because it's a great way to enhance the Heikin-Ashi Technique. Many thanks in advance.


---

## Re: Heikin-Ashi Delta

**Apprentice** · Tue Jan 28, 2014 3:06 am

Please Try Updated Version Shift parameter is introduced.
Dan Valcu Heikin-Ashi Delta Added.


---

## Re: Heikin-Ashi Delta

**Lestat39a** · Tue Jan 28, 2014 4:28 am

Wow, that was quick! Great job - Thank you very much!


---

## Re: Heikin-Ashi Delta

**pipkilla** · Wed Nov 18, 2015 6:07 pm

Hi there
Can I get slow ha delta please? I modified ha delta script in trading view as follow:
study(title="haDelta by Dan Valcu", shorttitle="smooth haDelta+SMA")
delta = close - open
s2=sma(delta, 3)
s3=sma(sma(delta, 3),3)
plot(s2, color=black)
plot(s3, color = red)
plot(s3, color=red, style=area)
c_color=s3 < 0 ? (s3 < s3[1] ? red : lime) : (s3 >= 0 ? (s3 > s3[1] ? lime : red) : na)
plot(s3, color=c_color, style=circles, linewidth=2)
h0 = hline(0)

Also
can you add solid line at 0? shaded areas and there are green and red dots at each candle on trading view. that will be great addon for marketscope


---

## Re: Heikin-Ashi Delta

**Apprentice** · Tue Nov 24, 2015 6:10 am

Dan Valcu HA Delta Modification added.


---

## Re: Heikin-Ashi Delta

**pipkilla** · Tue Dec 08, 2015 2:57 am

Thanks again. The settings are fine. I was talking about dots and colour options as shown in the screenshot. is it possible to add? That will be wicked.


---

## Re: Heikin-Ashi Delta

**Apprentice** · Thu Dec 10, 2015 6:17 am

For Dan Valcu HA Delta Modification.lua?


---

## Re: Heikin-Ashi Delta

**pipkilla** · Sat Dec 12, 2015 11:12 am

Yes please


---

## Re: Heikin-Ashi Delta

**Apprentice** · Wed Dec 16, 2015 5:09 am

Try it now.


---

## Re: Heikin-Ashi Delta

**pipkilla** · Thu Dec 17, 2015 4:48 pm

Hi Apprentice
Dots look good now. Only thing i want to add is to fill the area between two averages. Just like the picture i posted from trading view. I have screen shot from marketscope as well. Currently it is blank. Can we get colour fill option.
Also, I was wondering why are dots shifted on marketscope (sometime green comes first here but on trading view it comes later). They should match no?
Thank you again


---

## Re: Heikin-Ashi Delta

**Apprentice** · Mon Dec 21, 2015 5:31 am

Your request is added to the development list.


---

## Re: Heikin-Ashi Delta

**pipkilla** · Tue Dec 22, 2015 12:31 am

thanks again


---

## Re: Heikin-Ashi Delta

**pipkilla** · Mon Feb 29, 2016 8:58 pm

Hi Apprentice
Any update on this?


---

## Re: Heikin-Ashi Delta

**Apprentice** · Sun Jul 30, 2017 11:19 am

The indicator was revised and updated.


---

## Re: Heikin-Ashi Delta

**logicgate** · Sun Apr 23, 2023 7:59 am

Hello Dear Friend Apprentice, can we get the Heikin Ashi Delta (Dan Valcu version) for MT5 please?

The only mode I ask is that you use the smoothed heikin ashi formula on it so we could choose the smoothing period in settings.

This way if you choose period of 1, indicator behaves as the original (1 = regular heikin ashi), and as you increased the period you increase smoothing. Attaching the smoothed heikin ashi formula for you here to have a look.

Thanks buddy


---

## Re: Heikin-Ashi Delta

**Apprentice** · Wed Apr 26, 2023 1:18 pm

We have added your request to the development list.
Development reference 362.


---

## Re: Heikin-Ashi Delta

**logicgate** · Sun Jul 30, 2023 4:49 am

Hello dear friend, it seems that this request got forgotten too...


---

## Re: Heikin-Ashi Delta

**logicgate** · Fri Nov 22, 2024 5:06 am

Dev request 362, nothing yet?
