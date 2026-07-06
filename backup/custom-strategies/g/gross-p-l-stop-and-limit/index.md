# Gross P/L Stop and Limit

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=14956  
> Forum: 31 · Topic 14956 · 14 post(s)


---

## Gross P/L Stop and Limit

**Alexander.Gettinger** · Tue Mar 20, 2012 1:29 pm

The strategy will close all open positions for all symbols for achieving the specified stop or limit levels.

Download:

 [GrossPL_Close.lua](files/28342/GrossPL_Close.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Gross P/L Stop and Limit

**TraderKen** · Sun Mar 25, 2012 4:11 pm

Hi Alexander,

I have a question. For US clients, FXCM Trading Station already has the Net Stop and Net Limit options. Is this strategy different from those choices ?

From FXCM LLC:

Net Stop Order

FXCM LLC (US) customers can use Net Stop Orders to help manage their risk, and to prevent one trade from wiping out an account. This order automatically closes every position you have in any one currency pair at the best available price once a certain price is reached. A Net Stop can only be set at a price less favorable than the current price.

 Example: You buy several positions of EUR/USD, totaling 100,000 units, with an average entry price of 1.47927. You want the positions to close automatically if the EUR/USD moves 100 pips against you. So, you set a Net Stop Order at 1.46927. This stop will apply to ALL open positions in the EUR/USD in your account.

To Set a Net Stop Order: You can enter a Net Stop Order by selecting a currency pair in the “Summary” window, and clicking on the “Stop” button.

Thank you.


---

## Re: Gross P/L Stop and Limit

**mfoste1** · Mon Mar 26, 2012 12:55 pm

> **Alexander.Gettinger wrote:**
> The strategy will close all open positions for all symbols for achieving the specified stop or limit levels.
>
> Download:
>
>
> GrossPL_Close.lua

is this in dollar amounts in the account balance?


---

## Re: Gross P/L Stop and Limit

**mfoste1** · Sat Mar 31, 2012 12:45 pm

> **Alexander.Gettinger wrote:**
> The strategy will close all open positions for all symbols for achieving the specified stop or limit levels.
>
> Download:
>
>
> GrossPL_Close.lua

is this in dollar amounts or pips?


---

## Re: Gross P/L Stop and Limit

**Apprentice** · Mon Apr 02, 2012 4:38 am

The current profit/loss of the position expressed in the account currency.


---

## Re: Gross P/L Stop and Limit

**arstechnica** · Thu Nov 01, 2012 1:31 am

A good implementation in my opinion would be to add a second condition:

Stop and limit with referenge to daily P/L

It would be ver usefull for money management


---

## Re: Gross P/L Stop and Limit

**guangho** · Mon Dec 03, 2012 2:12 am

Is there such a strategy?

Just what I selected species ( eur/usd or gbp/usd ) entire position. Profit loss of unwinding, unwinding. Not selected varieties do not handle.

Website of the other strategies aimed at selected cultivars of specified positions of execution, if I open up many positions in the strategy of setting time will be very troublesome.

thank you！


---

## Re: Gross P/L Stop and Limit

**cnikitopoulos94** · Mon Oct 05, 2015 7:19 am

Are U.S. Accounts allowed to use this?


---

## Re: Gross P/L Stop and Limit

**Apprentice** · Thu Oct 08, 2015 5:07 am

Yes.


---

## Re: Gross P/L Stop and Limit

**fwcolbert** · Wed Oct 21, 2015 12:49 am

Hey Can this strategy resume playing without pausing every time a gross profit is reached?


---

## Re: Gross P/L Stop and Limit

**Apprentice** · Thu Oct 22, 2015 4:45 am

Try this version.

 [GrossPL_Close.lua](files/102955/GrossPL_Close.lua)


---

## Re: Gross P/L Stop and Limit

**pinimo** · Sat Nov 28, 2015 8:50 am

This strategy works only with currencies or also with CFD?
If I start the strategy with EUR/USD, It close all symblos such for example GBP/USD?

Thank you.


---

## Re: Gross P/L Stop and Limit

**Apprentice** · Tue Dec 01, 2015 6:28 am

Will work with both.
Will close All open positions for all symbols


---

## Re: Gross P/L Stop and Limit

**Apprentice** · Wed Dec 14, 2016 4:46 am

Strategy was revised and updated.
