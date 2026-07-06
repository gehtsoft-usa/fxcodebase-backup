# Average Number of Price Changes

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66614  
> Forum: 17 · Topic 66614 · 13 post(s)


---

## Average Number of Price Changes

**Apprentice** · Sat Sep 01, 2018 6:32 am

![USDOLLAR m1 (09-01-2018 1133).png](images/120893/USDOLLAR%20m1%20%2809-01-2018%201133%29.png)



Based on request
[viewtopic.php?f=27&t=66613&p=120892#p120892](https://fxcodebase.com/code/viewtopic.php?f=27&t=66613&p=120892#p120892)

 [Average Number of Price Changes.lua](files/120893/Average%20Number%20of%20Price%20Changes.lua)

 

![EURUSD H1 (09-03-2018 1134).png](images/120893/EURUSD%20H1%20%2809-03-2018%201134%29.png)



 [Average Number of Price Changes overview.lua](files/120893/Average%20Number%20of%20Price%20Changes%20overview.lua)


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Sat Sep 01, 2018 11:58 am

Check the blue square, why the indicator stay flat if the price do a big move down in a little espace of time.

Can you explain the logic you used ?

I think is a great indicator idea we can improve it and that can help us a lot


---

## Re: Average Number of Price Changes

**Apprentice** · Sat Sep 01, 2018 3:13 pm

![EURUSD m1 (09-01-2018 2013).png](images/120899/EURUSD%20m1%20%2809-01-2018%202013%29.png)



The tick volume was used for approximation.
Low tick volume will be reflected in the final result.


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Sun Sep 02, 2018 11:43 am

I think the correct way is this:

Check the attached photo, I get this data directly from the marketscoope, as you can see in the F and G column there is the prices changes in every second.

The idea can be: with this data check how many times the price change it in one minute then when you have 60 minutes make an average of how many changes in every minute.

In the red lined column you see how many changes do the price every minute in each hour at the end an average of changes every hour.

In the blue column you can see the actual period.

So with that data for example i can compare the actual period with an historical period.

The red lined column need to be an average of X last days (with an option to change it)

You can put the indicator like the AUD/JPY attached image.


---

## Re: Average Number of Price Changes

**Apprentice** · Sun Sep 02, 2018 3:34 pm

Do you want an indicator that will show you how many changes we have for each of the last 24 hours and the historic average?

I can only do this by using tick data.
Other methods are impractical
 unless you want to have a Trading Station always on.


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Sun Sep 02, 2018 3:50 pm

Yes how many changes in each hour


---

## Re: Average Number of Price Changes

**Apprentice** · Mon Sep 03, 2018 6:32 am

Average Number of Price Changes overview added.


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Mon Sep 03, 2018 12:27 pm

I think the current hour indicator is wrong, check the attached image the hour in my computer is correct but the hour in the indicator is wrong.

Can you reduce the space between the columns, make the text more smaller and put the indicator more small because it take too much space in the chart, can you reduce the size to the small blue box.


---

## Re: Average Number of Price Changes

**Apprentice** · Tue Sep 04, 2018 9:13 am

Average Number of Price Changes overview.lua style update.


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Wed Sep 05, 2018 9:37 am

The style is ok but the current hour is wrong now it's say 10:00 AM but the actual hour is 8:00 AM


---

## Re: Average Number of Price Changes

**Apprentice** · Fri Sep 07, 2018 3:58 am

EST is used.


---

## Re: Average Number of Price Changes

**Reymondpolanco** · Tue Sep 11, 2018 3:06 pm

Can you delete the numbers after the point


---

## Re: Average Number of Price Changes

**Apprentice** · Tue Sep 11, 2018 4:51 pm

Try it now.
