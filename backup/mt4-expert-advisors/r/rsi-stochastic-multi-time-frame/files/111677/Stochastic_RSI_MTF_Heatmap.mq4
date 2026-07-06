// Id: 17869
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

#property indicator_separate_window
#property  indicator_buffers 21
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrDarkGray
#property indicator_color4  clrLime
#property indicator_color5  clrRed
#property indicator_color6  clrDarkGray
#property indicator_color7  clrLime
#property indicator_color8  clrRed
#property indicator_color9  clrDarkGray
#property indicator_color10 clrLime
#property indicator_color11 clrRed
#property indicator_color12 clrDarkGray
#property indicator_color13 clrLime
#property indicator_color14 clrRed
#property indicator_color15 clrDarkGray
#property indicator_color16 clrLime
#property indicator_color17 clrRed
#property indicator_color18 clrDarkGray
#property indicator_color19 clrLime
#property indicator_color20 clrRed
#property indicator_color21 clrDarkGray
#property indicator_minimum 0
#property indicator_maximum 5

enum metodo{ K_and_D=1, Middle_Line=2, OBOS=3, Slope=4 };

input  metodo Compare_Method = OBOS;
extern int    RSI_Periods    = 14;
extern int    K_period       = 14;
extern int    D_period       = 3;
extern int    Slowing        = 5;
extern int    OB_Level       = 80;
extern int    OS_Level       = 20;

double w1_up[];
double w1_dn[];
double w1_nt[];
double d1_up[];
double d1_dn[];
double d1_nt[];
double h4_up[];
double h4_dn[];
double h4_nt[];
double h1_up[];
double h1_dn[];
double h1_nt[];
double m30_up[];
double m30_dn[];
double m30_nt[];
double m15_up[];
double m15_dn[];
double m15_nt[];
double m5_up[];
double m5_dn[];
double m5_nt[];

double SK_w1[];
double SK_array_w1[];
double SD_w1[];
double RSI_w1[];
double SKI_w1[];

double SK_d1[];
double SK_array_d1[];
double SD_d1[];
double RSI_d1[];
double SKI_d1[];

double SK_h4[];
double SK_array_h4[];
double SD_h4[];
double RSI_h4[];
double SKI_h4[];

double SK_h1[];
double SK_array_h1[];
double SD_h1[];
double RSI_h1[];
double SKI_h1[];

double SK_m30[];
double SK_array_m30[];
double SD_m30[];
double RSI_m30[];
double SKI_m30[];

double SK_m15[];
double SK_array_m15[];
double SD_m15[];
double RSI_m15[];
double SKI_m15[];

double SK_m5[];
double SK_array_m5[];
double SD_m5[];
double RSI_m5[];
double SKI_m5[];

string IndName;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


