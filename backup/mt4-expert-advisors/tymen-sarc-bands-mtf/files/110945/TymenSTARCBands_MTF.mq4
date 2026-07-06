//+------------------------------------------------------------------+
//|                                         Tymen_STARCBands_MTF.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 15

#property indicator_color1  clrLime
#property indicator_width1  1
#property indicator_color2  clrLime
#property indicator_width2  1
#property indicator_color3  clrLime
#property indicator_width3  1
#property indicator_color4  clrLime
#property indicator_width4  1
#property indicator_color5  clrLime
#property indicator_width5  1

#property indicator_color6  clrYellow
#property indicator_width6  1
#property indicator_color7  clrYellow
#property indicator_width7  1
#property indicator_color8  clrYellow
#property indicator_width8  1
#property indicator_color9  clrYellow
#property indicator_width9  1
#property indicator_color10  clrYellow
#property indicator_width10  1

#property indicator_color11  clrRed
#property indicator_width11  1
#property indicator_color12  clrRed
#property indicator_width12  1
#property indicator_color13  clrRed
#property indicator_width13  1
#property indicator_color14  clrRed
#property indicator_width14  1
#property indicator_color15  clrRed
#property indicator_width15  1

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

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern bool     Steps_Mode     = false;
extern bool     Show_Middle    = true;
extern string   Comment1       = "- TimeFrame 1 Parameters -";
input  e_cycles TimeFrame_1    = Min_15;
extern int      ATR_Period1    = 15;
extern int      MA_Period1     = 6;
extern e_method MA_Method1     = EMA;
extern e_price  MA_Price_Type1 = CLOSE;
extern double   KATR1          = 1;
extern double   MKATR1         = 0.7;
extern string   Comment2       = "- TimeFrame 2 Parameters -";
input  e_cycles TimeFrame_2    = Min_60;
extern int      ATR_Period2    = 15;
extern int      MA_Period2     = 6;
extern e_method MA_Method2     = EMA;
extern e_price  MA_Price_Type2 = CLOSE;
extern double   KATR2          = 1;
extern double   MKATR2         = 0.7;
extern string   Comment3       = "- TimeFrame 3 Parameters -";
input  e_cycles TimeFrame_3    = Min_240;
extern int      ATR_Period3    = 15;
extern int      MA_Period3     = 6;
extern e_method MA_Method3     = EMA;
extern e_price  MA_Price_Type3 = CLOSE;
extern double   KATR3          = 1;
extern double   MKATR3         = 0.7;

double Middle1[], Upper1[], Lower1[], MUpper1[], MLower1[];
double Middle2[], Upper2[], Lower2[], MUpper2[], MLower2[];
double Middle3[], Upper3[], Lower3[], MUpper3[], MLower3[];

