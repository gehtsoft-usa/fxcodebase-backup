# Fred Tam F1 Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=3971  
> Forum: 17 · Topic 3971 · 44 post(s)


---

## Fred Tam F1 Indicator

**Apprentice** · Wed Apr 20, 2011 4:59 am

![Fred Tam F1 Indicator.png](images/9852/Fred%20Tam%20F1%20Indicator.png)



1) Buy arrow
If recent closing price is higher than the recent days close max
( eg. close(0) > Max(close(i) )
2) Sell ​​
If recent closing price is lower than the recent days close min
 ( eg. close(0) < Min(close(i) )

 [Fred Tam F1 Indicator.lua](files/9852/Fred%20Tam%20F1%20Indicator.lua)

 [Fred Tam F1 Indicator with Alert.lua](files/9852/Fred%20Tam%20F1%20Indicator%20with%20Alert.lua)

I have added a choice between two types of signals.
Close and High / Low Data stream as a source for the signal.

I have noticed that High / Low option offered less noise.

MT4/MQ4 version
[viewtopic.php?f=38&t=69892](https://fxcodebase.com/code/viewtopic.php?f=38&t=69892)


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Wed Apr 20, 2011 8:28 am

Separate parameters for the Buy and Sell period added.


---

## Re: Fred Tam F1 Indicator

**bingyunid** · Fri Apr 22, 2011 3:13 am

Hi,Apprentice ,Thanks very much for this indicator, is it possible to develop a MTF version of this indicator?Thanks


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Fri Apr 22, 2011 4:08 am

I'll try to finish this version in the next few days.


---

## Re: Fred Tam F1 Indicator

**yasirali1974** · Fri Apr 22, 2011 3:11 pm

Is it possible to make stratagy based on this indicator coz i believe its going to be great with inputs of h/l buy signal 2 sell signal 2 on 4hrly chart. thanks.
Yasir


---

## Re: Fred Tam F1 Indicator

**yasirali1974** · Sat Apr 23, 2011 4:47 am

> **yasirali1974 wrote:**
> Is it possible to make stratagy based on this indicator coz i believe its going to be great with inputs of h/l buy signal 2 sell signal 2 on 4hrly chart. thanks.
> Yasir

and stops below the signal candle with tp 60pips


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Sun Apr 24, 2011 9:16 am

Update.


---

## Re: Fred Tam F1 Indicator

**bingyunid** · Sun Apr 24, 2011 11:20 pm

> **Apprentice wrote:**
> I'll try to finish this version in the next few days.

 Thanks very much, Apprentice,


---

## Re: Fred Tam F1 Indicator

**RJH501** · Sun Jul 17, 2011 12:25 pm

Has a signal or strategy been developed using this indicator?

If not would it be possible to add it to the QUE?

Regards,

RJH


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Mon Jul 18, 2011 6:17 am

Strategy can be found here.
[viewtopic.php?f=31&t=3972&p=9984&hilit=Fred+Tam#p9984](https://fxcodebase.com/code/viewtopic.php?f=31&t=3972&p=9984&hilit=Fred+Tam#p9984)


---

## Re: Fred Tam F1 Indicator

**fskliris** · Mon Jul 18, 2011 1:07 pm

The signal in this indicator is very good, but when someone uses the strategy it gives signal in the next candle. Some one could use it in the same candle that the arow shows and put takeprofit 20-25 pips. That way it is always winning. Can you do something about this apprentice? Thanks again

I dont Know if i made my self clear. What i mean is that order must open automatically imediatelly as soon as the price breaks the 4high or 4 low . This way if we put tp a certain amount lets say 20pips for EURUSD in 1 hour TF, the action will be profitable .Usually in 1 hour TF the order will close in the same candle . Check this out.
Is it possible to fix it master?


---

## Re: Fred Tam F1 Indicator

**alishus** · Tue Jul 19, 2011 5:09 am

can you please add the alert option too,it looks great.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Wed Jul 20, 2011 6:50 am

Strategy can be found here, You can use it as Alert.
[viewtopic.php?f=31&t=3972&p=9984&hilit=Fred+Tam#p9984](https://fxcodebase.com/code/viewtopic.php?f=31&t=3972&p=9984&hilit=Fred+Tam#p9984)


---

## Re: Fred Tam F1 Indicator

**RJH501** · Thu Jul 21, 2011 2:36 pm

Would like to have your help in trouble shooting a problem I see recurring with the Fred Tam F1 Strategy. Please reference charts. the last two trades which the strategy took with no indicator signal.

Is there an issue with the program or am I doing something wrong?

Thanks for your help!

Richard


---

## Re: Fred Tam F1 Indicator

**bgmays** · Mon Sep 12, 2011 10:01 pm

Great work! Is there a way that you could add a filter using the 200 mva? So that it only shows green arrows above the 200 period mva and vice versa?


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Tue Sep 13, 2011 4:22 am

Filter of this type is possible.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Sat Mar 18, 2017 7:54 am

Indicator was revised and updated.


---

## Re: Fred Tam F1 Indicator

**6-sycamor** · Sun Nov 12, 2017 10:44 am

Very good indicator, I have been watching him for a long time on m30.

I would like to add an alarm option (info box like: sell signal on xxx) and an alarm sound with the possibility to indicate a specific sound.

Thank you very much and I look forward to hearing from you.

Regards,

Sycamor


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Sun Nov 12, 2017 12:14 pm

Fred Tam F1 Indicator with Alert.lua added.


---

## Re: Fred Tam F1 Indicator

**6-sycamor** · Sun Nov 12, 2017 2:39 pm

Thank you very, very much !

Observe this for next few days.

Regards,

S.


---

## Re: Fred Tam F1 Indicator

**6-sycamor** · Mon Nov 13, 2017 7:21 pm

Hi,

today look for this indicator and ... not working.

Alert is on (Prawda), sound is on and nothing happen.

No sounds, no info box on screen ...

Can you check ?

Regards,

S.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Tue Nov 14, 2017 5:17 am

Fixed.


---

## Re: Fred Tam F1 Indicator

**6-sycamor** · Tue Nov 14, 2017 5:23 am

Thanks,

go look

Regards,

S.


---

## Re: Fred Tam F1 Indicator

**6-sycamor** · Tue Nov 14, 2017 6:35 am

Now is OK,

thank yoy very much.

regards,

S.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Fri Jun 29, 2018 7:15 am

The Indicator was revised and updated.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Wed Mar 18, 2020 5:49 pm

Hi Apprentice,

Could you take a look at this indicator please? It mostly works well except I notice that the signals on the chart sometimes disappear after a chart refresh. It is not quite working properly and there is something weird with the alert sound. Much appreciated if you could clean it up. Thanks a lot.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Thu Mar 19, 2020 12:27 am

Hi Apprentice,

Here is an example of the issue attached.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu Mar 19, 2020 4:21 am

Your request is added to the development list.
Development reference 898.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Thu Mar 19, 2020 7:06 am

Hi Apprentice,

Thanks for your fast work. Seems to show too many signals now. Something still a bit wrong with it.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu Mar 19, 2020 9:18 am

Your request is added to the development list.
Development reference 903.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Fri Mar 20, 2020 6:29 am

Hi Apprentice,

Thanks a lot! Looks good. Will try it out next week. Cheers


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Wed Mar 25, 2020 4:50 pm

> **Apprentice wrote:**
> Try this version.
>
>
> Fred Tam F1 Indicator with Alert.lua

Hi Apprentice,

It seems to be better but I am still having the same issue when I refresh the chart the arrows disappear (or appear) where they weren't before refresh. Also the sound alert doesn't seem to work. Thanks.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu Mar 26, 2020 6:23 am

Your request is added to the development list.
Development reference 944.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Fri Mar 27, 2020 8:12 am

[Fred Tam F1 Indicator with Alert.lua](files/132323/Fred%20Tam%20F1%20Indicator%20with%20Alert.lua)

Try this version.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Sat Mar 28, 2020 6:53 am

Hi Apprentice,

The latest version doesn't work like the other ones- too many signals. The previous version was the best and it doesn't repaint all the time. I use it on the high/low option which provides fewer signals but could there be something wrong with the code for that setting?


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Mon Mar 30, 2020 6:31 am

Your request is added to the development list.
Development reference 958.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Tue Mar 31, 2020 5:36 am

Can you provide a bit more information, maybe a screenshot?
I don't have any issues with it. Do you have any errors in the log?


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Tue Mar 31, 2020 7:36 am

Here are some examples- initial then after refresh. I'm not sure what you mean about the log.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu Apr 02, 2020 5:25 am

Make sure that you have reinstalled it properly. It looks like an old code. Or try to rename it and import that renamed version.


---

## Re: Fred Tam F1 Indicator

**nbats7979** · Sat May 16, 2020 10:12 am

Hi Is it possible to have the MT4 version for this please? The one with the alert. Thanks.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Sat May 16, 2020 3:42 pm

Your request is added to the development list.
Development reference 1301.


---

## Re: Fred Tam F1 Indicator

**lowcoloured** · Thu May 21, 2020 1:46 am

Does Fred Tam F1 Indicator repaints?


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu May 21, 2020 6:14 am

It does not.


---

## Re: Fred Tam F1 Indicator

**Apprentice** · Thu May 21, 2020 9:09 am

MT4/MQ4 version
[viewtopic.php?f=38&t=69892](https://fxcodebase.com/code/viewtopic.php?f=38&t=69892)
