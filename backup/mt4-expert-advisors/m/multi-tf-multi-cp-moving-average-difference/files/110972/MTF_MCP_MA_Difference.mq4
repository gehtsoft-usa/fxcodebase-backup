//+------------------------------------------------------------------+
//|                                        MTF_MCP_MA_Difference.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1  clrLime
#property indicator_width1  1
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_levelcolor clrYellow

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

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
             
enum e_method2{ Method_SMA = 1, Method_EMA = 2, Method_SMMA = 3, Method_LWMA = 4 };

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern bool      Normalize_Pips = true;
extern string    Comment1       = "- TimeFrame 1 Parameters -";
extern string    Currency_Pair1 = "USDJPY";
input  e_cycles  TimeFrame_1    = Min_60;
extern int       MA_Period1     = 50;
extern e_method  MA_Method1     = EMA;
extern e_price   MA_Price_Type1 = CLOSE;
extern string    Comment2       = "- TimeFrame 2 Parameters -";
extern string    Currency_Pair2 = "EURUSD";
input  e_cycles  TimeFrame_2    = Min_240;
extern int       MA_Period2     = 50;
extern e_method  MA_Method2     = EMA;
extern e_price   MA_Price_Type2 = CLOSE;
extern string    Comment3       = "- Signal Parameters -";
extern int       Signal_Period  = 20;
extern e_method2 Signal_Method  = Method_EMA;

double Diff[];
double Signal[];

double MA1[];
double MA2[];
double Price1[];
double Price2[];

//+****************************************************************+

