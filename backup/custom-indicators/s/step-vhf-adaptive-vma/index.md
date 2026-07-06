# Step - VHF - Adaptive VMA

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=67313  
> Forum: 17 · Topic 67313 · 6 post(s)


---

## Step - VHF - Adaptive VMA

**Apprentice** · Fri Feb 01, 2019 9:08 am

![EURUSD H1 (02-01-2019 1312).png](images/123654/EURUSD%20H1%20%2802-01-2019%201312%29.png)



Based on request.
[viewtopic.php?f=27&t=67310](https://fxcodebase.com/code/viewtopic.php?f=27&t=67310)

 [step - vhf - adaptive vma.lua](files/123654/step%20-%20vhf%20-%20adaptive%20vma.lua)


---

## Re: Step - VHF - Adaptive VMA

**bartwas1** · Fri Feb 01, 2019 11:38 am

Hi Apprentice

Thank you for fulfilling my request so swiftly. I've done comparison to mt4's version of this indie and there are differences. In meta trader 4 this indie looks much smoother on the same settings. Maybe it depends on how VMA is calculated. Accordingly to 'mladen' who made mt5' version of step- vhf - adaptive VMA, VMA should be calculated following way: "To calculate the Variable Moving Average (VMA):

with VR = Volatility Ratio

VMA = [ { 0.0788 * VR } * Close ] + [ { (1 - 0.078) * VR } * yesterday's VMA ]"

By all means I'm grateful, but is there any chance to make it this indie smother for marketscope?

Kind regards
B.


---

## Re: Step - VHF - Adaptive VMA

**bartwas1** · Fri Feb 01, 2019 12:02 pm

Hi Apprentice

Mladen's explanation of VMA.

"The formula for original VMA calculation is the following :
Code:

VMA = (α * VI * Price) + ((1 – ( α * VI )) * VMA[1])

Where:

α = 2 / (N + 1)

VI = Users choice of a measure of volatility or trend strength.

N = User selected constant smoothing period."

I really want this indie to be smoother as it is in meta trader 4.

kind regards
B.


---

## Re: Step - VHF - Adaptive VMA

**Apprentice** · Fri Feb 01, 2019 1:49 pm

If "Step Size (in Pips)" is set to zero in MQ4 version we will have
Average[period] = Average[period-1]+(alpha*vhf*2)*(source[period]-Average[period-1]);
Otherwise more complex formula will be used.


---

## Re: Step - VHF - Adaptive VMA

**bartwas1** · Fri Feb 01, 2019 4:20 pm

Hi Apprentice

I've read you response, but I'm not a coder. I've posted this formula so it might be useful to you to make this indie similar to mq4 version. I've assumed that it might be helpful somehow. If you tell me that is the best you can do and that's the closest result that can be achieved by converting step VHF adaptive MA into lua I'm happy with that, because without you I wouldn't have this indie in my marketscope. Thank you.

I'll play with settings, for now... I've noticed that if I set step size to 2 in marketscope and then I may have results more or less similar to MQ4 version with settings as follows: VMA period 14, VHF period 0 and step size 1, price close.

Anyhow, thanks again for your effort.
Bart


---

## Re: Step - VHF - Adaptive VMA

**Apprentice** · Mon Feb 04, 2019 7:27 am

Minor update.
