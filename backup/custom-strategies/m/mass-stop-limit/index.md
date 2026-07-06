# Mass Stop/Limit

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3857  
> Forum: 31 · Topic 3857 · 16 post(s)


---

## Mass Stop/Limit

**vstrelnikov** · Wed Apr 06, 2011 4:15 pm

The very simple helper, which works only on non-FIFO accounts.
Just continually puts predefined Stop/Limit values on each trade.

Will be helpful if you are constantly forgetting to put Stop/Limit value on trades.

 [MassStopLimit.lua](files/9438/MassStopLimit.lua)

The Strategy was revised and updated on January 21, 2019.


---

## Re: Mass Stop/Limit

**ggiannop** · Wed Aug 10, 2011 3:58 pm

can this be used somehow to put trailing stops ? or how can i add to other strategies with simple stops ...a trailing one


---

## Re: Mass Stop/Limit

**jtatalov** · Fri Aug 12, 2011 3:03 pm

Can this strategy be used simultaneously with other strategies to obtain real life simulations? Thank you in advance for your work and help


---

## Re: Mass Stop/Limit

**jtatalov** · Fri Aug 12, 2011 3:12 pm

Also, is there a reason it can only be used with a non-FIFO account?


---

## Re: Mass Stop/Limit

**sunshine** · Sat Aug 13, 2011 3:58 am

> **ggiannop wrote:**
> can this be used somehow to put trailing stops ? or how can i add to other strategies with simple stops ...a trailing one

Attached is the Mass Stop/Limit which allows placing of trailing stops.


---

## Re: Mass Stop/Limit

**sunshine** · Sat Aug 13, 2011 4:08 am

> **jtatalov wrote:**
> Can this strategy be used simultaneously with other strategies to obtain real life simulations? Thank you in advance for your work and help

The strategy can be used simultaneously with other strategies. However I suppose that this doesn't make sense because the most of strategies have own parameters for risk management. The Mass Stop/Limit is intended rather for manual trading for the case you forgot to place Stop/Limit.

> **jtatalov wrote:**
> Also, is there a reason it can only be used with a non-FIFO account?

The strategy cannot be used on FIFO accounts since regular Stop/Limit orders for individual trades cannot be created on such accounts.


---

## Re: Mass Stop/Limit

**jtatalov** · Sat Aug 13, 2011 5:13 am

> **sunshine wrote:**
>
>
> > **jtatalov wrote:**
> > Can this strategy be used simultaneously with other strategies to obtain real life simulations? Thank you in advance for your work and help
>
>
> The strategy can be used simultaneously with other strategies. However I suppose that this doesn't make sense because the most of strategies have own parameters for risk management. The Mass Stop/Limit is intended rather for manual trading for the case you forgot to place Stop/Limit.
>
>
>
> > **jtatalov wrote:**
> > Also, is there a reason it can only be used with a non-FIFO account?
>
>
> The strategy cannot be used on FIFO accounts since regular Stop/Limit orders for individual trades cannot be created on such accounts.

I agree most strategies have risk management function embedded, however they cannot be personalized to the users money management policy. For example, the [TDI Indicator](https://fxcodebase.com/code/viewtopic.php?f=17&t=2069&p=10464&hilit=traders+dynamic+indicator#p10464) works great, however, occasionally it will give a false signals during ranging and/or consolidation periods where it would be prudent to add a 30-50 pip stop loss parameter to minimize potential losses. In addition, a trailing stop/limit parameter would allow the strategy to lock in gains for breakout periods. I'm wondering if it would be possible to incorporate the two functions into a single strategy?


---

## Re: Mass Stop/Limit

**sunshine** · Sat Aug 13, 2011 6:52 am

Do you mean this strategy?
[viewtopic.php?f=31&t=4134](https://fxcodebase.com/code/viewtopic.php?f=31&t=4134)
Would you like to have "set stop/limit/trailing stop" parameters for this strategy?


---

## Re: Mass Stop/Limit

**mfoste1** · Sat Aug 13, 2011 11:17 am

is there any way to make something for FIFO US accts that would always set a user specified stop and limit for all market orders made?


---

## Re: Mass Stop/Limit

**jtatalov** · Sat Aug 13, 2011 2:46 pm

> **sunshine wrote:**
> Do you mean this strategy?
> [viewtopic.php?f=31&t=4134](https://fxcodebase.com/code/viewtopic.php?f=31&t=4134)
> Would you like to have "set stop/limit/trailing stop" parameters for this strategy?

Yes, I have a FIFO account though and I'm not sure if the regulations would be contradictory to the strategy. I think it can be done, however, the user has to be comfortable with the program, opening multiple trades in one direction and closing them out at the same time. Thank you for the link, the extended back testing was my next question.


---

## Re: Mass Stop/Limit

**ggiannop** · Sun Aug 14, 2011 2:04 pm

thanks for the reply ..this is usefull with other strategies ..because other strategies have only fixed stops ....


---

## Re: Mass Stop/Limit

**sunshine** · Tue Aug 16, 2011 8:45 am

> **jtatalov wrote:**
> Yes, I have a FIFO account though and I'm not sure if the regulations would be contradictory to the strategy. I think it can be done, however, the user has to be comfortable with the program, opening multiple trades in one direction and closing them out at the same time. Thank you for the link, the extended back testing was my next question.

It's impossible to use the current MassStopLimit version with FIFO accounts. However it could be modified to create Net Stop/Limit orders in case the account is under FIFO regulations.


---

## Re: Mass Stop/Limit

**Apprentice** · Fri Dec 02, 2016 7:05 am

Bump up.


---

## Re: Mass Stop/Limit

**Kilgharrah** · Tue Dec 06, 2016 6:53 am

Hi, It is possible to add the functionality of **Time Parameters**(Start and Stop time, etc.), thanks.


---

## Re: Mass Stop/Limit

**Apprentice** · Tue Dec 06, 2016 7:41 am

Your request is added to the development list, Under Id Number 3688
 If someone is interested to do this task, please contact me.


---

## Re: Mass Stop/Limit

**Alexander.Gettinger** · Tue Sep 19, 2017 2:22 pm

> **Kilgharrah wrote:**
> Hi, It is possible to add the functionality of **Time Parameters**(Start and Stop time, etc.), thanks.

Updated.
