//+------------------------------------------------------------------+
//|                                            Dynamic_Trend_MTF.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrLime
#property indicator_color3  clrLime
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_color5  clrRed
#property indicator_color6  clrRed
#property indicator_color7  clrBlue
#property indicator_width7  2
#property indicator_color8  clrBlue
#property indicator_color9  clrBlue

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

extern int      Max_Periods = 14;
extern int      Percent     = 1;
input  e_cycles TimeFrame_1 = Min_240;
input  e_cycles TimeFrame_2 = Daily;
input  e_cycles TimeFrame_3 = Weekly;

double Trend1[], Trend2[], Trend3[];
double Up1[], Up2[], Up3[];
double Dn1[], Dn2[], Dn3[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Dynamic Trend MTF");
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
      
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   int Minutes3 = Get_TimeFrame(TimeFrame_3, true);
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,Trend1);
   SetIndexLabel(0,"Dynamic Trend "+Minutes1+" mins");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,Up1);
   SetIndexArrow(1,233);
   SetIndexLabel(1,"Up "+Minutes1+" mins");
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,Dn1);
   SetIndexArrow(2,234);
   SetIndexLabel(2,"Down "+Minutes1+" mins");
   
   SetIndexStyle(3,DRAW_SECTION);
   SetIndexBuffer(3,Trend2);
   SetIndexLabel(3,"Dynamic Trend "+Minutes2+" mins");
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexBuffer(4,Up2);
   SetIndexArrow(4,233);
   SetIndexLabel(4,"Up "+Minutes2+" mins");
   
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexBuffer(5,Dn2);
   SetIndexArrow(5,234);
   SetIndexLabel(5,"Down "+Minutes2+" mins");
   
   SetIndexStyle(6,DRAW_SECTION);
   SetIndexBuffer(6,Trend3);
   SetIndexLabel(6,"Dynamic Trend "+Minutes3+" mins");
   
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexBuffer(7,Up3);
   SetIndexArrow(7,233);
   SetIndexLabel(7,"Up "+Minutes3+" mins");
   
   SetIndexStyle(8,DRAW_ARROW);
   SetIndexBuffer(8,Dn3);
   SetIndexArrow(8,234);
   SetIndexLabel(8,"Down "+Minutes3+" mins");
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double max, min;
   int period, multiplier;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
   
      // TF 1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         for (j=(i+Max_Periods-1); j>=i; j--){
            if (j==(i+Max_Periods-1)) max = min = iClose(NULL,period,j);
            else{
               if (iClose(NULL,period,j) > max) max = iClose(NULL,period,j);
               if (iClose(NULL,period,j) < min) min = iClose(NULL,period,j);
            }
         }
         // Dynamic Trend
         if (iClose(NULL,period,i) < Trend1[(i+1)*multiplier]) Trend1[i*multiplier] = max - (Percent*pipSize); else Trend1[i*multiplier] = min + (Percent*pipSize);
         // Arrows
         if (iClose(NULL,period,i+3) > Trend1[(i+2)*multiplier] && iClose(NULL,period,i+2) < Trend1[(i+3)*multiplier]) Up1[i*multiplier] = Low[i*multiplier] - 10*pipSize;
         if (iClose(NULL,period,i+2) < Trend1[(i+1)*multiplier] && iClose(NULL,period,i+2) > Trend1[(i+3)*multiplier]) Dn1[i*multiplier] = High[i*multiplier] + 10*pipSize;
      }
      
      // TF 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         for (j=(i+Max_Periods-1); j>=i; j--){
            if (j==(i+Max_Periods-1)) max = min = iClose(NULL,period,j);
            else{
               if (iClose(NULL,period,j) > max) max = iClose(NULL,period,j);
               if (iClose(NULL,period,j) < min) min = iClose(NULL,period,j);
            }
         }
         // Dynamic Trend
         if (iClose(NULL,period,i) < Trend2[(i+1)*multiplier]) Trend2[i*multiplier] = max - (Percent*pipSize); else Trend2[i*multiplier] = min + (Percent*pipSize);
         // Arrows
         if (iClose(NULL,period,i+3) > Trend2[(i+2)*multiplier] && iClose(NULL,period,i+2) < Trend2[(i+3)*multiplier]) Up2[i*multiplier] = Low[i*multiplier] - 10*pipSize;
         if (iClose(NULL,period,i+2) < Trend2[(i+1)*multiplier] && iClose(NULL,period,i+2) > Trend2[(i+3)*multiplier]) Dn2[i*multiplier] = High[i*multiplier] + 10*pipSize;
      }
      
      // TF 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         for (j=(i+Max_Periods-1); j>=i; j--){
            if (j==(i+Max_Periods-1)) max = min = iClose(NULL,period,j);
            else{
               if (iClose(NULL,period,j) > max) max = iClose(NULL,period,j);
               if (iClose(NULL,period,j) < min) min = iClose(NULL,period,j);
            }
         }
         // Dynamic Trend
         if (iClose(NULL,period,i) < Trend3[(i+1)*multiplier]) Trend3[i*multiplier] = max - (Percent*pipSize); else Trend3[i*multiplier] = min + (Percent*pipSize);
         // Arrows
         if (iClose(NULL,period,i+3) > Trend3[(i+2)*multiplier] && iClose(NULL,period,i+2) < Trend3[(i+3)*multiplier]) Up3[i*multiplier] = Low[i*multiplier] - 10*pipSize;
         if (iClose(NULL,period,i+2) < Trend3[(i+1)*multiplier] && iClose(NULL,period,i+2) > Trend3[(i+3)*multiplier]) Dn3[i*multiplier] = High[i*multiplier] + 10*pipSize;
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