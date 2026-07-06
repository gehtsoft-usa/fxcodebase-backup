# Proportional Direction

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62630  
> Forum: 17 · Topic 62630 · 17 post(s)


---

## Proportional Direction

**Apprentice** · Fri Sep 04, 2015 7:34 am

![Proportional Direction.png](images/102171/Proportional%20Direction.png)



Based on the request.
[viewtopic.php?f=27&t=62627](https://fxcodebase.com/code/viewtopic.php?f=27&t=62627)

"Direct"
UP
close > open
Indicator> PreviousIndicator

DOWN
close<open
Indicator< PreviousIndicator

"ReverseIndicator"

UP
close < open
Indicator> PreviousIndicator

DOWN
close>open
Indicator< PreviousIndicator

"ReversePrice"

UP
close > open
Indicator< PreviousIndicator

DOWN
close<open
Indicator> PreviousIndicator

 [Proportional Direction.lua](files/102171/Proportional%20Direction.lua)


---

## Re: Proportional Direction

**Trader** · Mon Sep 07, 2015 12:25 am

Hello Apprentice
1) thank you for the fast reply but this is not as per the request
2) what am looking for;
3.a.i) should interact with indicators Already being used in that time frame
3.a.ii) for example if have added ROC/17//Signal//MACD/12/36/9/Low then in the droplist of the dialog box this should give the choice of all the lines of all the indicators added in the time frame ranging from the values of MACD to ROC
3.b) this indicator has to be continuous and not candle oriented
3.c) there should be only one/single arrow; preferably at the bottom right corner of the chart changing its color and direction in realtime with its proportional relation with price as per the details explained in [http://fxcodebase.com/code/viewtopic.php?f=27&t=62627](https://fxcodebase.com/code/viewtopic.php?f=27&t=62627)
4) looking forward to your comments to make progress on this matter
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Mon Sep 07, 2015 5:44 am

Hello Apprentice
1) further to the message above; instead of droplist this should allow any line to be selected from the 'Data Source' tab
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Tue Sep 08, 2015 1:20 pm

Hello Apprentice
1) would ask you to please look into this matter
2) the required is a very simple indicator;
3.a) with one/single arrow on the bottom right corner of the chart or preferably anywhere in the chart with mouse scroll
3.b) with adjustable size and color
3.c) showing the direct/indirect price relationship [selectable from dialog box] of any line selected from the 'Data Source' tab
3.d) in realtime and not on candle shift; for example like the slope line that changes its direction and color in realtime and not on candle shift
4) looking forward to your progress on this matter
Best regards
Trader


---

## Re: Proportional Direction

**Apprentice** · Thu Sep 10, 2015 3:07 am

Your request is added to the development list.


---

## Re: Proportional Direction

**Trader** · Thu Sep 10, 2015 6:18 am

Hello Apprentice
thank you and looking forward
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Fri Sep 11, 2015 12:26 pm

Hello Apprentice
1) just to ensure that we are on the same page of the book
2) the four possible combinations of the simultaneous movement of the value of [a] selected line from 'Data Source' and [b] price and the resultant behavior of the Arrow is explained in the following lines
3) for ease of concept say the;
	value of selected line = A
	price = B
	arrow = C
4) then in the simultaneous movement of A and B / if;
	A = Up + B = Up Then C = Green/Up
	A = Up + B = Down Then C = Red/Down
	A = Down + B = Up Then C = Red/Down
	A = Down + B = Down Then C = Green/Up
5) the above should be the behavior of the arrow in case 'Direct' is selected in the dialog box
6) incase 'Indirect' is selected in the dialog box the behavior of arrow should be opposite to the sequence explained above
7) other details in the dialog box would be related to the selection of [a] size [b] color [c] placement of the arrow
8) please leave a small note to indicate that you have read this post
9) looking forward to your progress on this matter
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Wed Sep 16, 2015 6:39 am

Hello Apprentice
1) just to say hello and request you to please take some time out to look into the above
2) i thank you in advance and;
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Mon Sep 28, 2015 12:12 am

Hello Apprentice
Please advise
Thank you and best regards
Trader


---

## Re: Proportional Direction

**Apprentice** · Mon Sep 28, 2015 2:33 am

Alex is committed to this task.


---

## Re: Proportional Direction

**Trader** · Tue Sep 29, 2015 7:27 am

Hello Apprentice
Thank you and looking forward
Best regards
Trader


---

## Re: Proportional Direction

**Trader** · Tue Sep 29, 2015 1:25 pm

Hello Apprentice
1) thank you and looking forward
2) i highly respect your skill as somebody said that in future there would only be two types of people; those who can code and those who cannot code
3) at the same time i understand that you are very busy so have a much simpler request as compared to the earlier one
4) simply/ if the values of two lines selected from the ‘Data Source’ tab become equal or within 3% close there should be a visual/audible alert and e-mail
5) the simple dialog box should just ask for the lines to be selected from the 'Data Source' tab and the usual interface details for the alerts and e-mail
6) this should create the alert in Realtime and Not at candle shift
7) i understand that there is already a request in pipeline and it does not feel appropriate to make the next request but only if you can oblige i would be very thankful
Thank you and best regards
Trader


---

## Re: Proportional Direction

**Trader** · Fri Oct 30, 2015 8:35 am

Hello Alex
Please advise
Thank you and best regards
Trader


---

## Re: Proportional Direction

**Trader** · Sat Jan 09, 2016 12:40 am

Hello Alex // Hello Apprentice
Please advise the 'Proportional Direction Arrow'
Thank you and best regards
Trader


---

## Re: Proportional Direction

**Apprentice** · Sun Jan 10, 2016 5:35 am

"Direct"
UP
close > open
Indicator> PreviousIndicator

DOWN
close<open
Indicator< PreviousIndicator

"ReverseIndicator"

UP
close < open
Indicator> PreviousIndicator

DOWN
close>open
Indicator< PreviousIndicator

"ReversePrice"

UP
close > open
Indicator< PreviousIndicator

DOWN
close<open
Indicator> PreviousIndicator


---

## Re: Proportional Direction

**Apprentice** · Tue Feb 09, 2016 4:51 am

Indicator based strategy can be found here.
[viewtopic.php?f=31&t=63134](https://fxcodebase.com/code/viewtopic.php?f=31&t=63134)


---

## Re: Proportional Direction

**Apprentice** · Wed Sep 12, 2018 5:51 am

The indicator was revised and updated.
