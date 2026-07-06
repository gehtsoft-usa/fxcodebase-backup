# Fibonacci Cross Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=70471  
> Forum: 38 · Topic 70471 · 11 post(s)


---

## Fibonacci Cross Alert

**Apprentice** · Tue Sep 22, 2020 3:16 am

Based on request.
[viewtopic.php?f=27&t=70464](https://fxcodebase.com/code/viewtopic.php?f=27&t=70464)

 [Fibonacci Cross Alert.mq4](files/137801/Fibonacci%20Cross%20Alert.mq4)

You need to draw a Finobacci and specify it's id in the indicator


---

## Re: Fibonacci Cross Alert

**egg999** · Mon Feb 07, 2022 2:43 pm

> **Apprentice wrote:**
> Based on request.
> [viewtopic.php?f=27&t=70464](https://fxcodebase.com/code/viewtopic.php?f=27&t=70464)
>
>
>
> Fibonacci Cross Alert.mq4
>
>
> You need to draw a Finobacci and specify it's id in the indicator

@Apprentice
Where can I see id of a fibonacci indicator?
Thanks


---

## Re: Fibonacci Cross Alert

**Apprentice** · Wed Feb 09, 2022 9:21 am

![Snimka zaslona 2022-02-09 152044.png](images/144976/Snimka%20zaslona%202022-02-09%20152044.png)


---

## Re: Fibonacci Cross Alert

**egg999** · Wed Feb 09, 2022 10:18 am

> **Apprentice wrote:**
>
>
> The attachment **Snimka zaslona 2022-02-09 152044.png** is no longer available

Thank you for replying, @Apprentice.
Maybe my previous question was not clear enough.
What I asked was the place where I can see the id of fibonacci indicator.
I am confused what the meaning of "indicator id".

Is term of "indicator id" meaning its indicator file name?
Or should I look for it by opening the mq4 file? If yes, in where part/line/row I can see that id and put it in that row/line/box.
Or where else?
Thanks again.
Rgds


---

## Re: Fibonacci Cross Alert

**egg999** · Wed Feb 09, 2022 10:28 am

P.S.
This is fibonacci file that I am using:

Regards,


---

## Re: Fibonacci Cross Alert

**Apprentice** · Fri Feb 11, 2022 5:53 am

Different IDs will be used if you use more than one instance of the indicator.


---

## Re: Fibonacci Cross Alert

**egg999** · Sun Feb 13, 2022 11:16 am

> **Apprentice wrote:**
> Different IDs will be used if you use more than one instance of the indicator.

And where can I see id indicator in an indicator?
Rgds.


---

## Re: Fibonacci Cross Alert

**Apprentice** · Mon Feb 14, 2022 3:29 am

Source ID is not relevant.


---

## Re: Fibonacci Cross Alert

**egg999** · Mon Feb 14, 2022 3:20 pm

> **Apprentice wrote:**
> Based on request.
> [viewtopic.php?f=27&t=70464](https://fxcodebase.com/code/viewtopic.php?f=27&t=70464)
>
>
>
> Fibonacci Cross Alert.mq4
>
>
> You need to draw a Finobacci and specify it's id in the indicator

And what I should specify in the indicator?

*sorry for keep asking because this alert indicator is very useful.

Rgds,


---

## Re: Fibonacci Cross Alert

**Apprentice** · Tue Feb 15, 2022 8:12 am

If your goal is to use it with another indicator.
We will need to write a new alert indicator.


---

## Re: Fibonacci Cross Alert

**egg999** · Tue Feb 15, 2022 3:10 pm

> **Apprentice wrote:**
> If your goal is to use it with another indicator.
> We will need to write a new alert indicator.

Thank you for your patience, @Apprentice.
My goal is to get alert when a candle cross the specific fibonacci line (i.e 0.618).
I've tried attaching your indicator and nothing show up in the chart. Not even 0.618 line.
So I thought maybe it needs a fibonacci indicator and both should be connected by inputing the fibonacci id into the fibonacci alert indicator.
But I don't know how to find the fibonacci indicator id.

Please find attached fibonacci indicator that I am using right now.

Thanks a lot and regards,
