# High Low Range Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70233  
> Forum: 17 · Topic 70233 · 13 post(s)


---

## High Low Range Average

**Apprentice** · Mon Jul 27, 2020 5:07 pm

![EURUSD H1 (07-27-2020 2217).png](images/136345/EURUSD%20H1%20%2807-27-2020%202217%29.png)



Based on request.
[viewtopic.php?f=27&t=70226](https://fxcodebase.com/code/viewtopic.php?f=27&t=70226)

 [High Low Range Average.lua](files/136345/High%20Low%20Range%20Average.lua)

 [High Low Range Average Readout.lua](files/136345/High%20Low%20Range%20Average%20Readout.lua)


---

## Re: High Low Range Average

**MadMan** · Tue Jul 28, 2020 2:39 am

Thank you .. but it is not what I am looking for
Please let me know if the above request is not clear

Thanks in advance


---

## Re: High Low Range Average

**Apprentice** · Tue Jul 28, 2020 1:57 pm

We have two lines, averages of
1) high - open
2) open - low

Can you specify the equation?


---

## Re: High Low Range Average

**MadMan** · Wed Jul 29, 2020 2:36 am

Can you please check the attached sheet and let me know .. it's a sample

I need the two averages to be displayed on chart .. no lines or oscillator


---

## Re: High Low Range Average

**Apprentice** · Wed Jul 29, 2020 4:04 pm

As numbers only?


---

## Re: High Low Range Average

**MadMan** · Thu Jul 30, 2020 3:41 am

yes .. only the numbers (in pips)


---

## Re: High Low Range Average

**Apprentice** · Fri Jul 31, 2020 5:26 am

High Low Range Average Readout added.


---

## Re: High Low Range Average

**MadMan** · Sat Aug 01, 2020 3:45 am

Thank you Apprentice .. this is good .. nice and simple as desired

But can you please double check the calculation as I am getting different results on excel

let me break it down once more

The difference (in pips) between open price & highest price
The difference (in pips) between open price & lowest price
then calculate the average of the above two values for N number of periods EXCLUDING the current candle

Please let me know if more details needed.

Regards


---

## Re: High Low Range Average

**Apprentice** · Sun Aug 02, 2020 8:28 am

high[period]= source.high[period]-source.open[period];
	low[period]= source.open[period]-source.low[period];

 High[period]= mathex.avg(high,period-Period+1, period);
 Low[period]= mathex.avg(low,period-Period+1, period);


---

## Re: High Low Range Average

**MadMan** · Mon Aug 03, 2020 1:35 am

OK .. i will double check at my side

But is it possible to get the standard deviation as well .. same thing but instead of average .. calculate the standard deviation.

Thanks


---

## Re: High Low Range Average

**MadMan** · Tue Aug 11, 2020 5:06 am

Any update on my request ????


---

## Re: High Low Range Average

**steveped** · Sun Aug 23, 2020 7:05 pm

Hi guys,
Any chance to have the line with 2 colours for >0 and <0 when ‘Combine’ is set to ‘Yes’?


---

## Re: High Low Range Average

**Apprentice** · Mon Aug 24, 2020 3:35 am

[High Low Range Average.lua](files/137005/High%20Low%20Range%20Average.lua)

Try this version.
