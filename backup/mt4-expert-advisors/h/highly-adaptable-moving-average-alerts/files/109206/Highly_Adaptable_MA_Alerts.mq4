//+------------------------------------------------------------------+
//|                                   Highly_Adaptable_MA_Alerts.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "Alert will be given if HA trend changes occur outside TMA Line band"

#property indicator_buffers 6
#property indicator_chart_window
#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_style2 STYLE_DOT
#property indicator_color3 clrLime
#property indicator_width3 1
#property indicator_style3 STYLE_DOT
#property indicator_color4 clrYellow
#property indicator_width4 2
#property indicator_color5 clrRed
#property indicator_width5 2
#property indicator_color6 clrLime
#property indicator_width6 2

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
enum e_alert{ Touch=1, Cross=2 };
enum e_hit  { ALL=1, Mean=2, Top=3, Bottom=4, None=5 };

extern int      MA_Period     = 50;
extern e_method MA_Method     = EMA;
extern e_price  MA_Price_Type = CLOSE;
extern e_alert  Signal_Type   = Cross;
extern e_hit    Show_Alert    = ALL;
extern double   Bands_Percent = 0.618;
extern bool     Sound_Alert   = true;
extern bool     Email_Alert   = true;

double MA[];
double TOP[];
double BOT[];
double Signal_Mean[];
double Signal_Top[];
double Signal_Bottom[];
double Price[];

double tmp[][2];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Highly Adaptable Moving Average Alert");
   IndicatorBuffers(7);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TOP);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BOT);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,Signal_Mean);
   SetIndexArrow(3,174);
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexBuffer(4,Signal_Top);
   SetIndexArrow(4,234);
   
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexBuffer(5,Signal_Bottom);
   SetIndexArrow(5,233);
   
   SetIndexBuffer(6,Price);
   
   return(0);
  }

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for (i=limit; i>=0; i--) Price[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type),i);  
   
   for (i=limit; i>=0; i--){
      
      switch(MA_Method){
         case 1 : MA[i] = SMA(Price,MA_Period,i); break;
         case 2 : MA[i] = EMA(Price[i],MA[i+1],MA_Period,i); break;
         case 3 : MA[i] = Wilder(Price[i],MA[i+1],MA_Period,i); break;  
         case 4 : MA[i] = LWMA(Price,MA_Period,i); break;
         case 5 : MA[i] = SineWMA(Price,MA_Period,i); break;
         case 6 : MA[i] = TriMA(Price,MA_Period,i); break;
         case 7 : MA[i] = LSMA(Price,MA_Period,i); break;
         case 8 : MA[i] = SMMA(Price,MA[i+1],MA_Period,i); break;
         case 9 : MA[i] = HMA(Price,MA_Period,i); break;
         case 10: MA[i] = ZeroLagEMA(Price,MA[i+1],MA_Period,i); break;
         case 11: MA[i] = ITrend(Price,MA,MA_Period,i); break;
         case 12: MA[i] = Median(Price,MA_Period,i); break;
         case 13: MA[i] = GeoMean(Price,MA_Period,i); break;
         case 14: MA[i] = REMA(Price[i],MA,MA_Period,0.5,i); break;
         case 15: MA[i] = ILRS(Price,MA_Period,i); break;
         case 16: MA[i] = IE2(Price,MA_Period,i); break;
         case 17: MA[i] = TriMA_gen(Price,MA_Period,i); break;
         default: MA[i] = SMA(Price,MA_Period,i); break;
      }
      TOP[i] = MA[i]*(1+(Bands_Percent/100));
      BOT[i] = MA[i]*(1-(Bands_Percent/100));
      
   }
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for (i=limit; i>=0; i--){
      
      // Mean
      if ((Show_Alert==1 || Show_Alert==2) && ((Close[i+1]<MA[i+1]&&Close[i]>=MA[i]) || (Close[i+1]>MA[i+1]&&Close[i]<=MA[i]))){
         Signal_Mean[i] = MA[i];
         if (i==0 && Time[0] > LastAlert){
            if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average!");
            if (Email_Alert) SendMail("Moving Average Cross Signal", Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average Center Line.");
            LastAlert = TimeCurrent();
         }
      }
      
      // Top
      if ((Show_Alert==1 || Show_Alert==3) && Close[i+1]<TOP[i+1] && Close[i]>=TOP[i] ){
         Signal_Top[i] = High[i]+(20*pipSize);
         if (i==0 && Time[0] > LastAlert){
            if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average Top Band!");
            if (Email_Alert) SendMail("Moving Average Cross Signal", Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average Top Band.");
            LastAlert = TimeCurrent();
         }
      }
      
      // Bottom
      if ((Show_Alert==1 || Show_Alert==4) && Close[i+1]>BOT[i+1] && Close[i]<=BOT[i] ){
         Signal_Bottom[i] = Low[i]-(20*pipSize);
         if (i==0 && Time[0] > LastAlert){
            if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average Top Band!");
            if (Email_Alert) SendMail("Moving Average Cross Signal", Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average Top Band.");
            LastAlert = TimeCurrent();
         }
      }
      
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