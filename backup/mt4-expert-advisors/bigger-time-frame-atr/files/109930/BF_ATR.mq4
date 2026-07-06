//+------------------------------------------------------------------+
//|                                                       BF_ATR.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_color3  clrBlue
#property indicator_width3  2

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

extern int      ATR_Periods = 14;
input  e_cycles TimeFrame_1 = Min_240;
input  e_cycles TimeFrame_2 = Daily;
input  e_cycles TimeFrame_3 = Weekly;

double ATR1[], ATR2[], ATR3[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Bigger Time Frame ATR");
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
      
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   int Minutes3 = Get_TimeFrame(TimeFrame_3, true);
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ATR1);
   SetIndexLabel(0,"Dynamic Trend "+Minutes1+" mins");
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,ATR2);
   SetIndexLabel(1,"Dynamic Trend "+Minutes2+" mins");
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,ATR3);
   SetIndexLabel(2,"Dynamic Trend "+Minutes3+" mins");
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier;
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
   
      // TF 1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         ATR1[i*multiplier] = iATR(NULL,period,ATR_Periods,i);
      }
      
      // TF 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         ATR2[i*multiplier] = iATR(NULL,period,ATR_Periods,i);
      }
      
      // TF 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         ATR3[i*multiplier] = iATR(NULL,period,ATR_Periods,i);
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