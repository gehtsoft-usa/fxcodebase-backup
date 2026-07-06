# RSI Ranking Dashboard

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70469  
> Forum: 17 · Topic 70469 · 20 post(s)


---

## RSI Ranking Dashboard

**Apprentice** · Mon Sep 21, 2020 1:15 pm

![TSLA.us D1 (09-21-2020 2014).png](images/137778/TSLA.us%20D1%20%2809-21-2020%202014%29.png)



Based on request.
[viewtopic.php?f=27&t=70461](https://fxcodebase.com/code/viewtopic.php?f=27&t=70461)

 [RSI Ranking Dashboard.lua](files/137778/RSI%20Ranking%20Dashboard.lua)


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Tue Sep 22, 2020 1:39 am

> **Apprentice wrote:**
>
>
> TSLA.us D1 (09-21-2020 2014).png
>
>
> Based on request.
> [viewtopic.php?f=27&t=70461](https://fxcodebase.com/code/viewtopic.php?f=27&t=70461)
>
>
> RSI Ranking Dashboard.lua

Firstly ,
Thanks Apprentice for your fast work .

Request for three updates as below :

1. **Instrument Selection in the strategy** -
Need only one boolean to Select All instruments , and not slot selection as its doing now .
Ex .Select All Instruments - Yes /no
Ranking should be then based on All instruments (Subsribed in Marketscope ).

2. **Multi-indicator option selection in the strategy .**
Can the strategy use multi-indicator like can be changed from RSI to Obos , or Macd like wise .
It should use the Absolute values of the indicator so even if any indicator is used which has any negative value , it wont affect the ranking calculation, so absolute value is required.

3.**Need a strategy for the indicator -ONLY SELL.**
a . The strategy should give a SELL terminal alert (as shown below) for top three Rsi ranks , when it scans all subsribed instruments for a particular time frame .

**IMPORTANT INFO :**
If multi time frame is not possible for this kind of strategy , Just Keep a selection for One time frame , so it would rank All the subsribed instruments based on their Rsi value for that one particular time frame.

Example
1. Received a strategy from you Where its has the following options :
1. Select All instruments - YES .
2. Select Time frame - H1
3. Select indicator - RSI .
Thats it !!

Once i run this strategy in backtester , it should alert :
Eurusd Sell - RANK 1 - Rsi value - 95 - TF-H1
Eurjpy Sell - RANK 2 - Rsi value- 72 - TF- H1
Audcad Sell - RANK 3 - Rsi value- 50 - TF- H1

Hope the description is clear .

Regards ,
Santosh Sahu .


---

## Re: RSI Ranking Dashboard

**Apprentice** · Tue Sep 22, 2020 2:39 am

Your request is added to the development list.
Development reference 2076.


---

## Re: RSI Ranking Dashboard

**Apprentice** · Tue Sep 22, 2020 3:21 am

[Ranking Dashboard.lua](files/137804/Ranking%20Dashboard.lua)

Try this version.


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Tue Sep 22, 2020 4:16 am

> **Apprentice wrote:**
>
>
> Ranking Dashboard.lua
>
>
> Try this version.

Fast Apprentice !!
Good work as always .

Request 1 -- Select All time frames achieved well .
Request 2 -- Multi-indicator option achieved well .

**Request 3 -- Can the strategy be backtested ?**
If yes , will it give the following alert ?
Once i run this strategy in backtester , it should alert :
Eurusd Sell - RANK 1 - Rsi value - 95 - TF-H1
Eurjpy Sell - RANK 2 - Rsi value- 72 - TF- H1
Audcad Sell - RANK 3 - Rsi value- 50 - TF- H1

Regards ,
Santosh .


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Tue Sep 22, 2020 7:36 am

> **Apprentice wrote:**
>
>
> Ranking Dashboard.lua
>
>
> Try this version.

Dear Apprentice ,
Found a bug .

When i see in pair m1 , whenever a pair changes its rank like
Eurusd changes from Rank 10 To Rank 1 ,
I see no popup alert , no sound alert and neither print to log message ?

The same is with other time frames too.

Anything you could fix ?


---

## Re: RSI Ranking Dashboard

**Apprentice** · Wed Sep 23, 2020 2:09 am

Your request is added to the development list.
Development reference 2082.


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Wed Sep 23, 2020 6:32 am

Good work ,
Its alerting now.
**Bug :**
1.For m1 , its alerting after every one min .
Same goes with 5 min and other tf .
2. Alerting all together Rank 1 ,Rank 2 and Rank 3 .

**Fix**
It should only alert when there is a change in rank .
Example
m1 - Eurusd jumps from rank 5 to rank1
It should only alert -
Eurusd - Rank 1 -m1
If there is no change in rank 2 and rank3 , it should not alert that .


---

## Re: RSI Ranking Dashboard

**Apprentice** · Wed Sep 23, 2020 9:08 am

Your request is added to the development list.
Development reference 2092.


---

## Re: RSI Ranking Dashboard

**Apprentice** · Thu Sep 24, 2020 2:45 am

[Ranking Dashboard.lua](files/137872/Ranking%20Dashboard.lua)

Try it now.


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Thu Sep 24, 2020 7:26 am

Great work.
Its Alerting what was needed .
Thanks Apprentice .

Santosh .


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Fri Sep 25, 2020 2:28 pm

> **Apprentice wrote:**
>
>
> Ranking Dashboard.lua
>
>
> Try it now.

It's alerting the same as desired.
Can you make same functionality of the indicator as a strategy?


---

## Re: RSI Ranking Dashboard

**Apprentice** · Sat Sep 26, 2020 1:47 am

Your request is added to the development list.
Development reference 2101.


---

## Re: RSI Ranking Dashboard

**Apprentice** · Mon Sep 28, 2020 4:24 am

What should be the rules for entry and exit?


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Mon Sep 28, 2020 7:29 am

> **Apprentice wrote:**
> What should be the rules for entry and exit?

Need a strategy for the indicator -ONLY SELL.
a . The strategy should give a SELL terminal alert (as shown below) for top three Rsi ranks , when it scans all subsribed instruments for a particular time fram

Once i run this strategy in backtester , it should alert :
Eurusd Sell - RANK 1 - Rsi value - 95 - TF-H1
Eurjpy Sell - RANK 2 - Rsi value- 72 - TF- H1
Audcad Sell - RANK 3 - Rsi value- 50 - TF- H1

Hope the description is clear .


---

## Re: RSI Ranking Dashboard

**Apprentice** · Tue Sep 29, 2020 5:26 am

Your request is added to the development list.
Development reference 2123.


---

## Re: RSI Ranking Dashboard

**Apprentice** · Wed Sep 30, 2020 10:51 am

[Ranking Strategy.lua](files/138004/Ranking%20Strategy.lua)

Try this version.


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Wed Sep 30, 2020 11:37 am

> **Apprentice wrote:**
>
>
> Ranking Strategy.lua
>
>
> Try this version.

Can it be backtested to see the alerts (the instrument name) which topped 3 rank of rsi of all subscribed instruments ?


---

## Re: RSI Ranking Dashboard

**Apprentice** · Fri Oct 02, 2020 2:11 am

As dashboard?


---

## Re: RSI Ranking Dashboard

**SANTOSH** · Fri Oct 02, 2020 2:45 am

> **Apprentice wrote:**
> As dashboard?

No , I want to run q strategy to see these alerts in strategy backtester ?
