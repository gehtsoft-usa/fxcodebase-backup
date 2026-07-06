# Least Square Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=65229  
> Forum: 48 · Topic 65229 · 1 post(s)


---

## Least Square Moving Average

**Alexander.Gettinger** · Sat Oct 28, 2017 9:34 am

Formulas:
LSMA[i]=Sum/L2, where
Sum[i] = (Length-N)*Price[i]+(Length-N-1)*Price[i-1]+…+(1-N)*Price[i-Length+1],
N = (Length+1)/3,
L2 = Length*(Length+1)/6.

 

![LSMA_JS.PNG](images/115653/LSMA_JS.PNG)



Download:

 [LSMA_JS.jsl](files/115653/LSMA_JS.jsl)
