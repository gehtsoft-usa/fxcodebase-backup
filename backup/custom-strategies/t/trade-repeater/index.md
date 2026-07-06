# Trade_Repeater

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65821  
> Forum: 31 · Topic 65821 · 19 post(s)


---

## Trade_Repeater

**Apprentice** · Sat Mar 10, 2018 7:07 pm

[trade_repeater.lua](files/118122/trade_repeater.lua)

Based on the request.
[viewtopic.php?f=27&t=65814](https://fxcodebase.com/code/viewtopic.php?f=27&t=65814)

MT4/MQ4 version.
[viewtopic.php?f=38&t=68914](https://fxcodebase.com/code/viewtopic.php?f=38&t=68914)


---

## Re: Rrade_Repeater

**flbrgz** · Sun Mar 11, 2018 8:38 pm

Hi, Thanks for the super fast response. I am testing it out on my demo account now. I will let you know how it goes.

I will donating to you once this is working as required.

Regards,
Paul.


---

## Re: Trade_Repeater

**flbrgz** · Thu Mar 15, 2018 10:22 am

Hi all.

I have been using Trade Repeater for most this week on my demo account. It worked as I had requested and I couldn't live without it now.

I am now running it on my live account after seeing the results on my demo account.

Obviously this isn't going to be for everyone and I have developed a specific trading strategy that works for me and Trade Repeater is just what I wanted.

There is only one minor improvement that I would like. I think that if possible you would have done it this way in the original but maybe it can be done.

It appears that when a trade closes, the order is repeated using the actual entry point of the previous trade. Sometimes the previous trades opened at a slightly different price to the set entry point, so over 5 to 10 trades there is a little shifting of the entry point.

Is there a way to always refer the the set entry point or can we only refer to the actual entry point of the previous trade.

I will be using the Trade Repeater as is even if it can't be tweaked.

Regards.


---

## Re: Trade_Repeater

**Apprentice** · Tue Mar 27, 2018 10:19 am

[trade_repeater.lua](files/118393/trade_repeater.lua)

This is because of slippage. We changed the strategy, so it'll remember the original rate


---

## Re: Trade_Repeater

**flbrgz** · Tue Nov 06, 2018 12:59 am

Hello all. Hope your trading is going well.

I have been using the Trade Repeater for quite some time and except for my own bending of my own rules it has performed very well. There are some further coding challenges I have for you if you are willing.

I still have some issues with slippage. Is there a way to round the order value to its closest .01
I trade eur/nzd so if instance I may have trades at 1.50, 1.51, 1.52 ect these get repeated at say 1.503 1.512, 1.523 etc. Can they be rounded back to 1.50, 1.51, 1.52 before setting the repeat order.

I know it's really nothing but I find it easier to browse my trades when they all have trailing zeros and not random slippage values.

Now the big challenge.

Can we set a new value by pip distance on the repeat order if we get stopped out.instead of the original order value.

So if my sell trade at 1.50 gets stopped out, say 200 pips 1.70 can the repeat trade say " because we have been stopped out the order value will be 300 pips higher than the original trade. If the Trade closes at a profit then the original trade value will be used for the repeat trade".

The stopped out new order replacement value would be a setting in the strategy options settings.

A lot to think about I know.

Thanks in advance for any responses.


---

## Re: Trade_Repeater

**Apprentice** · Sun Nov 11, 2018 5:42 am

Your request is added to the development list under Id Number 4308


---

## Re: Trade_Repeater

**flbrgz** · Mon Nov 12, 2018 4:47 am

Awesome, thanks.


---

## Re: Trade_Repeater

**flbrgz** · Sat Aug 31, 2019 11:42 pm

Hello all.

I haven't traded in a while. I went on leave and changed my strategy and currency traded to something I thought was safer and unfortunately failed to consider a few things and I got wiped out. No fault to trade repeater it does what I asked for. Luckily there wasn't too much money involved.

I have had a year off and have started trading again using the trade repeater and have implemented a hedging strategy that has already protected my account.

I just need to get this trade repeater fine tuned. I have looked through its code but I am not really a programmer so I got lost pretty quickly.

I have a new request to try to stop the slippage issue as it still there during fast volatile markets.

Is there a way to round the entry point number to the fourth decimal. So 1.76452 would be 1.7645 and say 1.76458 would be 1.7646. It seems to the last or 5th digit that it throwing a spanner in the works.

It may seem a little trivial but with the strategy I am using, I can have up to 40 trades open with orders for more trades and hedging trades in place, the 5th digit makes it a little confusing at times and looking at my trading the history the rounding to the 4th digit would solve any remaining issues for me. It would reduce errors from slippage and make my daily routine of correcting slippage in orders a lot more efficient.

Thanks for everything. Keep up the good work.


---

## Re: Trade_Repeater

**flbrgz** · Wed Sep 04, 2019 10:36 pm

Hi all,

Just wondering if there is an easy way to convert this for mt4 application. Or is there already a similar strategy available

Cheers.


---

## Re: Trade_Repeater

**Apprentice** · Tue Sep 10, 2019 8:13 am

Your request is added to the development list.
Development reference 64.


---

## Re: Trade_Repeater

**Krypt0n1te** · Thu Mar 05, 2020 9:41 am

Dear Apprentice!

Thank you SO much for creating this strategy.

**I trade the NAS100 via FXCM's Trading Station**.

I've downloaded the Trade_Repeater strategy last night and tested it on an FXCM demo account.

It works PERFECTLY with EUR/USD but unfortunately, it does NOT work with NAS100.

Further testing...

 If I run the strategy for EUR/USD and I have a EUR/USD trade that closes then the strategy creates 1 new buy order....Perfect
 If I run the strategy for NAS100 and I have a NAS100 trade that closes then nothing happens.
 If I run the strategy for EUR/USD and NAS100 simultaneously and a trade for EUR/USD closes then the strategy creates 2 new buy orders for EUR/USD, if a trade for NAS100 closes nothing happens.

Pretty please can you look into it.

Kindest Regards
Krypt0n1te


---

## Re: Trade_Repeater

**Apprentice** · Fri Mar 06, 2020 6:30 am

Your request is added to the development list.
Development reference 834.


---

## Re: Trade_Repeater

**Apprentice** · Mon Mar 09, 2020 7:06 am

[trade_repeater.lua](files/131813/trade_repeater.lua)

Try this version.


---

## Re: Trade_Repeater

**Krypt0n1te** · Mon Mar 09, 2020 12:37 pm

Dear Apprentice

Thank you, thank you, thank you!

It means a lot to me.

Regards

Krypt0n1te


---

## Re: Trade_Repeater

**Krypt0n1te** · Wed Mar 11, 2020 5:26 pm

Dear Apprentice

May I please ask for some more of your time, please.

I have used and tested the latest version of this strategy to a great extent both on a demo as well as my live accounts.

Findings:

 TP (Profit-taking price or closing price or limit price): Each time a closed trade is repeated or duplicated the TP is perfect, each time, **whether or not there was slippage, the TP for the new pending order is exactly the same as for the trade that closed** - Thank you.

 Entry Price (Opening price): Unfortunately, the entry price for the new order that is created is different from what was specified in the original order. Often it varies by a small amount, couple of decimals, but now and then there's actually a huge difference. Could you please look into it?

 Example of one of the "weird" trades: **(Actual Trade)**

An Entry order was created manually on the NAS100 with the following values...
Entry point: 8094
TP: 8143

The order got filled at 8093.85 and closed out at 8143.40

The new order that was created by the strategy after the manual trade had closed had the following values:
Entry point: 8021 - (73 points or 0.9% lower)
TP: 8143 - (Spot on)

Thank you so much for your time.

Kindest Regards

Krypt0n1te


---

## Re: Trade_Repeater

**Apprentice** · Fri Mar 13, 2020 5:55 am

Your request is added to the development list.
Development reference 865.


---

## Re: Trade_Repeater

**Apprentice** · Mon Mar 16, 2020 6:08 am

It's not possible to get information about the original entry order rate.
The only thing we can get is a trade open price. That what we are using.


---

## Re: Trade_Repeater

**Krypt0n1te** · Mon Mar 16, 2020 2:46 pm

> **Apprentice wrote:**
> It's not possible to get information about the original entry order rate.
> The only thing we can get is a trade open price. That what we are using.

Dear Apprentice

Thank you for your reply. If I may ask... Do you know why the majority of the opening prices of the duplicate orders are very close to the original order but then once in a while you get a duplicate order where the opening price is completely different to the original order?

Why does this not happen for the closing price of the orders which are perfect each time?

Thanks

Krypt0n1te


---

## Re: Trade_Repeater

**Apprentice** · Tue Mar 17, 2020 11:50 am

This is a question for FXCM.
It is not TS related.
I believe it is related to liquidity.