int init(){
   
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   
   if (Minutes1 > Minutes2) int m = Minutes1/Period(); else m = Minutes2/Period();
   if (MA_Period1 > MA_Period2) int DrawBegin = m*MA_Period1; else DrawBegin = m*MA_Period2;
   
   IndicatorShortName("Multi TF Multi CP MA Difference "+Currency_Pair1+" ("+Minutes1+" mins) - "+Currency_Pair2+" ("+Minutes2+" mins)");
   
   IndicatorBuffers(6);
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,Diff);
   SetIndexLabel(0,"Difference");
   SetIndexDrawBegin(0,DrawBegin);
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,Signal);
   SetIndexLabel(1,"Signal");
   SetIndexDrawBegin(1,DrawBegin);
   
   SetIndexBuffer(2,MA1);
   SetIndexBuffer(3,MA2);
   
   SetIndexBuffer(4,Price1);
   SetIndexBuffer(5,Price2);
   
   SetLevelValue(0,0);
   SetLevelStyle(STYLE_DOT,0);
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false ){
   
      // TimeFrame 1
      
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
        
         current = iBarShift(Currency_Pair1,0,iTime(Currency_Pair1,period,i));
         if (i>0) next = iBarShift(Currency_Pair1,0,iTime(Currency_Pair1,period,i-1)); else next = 0;
         
         Price1[current] = iMA(Currency_Pair1,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type1),i);
         
         switch(MA_Method1){
            case 1 : MA1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
            case 2 : MA1[current] = EMA(Price1[current],MA1[current+(1*multiplier)],MA_Period1,current); break;
            case 3 : MA1[current] = Wilder(Price1[current],MA1[current+(1*multiplier)],MA_Period1,current); break;  
            case 4 : MA1[current] = LWMA(Price1,MA_Period1,current, multiplier); break;
            case 5 : MA1[current] = SineWMA(Price1,MA_Period1,current, multiplier); break;
            case 6 : MA1[current] = TriMA(Price1,MA_Period1,current, multiplier); break;
            case 7 : MA1[current] = LSMA(Price1,MA_Period1,current, multiplier); break;
            case 8 : MA1[current] = SMMA(Price1,MA1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 9 : MA1[current] = HMA(Price1,MA_Period1,current, multiplier); break;
            case 10: MA1[current] = ZeroLagEMA(Price1,MA1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 11: MA1[current] = ITrend(Price1,MA1,MA_Period1,current, multiplier); break;
            case 12: MA1[current] = Median(Price1,MA_Period1,current, multiplier); break;
            case 13: MA1[current] = GeoMean(Price1,MA_Period1,current, multiplier); break;
            case 14: MA1[current] = REMA(Price1[current],MA1,MA_Period1,0.5,current, multiplier); break;
            case 15: MA1[current] = ILRS(Price1,MA_Period1,current, multiplier); break;
            case 16: MA1[current] = IE2(Price1,MA_Period1,current, multiplier); break;
            case 17: MA1[current] = TriMA_gen(Price1,MA_Period1,current, multiplier); break;
            default: MA1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
         }
         for (j=current; j>=next; j--){
            MA1[j] = MA1[current];
         }
         
      }
      
      // TimeFrame 2
      
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(Currency_Pair2,0,iTime(Currency_Pair2,period,i));
         if (i>0) next = iBarShift(Currency_Pair2,0,iTime(Currency_Pair2,period,i-1)); else next = 0;
         
         Price2[current] = iMA(Currency_Pair2,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type2),i);
         
         switch(MA_Method2){
            case 1 : MA2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
            case 2 : MA2[current] = EMA(Price2[current],MA2[current+(1*multiplier)],MA_Period2,current); break;
            case 3 : MA2[current] = Wilder(Price2[current],MA2[current+(1*multiplier)],MA_Period2,current); break;  
            case 4 : MA2[current] = LWMA(Price2,MA_Period2,current, multiplier); break;
            case 5 : MA2[current] = SineWMA(Price2,MA_Period2,current, multiplier); break;
            case 6 : MA2[current] = TriMA(Price2,MA_Period2,current, multiplier); break;
            case 7 : MA2[current] = LSMA(Price2,MA_Period2,current, multiplier); break;
            case 8 : MA2[current] = SMMA(Price2,MA2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 9 : MA2[current] = HMA(Price2,MA_Period2,current, multiplier); break;
            case 10: MA2[current] = ZeroLagEMA(Price2,MA2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 11: MA2[current] = ITrend(Price2,MA2,MA_Period2,current, multiplier); break;
            case 12: MA2[current] = Median(Price2,MA_Period2,current, multiplier); break;
            case 13: MA2[current] = GeoMean(Price2,MA_Period2,current, multiplier); break;
            case 14: MA2[current] = REMA(Price2[current],MA2,MA_Period2,0.5,current, multiplier); break;
            case 15: MA2[current] = ILRS(Price2,MA_Period2,current, multiplier); break;
            case 16: MA2[current] = IE2(Price2,MA_Period2,current, multiplier); break;
            case 17: MA2[current] = TriMA_gen(Price2,MA_Period2,current, multiplier); break;
            default: MA2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
         }
         for (j=current; j>=next; j--){
            MA2[j] = MA2[current];
         }
         
      }
      
      for (i=limit; i>=0; i--){
      
         if (Normalize_Pips){
         
            Diff[i] = ( (pow(10,MarketInfo(Currency_Pair1,MODE_DIGITS)-1)*(MA1[i]-MA1[i+(1*Get_TimeFrame(TimeFrame_1, true)/Period())])) - (pow(10,MarketInfo(Currency_Pair2,MODE_DIGITS)-1)*(MA2[i]-MA2[i+(1*Get_TimeFrame(TimeFrame_2, true)/Period())])) );
         
         }else{

            Diff[i] = MA1[i] - MA2[i];

         }
         
         Signal[i] = iMAOnArray(Diff,WHOLE_ARRAY,Signal_Period,0,ENUM_MA_METHOD(Signal_Method),i);
      
      }
   
   } // if Check==false
   
   Comment("");
   
   return(0);
   
  }
  
bool Check (int BTF){
   
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<1) wrong_tf = true;
   if (Period()==15    && BTF<2) wrong_tf = true;
   if (Period()==30    && BTF<3) wrong_tf = true;
   if (Period()==60    && BTF<4) wrong_tf = true;
   if (Period()==240   && BTF<5) wrong_tf = true;
   if (Period()==1440  && BTF<6) wrong_tf = true;
   if (Period()==10080 && BTF<7) wrong_tf = true;
   if (Period()==43200)          wrong_tf = true;
   
   return(wrong_tf);
   
}