int init(){
   
   IndicatorBuffers(56);
   
   SetIndexBuffer(0,w1_up);
   SetIndexBuffer(1,w1_dn);
   SetIndexBuffer(2,w1_nt);
   SetIndexBuffer(3,d1_up);
   SetIndexBuffer(4,d1_dn);
   SetIndexBuffer(5,d1_nt);
   SetIndexBuffer(6,h4_up);
   SetIndexBuffer(7,h4_dn);
   SetIndexBuffer(8,h4_nt);
   SetIndexBuffer(9,h1_up);
   SetIndexBuffer(10,h1_dn);
   SetIndexBuffer(11,h1_nt);
   SetIndexBuffer(12,m30_up);
   SetIndexBuffer(13,m30_dn);
   SetIndexBuffer(14,m30_nt);
   SetIndexBuffer(15,m15_up);
   SetIndexBuffer(16,m15_dn);
   SetIndexBuffer(17,m15_nt);
   SetIndexBuffer(18,m5_up);
   SetIndexBuffer(19,m5_dn);
   SetIndexBuffer(20,m5_nt);
   
   int arrow = 110;
   for (int i = 0; i < 21; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndName = "Stochastic RSI MTF Heatmap";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndName = IndicatorName;
   
   SetIndexBuffer(21,SK_w1);
   SetIndexBuffer(22,SD_w1);
   SetIndexBuffer(23,SK_array_w1);
   SetIndexBuffer(24,RSI_w1);
   SetIndexBuffer(25,SKI_w1);
   
   SetIndexBuffer(26,SK_d1);
   SetIndexBuffer(27,SD_d1);
   SetIndexBuffer(28,SK_array_d1);
   SetIndexBuffer(29,RSI_d1);
   SetIndexBuffer(30,SKI_d1);
   
   SetIndexBuffer(31,SK_h4);
   SetIndexBuffer(32,SD_h4);
   SetIndexBuffer(33,SK_array_h4);
   SetIndexBuffer(34,RSI_h4);
   SetIndexBuffer(35,SKI_h4);
   
   SetIndexBuffer(36,SK_h1);
   SetIndexBuffer(37,SD_h1);
   SetIndexBuffer(38,SK_array_h1);
   SetIndexBuffer(39,RSI_h1);
   SetIndexBuffer(40,SKI_h1);
   
   SetIndexBuffer(41,SK_m30);
   SetIndexBuffer(42,SD_m30);
   SetIndexBuffer(43,SK_array_m30);
   SetIndexBuffer(44,RSI_m30);
   SetIndexBuffer(45,SKI_m30);
   
   SetIndexBuffer(46,SK_m15);
   SetIndexBuffer(47,SD_m15);
   SetIndexBuffer(48,SK_array_m15);
   SetIndexBuffer(49,RSI_m15);
   SetIndexBuffer(50,SKI_m15);
   
   SetIndexBuffer(51,SK_m5);
   SetIndexBuffer(52,SD_m5);
   SetIndexBuffer(53,SK_array_m5);
   SetIndexBuffer(54,RSI_m5);
   SetIndexBuffer(55,SKI_m5);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   double max, min;
   
   // Week
   if (Period() < 43200){
      period     = PERIOD_W1;
      multiplier = 10080/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_w1[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_w1[j];
            else{
               if (RSI_w1[j]>max) max = RSI_w1[j];
               if (RSI_w1[j]<min) min = RSI_w1[j];
            }
         }
         if (min==max)
            SKI_w1[i] = 100;
         else
            SKI_w1[i] = (RSI_w1[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_w1[current] = SK_array_w1[i] = iMAOnArray(SKI_w1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_w1[j]  = SK_w1[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_w1[current] = iMAOnArray(SK_array_w1,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_w1[j]  = SD_w1[current];
      }
      for (i=limit; i>=0; i--){
         w1_up[i] = -1.0;
         w1_dn[i] = -1.0;
         w1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_w1[i] > SD_w1[i])
               w1_up[i] = 1.0;
            else
               w1_dn[i] = 1.0;
         }
         if (Compare_Method==2){
            if (SK_w1[i] > 50)
               w1_up[i] = 1.0;
            else
               w1_dn[i] = 1.0;
         }
         if (Compare_Method==3){
            if (SK_w1[i] > OB_Level)
               w1_up[i] = 1.0;
            else if (SK_w1[i] < OS_Level)
               w1_dn[i] = 1.0;
            else
               w1_nt[i] = 1.0;
         }
         if (Compare_Method==4){
            if (SK_w1[i] > SK_w1[i+1])
               w1_up[i] = 1.0;
            else
               w1_dn[i] = 1.0;
         }
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
   } // Week End
   
   // Day
   if (Period() < 10080){
      period     = PERIOD_D1;
      multiplier = 1440/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_d1[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_d1[j];
            else{
               if (RSI_d1[j]>max) max = RSI_d1[j];
               if (RSI_d1[j]<min) min = RSI_d1[j];
            }
         }
         if (min==max)
            SKI_d1[i] = 100;
         else
            SKI_d1[i] = (RSI_d1[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_d1[current] = SK_array_d1[i] = iMAOnArray(SKI_d1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_d1[j]  = SK_d1[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_d1[current] = iMAOnArray(SK_array_d1,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_d1[j]  = SD_d1[current];
      }
      for (i=limit; i>=0; i--){
         d1_up[i] = -1.0;
         d1_dn[i] = -1.0;
         d1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_d1[i] > SD_d1[i])
               d1_up[i] = 1.5;
            else
               d1_dn[i] = 1.5;
         }
         if (Compare_Method==2){
            if (SK_d1[i] > 50)
               d1_up[i] = 1.5;
            else
               d1_dn[i] = 1.5;
         }
         if (Compare_Method==3){
            if (SK_d1[i] > OB_Level)
               d1_up[i] = 1.5;
            else if (SK_d1[i] < OS_Level)
               d1_dn[i] = 1.5;
            else
               d1_nt[i] = 1.5;
         }
         if (Compare_Method==4){
            if (SK_d1[i] > SK_d1[i+1])
               d1_up[i] = 1.5;
            else
               d1_dn[i] = 1.5;
         }
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
   } // Day End
   
   // H4
   if (Period() < 1440){
      period     = PERIOD_H4;
      multiplier = 240/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_h4[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_h4[j];
            else{
               if (RSI_h4[j]>max) max = RSI_h4[j];
               if (RSI_h4[j]<min) min = RSI_h4[j];
            }
         }
         if (min==max)
            SKI_h4[i] = 100;
         else
            SKI_h4[i] = (RSI_h4[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_h4[current] = SK_array_h4[i] = iMAOnArray(SKI_h4,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_h4[j]  = SK_h4[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_h4[current] = iMAOnArray(SK_array_h4,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_h4[j]  = SD_h4[current];
      }
      for (i=limit; i>=0; i--){
         h4_up[i] = -1.0;
         h4_dn[i] = -1.0;
         h4_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_h4[i] > SD_h4[i])
               h4_up[i] = 2.0;
            else
               h4_dn[i] = 2.0;
         }
         if (Compare_Method==2){
            if (SK_h4[i] > 50)
               h4_up[i] = 2.0;
            else
               h4_dn[i] = 2.0;
         }
         if (Compare_Method==3){
            if (SK_h4[i] > OB_Level)
               h4_up[i] = 2.0;
            else if (SK_h4[i] < OS_Level)
               h4_dn[i] = 2.0;
            else
               h4_nt[i] = 2.0;
         }
         if (Compare_Method==4){
            if (SK_h4[i] > SK_h4[i+1])
               h4_up[i] = 2.0;
            else
               h4_dn[i] = 2.0;
         } 
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
   } // H4 End
   
   // H1
   if (Period() < 240){
      period     = PERIOD_H1;
      multiplier = 60/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_h1[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_h1[j];
            else{
               if (RSI_h1[j]>max) max = RSI_h1[j];
               if (RSI_h1[j]<min) min = RSI_h1[j];
            }
         }
         if (min==max)
            SKI_h1[i] = 100;
         else
            SKI_h1[i] = (RSI_h1[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_h1[current] = SK_array_h1[i] = iMAOnArray(SKI_h1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_h1[j]  = SK_h1[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_h1[current] = iMAOnArray(SK_array_h1,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_h1[j]  = SD_h1[current];
      }
      for (i=limit; i>=0; i--){
         h1_up[i] = -1.0;
         h1_dn[i] = -1.0;
         h1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_h1[i] > SD_h1[i])
               h1_up[i] = 2.5;
            else
               h1_dn[i] = 2.5;
         }
         if (Compare_Method==2){
            if (SK_h1[i] > 50)
               h1_up[i] = 2.5;
            else
               h1_dn[i] = 2.5;
         }
         if (Compare_Method==3){
            if (SK_h1[i] > OB_Level)
               h1_up[i] = 2.5;
            else if (SK_h1[i] < OS_Level)
               h1_dn[i] = 2.5;
            else
               h1_nt[i] = 2.5;
         }
         if (Compare_Method==4){
            if (SK_h1[i] > SK_h1[i+1])
               h1_up[i] = 2.5;
            else
               h1_dn[i] = 2.5;
         }  
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
   } // H1 End
   
   // M30
   if (Period() < 60){
      period     = PERIOD_M30;
      multiplier = 30/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_m30[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_m30[j];
            else{
               if (RSI_m30[j]>max) max = RSI_m30[j];
               if (RSI_m30[j]<min) min = RSI_m30[j];
            }
         }
         if (min==max)
            SKI_m30[i] = 100;
         else
            SKI_m30[i] = (RSI_m30[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_m30[current] = SK_array_m30[i] = iMAOnArray(SKI_m30,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_m30[j]  = SK_m30[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_m30[current] = iMAOnArray(SK_array_m30,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_m30[j]  = SD_m30[current];
      }
      for (i=limit; i>=0; i--){
         m30_up[i] = -1.0;
         m30_dn[i] = -1.0;
         m30_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_m30[i] > SD_m30[i])
               m30_up[i] = 3.0;
            else
               m30_dn[i] = 3.0;
         }
         if (Compare_Method==2){
            if (SK_m30[i] > 50)
               m30_up[i] = 3.0;
            else
               m30_dn[i] = 3.0;
         }
         if (Compare_Method==3){
            if (SK_m30[i] > OB_Level)
               m30_up[i] = 3.0;
            else if (SK_m30[i] < OS_Level)
               m30_dn[i] = 3.0;
            else
               m30_nt[i] = 3.0;
         }
         if (Compare_Method==4){
            if (SK_m30[i] > SK_m30[i+1])
               m30_up[i] = 3.0;
            else
               m30_dn[i] = 3.0;
         }  
         Etiqueta("HeatLbl_M30"," - M30 ",3.3, Time[0]);
      }
   } // M30 End
   
   // M15
   if (Period() < 30){
      period     = PERIOD_M15;
      multiplier = 15/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_m15[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_m15[j];
            else{
               if (RSI_m15[j]>max) max = RSI_m15[j];
               if (RSI_m15[j]<min) min = RSI_m15[j];
            }
         }
         if (min==max)
            SKI_m15[i] = 100;
         else
            SKI_m15[i] = (RSI_m15[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_m15[current] = SK_array_m15[i] = iMAOnArray(SKI_m15,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_m15[j]  = SK_m15[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_m15[current] = iMAOnArray(SK_array_m15,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_m15[j]  = SD_m15[current];
      }
      for (i=limit; i>=0; i--){
         m15_up[i] = -1.0;
         m15_dn[i] = -1.0;
         m15_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_m15[i] > SD_m15[i])
               m15_up[i] = 3.5;
            else
               m15_dn[i] = 3.5;
         }
         if (Compare_Method==2){
            if (SK_m15[i] > 50)
               m15_up[i] = 3.5;
            else
               m15_dn[i] = 3.5;
         }
         if (Compare_Method==3){
            if (SK_m15[i] > OB_Level)
               m15_up[i] = 3.5;
            else if (SK_m15[i] < OS_Level)
               m15_dn[i] = 3.5;
            else
               m15_nt[i] = 3.5;
         }
         if (Compare_Method==4){
            if (SK_m15[i] > SK_m15[i+1])
               m15_up[i] = 3.5;
            else
               m15_dn[i] = 3.5;
         } 
         Etiqueta("HeatLbl_M15"," - M15 ",3.8, Time[0]);
      }
   } // M15 End
   
   // M5
   if (Period() < 15){
      period     = PERIOD_M5;
      multiplier = 5/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){     
         RSI_m5[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
         for (j=(i+K_period-1); j>=i; j--){
            if (j==(i+K_period-1))
               max = min = RSI_m5[j];
            else{
               if (RSI_m5[j]>max) max = RSI_m5[j];
               if (RSI_m5[j]<min) min = RSI_m5[j];
            }
         }
         if (min==max)
            SKI_m5[i] = 100;
         else
            SKI_m5[i] = (RSI_m5[i] - min) / (max - min) * 100;
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SK_m5[current] = SK_array_m5[i] = iMAOnArray(SKI_m5,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SK_m5[j]  = SK_m5[current];
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         SD_m5[current] = iMAOnArray(SK_array_m5,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
         for (j=current; j>=next; j--) SD_m5[j]  = SD_m5[current];
      }
      for (i=limit; i>=0; i--){
         m5_up[i] = -1.0;
         m5_dn[i] = -1.0;
         m5_nt[i] = -1.0;
         if (Compare_Method==1){
            if (SK_m5[i] > SD_m5[i])
               m5_up[i] = 4.0;
            else
               m5_dn[i] = 4.0;
         }
         if (Compare_Method==2){
            if (SK_m5[i] > 50)
               m5_up[i] = 4.0;
            else
               m5_dn[i] = 4.0;
         }
         if (Compare_Method==3){
            if (SK_m5[i] > OB_Level)
               m5_up[i] = 4.0;
            else if (SK_m5[i] < OS_Level)
               m5_dn[i] = 4.0;
            else
               m5_nt[i] = 4.0;
         }
         if (Compare_Method==4){
            if (SK_m5[i] > SK_m5[i+1])
               m5_up[i] = 4.0;
            else
               m5_dn[i] = 4.0;
         }
         Etiqueta("HeatLbl_M5"," - M5 ",4.3, Time[0]);
      }
   } // M5 End
   
//----
   return(0);
}

int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
  ObjectSetText(IndicatorObjPrefix + sName, " "+sLabel, 8, "Lucida Console", clrWhite);
  ObjectMove(IndicatorObjPrefix + sName,0,tTime+Period()*60*2, dPrice);
  return(0);
}

void Limpiar(){
   ObjectDelete("HeatLbl_M1");
   ObjectDelete("HeatLbl_M5");
   ObjectDelete("HeatLbl_M15");
   ObjectDelete("HeatLbl_M30");
   ObjectDelete("HeatLbl_H1");
   ObjectDelete("HeatLbl_H4");
   ObjectDelete("HeatLbl_D1");
   ObjectDelete("HeatLbl_W1");
}