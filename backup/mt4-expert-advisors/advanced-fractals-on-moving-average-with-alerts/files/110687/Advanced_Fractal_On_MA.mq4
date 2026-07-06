//+------------------------------------------------------------------+
//|                                       Advanced_Fractal_On_MA.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "This version of fractals searches maximums and minimums MA using extended variant of MA"

#property indicator_buffers 2
#property indicator_chart_window
#property indicator_color1 clrLime
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1

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

extern e_method MA_Method = SMA;
extern int      MA_Period = 20;
extern int      Fractals  = 5;
extern e_price  Up_Price  = HIGH;
extern e_price  Dn_Price  = LOW;
extern bool     Sound_Alert   = true;
extern bool     Email_Alert   = true;

double Fl_Up[];
double Fl_Dn[];

double MA_Up[];
double MA_Dn[];
double Price_Up[];
double Price_Dn[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Advanced Fractals on MA");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexBuffer(0,Fl_Up);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexBuffer(1,Fl_Dn);
   
   SetIndexBuffer(2,MA_Up);
   SetIndexBuffer(3,MA_Dn);
   SetIndexBuffer(4,Price_Up);
   SetIndexBuffer(5,Price_Dn);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for (i=limit; i>=0; i--){
      
      Price_Up[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(Up_Price),i);  
      Price_Dn[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(Dn_Price),i);  
      
   }
   
   for (i=limit; i>=0; i--){
      
      switch(MA_Method){
         case 1 :
            MA_Up[i] = SMA(Price_Up,MA_Period,i);
            MA_Dn[i] = SMA(Price_Dn,MA_Period,i);
            break;
         case 2 :
            MA_Up[i] = EMA(Price_Up[i],MA_Up[i+1],MA_Period,i);
            MA_Dn[i] = EMA(Price_Dn[i],MA_Dn[i+1],MA_Period,i);
            break;
         case 3 :
            MA_Up[i] = Wilder(Price_Up[i],MA_Up[i+1],MA_Period,i);
            MA_Dn[i] = Wilder(Price_Dn[i],MA_Dn[i+1],MA_Period,i);
            break;  
         case 4 :
            MA_Up[i] = LWMA(Price_Up,MA_Period,i);
            MA_Dn[i] = LWMA(Price_Dn,MA_Period,i);
            break;
         case 5 :
            MA_Up[i] = SineWMA(Price_Up,MA_Period,i);
            MA_Dn[i] = SineWMA(Price_Dn,MA_Period,i);
            break;
         case 6 :
            MA_Up[i] = TriMA(Price_Up,MA_Period,i);
            MA_Dn[i] = TriMA(Price_Dn,MA_Period,i);
            break;
         case 7 :
            MA_Up[i] = LSMA(Price_Up,MA_Period,i);
            MA_Dn[i] = LSMA(Price_Dn,MA_Period,i);
            break;
         case 8 :
            MA_Up[i] = SMMA(Price_Up,MA_Up[i+1],MA_Period,i);
            MA_Dn[i] = SMMA(Price_Dn,MA_Dn[i+1],MA_Period,i);
            break;
         case 9 :
            MA_Up[i] = HMA(Price_Up,MA_Period,i);
            MA_Dn[i] = HMA(Price_Dn,MA_Period,i);
            break;
         case 10:
            MA_Up[i] = ZeroLagEMA(Price_Up,MA_Up[i+1],MA_Period,i);
            MA_Dn[i] = ZeroLagEMA(Price_Dn,MA_Dn[i+1],MA_Period,i);
            break;
         case 11:
            MA_Up[i] = ITrend(Price_Up,MA_Up,MA_Period,i);
            MA_Dn[i] = ITrend(Price_Dn,MA_Dn,MA_Period,i);
            break;
         case 12:
            MA_Up[i] = Median(Price_Up,MA_Period,i);
            MA_Dn[i] = Median(Price_Dn,MA_Period,i);
            break;
         case 13:
            MA_Up[i] = GeoMean(Price_Up,MA_Period,i);
            MA_Dn[i] = GeoMean(Price_Dn,MA_Period,i);
            break;
         case 14:
            MA_Up[i] = REMA(Price_Up[i],MA_Up,MA_Period,0.5,i);
            MA_Dn[i] = REMA(Price_Dn[i],MA_Dn,MA_Period,0.5,i);
            break;
         case 15:
            MA_Up[i] = ILRS(Price_Up,MA_Period,i);
            MA_Dn[i] = ILRS(Price_Dn,MA_Period,i);
            break;
         case 16:
            MA_Up[i] = IE2(Price_Up,MA_Period,i);
            MA_Dn[i] = IE2(Price_Dn,MA_Period,i);
            break;
         case 17:
            MA_Up[i] = TriMA_gen(Price_Up,MA_Period,i);
            MA_Dn[i] = TriMA_gen(Price_Dn,MA_Period,i);
            break;
         default:
            MA_Up[i] = SMA(Price_Up,MA_Period,i);
            MA_Dn[i] = SMA(Price_Dn,MA_Period,i);
            break;
      }
      
   }
   
   bool fractal_up, fractal_dn;
   string Alert_Text;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for (i=limit; i>=0; i--){
      
      fractal_up = true;
      fractal_dn = true;
      
      for (j=1; j<MathFloor((Fractals-1)/2); j++){
         
         if (MA_Dn[i+j] <= MA_Dn[i] || MA_Dn[i-j] <= MA_Dn[i]) fractal_dn = false;
         if (MA_Up[i+j] >= MA_Up[i] || MA_Up[i-j] >= MA_Up[i]) fractal_up = false;
         
      }
      
      if (fractal_dn){
         Fl_Dn[i] = Low[i]  - 3*pipSize;
         Alert_Text = "Down";
      }
      
      if (fractal_up){
         Fl_Up[i] = High[i] + 3*pipSize;
         Alert_Text = "Up";
      }
      
      if (i==0 && Time[0] > LastAlert && (fractal_dn || fractal_up)){
         if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": New Advanced "+Alert_Text+" Fractal!");
         if (Email_Alert) SendMail("Advanced Fractal Signal", Symbol() + "," + TFToStr(Period()) + ": New Advanced "+Alert_Text+" Fractal!");
         LastAlert = TimeCurrent();
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