int Get_TimeFrame(int BTF, bool mins = false){
   int Periodo, Minutes;
   if (BTF==1){ Periodo = PERIOD_M5;  Minutes = 5;     }
   if (BTF==2){ Periodo = PERIOD_M15; Minutes = 15;    }
   if (BTF==3){ Periodo = PERIOD_M30; Minutes = 30;    }
   if (BTF==4){ Periodo = PERIOD_H1;  Minutes = 60;    }
   if (BTF==5){ Periodo = PERIOD_H4;  Minutes = 240;   }
   if (BTF==6){ Periodo = PERIOD_D1;  Minutes = 1440;  }
   if (BTF==7){ Periodo = PERIOD_W1;  Minutes = 10080; }
   if (BTF==8){ Periodo = PERIOD_MN1; Minutes = 43200; }
   if (mins) return(Minutes); else return(Periodo);
}

double SMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+(i*mult)];
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

double LWMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+(i*mult)]*(per - i);
   }
   if(Weight>0)
      double lwma = Sum/Weight;
   else
      lwma = 0; 
   return(lwma);
} 

double SineWMA(double &array[],int per,int bar, int mult=1){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+(i*mult)]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      double swma = Sum/Weight;
   else
      swma = 0; 
   return(swma);
}

double TriMA(double &array[],int per,int bar, int mult=1){
   double sma;
   int len = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+(i*mult),mult);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar, int mult=1){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+((per-i)*mult)];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar, int mult=1){
   if(bar == Bars - per)
      double smma = SMA(array,per,bar, mult);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) Sum += array[bar+((i+1)*mult)];
      smma = (Sum - prev + array[bar])/per;
   }
   return(smma);
}                

double HMA(double &array[],int per,int bar, int mult=1){
   double tmp1[];
   int len = MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      double hma = array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+(i*mult),mult) - LWMA(array,per,bar+(i*mult),mult);  
      hma = LWMA(tmp1,len,0); 
   }  
   return(hma);
}

double ZeroLagEMA(double &price[],double prev,int per,int bar, int mult=1){
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   if(bar >= Bars - lag)
      double zema = price[bar];
   else 
      zema = alfa*(2*price[bar] - price[bar+(lag*mult)]) + (1-alfa)*prev;
   return(zema);
}

double ITrend(double &price[],double &array[],int per,int bar, int mult=1){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+(1*mult)] - (alfa - 0.75*alfa*alfa)*price[bar+(2*mult)] + 2*(1-alfa)*array[bar+(1*mult)] - (1-alfa)*(1-alfa)*array[bar+(2*mult)];
   else
      it = (price[bar] + 2*price[bar+(1*mult)] + price[bar+(2*mult)])/4;
   return(it);
}

double Median(double &price[],int per,int bar, int mult=1){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+(i*mult)];
   ArraySort(array);
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
   return(median); 
}

double GeoMean(double &price[],int per,int bar, int mult=1){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+(i*mult)],1.0/per); 
   }   
   return(gmean);
}

double REMA(double price,double &array[],int per,double lambda,int bar, int mult=1){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      double rema = price;
   else 
      rema = (array[bar+(1*mult)]*(1+2*lambda) + alpha*(price - array[bar+(1*mult)]) - lambda*array[bar+(2*mult)])/(1+lambda);    
   return(rema);
}

double ILRS(double &price[],int per,int bar, int mult=1){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+(i*mult)];
      sumy += price[bar+(i*mult)];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar,mult);
   return(ilrs);
}

double IE2(double &price[],int per,int bar, int mult=1){
   double ie = 0.5*(ILRS(price,per,bar,mult) + LSMA(price,per,bar,mult));
   return(ie); 
}
 

double TriMA_gen(double &array[],int per,int bar, int mult=1){
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+(i*mult),mult);
   double trimagen = sum/len2;
   return(trimagen);
}