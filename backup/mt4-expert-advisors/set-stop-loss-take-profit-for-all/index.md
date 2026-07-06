# Set Stop Loss Take Profit For All

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=70479  
> Forum: 38 · Topic 70479 · 21 post(s)


---

## Set Stop Loss Take Profit For All

**Apprentice** · Thu Sep 24, 2020 2:50 am

Based on TS2/Lua version.
[viewtopic.php?f=17&t=65384](https://fxcodebase.com/code/viewtopic.php?f=17&t=65384)

 [Set Stop Loss Take Profit For All.mq4](files/137875/Set%20Stop%20Loss%20Take%20Profit%20For%20All.mq4)


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Wed Jan 13, 2021 9:00 am

Hi.

Please assist in creating an Stop Loss EA based on the following criteria:

Multiple entries placed at once, user able to specify the number of trades and TP target for each (with an option of not having a TP target, say having a zero value for example in a trending mkt).

When actual price reaches 1st TP target (Placed by user), activate stop loss at the break-even entry price of each trade in case price retraces. Your help is on this appreciated. Thanks.

Regards


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Thu Jan 14, 2021 3:56 am

Your request is added to the development list.
Development reference 79.


---

## Re: Set Stop Loss Take Profit For All

**optionhk** · Sun Jan 17, 2021 12:37 pm

> **Apprentice wrote:**
> Based on TS2/Lua version.
> [viewtopic.php?f=17&t=65384](https://fxcodebase.com/code/viewtopic.php?f=17&t=65384)
>
>
> Set Stop Loss Take Profit For All.mq4

Excellent EA.

Can you please modify this EA to act as an indicator for two purposes. Not for trading but to record statistics and show it moving dynamically currently.

1. To watch the trade visually in action like ADR MTF projection indicator moves trade dynamically. ADR MTF shows trade in action . Please show TP and SL pulling each other like your ADR MTF does visually so well.

2. Collect statistics by looking back at past trades and record this information based on user query.

Need following inputs
(a) TF - New
(b) Lookback - New
(c) Take Profit,Pips _ Already there Add a switch true/false. If false it will use (d)
(d) Stop Loss, Pips - Already there. Add a switch true/false. If false it will use (e)
(e) Take Profit, Minutes - New
(f) Stop Loss, minutes - New

**Statistics needed for TP and SL in terms of Pips in Chart TF of 15 minutes (current TF)**

 Example 1 (for Pips) : I input TP 25 and SL 10 and want to know statistics for Longs and Shorts separately

Count how many times TP size of 25 hit and how many times it failed or hit SL

Example 2 (for minutes) I input TP 5 minutes and SL 10 minutes and want to know statistics forLongs and Shorts separately

Count how many times TP size of 5 minutes hit and how many times it failed or hit SL of 10 minutes.


---

## Re: Set Stop Loss Take Profit For All

**fx1079** · Sun Jan 17, 2021 9:20 pm

> **Apprentice wrote:**
> Based on TS2/Lua version.
> [viewtopic.php?f=17&t=65384](https://fxcodebase.com/code/viewtopic.php?f=17&t=65384)
>
>
> Set Stop Loss Take Profit For All.mq4

Hello sir, i think you've forgot to include this line in the custom indicator

Code: [Select all](https://fxcodebase.com/code/)
`#property indicator_chart_window`


---

## Re: Set Stop Loss Take Profit For All

**yolerap** · Wed Jan 20, 2021 1:20 pm

Hello,

Is exist one EA set one stop or take profit at the same distance as soon as one stop or take profit is manualy put?


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Thu Jan 21, 2021 3:18 pm

Your request is added to the development list.
Development reference 113.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Sun Feb 14, 2021 9:53 am

Task 79
Try this version.
[viewtopic.php?f=38&t=70922](https://fxcodebase.com/code/viewtopic.php?f=38&t=70922)


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Mon May 24, 2021 5:18 am

Hi,

Thankyou. Is it possible to change the Take Profit and Stop Loss pips/points to Price values for that particular currency pair.

Regards


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Tue May 25, 2021 4:03 am

Your request is added to the development list.
Development reference 509.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Thu May 27, 2021 11:35 am

Can you confirm?
You will set the stop level via parameters set by the user as value, not as pips?


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Wed Jun 09, 2021 4:56 am

Hi,

Yes. Because I find that my TP or B/E levels are reached on platform screen but not triggered.(spread). if there are alternatives, please advise.

Thanks.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Thu Jun 10, 2021 9:44 am

Your request is added to the development list.
Development reference 566.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Tue Jun 15, 2021 1:43 pm

[Set_Stop_Loss_Take_Profit_Absolute_For_All.mq4](files/142517/Set_Stop_Loss_Take_Profit_Absolute_For_All.mq4)

Try this version.


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Wed Jun 16, 2021 1:08 pm

Hi,

Much appreciated Apprentice. Could you add 'break-even after x amount of pips' variable to the inputs, such that SL moves to Breakeven when these x pips (absolute) are reached before TP.

Regards


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Wed Jun 16, 2021 3:37 pm

Hi

Forgot one more thing, another input variable, i.e. number of trades in which TP pips is active, all else being constant, thereby leaving at least one trade in case there is a continuation / trend.

Thanks.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Fri Jun 18, 2021 4:43 am

Your request is added to the development list.
Development reference 583.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Wed Jun 23, 2021 9:23 am

[Set_Stop_Loss_Take_Profit_Absolute_For_All.mq4](files/142584/Set_Stop_Loss_Take_Profit_Absolute_For_All.mq4)

Try this version.


---

## Re: Set Stop Loss Take Profit For All

**evansrono** · Fri Jul 09, 2021 3:24 am

Hi,

Appreciate your work on this, however the count is not accurate. From the EURUSD example, the count for gong long should be 24 closed candles not 5.

The Row for going short is not showing, on which the count should be 25 closed candles.

Regards


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Fri Jul 09, 2021 7:40 am

Your request is added to the development list.
Development reference 626.


---

## Re: Set Stop Loss Take Profit For All

**Apprentice** · Mon Jul 12, 2021 1:12 pm

I can't repeat it. It works fine for me.
