# Profit Level Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=59810  
> Forum: 29 · Topic 59810 · 12 post(s)


---

## Profit Level Alert

**Apprentice** · Wed Nov 06, 2013 6:09 am

[Profit Level Alert.lua](files/90608/Profit%20Level%20Alert.lua)

 [Profit Level Cross Alert.lua](files/90608/Profit%20Level%20Cross%20Alert.lua)

Alert will be given,
if set, account level is reached.

 "Balance", "Equity", "GrossPL" and "DayPL are supported


---

## Re: Profit Level Alert

**StefPasc** · Wed Nov 06, 2013 8:08 am

when openning the Method window it displays 6 possible selections :
"GrossPL", "Balance", "Equity", "GrossPL", "Balance"and "DayPL"
Is it right ?


---

## Re: Profit Level Alert

**snaderc** · Wed Nov 06, 2013 10:07 am

The Symbol field seems to be confusing things here. Perhaps we have a misunderstanding or I'm misunderstanding how to use this tool. I'm not looking for profit on individual currency pair positions. I am looking for an alert that notifies me when my account Net P/L reaches a certain profit or loss level, irregardless of which and how many currency pairs are in my account. I don't know how else to say that I want a notification when my overall Net P/L reaches certain extremes. And, I would like to be notified via e-mail so I can live, but be notified at the critical points I set. Example of a message I would like to receive: "Your Net P/L has reached -3.00 (in my case, dollars). At that point, I would likely make an adjustment to the positions held.


---

## Re: Profit Level Alert

**Apprentice** · Wed Nov 06, 2013 10:31 am

Method Duplicates are removed.

As for the currency pair selection.
It is irelevantas, as this is an account based alert.
Unfortunately can not be removed.
It is not defined within alert code.


---

## Re: Profit Level Alert

**snaderc** · Wed Nov 06, 2013 11:13 am

I am sorry. The loaded the wrong indicator. The tool provided is what I was looking for. Thank you. Curious, however, why Net P/L is not an option. Gross P/L is sufficient for my purpose.


---

## Re: Profit Level Alert

**Apprentice** · Wed Nov 06, 2013 12:24 pm

GrossPL IS The profit and loss on all open positions in the account.
The GrossPL is the difference between the Equity and the Balance of the account.


---

## Re: Profit Level Alert

**snaderc** · Wed Nov 06, 2013 12:33 pm

Thank you!


---

## Re: Profit Level Alert

**snaderc** · Wed Nov 06, 2013 1:19 pm

Is it possible to have multiple thresholds? (i.e. -3.00 and +3.00)?


---

## Re: Profit Level Alert

**Apprentice** · Thu Nov 07, 2013 5:34 am

Try to use Profit Level Cross Alert
This version supports cross algorithm, and negative value.
At this time I do not plan to add multi level alert.
However you can define multiple instances of this alert.


---

## Re: Profit Level Alert

**snaderc** · Thu Nov 07, 2013 2:38 pm

The (overlooked) obvious answer of having multiple alerts running is fine. Thanks again.


---

## Re: Profit Level Alert

**Sepp64** · Wed Nov 19, 2014 2:53 pm

"Close all open orders" once the alarm triggered. Can this option be added?

Thanks,


---

## Re: Profit Level Alert

**Apprentice** · Fri Nov 21, 2014 4:03 am

Your request is added to the development list.
