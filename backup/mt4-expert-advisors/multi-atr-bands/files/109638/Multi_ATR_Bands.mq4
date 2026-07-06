//+------------------------------------------------------------------+
//|                                              Multi_ATR_Bands.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "ATR Bands with Multiple Selection"

#property indicator_buffers 9
#property indicator_chart_window
#property indicator_color1 clrRed
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_style2 STYLE_DOT
#property indicator_color3 clrRed
#property indicator_width3 1
#property indicator_style3 STYLE_DOT

#property indicator_color4 clrYellow
#property indicator_width4 1
#property indicator_color5 clrYellow
#property indicator_width5 1
#property indicator_style5 STYLE_DOT
#property indicator_color6 clrYellow
#property indicator_width6 1
#property indicator_style6 STYLE_DOT

#property indicator_color7 clrDodgerBlue
#property indicator_width7 1
#property indicator_color8 clrDodgerBlue
#property indicator_width8 1
#property indicator_style8 STYLE_DOT
#property indicator_color9 clrDodgerBlue
#property indicator_width9 1
#property indicator_style9 STYLE_DOT

enum e_method{ SMA        =  1,
               EMA        =  2,
               Wilder     =  3,
               LWMA       =  4,
               SineWMA    =  5,
               TriMA      =  6,
               LSMA       =  7,
               SMMA       =  8,
               HMA        =  9,
               ZeroLagEMA = 10,
               ITrend     = 11,
               Median     = 12,
               GeoMean    = 13,
               REMA       = 14,
               ILRS       = 15,
               IE_2       = 16,
               TriMAgen   = 17
             };

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern bool     Show_MidLine   = false;
extern bool     Show_Bands1    = true;
extern int      ATR_Period1    = 14;
extern int      MA_Period1     = 14;
extern e_method MA_Method1     = EMA;
extern e_price  MA_Price_Type1 = CLOSE;
extern double   Bands_Percent1 = 2.0;
extern bool     Show_Bands2    = true;
extern int      ATR_Period2    = 18;
extern int      MA_Period2     = 50;
extern e_method MA_Method2     = SMMA;
extern e_price  MA_Price_Type2 = CLOSE;
extern double   Bands_Percent2 = 2.0;
extern bool     Show_Bands3    = true;
extern int      ATR_Period3    = 15;
extern int      MA_Period3     = 100;
extern e_method MA_Method3     = HMA;
extern e_price  MA_Price_Type3 = CLOSE;
extern double   Bands_Percent3 = 2.0;

double MA1[], MA2[], MA3[];
double TOP1[], TOP2[], TOP3[];
double BOT1[], BOT2[], BOT3[];
double Price1[], Price2[], Price3[];
double ATR1[], ATR2[], ATR3[];

double Signal_Mean[];
double Signal_Top[];
double Signal_Bottom[];

