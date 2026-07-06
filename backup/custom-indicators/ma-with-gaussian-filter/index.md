# MA with Gaussian Filter

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=12230  
> Forum: 17 · Topic 12230 · 2 post(s)


---

## MA with Gaussian Filter

**Alexander.Gettinger** · Tue Jan 24, 2012 6:47 am

Formulas:
GaussMA[i]=p1*Price[i-1]+p2*GaussMA[i-1]-p3*GaussMA[i-2]+p4*GaussMA[i-3]-p5*GaussMA[i-4], where
p1=Alpha^4,
p2=4*(1-Alpha),
p3=6*(1-Alpha)^2,
p4=4*(1-Alpha)^3,
p5=(1-Alpha)^4,
Alpha=-Beta+sqrt(Beta*(Beta+2)),
Beta=(1-cos(w))/(2^(1/3)-1),
w=2*Pi/Period.

 

![GaussMA.png](images/24220/GaussMA.png)



Line color indicates growth or decline.
Color of dots corresponds to the acceleration or deceleration.

Download:

 [GaussMA.lua](files/24220/GaussMA.lua)

The indicator was revised and updated


---

## Re: MA with Gaussian Filter

**Apprentice** · Thu Mar 23, 2017 3:02 pm

Indicator was revised and updated.
