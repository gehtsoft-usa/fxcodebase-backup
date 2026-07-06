//+------------------------------------------------------------------+
//|                                               All_MA_Average.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "Average of All Moving Averages"

#property indicator_buffers 1
#property indicator_chart_window
#property indicator_color1 clrYellow
#property indicator_width1 1

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      MA_Period     = 50;
extern e_price  MA_Price_Type = CLOSE;

double MA[];
double Price[];

double aEMA[];
double aWilder[];
double aSMMA[];
double aZeroLagEMA[];
double aITrend[];
double aREMA[];

double tmp[][2];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Average of All Moving Averages");
   IndicatorBuffers(8);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   
   SetIndexBuffer(1,Price);
   
   SetIndexBuffer(2,aEMA);
   SetIndexBuffer(3,aWilder);
   SetIndexBuffer(4,aSMMA);
   SetIndexBuffer(5,aZeroLagEMA);
   SetIndexBuffer(6,aITrend);
   SetIndexBuffer(7,aREMA);
   
   return(0);
  }

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for (i=limit; i>=0; i--) Price[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type),i);  
   
   for (i=limit; i>=0; i--){
      aEMA[i]        = EMA(Price[i],aEMA[i+1],MA_Period,i);
      aWilder[i]     = Wilder(Price[i],aWilder[i+1],MA_Period,i);  
      aSMMA[i]       = SMMA(Price,aSMMA[i+1],MA_Period,i);
      aZeroLagEMA[i] = ZeroLagEMA(Price,aZeroLagEMA[i+1],MA_Period,i);
      aITrend[i]     = ITrend(Price,aITrend,MA_Period,i);
      aREMA[i]       = REMA(Price[i],aREMA,MA_Period,0.5,i);
   }
   
   double iSMA, iLWMA, iSineWMA, iTriMA, iLSMA, iHMA, iMedian, iGeoMean, iILRS, iIE2, iTriMA_gen;
   
   for (i=limit; i>=0; i--){
         
         iSMA        = SMA(Price,MA_Period,i);
         iLWMA       = LWMA(Price,MA_Period,i);
         iSineWMA    = SineWMA(Price,MA_Period,i);
         iTriMA      = TriMA(Price,MA_Period,i);
         iLSMA       = LSMA(Price,MA_Period,i);
         iHMA        = HMA(Price,MA_Period,i);
         iMedian     = Median(Price,MA_Period,i);
         iGeoMean    = GeoMean(Price,MA_Period,i);
         iILRS       = ILRS(Price,MA_Period,i);
         iIE2        = IE2(Price,MA_Period,i);
         iTriMA_gen  = TriMA_gen(Price,MA_Period,i);
         
         MA[i] = (iSMA + aEMA[i] + aWilder[i] + iLWMA + iSineWMA + iTriMA + iLSMA + aSMMA[i] + iHMA + aZeroLagEMA[i] + aITrend[i] + iMedian + iGeoMean + aREMA[i] + iILRS + iIE2 + iTriMA_gen) / 17;
      
   }
   
   
//----
   return(0);
}

double SMA(double &array[],int per,int bar){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i];
   return(Sum/per);
}                

double EMA(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double ema = price;
   else 
      ema = prev + 2.0/(1+per)*(price - prev); 
   return(ema);
}

double Wilder(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double wilder = price;
   else 
      wilder = prev + (price - prev)/per; 
   return(wilder);
}

double LWMA(double &array[],int per,int bar){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+i]*(per - i);
   }
   if(Weight>0)
      double lwma = Sum/Weight;
   else
      lwma = 0; 
   return(lwma);
} 

double SineWMA(double &array[],int per,int bar){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+i]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      double swma = Sum/Weight;
   else
      swma = 0; 
   return(swma);
}

double TriMA(double &array[],int per,int bar){
   double sma;
   int len = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+i);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+per-i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar){
   if(bar == Bars - per)
      double smma = SMA(array,per,bar);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) Sum += array[bar+i+1];
      smma = (Sum - prev + array[bar])/per;
   }
   return(smma);
}                

double HMA(double &array[],int per,int bar){
   double tmp1[];
   int len = MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      double hma = array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+i) - LWMA(array,per,bar+i);  
      hma = LWMA(tmp1,len,0); 
   }  
   return(hma);
}

double ZeroLagEMA(double &price[],double prev,int per,int bar){
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   if(bar >= Bars - lag)
      double zema = price[bar];
   else 
      zema = alfa*(2*price[bar] - price[bar+lag]) + (1-alfa)*prev;
   return(zema);
}

double ITrend(double &price[],double &array[],int per,int bar){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+1] - (alfa - 0.75*alfa*alfa)*price[bar+2] + 2*(1-alfa)*array[bar+1] - (1-alfa)*(1-alfa)*array[bar+2];
   else
      it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   return(it);
}

double Median(double &price[],int per,int bar){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
   return(median); 
}

double GeoMean(double &price[],int per,int bar){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }   
   return(gmean);
}

double REMA(double price,double &array[],int per,double lambda,int bar){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      double rema = price;
   else 
      rema = (array[bar+1]*(1+2*lambda) + alpha*(price - array[bar+1]) - lambda*array[bar+2])/(1+lambda);    
   return(rema);
}

double ILRS(double &price[],int per,int bar){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+i];
      sumy += price[bar+i];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar);
   return(ilrs);
}

double IE2(double &price[],int per,int bar){
   double ie = 0.5*(ILRS(price,per,bar) + LSMA(price,per,bar));
   return(ie); 
}
 

double TriMA_gen(double &array[],int per,int bar){
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+i);
   double trimagen = sum/len2;
   return(trimagen);
}

double VWMA(double &array[],int per,int bar){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= Volume[bar+i];
      Sum += array[bar+i]*Volume[bar+i];
   }
   if(Weight>0)
      double vwma = Sum/Weight;
   else
      vwma = 0; 
   return(vwma);
} 