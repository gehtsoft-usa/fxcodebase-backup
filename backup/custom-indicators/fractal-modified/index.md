# Fractal modified

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63313  
> Forum: 17 · Topic 63313 · 3 post(s)


---

## Fractal modified

**eurusd86** · Sun Mar 27, 2016 3:24 am

the raw fractal.lua is too small to see，and it can't display number 3 ，so i looked up the ebook ，modified it to this one.
up1 = instance:createTextOutput ("", "UpL", "calibrib", 18, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
 down1 = instance:createTextOutput ("", "DnL", "calibrib", 18, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);

font "calibrib" solved the mistake ，
fontsize 18 is better


---

## Re: Fractal modified

**Apprentice** · Mon Mar 28, 2016 7:18 am

![GBPUSD H1 (03-28-2016 1343).png](images/105508/GBPUSD%20H1%20%2803-28-2016%201343%29.png)



Try this version.
Font size can be adjusted.

 [Fractal Modified.lua](files/105508/Fractal%20Modified.lua)


---

## Re: Fractal modified

**Apprentice** · Fri Sep 07, 2018 11:31 am

The Indicator was revised and updated.
