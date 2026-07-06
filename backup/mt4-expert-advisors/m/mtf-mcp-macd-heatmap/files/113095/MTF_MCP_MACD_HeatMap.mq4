// Id: 18528
//+------------------------------------------------------------------+
//|                                         MTF_MCP_MACD_HeatMap.mq4 |
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

enum metodo{ MACD_Signal=1, MACD_Zero_Line=2, Signal_Zero_Line=3 };

input  metodo Compare_Method = MACD_Signal;
extern int    Fast_EMA       = 12;
extern int    Slow_EMA       = 26;
extern int    Signal         = 9;
extern string Comment0       = "<< Currency Pair: Leave Blank for Current >>";
extern string Currency_Pair  = "EURUSD";

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

double MACD_w1[];
double Signal_w1[];

double MACD_d1[];
double Signal_d1[];

double MACD_h4[];
double Signal_h4[];

double MACD_h1[];
double Signal_h1[];

double MACD_m30[];
double Signal_m30[];

double MACD_m15[];
double Signal_m15[];

double MACD_m5[];
double Signal_m5[];

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
   
   IndicatorBuffers(35);
   
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
   
   IndName = "MTF_MCP_MACD_HeatMap";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   SetIndexBuffer(21,MACD_w1);
   SetIndexBuffer(22,Signal_w1);
   
   SetIndexBuffer(23,MACD_d1);
   SetIndexBuffer(24,Signal_d1);
   
   SetIndexBuffer(25,MACD_h4);
   SetIndexBuffer(26,Signal_h4);
   
   SetIndexBuffer(27,MACD_h1);
   SetIndexBuffer(28,Signal_h1);
   
   SetIndexBuffer(29,MACD_m30);
   SetIndexBuffer(30,Signal_m30);
   
   SetIndexBuffer(31,MACD_m15);
   SetIndexBuffer(32,Signal_m15);
   
   SetIndexBuffer(33,MACD_m5);
   SetIndexBuffer(34,Signal_m5);
   
   Limpiar();
   
   return(0);
}

int deinit(){
   Limpiar();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current;
   
   if (Currency_Pair!="") string Symbolo = Currency_Pair; else Symbolo = NULL;
   
   // Week
   if (Period() < 43200){
      period     = PERIOD_W1;
      multiplier = 10080/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_w1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_w1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         w1_up[i] = -1.0;
         w1_dn[i] = -1.0;
         w1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_w1[i] > Signal_w1[i])
               w1_up[i] = 1.0;
            else
               w1_dn[i] = 1.0;
         }
         if (Compare_Method==2){
            if (MACD_w1[i] > 0)
               w1_up[i] = 1.0;
            else
               w1_dn[i] = 1.0;
         }
         if (Compare_Method==3){
            if (Signal_w1[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_d1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_d1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         d1_up[i] = -1.0;
         d1_dn[i] = -1.0;
         d1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_d1[i] > Signal_d1[i])
               d1_up[i] = 1.5;
            else
               d1_dn[i] = 1.5;
         }
         if (Compare_Method==2){
            if (MACD_d1[i] > 0)
               d1_up[i] = 1.5;
            else
               d1_dn[i] = 1.5;
         }
         if (Compare_Method==3){
            if (Signal_d1[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_h4[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_h4[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         h4_up[i] = -1.0;
         h4_dn[i] = -1.0;
         h4_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_h4[i] > Signal_h4[i])
               h4_up[i] = 2.0;
            else
               h4_dn[i] = 2.0;
         }
         if (Compare_Method==2){
            if (MACD_h4[i] > 0)
               h4_up[i] = 2.0;
            else
               h4_dn[i] = 2.0;
         }
         if (Compare_Method==3){
            if (Signal_h4[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_h1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_h1[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         h1_up[i] = -1.0;
         h1_dn[i] = -1.0;
         h1_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_h1[i] > Signal_h1[i])
               h1_up[i] = 2.5;
            else
               h1_dn[i] = 2.5;
         }
         if (Compare_Method==2){
            if (MACD_h1[i] > 0)
               h1_up[i] = 2.5;
            else
               h1_dn[i] = 2.5;
         }
         if (Compare_Method==3){
            if (Signal_h1[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_m30[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_m30[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         m30_up[i] = -1.0;
         m30_dn[i] = -1.0;
         m30_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_m30[i] > Signal_m30[i])
               m30_up[i] = 3.0;
            else
               m30_dn[i] = 3.0;
         }
         if (Compare_Method==2){
            if (MACD_m30[i] > 0)
               m30_up[i] = 3.0;
            else
               m30_dn[i] = 3.0;
         }
         if (Compare_Method==3){
            if (Signal_m30[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_m15[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_m15[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         m15_up[i] = -1.0;
         m15_dn[i] = -1.0;
         m15_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_m15[i] > Signal_m15[i])
               m15_up[i] = 3.5;
            else
               m15_dn[i] = 3.5;
         }
         if (Compare_Method==2){
            if (MACD_m15[i] > 0)
               m15_up[i] = 3.5;
            else
               m15_dn[i] = 3.5;
         }
         if (Compare_Method==3){
            if (Signal_m15[i] > 0)
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
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,0,Time[i]);
         MACD_m5[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_MAIN,current);
         Signal_m5[i] = iMACD(Symbolo,period,Fast_EMA,Slow_EMA,Signal,PRICE_CLOSE,MODE_SIGNAL,current);
      }
      for (i=limit; i>=0; i--){
         m5_up[i] = -1.0;
         m5_dn[i] = -1.0;
         m5_nt[i] = -1.0;
         if (Compare_Method==1){
            if (MACD_m5[i] > Signal_m5[i])
               m5_up[i] = 4.0;
            else
               m5_dn[i] = 4.0;
         }
         if (Compare_Method==2){
            if (MACD_m5[i] > 0)
               m5_up[i] = 4.0;
            else
               m5_dn[i] = 4.0;
         }
         if (Compare_Method==3){
            if (Signal_m5[i] > 0)
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
}