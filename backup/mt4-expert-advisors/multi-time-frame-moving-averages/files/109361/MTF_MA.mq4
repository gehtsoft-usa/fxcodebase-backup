//+------------------------------------------------------------------+
//|                                                       MTF_MA.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  clrOliveDrab
#property indicator_width1  3

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };
enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

input  e_cycles TimeFrame      = Min_240;
input  e_method Moving_Average = EMA;
input  e_price  Price_Type     = CLOSE;
extern int      MA_Periods     = 14;
extern bool     Steps_Mode     = false;

double MA[];

//+****************************************************************+

int init(){
   
   int Minutes = Get_TimeFrame(TimeFrame, true);
   
   string Metodo;
   switch(Moving_Average){ case 0: Metodo="SMA"; break; case 1: Metodo="EMA"; break; case 2: Metodo="SMMA"; break; case 3: Metodo="LWMA"; break; }
   
   IndicatorShortName("MTF "+Metodo+" "+Minutes+" mins");
   
   if (Check(TimeFrame)) Alert("The Bigger TF Source selected should be greater or equal than the current one");
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,MA);
   SetIndexLabel(0,"MTF "+Metodo+" "+Minutes+" mins");
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Check(TimeFrame)==false){
   
      period     = Get_TimeFrame(TimeFrame);
      multiplier = Get_TimeFrame(TimeFrame, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         MA[current] = iMA(NULL ,period, MA_Periods, 0, ENUM_MA_METHOD(Moving_Average), ENUM_APPLIED_PRICE(Price_Type), i);
         if (Steps_Mode) for (j=current; j>=next; j--) MA[j] = MA[current];

      }
   
   } // if Check==false
   
   return(0);
   
  }
  
bool Check (int BTF){
   
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<2) wrong_tf = true;
   if (Period()==15    && BTF<3) wrong_tf = true;
   if (Period()==30    && BTF<4) wrong_tf = true;
   if (Period()==60    && BTF<5) wrong_tf = true;
   if (Period()==240   && BTF<6) wrong_tf = true;
   if (Period()==1440  && BTF<7) wrong_tf = true;
   if (Period()==10080 && BTF<8) wrong_tf = true;
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