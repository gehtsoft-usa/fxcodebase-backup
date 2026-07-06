// Id: 20454
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65679

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_color3  clrBlue
#property indicator_width3  2
#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

extern int      Smooth1  = 7;
extern int      Smooth2 = 14;
input  e_cycles TimeFrame_1 = Min_60;
input  e_cycles TimeFrame_2 = Min_240;
input  e_cycles TimeFrame_3 = Daily;

double TSI1[], TSI2[], TSI3[];
double tsi1[], tsi2[], tsi3[];

//+****************************************************************+

int init(){
   
       double temp = iCustom(NULL, 0, "TSI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TSI' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("MTF TSI");
   IndicatorBuffers(6);
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
      
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   int Minutes3 = Get_TimeFrame(TimeFrame_3, true);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TSI1);
   SetIndexLabel(0,"TSI "+Minutes1+" mins");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TSI2);
   SetIndexLabel(1,"TSI "+Minutes2+" mins");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,TSI3);
   SetIndexLabel(2,"TSI "+Minutes3+" mins");
   
   SetIndexBuffer(3,tsi1);
   SetIndexBuffer(4,tsi2);
   SetIndexBuffer(5,tsi3);
   
   SetLevelValue(0,0);
   
   return(0);
  
}
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
   
      // TF 1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         tsi1[current] = iCustom(NULL,period,"TSI",Smooth1,Smooth2,0,i);
         for (j=current; j>=next; j--){
            TSI1[j] = tsi1[current];
         }
      }
      
      // TF 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         tsi2[current] = iCustom(NULL,period,"TSI",Smooth1,Smooth2,0,i);
         for (j=current; j>=next; j--){
            TSI2[j] = tsi2[current];
         }
      }
      
      // TF 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         tsi3[current] = iCustom(NULL,period,"TSI",Smooth1,Smooth2,0,i);
         for (j=current; j>=next; j--){
            TSI3[j] = tsi3[current];
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