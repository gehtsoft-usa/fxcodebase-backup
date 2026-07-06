# Average rates

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66105  
> Forum: 17 · Topic 66105 · 20 post(s)


---

## Average rates

**Apprentice** · Sat May 05, 2018 7:37 am

![EURUSD H1 (02-27-2017 0436).png](images/119099/EURUSD%20H1%20%2802-27-2017%200436%29.png)



Based on the request.
[viewtopic.php?f=27&t=65963](https://fxcodebase.com/code/viewtopic.php?f=27&t=65963)
Will give you the ability to create custom equal weighted index.

 [Average rates.lua](files/119099/Average%20rates.lua)

Will produce 100 every time average rate for currencies coincides with the values of the first candle in data set.

 [Arithmetic Mean.lua](files/119099/Arithmetic%20Mean.lua)

AUD/CAD	0.96838
AUD/CHF	0.75327
AUD/JPY	82.190
Would produce a sum of 83.91165 and average of 27.97055.

 [Simple Arithmetic Mean.lua](files/119099/Simple%20Arithmetic%20Mean.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=68601](https://fxcodebase.com/code/viewtopic.php?f=38&t=68601)


---

## Re: Average rates

**speakinmymind** · Sun May 06, 2018 1:03 pm

Could you explain the calculations to me? I may have a misunderstanding of how indexes work.

I selected EUR as the base, and EUR/USD for all of the four selections. I noticed the output line is the same visual as the EUR/USD pair, which was expected, however, the output data is 133.1048.

I expected an average of the four selections which would have came out to 1.19596

or a sum of the four selections which would have came out to 4.78384.

Can you help me understand what you did to get your output?


---

## Re: Average rates

**speakinmymind** · Sun May 06, 2018 4:42 pm

I did some further research and I understand the currency strength aspect provided here. Is it possible to add the other currencies to the "Base" list? Also the ability to use seven symbols in the calculation?

This indicator is useful but not quite what I was looking for. I'm looking for the same type of output, but instead of measuring the strength of the currency, I'd rather see a visual of what the historical average between multiple rates, i.e.:

AUD/CAD	0.96838
AUD/CHF	0.75327
AUD/JPY	82.190

Would produce an average output of: 27.97055.

or the sum which the output would be 83.91165

In addition, the ability to use the reciprocal would be needed in the following example:

NZD/USD	0.70198
USD/CAD	1.28467
USD/CHF	0.99937

to convert to:

USD/NZD	1.42454
USD/CAD	1.28467
USD/CHF	0.99937

Before producing the optional outputs:

average: 1.23619
sum: 3.70858

Please allow for as many input symbols as possible. Thanks!!


---

## Re: Average rates

**Apprentice** · Mon May 07, 2018 4:18 am

Additional "Base" , currency pairs added.


---

## Re: Average rates

**Apprentice** · Mon May 07, 2018 4:39 am

Arithmetic Mean.lua added.


---

## Re: Average rates

**speakinmymind** · Mon May 07, 2018 6:33 am

Thanks! The Arithmetic Mean.lua is what I was looking for, however, it seems to error out consistently whenever I zoom out to load more data, I'm hoping this can be fixed??

With the Average Rates.lua indicator, is it possible to have the indicator automatically pre-select all subscribed instruments related to the base pair for its calculation?

Side note, is there any chance that a future version of Marketscope will allow the streaming of all symbols (opposed to the 20 symbols limit)?

Thanks!


---

## Re: Average rates

**Apprentice** · Mon May 07, 2018 7:23 am

Try it now.
TS can have an unlimited number of instruments.
You need to ask FXCM to increase this limit for your account.


---

## Re: Average rates

**speakinmymind** · Wed May 09, 2018 11:30 pm

Could you eliminate the "base currency" selection in the Arithmetic Mean.lua indicator?

It shouldn't be needed to find the simple mean between the two rates and not the currency strength.

Also, it prevents me from adding a symbol that isn't related.

For example, I cannot look at the mean between GBP/CAD, USD/CAD, and GBP/USD.

I get an error, as one of the three will not be related to the "base currency"

Thanks!


---

## Re: Average rates

**Apprentice** · Thu May 10, 2018 4:16 am

Simple Arithmetic Mean.lua added.


---

## Re: Average rates

**speakinmymind** · Thu May 10, 2018 2:22 pm

Thanks Apprentice!!

For the Simple Mean, could you please put the selected pairs in the legend of the indicator, and if inverse is selected it would reflect that? I know it's cosmetic...


---

## Re: Average rates

**Apprentice** · Mon May 14, 2018 6:21 am

Try it now.


---

## Re: Average rates

**speakinmymind** · Mon May 14, 2018 8:40 pm

Could you automate this process for me?

The Simple Arithmetic Mean is used four times:

1. Selected Pair (EUR/USD in this example)

2. (GBP is base in this example) Put GBP on left of quote and use both currencies in the selected pair. (Here it would be GBP/USD and GBP/EUR).

3. Recipricol of step 2. (Here it would be USD/GBP and EUR/GBP.

4. Add step 2 and 3 to create a midpoint. (Here it would be GBP/USD, GBP/EUR, USD/GBP, and EUR/GBP

The only thing the user should be able to change is the base currency. All JPY related quotes should have a 0.01 weight.

Thanks!


---

## Re: Average rates

**Apprentice** · Tue May 15, 2018 8:14 am

Try this version.
[viewtopic.php?f=17&t=66125](https://fxcodebase.com/code/viewtopic.php?f=17&t=66125)


---

## Re: Average rates

**jusiur** · Sat Jun 22, 2019 7:59 pm

Thank you for those indies, may I ask if it´s possible an MT4 version of Simple Arithmetic Mean please? really we have here a very valuable tool, good concept and good work.
Thanks again Apprentice & speakinmymind !!


---

## Re: Average rates

**Apprentice** · Sun Jun 23, 2019 11:32 am

Your request is added to the development list under Id Number 4742


---

## Re: Average rates

**Apprentice** · Tue Jun 25, 2019 4:46 am

MT4/MQ4 version
[viewtopic.php?f=38&t=68601](https://fxcodebase.com/code/viewtopic.php?f=38&t=68601)


---

## Re: Average rates

**jusiur** · Tue Jun 25, 2019 8:46 pm

> **Apprentice wrote:**
> MT4/MQ4 version
> [viewtopic.php?f=38&t=68601](https://fxcodebase.com/code/viewtopic.php?f=38&t=68601)

I appreciate your help, thank you


---

## Re: Average rates

**speakinmymind** · Sun Jul 23, 2023 10:01 pm

Can you make a Simple Mean that will use indicator input?

I want to select (and customize data source) on two indicators and produce the mean in a line.

It would also help to be able to select which data stream for indicators that have more than one.

Thanks!


---

## Re: Average rates

**Apprentice** · Tue Jul 25, 2023 5:24 am

We have added your request to the development list.
Development reference 639.


---

## Re: Average rates

**Apprentice** · Tue Jul 25, 2023 11:22 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=73968](https://fxcodebase.com/code/viewtopic.php?f=17&t=73968)
