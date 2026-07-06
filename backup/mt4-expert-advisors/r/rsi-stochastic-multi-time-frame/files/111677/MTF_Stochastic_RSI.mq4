//+------------------------------------------------------------------+
//|                                           MTF_Stochastic_RSI.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 6
#property indicator_separate_window
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrLime
#property indicator_width2 1
#property indicator_style2 STYLE_DOT
#property indicator_color2 clrLime
#property indicator_width3 2
#property indicator_style3 STYLE_SOLID
#property indicator_color3 clrRed
#property indicator_width4 1
#property indicator_style4 STYLE_DOT
#property indicator_color4 clrRed
#property indicator_width5 2
#property indicator_style5 STYLE_SOLID
#property indicator_color5 clrDodgerBlue
#property indicator_width6 1
#property indicator_style6 STYLE_DOT
#property indicator_color6 clrDodgerBlue
#property indicator_levelwidth 1
#property indicator_levelcolor clrYellow
#property indicator_levelstyle STYLE_DOT

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

input  e_cycles TimeFrame_1 = Min_15;
input  e_cycles TimeFrame_2 = Min_60;
input  e_cycles TimeFrame_3 = Min_240;
extern int      RSI_Periods = 14;
extern int      K_period    = 14;
extern int      D_period    = 3;
extern int      Slowing     = 5;
extern int      OB_Level    = 80;
extern int      OS_Level    = 20;

double SK1[];
double SK1_array[];
double SD1[];
double RSI1[];
double SKI1[];

double SK2[];
double SK2_array[];
double SD2[];
double RSI2[];
double SKI2[];

double SK3[];
double SK3_array[];
double SD3[];
double RSI3[];
double SKI3[];

int init(){
   
   IndicatorShortName("MTF Stochastic RSI");
   IndicatorBuffers(15);
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,SK1);
   SetIndexLabel(0,"SK1");
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,SD1);
   SetIndexLabel(1,"SD1");
  
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,SK2);
   SetIndexLabel(2,"SK2");
   SetIndexStyle(3,DRAW_SECTION);
   SetIndexBuffer(3,SD2);
   SetIndexLabel(3,"SD2");
   
   SetIndexStyle(4,DRAW_SECTION);
   SetIndexBuffer(4,SK3);
   SetIndexLabel(4,"SK3");
   SetIndexStyle(5,DRAW_SECTION);
   SetIndexBuffer(5,SD3);
   SetIndexLabel(5,"SD3");
   
   for (int k=0; k<6; k++){
      SetIndexDrawBegin(k,K_period+1);
   }
   
   SetIndexBuffer(6,SK1_array);
   SetIndexBuffer(7,RSI1);
   SetIndexBuffer(8,SKI1);
   
   SetIndexBuffer(9,SK2_array);
   SetIndexBuffer(10,RSI2);
   SetIndexBuffer(11,SKI2);
   
   SetIndexBuffer(12,SK3_array);
   SetIndexBuffer(13,RSI3);
   SetIndexBuffer(14,SKI3);
   
   SetLevelValue(0,OB_Level);
   SetLevelValue(1,OS_Level);
   SetLevelValue(2,50);
   
   return(0);
}

int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
   
      double max, min;
      
      // TimeFrame 1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         
         RSI1[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI1[j];
            else{
               if (RSI1[j]>max) max = RSI1[j];
               if (RSI1[j]<min) min = RSI1[j];
            }
         }
         
         if (min==max){
         
            SKI1[i] = 100;
         
         }else{
         
            SKI1[i] = (RSI1[i] - min) / (max - min) * 100;
            
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SK1[current] = SK1_array[i] = iMAOnArray(SKI1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         
         for (j=current; j>=next; j--){
            SK1[j]  = SK1[current];
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SD1[current] = iMAOnArray(SK1_array,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--){
            SD1[j]  = SD1[current];
         }
         
      }
      
      // TimeFrame 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         
         RSI2[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI2[j];
            else{
               if (RSI2[j]>max) max = RSI2[j];
               if (RSI2[j]<min) min = RSI2[j];
            }
         }
         
         if (min==max){
         
            SKI2[i] = 100;
         
         }else{
         
            SKI2[i] = (RSI2[i] - min) / (max - min) * 100;
            
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SK2[current] = SK2_array[i] = iMAOnArray(SKI2,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         
         for (j=current; j>=next; j--){
            SK2[j]  = SK2[current];
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SD2[current] = iMAOnArray(SK2_array,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--){
            SD2[j]  = SD2[current];
         }
         
      }
      
      // TimeFrame 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         
         RSI3[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI3[j];
            else{
               if (RSI3[j]>max) max = RSI3[j];
               if (RSI3[j]<min) min = RSI3[j];
            }
         }
         
         if (min==max){
         
            SKI3[i] = 100;
         
         }else{
         
            SKI3[i] = (RSI3[i] - min) / (max - min) * 100;
            
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SK3[current] = SK3_array[i] = iMAOnArray(SKI3,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         
         for (j=current; j>=next; j--){
            SK3[j]  = SK3[current];
         }
         
      }
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         SD3[current] = iMAOnArray(SK3_array,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--){
            SD3[j]  = SD3[current];
         }
         
      }
      
   }
   
//----
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