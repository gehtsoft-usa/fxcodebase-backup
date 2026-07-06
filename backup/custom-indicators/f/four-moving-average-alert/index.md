# Four Moving Average Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63500  
> Forum: 17 · Topic 63500 · 14 post(s)


---

## Four Moving Average Alert

**Apprentice** · Thu May 19, 2016 5:19 am

![EURUSD m1 (05-19-2016 1145).png](images/106351/EURUSD%20m1%20%2805-19-2016%201145%29.png)



Based on the request.
[viewtopic.php?f=27&t=63498](https://fxcodebase.com/code/viewtopic.php?f=27&t=63498)

For Long
Price (Any) MA CrossOver
Price> MA1
Price> MA2
Price > MA3
Price > MA4
Vice versa for Short

 [Four Moving Average Alert.lua](files/106351/Four%20Moving%20Average%20Alert.lua)


---

## Re: Four Moving Average Alert

**lancer7d** · Thu May 19, 2016 6:53 am

Would it be possible to support higher MA's? I use up to a 3100 MA on a smaller time frame and after testing this MA alert, all the MA lines disappear if I use 2830 MA or higher. Thank you..


---

## Re: Four Moving Average Alert

**Apprentice** · Thu May 19, 2016 7:24 am

> higher MA's

You mean higher time frames?


---

## Re: Four Moving Average Alert

**lancer7d** · Thu May 19, 2016 7:41 am

I use a 5 minute chart, with a 60, 480, 1220, and 3100 moving average. The lines for the first three moving average populate onto the screen every time until I put in the 3100ma. I tested it, and any average above 2830 makes all four moving average lines disappear. I was hoping you would be able to make a change to where the alert could support a moving averages up to 3100? I hope this is clearer than mud..


---

## Re: Four Moving Average Alert

**Apprentice** · Thu May 19, 2016 8:09 am

As it is limit is 4000.


---

## Re: Four Moving Average Alert

**lancer7d** · Thu May 19, 2016 12:42 pm

Seems to be working now.. thank you Apprentice for the quick replies and solution!


---

## Re: Four Moving Average Alert

**Apprentice** · Fri Aug 31, 2018 5:13 am

The indicator was revised and updated.


---

## Re: Four Moving Average Alert

**Mountaintrader** · Mon Jul 04, 2022 11:53 am

Hi Apprentice,

I have the Four MA indicator applied to a 5m chart. The Play Sound parameter is selected to Yes, with two .wav files applied to the indicator, but the audio never plays when the MA is crossed in both the End of Turn & Live.

When play is selected in the "Chose Sound" box both files play audio correctly.

Was wandering if it has a bug ?

Thanks

MT


---

## Re: Four Moving Average Alert

**Apprentice** · Mon Jul 04, 2022 6:18 pm

I don't have any problems. Was Up Arrow Alert.
Have you tried any other audio alerts?


---

## Re: Four Moving Average Alert

**Mountaintrader** · Tue Jul 05, 2022 12:42 pm

Apprentice,

So I applied the new audio alerts and it works now !

Thank you.

MT


---

## Re: Four Moving Average Alert

**LCM2022** · Tue Dec 06, 2022 4:07 am

This is my favorite indicator, as I've been looking for this for some time. Thank you Apprentice. Do you code strategies? I unfortunately have no knowledge of how to do so.


---

## Re: Four Moving Average Alert

**Apprentice** · Thu Dec 08, 2022 9:33 am

Yes i wrote strategies for FXCM TS2.


---

## Re: Four Moving Average Alert

**LCM2022** · Tue Jan 10, 2023 7:28 am

Apprentice, thank you for this indicator, I added this to my strategy last year and have had great results.

Do you have a version with less MAs, for instance 1, 2 or 3 Mas? I have a strategy adjustment in mind that would do well with less.


---

## Re: Four Moving Average Alert

**Apprentice** · Wed Jan 11, 2023 11:04 am

What do you have in mind?
All alerts can be turned off.
