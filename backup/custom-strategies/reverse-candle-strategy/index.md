# Reverse Candle Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63223  
> Forum: 31 · Topic 63223 · 10 post(s)


---

## Reverse Candle Strategy

**Apprentice** · Sun Mar 06, 2016 9:24 am

![EURUSD H1 (03-06-2016 1449).png](images/105155/EURUSD%20H1%20%2803-06-2016%201449%29.png)



Based on request.
[viewtopic.php?f=27&t=61730](https://fxcodebase.com/code/viewtopic.php?f=27&t=61730)

Short reverse candle
- current high is higher than previous high;
- current close is lower than current open= current close is lower than previous close;
- previous close is higher than previous open;

If these conditions are met, we have a short reverse candle.
To trade these reverse candle, the price has to cross under the reverse candle`s low within the next period.

Stop loss should be set to the pipsize of the reverse candle (so distance between reverse candle high and low) .
Long reverse candles are the opposite.

 [Reverse Candle Strategy.lua](files/105155/Reverse%20Candle%20Strategy.lua)


---

## Re: Reverse Candle Strategy

**Martin** · Sun Mar 13, 2016 3:50 am

hey Apprentice,

many many thanks for your work, very well done.

I am currently testing it in demo mode and found two issues:
The strategy sometimes starts to open 2 or 3 trades at the same time- see attachement
and
if a trade got opened and closed within one period and this period is still lasting, another trade is opened directly after the first one got closed.
Would you please have a look?

I really appreciate your help.
Thank you

Martin


---

## Re: Reverse Candle Strategy

**haveforexfun** · Mon Mar 14, 2016 2:51 am

Hi Apprentice,

could you also create an MTF MCP Dashboard of these reverse candles (as separate view).

Short reverse candle
- current high is higher than previous high;
- current close is lower than current open= current close is lower than previous close;
- previous close is higher than previous open;

Long reverse candle
- current low is lower than previous low;
- current close is higher than current open= current close is higher than previous close;
- previous close is lower than previous open;

Thank you very much
Haveforexfun


---

## Re: Reverse Candle Strategy

**Apprentice** · Mon Mar 21, 2016 8:13 am

Requested can be found here.
[viewtopic.php?f=17&t=63267](https://fxcodebase.com/code/viewtopic.php?f=17&t=63267)


---

## Re: Reverse Candle Strategy

**Martin** · Sat Mar 26, 2016 2:13 am

hey Apprentice,

let's say I want to trade a short reverse candle, not if the price is crossing under the reverse candle's low, but is crossing under the reverse candle's low minus 2 Pips, how could I implement that into the code:

 elseif Source.high[period]> Source.high[period-1]
	and Source.close[period]< Source.open[period]
	and Source.close[period-1]> Source.open[period-1]
	and Source.close[period+1]< Source.low[period]

Thanks in advance
Martin


---

## Re: Reverse Candle Strategy

**Martin** · Fri Apr 01, 2016 8:43 am

Hey Apprentice,

any updates on that?

Thanks in advance

Martin


---

## Re: Reverse Candle Strategy

**Apprentice** · Wed Apr 06, 2016 11:35 am

Code: [Select all](https://fxcodebase.com/code/)
`if   Source.low[period]< Source.low[period-1]
   and Source.close[period]> Source.open[period]
   and Source.close[period-1]< Source.open[period-1]
   and Source.close[period+1]> (Source.high[period]+2*Source:pipSize())
   then   
       -Long
        elseif   Source.high[period]> Source.high[period-1]
   and Source.close[period]< Source.open[period]
   and Source.close[period-1]> Source.open[period-1]
   and (Source.close[period+1]< Source.low[period]-2*Source:pipSize())
   then
       --Short
         end`


---

## Re: Reverse Candle Strategy

**Martin** · Wed Apr 13, 2016 2:56 pm

Hey Apprentice,

thanks a lot for your reply man, I really appreciate your help.
The strategy is working pretty well that way, the only thing
I would like to change is the following:
If a trade was opened and closed within the same period, the strategy directly
opens another trade as all conditions to do so are still met as we are still in [period+1].
How could I fix this? function tradescount??

Again many many thanks

Martin


---

## Re: Reverse Candle Strategy

**Apprentice** · Wed Apr 20, 2016 4:38 am

Your request is added to the development list.


---

## Re: Reverse Candle Strategy

**Apprentice** · Sun Jan 14, 2018 7:14 am

The strategy was revised and updated.
