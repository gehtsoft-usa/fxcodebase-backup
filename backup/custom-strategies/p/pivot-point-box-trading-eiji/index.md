# Pivot point Box trading - Eiji

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=69983  
> Forum: 31 · Topic 69983 · 12 post(s)


---

## Pivot point Box trading - Eiji

**Apprentice** · Tue Jun 09, 2020 7:25 am

![EURUSD D1 (06-09-2020 1235).png](images/134726/EURUSD%20D1%20%2806-09-2020%201235%29.png)



Based on request.
[viewtopic.php?f=31&p=134650](https://fxcodebase.com/code/viewtopic.php?f=31&p=134650)

 [Pivot point Box trading - Eiji.lua](files/134726/Pivot%20point%20Box%20trading%20-%20Eiji.lua)


---

## Re: Pivot point Box trading - Eiji

**eijicrown** · Wed Jun 10, 2020 6:06 am

Dear apprentice,

thank you very much.

- Could it be possible to have a box drawn of the chart or some ligns to indicates the level in order to have visual confirmation.
- could we also have the possibility to apply to a trade we already started manual ? (choosing the open trade ?)

I tried it but although it is activated I didn't have any trade activated, here are my settings.

thanks for your help


---

## Re: Pivot point Box trading - Eiji

**eijicrown** · Wed Jun 10, 2020 7:19 am

I actually saw the strategy working, but both take profit were not activated, so neither the breakeven


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Thu Jun 11, 2020 5:29 am

Your request is added to the development list.
Development reference 1462.


---

## Re: Pivot point Box trading - Eiji

**eijicrown** · Thu Jun 11, 2020 11:56 am

Thank you,

 don't know if it was mentioned earlier but once a border is activated, the Pivot Point is becoming the stop.
And multiposition can be opened at the same time.

Thank again for your support and help


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Fri Jun 12, 2020 3:49 am

It's a strategy.
It can't draw anything on the chart.
And it works with entry orders.
 We can't apply it to the existing trade.


---

## Re: Pivot point Box trading - Eiji

**eijicrown** · Wed Jun 24, 2020 11:16 am

No problem then can you just modify the stop to be on the pivot point.

Also the setup is not actualized on the live new pivot point - on the screenshot the new pivot point is drawn but the orders are not actualized


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Wed Jun 24, 2020 12:41 pm

Your request is added to the development list.
Development reference 1549.


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Thu Jun 25, 2020 4:42 am

[Pivot point Box trading - Eiji v2.lua](files/135259/Pivot%20point%20Box%20trading%20-%20Eiji%20v2.lua)

Try this version.


---

## Re: Pivot point Box trading - Eiji

**eijicrown** · Thu Jun 25, 2020 2:08 pm

Excellent, the box is following live the pivot point.
the trailing is working.

- the take profit 1 and 2 are not working
- also if buy trade has been activated and the price come back to close the trade at the pivot point - it should reactivate the buy order (at the moment, it's a buy trade is closed by the stop, it only remains the sell order) -

As many time the price just comes to bounce on the pivot point before the movement get big amplitude appears (especially on daily pivot point) - in that case we can have multiple buy signal on the same pivot point.

Thanks for the update, it looks really promising.


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Thu Jun 25, 2020 6:40 pm

Your request is added to the development list.
Development reference 1564.


---

## Re: Pivot point Box trading - Eiji

**Apprentice** · Fri Jun 26, 2020 3:48 am

I don't have any issues with it.
