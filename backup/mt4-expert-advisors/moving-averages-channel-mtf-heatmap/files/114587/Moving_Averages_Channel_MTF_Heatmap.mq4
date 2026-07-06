// Id: 18948
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65045

//+------------------------------------------------------------------+
//|                          Moving_Averages_Channel_MTF_Heatmap.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
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

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      Fast_MA_Period      = 10;
extern e_method Fast_MA_Method      = SMA;
extern e_price  Fast_MA_Price_Type  = CLOSE;
extern int      Slow_MA_Period      = 20;
extern e_method Slow_MA_Method      = SMA;
extern e_price  Slow_MA_Price_Type  = CLOSE;

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

double MA1_w1[];
double MA2_w1[];

double MA1_d1[];
double MA2_d1[];

double MA1_h4[];
double MA2_h4[];

double MA1_h1[];
double MA2_h1[];

double MA1_m30[];
double MA2_m30[];

double MA1_m15[];
double MA2_m15[];

double MA1_m5[];
double MA2_m5[];

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
   
   IndName = "Moving_Averages_Channel_MTF_Heatmap";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   SetIndexBuffer(21,MA1_w1);
   SetIndexBuffer(22,MA2_w1);
   
   SetIndexBuffer(23,MA1_d1);
   SetIndexBuffer(24,MA2_d1);
   
   SetIndexBuffer(25,MA1_h4);
   SetIndexBuffer(26,MA2_h4);
   
   SetIndexBuffer(27,MA1_h1);
   SetIndexBuffer(28,MA2_h1);
   
   SetIndexBuffer(29,MA1_m30);
   SetIndexBuffer(30,MA2_m30);
   
   SetIndexBuffer(31,MA1_m15);
   SetIndexBuffer(32,MA2_m15);
   
   SetIndexBuffer(33,MA1_m5);
   SetIndexBuffer(34,MA2_m5);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current;
   
   // Week
   if (Period() < 43200){
      period     = PERIOD_W1;
      multiplier = 10080/Period();
      for(i=limit ; i>=0; i--){
         current = iBarShift(NULL,PERIOD_W1,Time[i]);
         MA1_w1[i] = iMA(NULL,PERIOD_W1,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_w1[i] = iMA(NULL,PERIOD_W1,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_W1,current) > MA2_w1[i] && iClose(NULL,PERIOD_W1,current) > MA1_w1[i])
            w1_up[i] = 1.0;
         else if (iClose(NULL,PERIOD_W1,current) < MA2_w1[i] && iClose(NULL,PERIOD_W1,current) < MA1_w1[i])
            w1_dn[i] = 1.0;
         else
            w1_nt[i] = 1.0;
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
   } // Week End
   
   // Day
   if (Period() < 10080){
      period     = PERIOD_D1;
      multiplier = 1440/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_D1,Time[i]);
         MA1_d1[i] = iMA(NULL,PERIOD_D1,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_d1[i] = iMA(NULL,PERIOD_D1,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_D1,current) > MA2_d1[i] && iClose(NULL,PERIOD_D1,current) > MA1_d1[i])
            d1_up[i] = 1.5;
         else if (iClose(NULL,PERIOD_D1,current) < MA2_d1[i] && iClose(NULL,PERIOD_D1,current) < MA1_d1[i])
            d1_dn[i] = 1.5;
         else
            d1_nt[i] = 1.5;
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
   } // Day End
   
   // H4
   if (Period() < 1440){
      period     = PERIOD_H4;
      multiplier = 240/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_H4,Time[i]);
         MA1_h4[i] = iMA(NULL,PERIOD_H4,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_h4[i] = iMA(NULL,PERIOD_H4,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_H4,current) > MA2_h4[i] && iClose(NULL,PERIOD_H4,current) > MA1_h4[i])
            h4_up[i] = 2.0;
         else if (iClose(NULL,PERIOD_H4,current) < MA2_h4[i] && iClose(NULL,PERIOD_H4,current) < MA1_h4[i])
            h4_dn[i] = 2.0;
         else
            h4_nt[i] = 2.0;
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
   } // H4 End
   
   // H1
   if (Period() < 240){
      period     = PERIOD_H1;
      multiplier = 60/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_H1,Time[i]);
         MA1_h1[i] = iMA(NULL,PERIOD_H1,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_h1[i] = iMA(NULL,PERIOD_H1,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_H1,current) > MA2_h1[i] && iClose(NULL,PERIOD_H1,current) > MA1_h1[i])
            h1_up[i] = 2.5;
         else if (iClose(NULL,PERIOD_H1,current) < MA2_h1[i] && iClose(NULL,PERIOD_H1,current) < MA1_h1[i])
            h1_dn[i] = 2.5;
         else
            h1_nt[i] = 2.5;
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
   } // H1 End
   
   // M30
   if (Period() < 60){
      period     = PERIOD_M30;
      multiplier = 30/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_M30,Time[i]);
         MA1_m30[i] = iMA(NULL,PERIOD_M30,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_m30[i] = iMA(NULL,PERIOD_M30,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_M30,current) > MA2_m30[i] && iClose(NULL,PERIOD_M30,current) > MA1_m30[i])
            m30_up[i] = 3.0;
         else if (iClose(NULL,PERIOD_M30,current) < MA2_m30[i] && iClose(NULL,PERIOD_M30,current) < MA1_m30[i])
            m30_dn[i] = 3.0;
         else
            m30_nt[i] = 3.0;  
         Etiqueta("HeatLbl_M30"," - M30 ",3.3, Time[0]);
      }
   } // M30 End
   
   // M15
   if (Period() < 30){
      period     = PERIOD_M15;
      multiplier = 15/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_M15,Time[i]);
         MA1_m15[i] = iMA(NULL,PERIOD_M15,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_m15[i] = iMA(NULL,PERIOD_M15,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_M15,current) > MA2_m15[i] && iClose(NULL,PERIOD_M15,current) > MA1_m15[i])
            m15_up[i] = 3.5;
         else if (iClose(NULL,PERIOD_M15,current) < MA2_m15[i] && iClose(NULL,PERIOD_M15,current) < MA1_m15[i])
            m15_dn[i] = 3.5;
         else
            m15_nt[i] = 3.5; 
         Etiqueta("HeatLbl_M15"," - M15 ",3.8, Time[0]);
      }
   } // M15 End
   
   // M5
   if (Period() < 15){
      period     = PERIOD_M5;
      multiplier = 5/Period();
      for (i=limit; i>=0; i--){
         current = iBarShift(NULL,PERIOD_M5,Time[i]);
         MA1_m5[i] = iMA(NULL,PERIOD_M5,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price_Type),current);
         MA2_m5[i] = iMA(NULL,PERIOD_M5,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price_Type),current);
         if (iClose(NULL,PERIOD_M5,current) > MA2_m5[i] && iClose(NULL,PERIOD_M5,current) > MA1_m5[i])
            m5_up[i] = 4.0;
         else if (iClose(NULL,PERIOD_M5,current) < MA2_m5[i] && iClose(NULL,PERIOD_M5,current) < MA1_m5[i])
            m5_dn[i] = 4.0;
         else
            m5_nt[i] = 4.0;
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