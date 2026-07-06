# MTF Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62040  
> Forum: 17 · Topic 62040 · 21 post(s)


---

## MTF Moving Average

**Apprentice** · Wed Mar 25, 2015 9:37 am

![MTF Moving Average.png](images/99462/MTF%20Moving%20Average.png)



Based on the request.
[viewtopic.php?f=27&t=62021](https://fxcodebase.com/code/viewtopic.php?f=27&t=62021)
Will introduce a horizontal line for all selected time frames.
The line is identical to the value of the selected moving average for that time frame.

 [MTF Moving Average.lua](files/99462/MTF%20Moving%20Average.lua)


---

## Re: MTF Moving Average

**Apprentice** · Wed Aug 09, 2017 3:19 am

The indicator was revised and updated.


---

## Re: MTF Moving Average

**stfx_81** · Thu Aug 10, 2017 7:25 am

Lovely indicator - Couple of questions

Can the moving avg value be available on the line the same as the time frame shows?

also is there any way to make TS2 load a certain amount of data like mt4 does?

I want to use a big moving avg on a small time frame chart, but without scrolling the chart back it doesn't show the avg.

Thanks


---

## Re: MTF Moving Average

**Apprentice** · Sun Aug 13, 2017 2:42 am

value option added.
By default 300 price points are pre-loaded.


---

## Re: MTF Moving Average

**Apprentice** · Mon Oct 29, 2018 6:58 am

The indicator was revised and updated.


---

## Re: MTF Moving Average

**bruno2017** · Wed Oct 16, 2019 12:23 pm

Hello
would it be possible not to extend the line until the end.
would it be possible to fill a space between two lines with a color?
thank you


---

## Re: MTF Moving Average

**Apprentice** · Thu Oct 17, 2019 3:17 pm

Your request is added to the development list.
Development reference 207.


---

## Re: MTF Moving Average

**bruno2017** · Fri Oct 18, 2019 5:46 am

Hello
Can you change color for the space between the two lines.
red down / green high.
thank you


---

## Re: MTF Moving Average

**Apprentice** · Fri Oct 18, 2019 11:35 am

![EURUSD m5 (10-18-2019 1644).png](images/129304/EURUSD%20m5%20%2810-18-2019%201644%29.png)



Try this version.

 [MA_Channel.lua](files/129304/MA_Channel.lua)


---

## Re: MTF Moving Average

**bruno2017** · Fri Oct 18, 2019 2:11 pm

Hello
here is what I would like.

filling between the two lines and the non-extended line until the end


---

## Re: MTF Moving Average

**bruno2017** · Fri Nov 01, 2019 4:36 am

Hello sir
Have you understood what I would like?
the filling of the two lines horizantale.
bullish green
bearish red


---

## Re: MTF Moving Average

**Apprentice** · Wed Nov 06, 2019 9:15 am

There are 13 lines. Which of them should contain that channel?


---

## Re: MTF Moving Average

**bruno2017** · Thu Nov 07, 2019 8:15 am

hello ,
Here are the ones I teach:
time frame 1h =>MA period 20
time frame 1h =>MA period 50
thank you


---

## Re: MTF Moving Average

**Apprentice** · Fri Nov 08, 2019 4:53 am

Try this version.

 [MTF_Moving_Average_bruno2017.lua](files/129651/MTF_Moving_Average_bruno2017.lua)


---

## Re: MTF Moving Average

**bruno2017** · Fri Nov 08, 2019 5:32 am

great, thank you
is it possible to fill in red when MA 20 is lower than MA 50 and fill in green when MA 20 is greater than MA 50


---

## Re: MTF Moving Average

**Apprentice** · Mon Nov 11, 2019 6:09 am

Your request is added to the development list.
Development reference 299.


---

## Re: MTF Moving Average

**Apprentice** · Tue Nov 12, 2019 5:50 am

[MTF_Moving_Average_bruno2017.lua](files/129700/MTF_Moving_Average_bruno2017.lua)

Try this version.


---

## Re: MTF Moving Average

**bruno2017** · Wed Nov 13, 2019 5:53 am

Hello
Thank you very much
Regarding my method here:
MA 20 MA 50 time frame 1h trading in 15mn.
pulback in the area MA 20 MA 50 purchase or sell at the resumption of tendency.


---

## Re: MTF Moving Average

**tyros refa** · Fri Mar 05, 2021 10:13 am

Hi Apprentice

Great indicator! Is it possible to allow a spécific color to these horizontal lines when the slope of the moving average is down or up ? (example: red horizontal line for a down slope, and green for up)

Thx


---

## Re: MTF Moving Average

**Apprentice** · Fri Mar 05, 2021 12:04 pm

Your request is added to the development list.
Development reference 254.


---

## Re: MTF Moving Average

**Apprentice** · Mon Mar 08, 2021 8:55 am

[MTF_Moving_Average with Colors.lua](files/141100/MTF_Moving_Average%20with%20Colors.lua)

Try this version.
