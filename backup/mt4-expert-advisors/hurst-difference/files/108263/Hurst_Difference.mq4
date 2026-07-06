//+------------------------------------------------------------------+
//|                                             Hurst_Difference.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 1
#property indicator_separate_window
#property indicator_levelcolor clrWhite

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int     Periods    = 30;
extern e_price Price_Type = CLOSE;
extern color   Color_Line = clrYellow;

double HurstBuff[];
double Price[];
double FDI[];

int init(){
   
   IndicatorShortName("Hurst_Difference");
   IndicatorBuffers(3);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Color_Line);
   SetIndexBuffer(0,HurstBuff);
   SetIndexLabel(0,"Hurst Difference");
   
   SetIndexBuffer(1,Price);
   SetIndexBuffer(2,FDI);
   
   SetLevelValue(0,0);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for (i=limit-Periods; i>=0; i--){
      
      if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_CLOSE)
         Price[i]=Close[i];
      else if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_OPEN)
         Price[i]=Open[i];
      else if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_HIGH)
         Price[i]=High[i];
      else if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_LOW)
         Price[i]=Low[i];
      else if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_MEDIAN)
         Price[i]=(High[i]+Low[i])/2;
      else if (ENUM_APPLIED_PRICE(Price_Type)==PRICE_TYPICAL)
         Price[i]=(High[i]+Low[i]+Close[i])/3;
      else
         Price[i]=(High[i]+Low[i]+(2*Close[i]))/4;
         
   }
    
   double priceMax, priceMin, lenght, priorDiff, diff;
   
   for (i=limit-Periods; i>=0; i--){
      
      lenght=0;
      priorDiff=0;
      diff=0;
      
      for (j=(i+Periods-1); j>=i; j--){
         if (j==(i+Periods-1))
            priceMax = priceMin = Price[j];
         else{
            if (Price[j]>priceMax) priceMax = Price[j];
            if (Price[j]<priceMin)  priceMin = Price[j];
         }
      }
      
      for (j=(i+Periods-1); j>=i; j--){
         if ((priceMax-priceMin) > 0){
            diff = (Price[j]-priceMin)/(priceMax-priceMin);
            if (priceMax > priceMin){
               lenght = lenght+MathSqrt(MathPow(diff-priorDiff,2)+(1/MathPow(Periods,2)));
            }
            priorDiff=diff;
         }
      }
      
      if (lenght > 0)
         FDI[i] = (1+(MathLog(lenght)+MathLog(2))) / MathLog(2*(Periods-1));
      else
         FDI[i] = 0;
         
      HurstBuff[i] = FDI[i+1] - FDI[i];
         
   }
   
//----
   return(0);
}