double tmp[][2];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Multi ATR Bands");
   IndicatorBuffers(15);
   
   if (Show_MidLine) int MidLine = DRAW_LINE; else MidLine = DRAW_NONE;
   if (Show_Bands1)  int Bands1  = DRAW_LINE; else Bands1  = DRAW_NONE;
   if (Show_Bands2)  int Bands2  = DRAW_LINE; else Bands2  = DRAW_NONE;
   if (Show_Bands3)  int Bands3  = DRAW_LINE; else Bands3  = DRAW_NONE;
   
   SetIndexStyle(0,MidLine);
   SetIndexBuffer(0,MA1);
   SetIndexStyle(1,Bands1);
   SetIndexBuffer(1,TOP1);
   SetIndexStyle(2,Bands1);
   SetIndexBuffer(2,BOT1);
   
   SetIndexStyle(3,MidLine);
   SetIndexBuffer(3,MA2);
   SetIndexStyle(4,Bands2);
   SetIndexBuffer(4,TOP2);
   SetIndexStyle(5,Bands2);
   SetIndexBuffer(5,BOT2);
   
   SetIndexStyle(6,MidLine);
   SetIndexBuffer(6,MA3);
   SetIndexStyle(7,Bands3);
   SetIndexBuffer(7,TOP3);
   SetIndexStyle(8,Bands3);
   SetIndexBuffer(8,BOT3);
   
   SetIndexBuffer(9,Price1);
   SetIndexBuffer(10,ATR1);
   
   SetIndexBuffer(11,Price2);
   SetIndexBuffer(12,ATR2);
   
   SetIndexBuffer(13,Price3);
   SetIndexBuffer(14,ATR3);
   
   return(0);
  }

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for (i=limit; i>=0; i--){
      Price1[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type1),i);
      Price2[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type2),i);
      Price3[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type3),i);
   }
   
   for (i=limit; i>=0; i--){
      
      switch(MA_Method1){
         case 1 : MA1[i] = SMA(Price1,MA_Period1,i); break;
         case 2 : MA1[i] = EMA(Price1[i],MA1[i+1],MA_Period1,i); break;
         case 3 : MA1[i] = Wilder(Price1[i],MA1[i+1],MA_Period1,i); break;  
         case 4 : MA1[i] = LWMA(Price1,MA_Period1,i); break;
         case 5 : MA1[i] = SineWMA(Price1,MA_Period1,i); break;
         case 6 : MA1[i] = TriMA(Price1,MA_Period1,i); break;
         case 7 : MA1[i] = LSMA(Price1,MA_Period1,i); break;
         case 8 : MA1[i] = SMMA(Price1,MA1[i+1],MA_Period1,i); break;
         case 9 : MA1[i] = HMA(Price1,MA_Period1,i); break;
         case 10: MA1[i] = ZeroLagEMA(Price1,MA1[i+1],MA_Period1,i); break;
         case 11: MA1[i] = ITrend(Price1,MA1,MA_Period1,i); break;
         case 12: MA1[i] = Median(Price1,MA_Period1,i); break;
         case 13: MA1[i] = GeoMean(Price1,MA_Period1,i); break;
         case 14: MA1[i] = REMA(Price1[i],MA1,MA_Period1,0.5,i); break;
         case 15: MA1[i] = ILRS(Price1,MA_Period1,i); break;
         case 16: MA1[i] = IE2(Price1,MA_Period1,i); break;
         case 17: MA1[i] = TriMA_gen(Price1,MA_Period1,i); break;
         default: MA1[i] = SMA(Price1,MA_Period1,i); break;
      }
      ATR1[i] = iATR(NULL,0,ATR_Period1,i);
      TOP1[i] = MA1[i] + (ATR1[i]*Bands_Percent1);
      BOT1[i] = MA1[i] - (ATR1[i]*Bands_Percent1);
      
      switch(MA_Method2){
         case 1 : MA2[i] = SMA(Price2,MA_Period2,i); break;
         case 2 : MA2[i] = EMA(Price2[i],MA2[i+1],MA_Period2,i); break;
         case 3 : MA2[i] = Wilder(Price2[i],MA2[i+1],MA_Period2,i); break;  
         case 4 : MA2[i] = LWMA(Price2,MA_Period2,i); break;
         case 5 : MA2[i] = SineWMA(Price2,MA_Period2,i); break;
         case 6 : MA2[i] = TriMA(Price2,MA_Period2,i); break;
         case 7 : MA2[i] = LSMA(Price2,MA_Period2,i); break;
         case 8 : MA2[i] = SMMA(Price2,MA2[i+1],MA_Period2,i); break;
         case 9 : MA2[i] = HMA(Price2,MA_Period2,i); break;
         case 10: MA2[i] = ZeroLagEMA(Price2,MA2[i+1],MA_Period2,i); break;
         case 11: MA2[i] = ITrend(Price2,MA2,MA_Period2,i); break;
         case 12: MA2[i] = Median(Price2,MA_Period2,i); break;
         case 13: MA2[i] = GeoMean(Price2,MA_Period2,i); break;
         case 14: MA2[i] = REMA(Price2[i],MA2,MA_Period2,0.5,i); break;
         case 15: MA2[i] = ILRS(Price2,MA_Period2,i); break;
         case 16: MA2[i] = IE2(Price2,MA_Period2,i); break;
         case 17: MA2[i] = TriMA_gen(Price2,MA_Period2,i); break;
         default: MA1[i] = SMA(Price2,MA_Period2,i); break;
      }
      ATR2[i] = iATR(NULL,0,ATR_Period2,i);
      TOP2[i] = MA2[i] + (ATR2[i]*Bands_Percent2);
      BOT2[i] = MA2[i] - (ATR2[i]*Bands_Percent2);
      
      switch(MA_Method3){
         case 1 : MA3[i] = SMA(Price3,MA_Period3,i); break;
         case 2 : MA3[i] = EMA(Price3[i],MA3[i+1],MA_Period3,i); break;
         case 3 : MA3[i] = Wilder(Price3[i],MA3[i+1],MA_Period3,i); break;  
         case 4 : MA3[i] = LWMA(Price3,MA_Period3,i); break;
         case 5 : MA3[i] = SineWMA(Price3,MA_Period3,i); break;
         case 6 : MA3[i] = TriMA(Price3,MA_Period3,i); break;
         case 7 : MA3[i] = LSMA(Price3,MA_Period3,i); break;
         case 8 : MA3[i] = SMMA(Price3,MA3[i+1],MA_Period3,i); break;
         case 9 : MA3[i] = HMA(Price3,MA_Period3,i); break;
         case 10: MA3[i] = ZeroLagEMA(Price3,MA3[i+1],MA_Period3,i); break;
         case 11: MA3[i] = ITrend(Price3,MA3,MA_Period3,i); break;
         case 12: MA3[i] = Median(Price3,MA_Period3,i); break;
         case 13: MA3[i] = GeoMean(Price3,MA_Period3,i); break;
         case 14: MA3[i] = REMA(Price3[i],MA3,MA_Period3,0.5,i); break;
         case 15: MA3[i] = ILRS(Price3,MA_Period3,i); break;
         case 16: MA3[i] = IE2(Price3,MA_Period3,i); break;
         case 17: MA3[i] = TriMA_gen(Price3,MA_Period3,i); break;
         default: MA1[i] = SMA(Price3,MA_Period3,i); break;
      }
      ATR3[i] = iATR(NULL,0,ATR_Period3,i);
      TOP3[i] = MA3[i] + (ATR3[i]*Bands_Percent3);
      BOT3[i] = MA3[i] - (ATR3[i]*Bands_Percent3);
      
   }  
   
//----
   return(0);
}
  
string TFToStr(int tf){
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return("");
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