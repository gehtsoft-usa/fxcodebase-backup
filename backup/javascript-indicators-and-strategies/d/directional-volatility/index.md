# Directional Volatility

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68212  
> Forum: 48 · Topic 68212 · 1 post(s)


---

## Directional Volatility

**Alexander.Gettinger** · Sat Mar 30, 2019 11:29 am

Directional Volatility LONG
Mov((Ref(CLOSE,-1)-LOW),14,E)+ 3*Stdev((Mov((Ref(CLOSE,-1)-LOW),14,E)) ,14 ))
Directional Volatility SHORT
Mov((HIGH-Ref(CLOSE,-1)),14,E)+ 3*Stdev(Mov((HIGH-Ref(CLOSE,-1)),14,E) ,14 ))

 

![Directional Volatility.PNG](images/125431/Directional%20Volatility.PNG)



Download:

 [Directional Volatility_JS.jsl](files/125431/Directional%20Volatility_JS.jsl)
