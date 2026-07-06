# Entry order indicator helper

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65479  
> Forum: 17 · Topic 65479 · 3 post(s)


---

## Entry order indicator helper

**Apprentice** · Sun Dec 24, 2017 10:33 am

Based on the request.
[viewtopic.php?f=27&t=65478&p=116619#p116619](https://fxcodebase.com/code/viewtopic.php?f=27&t=65478&p=116619#p116619)

Stop level (in pips) is defined via parameters.
Limit level (in pips) is defined via parameters.

Execute via addCommand functionality, Execute Now.
Or at set time.

Helper will add two entry orders, x pips above below the current price.
Orders above price will be long
Orders below bellow will be short

Additionally,
the user can define the termination period for entry orders in seconds.
If any entry order is still present after this time, it will be deleted.

the user can define the termination period for executed entry orders (positions) in seconds.
If any positions are still present after this time, it will be closed.

Additionally, if the position is executed, the user can define a stop level shift step.
If the position has x pips in profit, the stop/limit level will be shifted for x pips.
Reset Profit counter.
If the position has reached x pips in profit from that level,
the stop/limit level will be shifted for x pips.
Reset Profit counter
And so on.

 [Entry order indicator helper.lua](files/116623/Entry%20order%20indicator%20helper.lua)

 [Entry_order_indicator_helper with Date and Time selector.lua](files/116623/Entry_order_indicator_helper%20with%20Date%20and%20Time%20selector.lua)


---

## Re: Entry order indicator helper

**Apprentice** · Wed Nov 20, 2019 6:39 am

Major update.


---

## Re: Entry order indicator helper

**Apprentice** · Wed Dec 11, 2019 5:26 pm

Version with Trailing/Breakeven.

 [Advanced Entry_order_indicator_helper.lua](files/130203/Advanced%20Entry_order_indicator_helper.lua)
