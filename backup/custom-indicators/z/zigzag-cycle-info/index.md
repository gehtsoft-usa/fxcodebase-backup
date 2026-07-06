# ZigZag Cycle Info

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66279  
> Forum: 17 · Topic 66279 · 24 post(s)


---

## ZigZag Cycle Info

**Apprentice** · Wed Jul 18, 2018 9:51 am

![EURUSD m1 (07-18-2018 1451).png](images/119989/EURUSD%20m1%20%2807-18-2018%201451%29.png)



Based on request.
[viewtopic.php?f=27&t=66277](https://fxcodebase.com/code/viewtopic.php?f=27&t=66277)

 [ZigZag Cycle Info.lua](files/119989/ZigZag%20Cycle%20Info.lua)

MT4 version.
[viewtopic.php?f=38&t=70604](https://fxcodebase.com/code/viewtopic.php?f=38&t=70604)


---

## Re: ZigZag Cycle Info

**7510109079** · Wed Jul 18, 2018 11:01 am

this is magnificent. Thank you very much !


---

## Re: ZigZag Cycle Info

**7510109079** · Wed Jul 18, 2018 11:10 am

I wonder, is there any way an alert can be incorporated to notify the user that a new swing has just started in the opposite direction?
This would effectively ONLY alert when there is a new colour change
thx in advance


---

## Re: ZigZag Cycle Info

**Apprentice** · Thu Jul 19, 2018 11:24 am

Your request is added to the development list under Id Number 4189


---

## Re: ZigZag Cycle Info

**7510109079** · Thu Jul 19, 2018 1:43 pm

ok thank you.

if anyone else would also like this functionality please show your interest by posting below


---

## Re: ZigZag Cycle Info

**Stoneguard** · Mon Jul 23, 2018 6:59 am

Hi

Nice indicator! Could you add a row, displaying the pip value of the actual cycle?

Thanks
Stoneguard


---

## Re: ZigZag Cycle Info

**Apprentice** · Tue Jul 24, 2018 7:46 am

Task 4189

 [ZigZag Cycle Info.lua](files/120055/ZigZag%20Cycle%20Info.lua)


---

## Re: ZigZag Cycle Info

**Apprentice** · Tue Jul 24, 2018 7:47 am

> Could you add a row, displaying the pip value of the actual cycle?

Last cycle only?


---

## Re: ZigZag Cycle Info

**7510109079** · Wed Jul 25, 2018 11:39 am

Hi Apprentice
can you examine the code and try to answer this question:

Once the **first** line segment of a **new** zigzag cycle is drawn, can it ever disappear if price action goes against it.
Or once a new zigzag segment is drawn it never disappears

thx


---

## Re: ZigZag Cycle Info

**7510109079** · Thu Jul 26, 2018 6:26 am

> **Stoneguard wrote:**
> Hi
>
> Nice indicator! Could you add a row, displaying the pip value of the actual cycle?
>
> Thanks
> Stoneguard

you can use this indi which shows peak pip values including that of the latest leg


---

## Re: ZigZag Cycle Info

**Apprentice** · Thu Jul 26, 2018 8:13 am

From my observations,
Lask segment will not change direction, direction extension is possible.


---

## Re: ZigZag Cycle Info

**7510109079** · Thu Jul 26, 2018 9:17 am

ok thx for that clarification.

I asked because i saw an MT4 zigzag indi do such a thing.

If your Indi was to do this it would render my strategy useless because it has to have a 'no-repaint' behaviour

Any chance you can find time to code in the 'alert on first segment' notification (Id Number 4189)?

thx


---

## Re: ZigZag Cycle Info

**TazmasterT** · Mon Mar 04, 2019 11:53 am

Hi,

I love this indicator so thank you for that.

Would you be able to add, in the information section, the average bars and a filter so instead of all cycles you could set it to a user defined number of cylces like 6 cycles and last 6 up and or down cycles as well.

If this is possible it would be awesome.

Many thanks
TMT


---

## Re: ZigZag Cycle Info

**7510109079** · Mon Mar 04, 2019 12:02 pm

Hi Apprentice
many thx for the addition of the alert into the **ZigZag Cycle Info** indicator.

Currently, if we want to display cycle info AND pip swing sizes, we have to use both the **Zigzag Cycle Info** indi and the **Zigzag-Integer** indi.

To save our system resources, can you add the Zigzag-Integer pips label functionality into the Zigzag Cycle Info indicator?

MAny thx in advance

P.S. heads up - in the Zigzag Cycle Info indicator, making 'Show Alert=No' does not turn off the sound/recurrent/email alerts. Making 'Play Sound=No' turns off the sound AND recurrent AND email alerts


---

## Re: ZigZag Cycle Info

**Apprentice** · Tue Mar 05, 2019 6:37 am

Your requests are added to the development list under Id Number 4516


---

## Re: ZigZag Cycle Info

**7510109079** · Wed Mar 06, 2019 8:35 am

ok thank you


---

## Re: ZigZag Cycle Info

**Apprentice** · Fri Mar 08, 2019 6:50 am

Try this version.

 [ZigZag Cycle Info v2.lua](files/124307/ZigZag%20Cycle%20Info%20v2.lua)


---

## Re: ZigZag Cycle Info

**7510109079** · Fri Mar 08, 2019 12:10 pm

many thanks for this but I cant get it to display anything except the legend text. No Cycle text or Swing lines/numbers


---

## Re: ZigZag Cycle Info

**TazmasterT** · Sun Mar 10, 2019 1:06 pm

Thank you for adding in the bars, however, there is a slight maths problem I think. It's showing average bars as 70 over the past 6 cycles whereas that should be closer to 20 per zigzag.

Could you also please add average number of bars both up and down.

You are doing such a great job.

Cheers
TMT


---

## Re: ZigZag Cycle Info

**Apprentice** · Tue Mar 12, 2019 11:44 am

Your requests are added to the development list under Id Number 4534


---

## Re: ZigZag Cycle Info

**Apprentice** · Thu Mar 14, 2019 6:52 am

It looks like you use some modified version of the indicator. I can't repeat the issue and the layout is slightly different (you version draws more data).


---

## Re: ZigZag Cycle Info

**cornel.miu24** · Sat Nov 07, 2020 4:02 am

Hello everyone!

This is a good tool. I appreciate the work done on this forum.
It is possible to convert it to mq4?
Thanks a lot!

Have a nice weekend!
Cornel


---

## Re: ZigZag Cycle Info

**Apprentice** · Sat Nov 07, 2020 6:26 am

Your request is added to the development list.
Development reference 2263.


---

## Re: ZigZag Cycle Info

**Apprentice** · Sun Nov 08, 2020 11:10 am

MT4 version.
[viewtopic.php?f=38&t=70604](https://fxcodebase.com/code/viewtopic.php?f=38&t=70604)
