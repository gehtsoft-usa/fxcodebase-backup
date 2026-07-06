# Chinkou Span Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62913  
> Forum: 31 · Topic 62913 · 16 post(s)


---

## Chinkou Span Strategy

**Apprentice** · Thu Nov 26, 2015 6:50 am

![Chinkou Span Strategy.png](images/103515/Chinkou%20Span%20Strategy.png)



Based on request.
[viewtopic.php?f=27&t=62908&p=103516#p103516](https://fxcodebase.com/code/viewtopic.php?f=27&t=62908&p=103516#p103516)

Long Entry
Chinkou span surpassed tenkan sen and Kijun sen

Exit is set at 26 period Low.
Short reverse logic.

 [Chinkou Span Strategy.lua](files/103515/Chinkou%20Span%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Chinkou Span Strategy

**Rastoh** · Mon Dec 07, 2015 4:38 am

Thank you for the excellent work done and the time that you have paid.

Probably everyone who tested this strategy may initially be disappointed. Backtest turned out very badly. .

Fire is a good servant but a bad master, and this also applies to this strategy.

Anyone who download or download this strategy, he ought to know and also how to use it.
Strategy while tests on demo accounts of the currency pair EUR / USD.

Example
 Value Line Chinkou span is greater than tenkan sen and Kijun sen. The growing trend.
I run a strategy and set up a program to sell (not purchase) and the number of pips 100 pips example .When line Chinkou span crosses two lines down, and starts the store on sale .. at this point in time need to pause the -Advantage. At this point it is better to set it manually. Where the stop loss is the highest price for the last 26 candles. Profit is also better to set, for example by Fibonaci or other indicator.
4 hour timeframe has more potential for greater profit.

If you expect a trend change, I set a strategy either for sale or purchase. Never both.
Strategy I have ever launched, with permission to purchase it is a growing trend.
Strategy I have ever running for sale when the downward trend.

Strategy should be run and set a trend that has not begun and that the store opened when the excavation line Chinkou span, which means confirmation of a new trend.

If someone had a better idea of ​​how to set profit or as a better strategy to use, I welcome any idea.

The problem is that when the program is run non-stop, for example at five minute chart and set to sale and purchase, store is always open in the direction of the trend, over time when the achieved even set profile. Then it is also more likely that the market turns against us. And we can go into the red numbers.

thank you


---

## Re: Chinkou Span Strategy

**jaricarr** · Sun Jul 10, 2016 11:58 pm

Hi

This strategy is missing the "Stop order in pips" field (amount of pips).
Can you please add it.

Thanks
JC


---

## Re: Chinkou Span Strategy

**Apprentice** · Mon Aug 08, 2016 7:35 am

Code: [Select all](https://fxcodebase.com/code/)
`if SetStop then
   local Value;
   local min,max= mathex.minmax(Source, Source,period-Period+1, period);
   local BuyDelta= (Source.close[period]-min)/Source:pipSize();
   local SellDelta= (max-Source.close[period])/Source:pipSize();
   
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = BuyDelta;
         
        else
            valuemap.PegPriceOffsetPipsStop = SellDelta;
        end
      
    end`
This is stop logic used.


---

## Re: Chinkou Span Strategy

**Apprentice** · Sat Dec 17, 2016 9:35 am

Strategy was revised and updated.


---

## Re: Chinkou Span Strategy

**mistertrade** · Sun Aug 07, 2022 1:42 am

Hello,
I use this strategy and it works well.
I wanted to know if it was possible to add a new parameter which would be: "Total number of trades executed by the strategy".
This new parameter would limit the number of trades (open and closed positions) that the strategy can execute.

Example: I execute the strategy and I set this new parameter to the value 5. When the number of trades carried out by this strategy (and only this strategy) reaches 5, no other position will be opened by the strategy.

Thanks for your help.


---

## Re: Chinkou Span Strategy

**Apprentice** · Mon Aug 08, 2022 5:35 am

We have added your request to the development list.
Development reference 471.


---

## Re: Chinkou Span Strategy

**Apprentice** · Thu Aug 11, 2022 4:13 am

"Total number of trades executed by the strategy" and "Total number of trades executed by the strategy (Time in Days)" were introduced.

It hasn't been tested myself, so I'd appreciate if you could.

 [Chinkou Span Strategy.lua](files/147047/Chinkou%20Span%20Strategy.lua)


---

## Re: Chinkou Span Strategy

**mistertrade** · Thu Aug 11, 2022 10:12 pm

Hello,

Thank you fort the new strategy. I will test it.

Can you just explain me what is exactly the parameter "Total number of trades executed by the strategy (Time in Days)" whose format is 'double' ?


---

## Re: Chinkou Span Strategy

**mistertrade** · Sun Aug 14, 2022 4:24 am

Hello Apprentice,

I tested the new strategy in simulation mode on the Ger30 instrument and unfortunately it doesn't seem to work.
I set the 2 new parameters as follows:
"TotalNumberOfPosition" = 3
"TotalNumberOfPositionTime" = 1.0
When I run the strategy, it works well but it keeps opening and closing positions, even when it reaches the maximum number of 3 (first parameter).

When you have time, can you see the problem?
Thanks.


---

## Re: Chinkou Span Strategy

**Apprentice** · Mon Aug 15, 2022 3:07 am

Try it now.


---

## Re: Chinkou Span Strategy

**mistertrade** · Wed Aug 17, 2022 1:20 am

Hello,

I tried the new version and I have exactly the same problem as during the first test: the strategy continues to open and close positions even when the maximum number of positions (entered in parameter) is reached.

Thank you for your help...


---

## Re: Chinkou Span Strategy

**Apprentice** · Wed Aug 17, 2022 2:11 am

With this settings
"TotalNumberOfPosition" = 3
"TotalNumberOfPositionTime" = 1.0
It will open up to 3 positions in 1 day (24 hours)


---

## Re: Chinkou Span Strategy

**mistertrade** · Thu Aug 18, 2022 1:49 am

Hello,

I understood now the meaning of the new parameters.
I did a test again in simulation mode on the Ger30 on the day of 4/01/2021 on the 5' timeframe.
The strategy automatically opened and closed more than 20 positions with the new parameters as follows:
"TotalNumberOfPosition" = 3
"TotalNumberOfPositionTime" = 1.0

Maybe I'm making a mistake but I don't see where.

Could someone else test this strategy with these same settings and tell me if it works ?

Thanks


---

## Re: Chinkou Span Strategy

**Apprentice** · Fri Aug 19, 2022 2:31 am

Bug Fixed.


---

## Re: Chinkou Span Strategy

**mistertrade** · Mon Aug 22, 2022 8:02 am

The last version is OK!

Thank you...
