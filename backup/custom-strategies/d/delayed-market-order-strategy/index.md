# Delayed Market Order Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=60651  
> Forum: 31 · Topic 60651 · 16 post(s)


---

## Delayed Market Order Strategy

**Apprentice** · Mon May 05, 2014 11:39 am

[Delayed Market Order Strategy.lua](files/93855/Delayed%20Market%20Order%20Strategy.lua)

This simple strategy will execute Market Order,
at some future point in time, regardless of the instrument value at this time.

The Strategy was revised and updated on December 11, 2018.


---

## Re: Delayed Market Order Strategy

**fjasonfx** · Mon Jun 09, 2014 7:24 pm

Hi Apprentice,
 I tried to download this into TS2 and it is giving me this error message.

" Impossible to Import the Selected file. The file is damaged or in the unsupported format"

I am getting the same error when I try to load the Entry Order Strategy also.

Do you or anybody else here know what is going on with this?

Much appreciated,

Jason


---

## Re: Delayed Market Order Strategy

**fjasonfx** · Tue Jun 10, 2014 7:18 am

I don't know what happened but it loaded them today. Thanks anyway!

Jason


---

## Re: Delayed Market Order Strategy

**fjasonfx** · Tue Jun 10, 2014 8:18 pm

Hey guys,
One question. Is there a way to trade less than 1 lot on these strategies? Or does it have to be even lots? I would like to trade something like 10k just to see if the strategy is working ok before I risk more.

Thanks,
Jason


---

## Re: Delayed Market Order Strategy

**Apprentice** · Wed Jun 11, 2014 4:35 am

Lot is minimum trade size.
Odd numbers are allowed.
Before investing any real money,
I advise you to test everything on a demo account.


---

## Re: Delayed Market Order Strategy

**fjasonfx** · Wed Jun 11, 2014 10:36 am

So I can't have a trade size less than 100K (1 Lot) but I can have a trade size of say 150K or 1.5 lots?
Is there a reason why we are not allowed to use smaller than 1lot trade size. Say 10K or 50K? Or is that just the way it is and can't be changed when using these strategies from fxcodebase?

Thnaks for asking my newbe questions,
Jason


---

## Re: Delayed Market Order Strategy

**Apprentice** · Thu Jun 12, 2014 2:07 am

It all depends on your account type.
For me lot size is 1000 Dollar.


---

## Re: Delayed Market Order Strategy

**moomoofx** · Mon Nov 17, 2014 10:03 pm

Strategy has been updated to meet the requirements requested here:

[viewtopic.php?f=27&t=60934](https://fxcodebase.com/code/viewtopic.php?f=27&t=60934)

Now we can have the strategy repeat periodically every n minutes.
Also the strategy has a flag to control if multiple orders should be opened by itself or only one position at a time.

Please redownload the strategy to get the latest.

Cheers,
MooMooForex


---

## Re: Delayed Market Order Strategy

**ogv1v1x** · Sun Dec 21, 2014 3:22 pm

Would there be any way to have it randomly select buy or sell at each repetition?


---

## Re: Delayed Market Order Strategy

**moomoofx** · Sun Dec 21, 2014 7:41 pm

Yes it is possible. Care to share why you would want to trade randomly?

Cheers,
MooMooForex


---

## Re: Delayed Market Order Strategy

**ogv1v1x** · Sun Dec 21, 2014 8:16 pm

Long story short I was having a few bad trading days last week. I was laying in bed last night thinking that an EA would probably have better success just randomly picking trades on a short timeframe chart.


---

## Re: Delayed Market Order Strategy

**moomoofx** · Mon Dec 22, 2014 12:42 am

A sign of desperation indeed.

Unfortunately in the long run it won't.

Imagine your profit target is 10 pips and stop loss is 10 pips, and you trade 10,000 times, you will win roughly half the time. I.e. 50% chance of winning, much like flipping a coin.

Profit Target of 5 pips and Stop is 10 pips will give you a 2/3rds chance of winning and only a 1/3rd chance of losing - sounds awesome, except you'll only be winning half as much each time, or alternatively losing twice as much each time. So, you are back to 50/50 again.

The above is of course assuming no spread and no commissions which realistically make a huge impact, typically 15-20% if not more. So each of your wins will actually win 20% less, and your losses will lose 20% more, skewing it even more against you.

Sorry! You need to find that elusive "edge" everyone is searching ... or I should say an elusive edge.

Cheers,
MooMooForex


---

## Re: Delayed Market Order Strategy

**ogv1v1x** · Mon Dec 22, 2014 7:59 am

I definitely don't disagree with you on why it wouldn't work, as it would be just as good as randomly picking red or black on a roulette wheel, which is also affected by the "commission" to the house (so I can see the the impression of the sign of desperation). My thought on it would be that the computer randomization would remove any human emotion affecting the randomness of choosing whether to buy or sell.

My real account is funded with $100 USD and has been set on Mirror Trader with FXCM, as I'm still working out strategies on demo accounts (trying to find that elusive edge) and have only been trading forex off and on for under a year. This was more a thought of interest and eventually more curiosity after thinking about it. If you're concerned that I would jump in with an EA to desperately make back anything I've lost, that's certainly not the case, as nothing real has been lost.

Thanks for the response though, and I wish you the best in finding your elusive edge as well.


---

## Re: Delayed Market Order Strategy

**moomoofx** · Mon Dec 22, 2014 8:38 am

I love to please so I'll put on the to-do list to add a randomized entry for you.

Cheers,
MooMooForex


---

## Re: Delayed Market Order Strategy

**ogv1v1x** · Wed Dec 24, 2014 2:37 pm

Thank you.


---

## Re: Delayed Market Order Strategy

**Apprentice** · Sun Dec 11, 2016 1:52 pm

Strategy was revised and updated.
