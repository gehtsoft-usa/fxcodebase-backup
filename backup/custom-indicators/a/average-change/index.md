# Average Change

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63400  
> Forum: 17 · Topic 63400 · 12 post(s)


---

## Average Change

**Apprentice** · Fri Apr 22, 2016 1:04 am

![EURUSD H2 (04-22-2016 0729).png](images/105907/EURUSD%20H2%20%2804-22-2016%200729%29.png)



Based on request.
[viewtopic.php?f=27&t=63399](https://fxcodebase.com/code/viewtopic.php?f=27&t=63399)
Will show difference between the current and previous close.
Moving average of raw data is available.

 [Average Change.lua](files/105907/Average%20Change.lua)

 

![EURUSD m1 (05-04-2016 0912).png](images/105907/EURUSD%20m1%20%2805-04-2016%200912%29.png)



 [Average Change with Normalization.lua](files/105907/Average%20Change%20with%20Normalization.lua)

The indicator was revised and updated


---

## Re: Average Change

**speakinmymind** · Tue May 03, 2016 4:03 am

Could you please allow the maximum periods to be at least 3000.

Also could you create a version of this with normalization?

Thank you!


---

## Re: Average Change

**Cactus** · Tue May 03, 2016 2:06 pm

How does this compare to [http://www.fxcodebase.com/code/viewtopi ... 48&start=0](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=23048&start=0)


---

## Re: Average Change

**speakinmymind** · Wed May 04, 2016 2:25 am

Could you please make the output more than two decimal places? Say at least five or six?

Thanks!


---

## Re: Average Change

**Apprentice** · Wed May 04, 2016 2:28 am

**Average Change**
Change= source[period]-source[period-1];
Average Change = Average of Change

**Disparity Index**
Disparity Index = (Close - MA of Close )/ MA of Close *100


---

## Re: Average Change

**Apprentice** · Wed May 04, 2016 2:46 am

Average Change with Normalization.lua Added.
Period limit increased.


---

## Re: Average Change

**speakinmymind** · Mon May 09, 2016 9:53 pm

Could you please make the output more than two decimal places? Say at least five or six?

Thanks!


---

## Re: Average Change

**Apprentice** · Tue May 10, 2016 3:17 am

Try it now.


---

## Re: Average Change

**speakinmymind** · Wed May 18, 2016 1:48 pm

Could you please add 3 more decimal places to the data?

Also could you please drop the leading zeroes?


---

## Re: Average Change

**Apprentice** · Thu May 19, 2016 3:46 am

Try it now.


---

## Re: Average Change

**mrlnb2016** · Wed Nov 16, 2016 4:29 am

Is it possible to add Precision to the parameters? Thanks a lot.


---

## Re: Average Change

**Apprentice** · Tue Apr 11, 2017 8:08 am

Indicator was revised and updated.
