# MTF MACD CCI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=8394  
> Forum: 31 · Topic 8394 · 23 post(s)


---

## MTF MACD CCI Strategy

**Apprentice** · Wed Nov 23, 2011 4:42 pm

![MTF MACD CCI Strategy.png](images/18564/MTF%20MACD%20CCI%20Strategy.png)



Buying conditions:

1.	cci [timeframe m5] > buy level {and}
2.	macd[time frame m5] > signal [time frame m5] {and}
3.	macd [time frame m5] < buy level {and}
4.	cci[timeframe H1] > buy level {and}
5.	macd[time frame H1] > signal [time frame H1] {and}
6.	cci[time frame H4] > buy level {and}
7.	macd[time frame H4] > signal [time frame H4] {and}
8.	cci[time frame D1] > buy level {and}
9.	macd[time frame D1] > signal [time frame D1]

Selling conditions:

1.	cci [timeframe m5] < sell level
2.	macd [time frame m5] < signal [time frame m5] {and}
3.	macd [time frame m5] > sell level {and}
4.	cci[timeframe H1] < sell level {and}
5.	macd[time frame H1] < signal [time frame H1] {and}
6.	cci[time frame H4] < sell level {and}
7.	macd[time frame H4] < signal [time frame H4] {and}
8.	cci[time frame D1] < sell level {and}
9.	macd[time frame D1] < signal [time frame D1]

exit buy:

1.	cci [timeframe m5] cross under buy level {or}
2.	macd [time frame m5] cross under signal [time frame m5] {or}
3.	cci[timeframe H1] cross under buy level {or}
4.	macd[time frame H1] cross under signal [time frame H1] {or}
5.	cci[time frame H4] cross under buy level {or}
6.	macd[time frame H4] cross under signal [time frame H4] {or}
7.	cci[time frame D1] cross under buy level {or}
8.	macd[time frame D1] cross under signal [time frame D1]

exit sell:

1.	cci [timeframe m5] cross over sell level {or}
2.	macd [time frame m5] cross over signal [time frame m5] {or}
3.	cci[timeframe H1] cross over sell level {or}
4.	macd[time frame H1] cross over signal [time frame H1] {or}
5.	cci[time frame H4] cross over sell level {or}
6.	macd[time frame H4] cross over signal [time frame H4] {or}
7.	cci[time frame D1] cross over sell level {or}
8.	macd[time frame D1] cross over signal [time frame D1]

 [MTF MACD CCI Strategy.lua](files/18564/MTF%20MACD%20CCI%20Strategy.lua)

I have add an option to choose, whether you want to use the Exit rules.
Also try playing with the Allow Multiple option.
The results are significantly different.

MT4/MQ4 version.
[viewtopic.php?f=38&t=70465](https://fxcodebase.com/code/viewtopic.php?f=38&t=70465)


---

## Re: MTF MACD CCI Strategy

**Stance** · Wed Oct 21, 2015 3:03 pm

Hi,

I'm trying to modify this strategy to add additional conditions such as current closing price (timeframe 4) is higher than previous closing price (timeframe 4).

What is the correct way to do this? I'm trying the following but it's not working.

Source[4].close[Source[4].close:size()-2] > Source[4].close[Source[4].close:size()-3]


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Thu Oct 22, 2015 4:49 am

Source[4].close[Source[4].close:size()-1] > Source[4].close[Source[4].close:size()-2]


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Wed Dec 14, 2016 4:02 am

Strategy was revised and updated.


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Thu Sep 17, 2020 11:21 am

Hello everybody, could you please convert this strategy for MT4?


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Fri Sep 18, 2020 3:01 am

Your request is added to the development list.
Development reference 2056.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Mon Sep 21, 2020 11:45 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=70465](https://fxcodebase.com/code/viewtopic.php?f=38&t=70465)


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Sun Sep 27, 2020 4:47 am

Thank you for your reply, I saw that the strategy converted in mq4 has only one time frame, could you convert the multi time frame version?


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Mon Sep 28, 2020 4:10 am

Your request is added to the development list.
Development reference 2118.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Thu Oct 01, 2020 3:22 am

[CCI_MACD_EA.mq4](files/138011/CCI_MACD_EA.mq4)

Try this version.


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Sun Oct 11, 2020 1:21 pm

Dear Apprentice,
thanks for your work, I saw that in your last conversion, there's the possibility to set only one setting for all the four time-frames. Could you please add the possibility to set different settings for different time-frames?


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Mon Oct 12, 2020 2:05 am

Your request is added to the development list.
Development reference 2170.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Tue Oct 13, 2020 6:29 am

[CCI_MACD_EA.mq4](files/138255/CCI_MACD_EA.mq4)

Try this version.


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Thu Oct 29, 2020 9:30 am

Thank you very much for your job, this is what I was looking for, expect for a parameter. Could you plese add the possibility of the 2hour among the time-frames?


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Sun Nov 15, 2020 2:03 pm

Dear Apprentice,
Could you please add the 2-hours time-frames?


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Tue Nov 17, 2020 6:56 am

Your request is added to the development list.
Development reference 2322.


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Mon Nov 30, 2020 10:26 am

Any news about the 2-hour time frame of MTF MACD for MT4?


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Mon Dec 28, 2020 2:05 pm

Dear Apprentice,
I tried the MTF_MACD strategy for MT4, but it does not work. Compared to the same strategy on TS, with the same setting,it works in a completely differt way. It opens very few positions and close them very quickly.
Could you please verify why it does not work properly?


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Mon Dec 28, 2020 3:13 pm

Your request is added to the development list.
Development reference 2540.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Wed Dec 30, 2020 5:12 am

Can you post, or provide link to the TS2 version, that you need in MT4?


---

## Re: MTF MACD CCI Strategy

**Claudio53** · Tue Jan 05, 2021 5:34 am

Dear Apprentice,
here there is the TS2 version of MTF MACD Strategy you asked me to compare it with the new MT4 version that doesn't work properly.
Let me know if there's anytihing else I can do.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Thu Jan 07, 2021 3:26 am

Your request is added to the development list.
Development reference 50.


---

## Re: MTF MACD CCI Strategy

**Apprentice** · Mon Jan 11, 2021 5:53 am

Try this version.
[viewtopic.php?f=38&t=70806](https://fxcodebase.com/code/viewtopic.php?f=38&t=70806)