double ATR1[], ATR2[], ATR3[];
double Price1[], Price2[], Price3[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Tymen STARC Bands MTF");
   IndicatorBuffers(21);
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
      
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   int Minutes3 = Get_TimeFrame(TimeFrame_3, true);
   
   int DrawBegin1 = (Minutes1/Period())*MA_Period1;
   int DrawBegin2 = (Minutes2/Period())*MA_Period2;
   int DrawBegin3 = (Minutes3/Period())*MA_Period3;
   
   if (Show_Middle) int MiddleLine = DRAW_SECTION; else MiddleLine = DRAW_NONE;
   
   // TimeFrame 1
   
   SetIndexStyle(0,MiddleLine);
   SetIndexBuffer(0,Middle1);
   SetIndexLabel(0,"Middle "+Minutes1+" mins");
   SetIndexDrawBegin(0,DrawBegin1);
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,Upper1);
   SetIndexLabel(1,"Upper "+Minutes1+" mins");
   SetIndexDrawBegin(1,DrawBegin1);
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,Lower1);
   SetIndexLabel(2,"Lower "+Minutes1+" mins");
   SetIndexDrawBegin(2,DrawBegin1);
   
   SetIndexStyle(3,DRAW_SECTION);
   SetIndexBuffer(3,MUpper1);
   SetIndexLabel(3,"MUpper "+Minutes1+" mins");
   SetIndexDrawBegin(3,DrawBegin1);
   
   SetIndexStyle(4,DRAW_SECTION);
   SetIndexBuffer(4,MLower1);
   SetIndexLabel(4,"MLower "+Minutes1+" mins");
   SetIndexDrawBegin(4,DrawBegin1);
   
   // TimeFrame 2
   
   SetIndexStyle(5,MiddleLine);
   SetIndexBuffer(5,Middle2);
   SetIndexLabel(5,"Middle "+Minutes2+" mins");
   SetIndexDrawBegin(5,DrawBegin2);
   
   SetIndexStyle(6,DRAW_SECTION);
   SetIndexBuffer(6,Upper2);
   SetIndexLabel(6,"Upper "+Minutes2+" mins");
   SetIndexDrawBegin(6,DrawBegin2);
   
   SetIndexStyle(7,DRAW_SECTION);
   SetIndexBuffer(7,Lower2);
   SetIndexLabel(7,"Lower "+Minutes2+" mins");
   SetIndexDrawBegin(7,DrawBegin2);
   
   SetIndexStyle(8,DRAW_SECTION);
   SetIndexBuffer(8,MUpper2);
   SetIndexLabel(8,"MUpper "+Minutes2+" mins");
   SetIndexDrawBegin(8,DrawBegin2);
   
   SetIndexStyle(9,DRAW_SECTION);
   SetIndexBuffer(9,MLower2);
   SetIndexLabel(9,"MLower "+Minutes2+" mins");
   SetIndexDrawBegin(9,DrawBegin2);
   
   // TimeFrame 3
   
   SetIndexStyle(10,MiddleLine);
   SetIndexBuffer(10,Middle3);
   SetIndexLabel(10,"Middle "+Minutes3+" mins");
   SetIndexDrawBegin(10,DrawBegin3);
   
   SetIndexStyle(11,DRAW_SECTION);
   SetIndexBuffer(11,Upper3);
   SetIndexLabel(11,"Upper "+Minutes3+" mins");
   SetIndexDrawBegin(11,DrawBegin3);
   
   SetIndexStyle(12,DRAW_SECTION);
   SetIndexBuffer(12,Lower3);
   SetIndexLabel(12,"Lower "+Minutes3+" mins");
   SetIndexDrawBegin(12,DrawBegin3);
   
   SetIndexStyle(13,DRAW_SECTION);
   SetIndexBuffer(13,MUpper3);
   SetIndexLabel(13,"MUpper "+Minutes3+" mins");
   SetIndexDrawBegin(13,DrawBegin3);
   
   SetIndexStyle(14,DRAW_SECTION);
   SetIndexBuffer(14,MLower3);
   SetIndexLabel(14,"MLower "+Minutes3+" mins");
   SetIndexDrawBegin(14,DrawBegin3);
   
   SetIndexBuffer(15,ATR1);
   SetIndexBuffer(16,ATR2);
   SetIndexBuffer(17,ATR3);
   
   SetIndexBuffer(18,Price1);
   SetIndexBuffer(19,Price2);
   SetIndexBuffer(20,Price3);
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
   
      // TimeFrame 1
      
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price1[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type1),i);
         
         switch(MA_Method1){
            case 1 : Middle1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
            case 2 : Middle1[current] = EMA(Price1[current],Middle1[current+(1*multiplier)],MA_Period1,current); break;
            case 3 : Middle1[current] = Wilder(Price1[current],Middle1[current+(1*multiplier)],MA_Period1,current); break;  
            case 4 : Middle1[current] = LWMA(Price1,MA_Period1,current, multiplier); break;
            case 5 : Middle1[current] = SineWMA(Price1,MA_Period1,current, multiplier); break;
            case 6 : Middle1[current] = TriMA(Price1,MA_Period1,current, multiplier); break;
            case 7 : Middle1[current] = LSMA(Price1,MA_Period1,current, multiplier); break;
            case 8 : Middle1[current] = SMMA(Price1,Middle1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 9 : Middle1[current] = HMA(Price1,MA_Period1,current, multiplier); break;
            case 10: Middle1[current] = ZeroLagEMA(Price1,Middle1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 11: Middle1[current] = ITrend(Price1,Middle1,MA_Period1,current, multiplier); break;
            case 12: Middle1[current] = Median(Price1,MA_Period1,current, multiplier); break;
            case 13: Middle1[current] = GeoMean(Price1,MA_Period1,current, multiplier); break;
            case 14: Middle1[current] = REMA(Price1[current],Middle1,MA_Period1,0.5,current, multiplier); break;
            case 15: Middle1[current] = ILRS(Price1,MA_Period1,current, multiplier); break;
            case 16: Middle1[current] = IE2(Price1,MA_Period1,current, multiplier); break;
            case 17: Middle1[current] = TriMA_gen(Price1,MA_Period1,current, multiplier); break;
            default: Middle1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
         }
         ATR1[current]    = iATR(NULL,period,ATR_Period1,i);
         Upper1[current]  = Middle1[current] + (ATR1[current]*KATR1);
         Lower1[current]  = Middle1[current] - (ATR1[current]*KATR1);
         MUpper1[current] = Middle1[current] + (ATR1[current]*MKATR1);
         MLower1[current] = Middle1[current] - (ATR1[current]*MKATR1);
         if (Steps_Mode){
            for (j=current; j>=next; j--){
               Middle1[j] = Middle1[current];
               Upper1[j]  = Upper1[current];
               Lower1[j]  = Lower1[current];
               MUpper1[j] = MUpper1[current];
               MLower1[j] = MLower1[current];
            }
         }else{
            if (i==0){
               Middle1[0] = Middle1[current];
               Upper1[0]  = Upper1[current];
               Lower1[0]  = Lower1[current];
               MUpper1[0] = MUpper1[current];
               MLower1[0] = MLower1[current];
            }
         }
         
      }
      
      // TimeFrame 2
      
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price2[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type2),i);
         
         switch(MA_Method2){
            case 1 : Middle2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
            case 2 : Middle2[current] = EMA(Price2[current],Middle2[current+(1*multiplier)],MA_Period2,current); break;
            case 3 : Middle2[current] = Wilder(Price2[current],Middle2[current+(1*multiplier)],MA_Period2,current); break;  
            case 4 : Middle2[current] = LWMA(Price2,MA_Period2,current, multiplier); break;
            case 5 : Middle2[current] = SineWMA(Price2,MA_Period2,current, multiplier); break;
            case 6 : Middle2[current] = TriMA(Price2,MA_Period2,current, multiplier); break;
            case 7 : Middle2[current] = LSMA(Price2,MA_Period2,current, multiplier); break;
            case 8 : Middle2[current] = SMMA(Price2,Middle2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 9 : Middle2[current] = HMA(Price2,MA_Period2,current, multiplier); break;
            case 10: Middle2[current] = ZeroLagEMA(Price2,Middle2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 11: Middle2[current] = ITrend(Price2,Middle2,MA_Period2,current, multiplier); break;
            case 12: Middle2[current] = Median(Price2,MA_Period2,current, multiplier); break;
            case 13: Middle2[current] = GeoMean(Price2,MA_Period2,current, multiplier); break;
            case 14: Middle2[current] = REMA(Price2[current],Middle2,MA_Period2,0.5,current, multiplier); break;
            case 15: Middle2[current] = ILRS(Price2,MA_Period2,current, multiplier); break;
            case 16: Middle2[current] = IE2(Price2,MA_Period2,current, multiplier); break;
            case 17: Middle2[current] = TriMA_gen(Price2,MA_Period2,current, multiplier); break;
            default: Middle2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
         }
         ATR2[current]    = iATR(NULL,period,ATR_Period2,i);
         Upper2[current]  = Middle2[current] + (ATR2[current]*KATR2);
         Lower2[current]  = Middle2[current] - (ATR2[current]*KATR2);
         MUpper2[current] = Middle2[current] + (ATR2[current]*MKATR2);
         MLower2[current] = Middle2[current] - (ATR2[current]*MKATR2);
         if (Steps_Mode){
            for (j=current; j>=next; j--){
               Middle2[j] = Middle2[current];
               Upper2[j]  = Upper2[current];
               Lower2[j]  = Lower2[current];
               MUpper2[j] = MUpper2[current];
               MLower2[j] = MLower2[current];
            }
         }else{
            if (i==0){
               Middle2[0] = Middle2[current];
               Upper2[0]  = Upper2[current];
               Lower2[0]  = Lower2[current];
               MUpper2[0] = MUpper2[current];
               MLower2[0] = MLower2[current];
            }
         }
         
      }
      
      // TimeFrame 3
      
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price3[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type3),i);
         
         switch(MA_Method3){
            case 1 : Middle3[current] = SMA(Price3,MA_Period3,current, multiplier); break;
            case 2 : Middle3[current] = EMA(Price3[current],Middle3[current+(1*multiplier)],MA_Period3,current); break;
            case 3 : Middle3[current] = Wilder(Price3[current],Middle3[current+(1*multiplier)],MA_Period3,current); break;  
            case 4 : Middle3[current] = LWMA(Price3,MA_Period3,current, multiplier); break;
            case 5 : Middle3[current] = SineWMA(Price3,MA_Period3,current, multiplier); break;
            case 6 : Middle3[current] = TriMA(Price3,MA_Period3,current, multiplier); break;
            case 7 : Middle3[current] = LSMA(Price3,MA_Period3,current, multiplier); break;
            case 8 : Middle3[current] = SMMA(Price3,Middle3[current+(1*multiplier)],MA_Period3,current, multiplier); break;
            case 9 : Middle3[current] = HMA(Price3,MA_Period3,current, multiplier); break;
            case 10: Middle3[current] = ZeroLagEMA(Price3,Middle3[current+(1*multiplier)],MA_Period3,current, multiplier); break;
            case 11: Middle3[current] = ITrend(Price3,Middle3,MA_Period3,current, multiplier); break;
            case 12: Middle3[current] = Median(Price3,MA_Period3,current, multiplier); break;
            case 13: Middle3[current] = GeoMean(Price3,MA_Period3,current, multiplier); break;
            case 14: Middle3[current] = REMA(Price3[current],Middle3,MA_Period3,0.5,current, multiplier); break;
            case 15: Middle3[current] = ILRS(Price3,MA_Period3,current, multiplier); break;
            case 16: Middle3[current] = IE2(Price3,MA_Period3,current, multiplier); break;
            case 17: Middle3[current] = TriMA_gen(Price3,MA_Period3,current, multiplier); break;
            default: Middle3[current] = SMA(Price3,MA_Period3,current, multiplier); break;
         }
         ATR3[current]    = iATR(NULL,period,ATR_Period3,i);
         Upper3[current]  = Middle3[current] + (ATR3[current]*KATR3);
         Lower3[current]  = Middle3[current] - (ATR3[current]*KATR3);
         MUpper3[current] = Middle3[current] + (ATR3[current]*MKATR3);
         MLower3[current] = Middle3[current] - (ATR3[current]*MKATR3);
         if (Steps_Mode){
            for (j=current; j>=next; j--){
               Middle3[j] = Middle3[current];
               Upper3[j]  = Upper3[current];
               Lower3[j]  = Lower3[current];
               MUpper3[j] = MUpper3[current];
               MLower3[j] = MLower3[current];
            }
         }else{
            if (i==0){
               Middle3[0] = Middle3[current];
               Upper3[0]  = Upper3[current];
               Lower3[0]  = Lower3[current];
               MUpper3[0] = MUpper3[current];
               MLower3[0] = MLower3[current];
            }
         }
         
      }
   
   } // if Check==false
   
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