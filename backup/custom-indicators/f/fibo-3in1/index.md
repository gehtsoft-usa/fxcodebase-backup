# Fibo_3in1

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69127  
> Forum: 17 · Topic 69127 · 15 post(s)


---

## Fibo_3in1

**Apprentice** · Thu Nov 14, 2019 11:17 am

![EURUSD H1 (11-14-2019 1524).png](images/129766/EURUSD%20H1%20%2811-14-2019%201524%29.png)



Based on request.
[viewtopic.php?f=17&t=69108](https://fxcodebase.com/code/viewtopic.php?f=17&t=69108)

 [Fibo_3in1.lua](files/129766/Fibo_3in1.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=69142](https://fxcodebase.com/code/viewtopic.php?f=38&t=69142)


---

## Re: Fibo_3in1

**filoo7** · Fri Nov 15, 2019 7:21 am

it's interesting, good work;)
but I would like to add two things:
-the values 1.272 / 1.618 / -0.272 / -0.382 / -0.618
-to be able to change the style of line of each period in order to differentiate them more easily.

this version is interesting for the days, weeks and months in progress, moreover does the indicator this updates automatically? it's primordial

I would also like a second version for the previous period. that is to say today 15/11/2019, I would like the fibo October, the fibo previous week of 04/11 to the 08/11 and the fibo of yesterday of 14/11

thank you for your work


---

## Re: Fibo_3in1

**Richstocks99** · Fri Nov 15, 2019 4:54 pm

Can you make this into a MT4 file? Thank You.


---

## Re: Fibo_3in1

**Apprentice** · Sat Nov 16, 2019 7:16 am

Your request is added to the development list.
Development reference 321.


---

## Re: Fibo_3in1

**Apprentice** · Tue Nov 19, 2019 6:16 am

MT4/MQ4 version
[viewtopic.php?f=38&t=69142](https://fxcodebase.com/code/viewtopic.php?f=38&t=69142)


---

## Re: Fibo_3in1

**filoo7** · Thu Nov 21, 2019 9:46 am

news for this addition?

I would also like a second version for the previous period. that is to say today 15/11/2019, I would like the fibo October, the fibo previous week of 04/11 to the 08/11 and the fibo of yesterday of 14/11

and I would like to add two things:
-the values 1.272 / 1.618 / -0.272 / -0.382 / -0.618
-to be able to change the style of line of each period in order to differentiate them more easily.


---

## Re: Fibo_3in1

**Apprentice** · Thu Nov 21, 2019 1:35 pm

Your request is added to the development list.
Development reference 337.


---

## Re: Fibo_3in1

**Apprentice** · Fri Nov 22, 2019 4:52 am

[Fibo_3in1.lua](files/129880/Fibo_3in1.lua)

Try this version.


---

## Re: Fibo_3in1

**filoo7** · Mon Nov 25, 2019 6:19 am

there are some problems ...
-in the indicator "the month shows" corresponds to the day and "the day shows" is the month
- the highest of the previous month corresponds to the highest of the current month
- the style of the lines must be added on the period and not on the lines (ex: month in dot, week in dashes and day in line), if not on a graph in one minutes, how to recognize the line?
- the previous level of price fibo (month, week, day) must be drawn until the current candle, see even next candles if possible, I propose to add a section "parametre" as in the fibo of the TS2 for "extend end" and "show price" and "level"
Thank you


---

## Re: Fibo_3in1

**Apprentice** · Mon Nov 25, 2019 6:53 am

Your request is added to the development list.
Development reference 354.


---

## Re: Fibo_3in1

**Apprentice** · Tue Nov 26, 2019 12:11 pm

[Fibo_3in1.lua](files/129944/Fibo_3in1.lua)

Try this version.


---

## Re: Fibo_3in1

**filoo7** · Fri Nov 29, 2019 7:16 am

ok it's better with different line style
Now we still have the problem of end of period
-the end of each period is not defined, when I shifts all the fibo of 1, the end of period is the highest / lowest current, while it must stop at 23:59:59 of each period


---

## Re: Fibo_3in1

**Apprentice** · Sat Nov 30, 2019 6:14 am

Your request is added to the development list.
Development reference 378.


---

## Re: Fibo_3in1

**Apprentice** · Mon Dec 02, 2019 4:47 am

I don't have any issues, It works like expected. But keep in mind that day ends at 17:00:00 EST, not at 00:00:00


---

## Re: Fibo_3in1

**filoo7** · Wed Dec 11, 2019 8:40 am

of course there is a problem, if I want to shift a period I want the highest / lowest of the fibo is on this same period and not on the period in progress.
Actually if i shifts from 1, i have the fibo over two period, i would like it to be only over the period shifted
