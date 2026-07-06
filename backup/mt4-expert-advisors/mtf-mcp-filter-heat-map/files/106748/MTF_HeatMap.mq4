// Id: 16240
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 27
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_color3 clrDarkGray
#property indicator_color4 clrGreen
#property indicator_color5 clrRed
#property indicator_color6 clrDarkGray
#property indicator_color7 clrGreen
#property indicator_color8 clrRed
#property indicator_color9 clrDarkGray
#property indicator_color10 clrGreen
#property indicator_color11 clrRed
#property indicator_color12 clrDarkGray
#property indicator_color13 clrGreen
#property indicator_color14 clrRed
#property indicator_color15 clrDarkGray
#property indicator_color16 clrGreen
#property indicator_color17 clrRed
#property indicator_color18 clrDarkGray
#property indicator_color19 clrGreen
#property indicator_color20 clrRed
#property indicator_color21 clrDarkGray
#property indicator_color22 clrGreen
#property indicator_color23 clrRed
#property indicator_color24 clrDarkGray
#property indicator_color25 clrGreen
#property indicator_color26 clrRed
#property indicator_color27 clrDarkGray
#property indicator_minimum 0
#property indicator_maximum 6

//---- indicator parameters


//---- indicator buffers
double     mn_up[];
double     mn_dn[];
double     mn_nt[];
double     w1_up[];
double     w1_dn[];
double     w1_nt[];
double     d1_up[];
double     d1_dn[];
double     d1_nt[];
double     h4_up[];
double     h4_dn[];
double     h4_nt[];
double     h1_up[];
double     h1_dn[];
double     h1_nt[];
double     m30_up[];
double     m30_dn[];
double     m30_nt[];
double     m15_up[];
double     m15_dn[];
double     m15_nt[];
double     m5_up[];
double     m5_dn[];
double     m5_nt[];
double     m1_up[];
double     m1_dn[];
double     m1_nt[];

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

//---- variables

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
//   IndicatorBuffers(3);
   
   int arrow = 110;
   
   SetIndexBuffer(0,mn_up);
   SetIndexBuffer(1,mn_dn);
   SetIndexBuffer(2,mn_nt);
   SetIndexBuffer(3,w1_up);
   SetIndexBuffer(4,w1_dn);
   SetIndexBuffer(5,w1_nt);
   SetIndexBuffer(6,d1_up);
   SetIndexBuffer(7,d1_dn);
   SetIndexBuffer(8,d1_nt);
   SetIndexBuffer(9,h4_up);
   SetIndexBuffer(10,h4_dn);
   SetIndexBuffer(11,h4_nt);
   SetIndexBuffer(12,h1_up);
   SetIndexBuffer(13,h1_dn);
   SetIndexBuffer(14,h1_nt);
   SetIndexBuffer(15,m30_up);
   SetIndexBuffer(16,m30_dn);
   SetIndexBuffer(17,m30_nt);
   SetIndexBuffer(18,m15_up);
   SetIndexBuffer(19,m15_dn);
   SetIndexBuffer(20,m15_nt);
   SetIndexBuffer(21,m5_up);
   SetIndexBuffer(22,m5_dn);
   SetIndexBuffer(23,m5_nt);
   SetIndexBuffer(24,m1_up);
   SetIndexBuffer(25,m1_dn);
   SetIndexBuffer(26,m1_nt);
   
   for (int i = 0; i < 27; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndicatorName = GenerateIndicatorName("MTF HeatMap");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
//---- initialization done
   return(0);
  }

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   double adx, adx_previous, plusdmi, minusdmi, macd;
   
   Limpiar();
   
   for (i=limit; i>=0; i--){
      
      // Month
      adx          = iADX(NULL, PERIOD_MN1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_MN1,Time[i]));
      adx_previous = iADX(NULL, PERIOD_MN1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_MN1,Time[i])+1);
      plusdmi      = iADX(NULL, PERIOD_MN1, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_MN1,Time[i]));
      minusdmi     = iADX(NULL, PERIOD_MN1, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_MN1,Time[i]));
      macd         = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_MN1,Time[i]));
      if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
         mn_up[i] = 0.5;
         mn_dn[i] = -1;
         mn_nt[i] = -1;
      }
      else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
         mn_dn[i] = 0.5;
         mn_up[i] = -1;
         mn_nt[i] = -1;
      }
      else{
         mn_dn[i] = -1;
         mn_up[i] = -1;
         mn_nt[i] = 0.5;
      }
      Etiqueta("HeatLbl_MN1"," - MN1",0.8, Time[0]);
      
      // Week
      if (Period() < 43200){
      
         adx          = iADX(NULL, PERIOD_W1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_W1,Time[i]));
         adx_previous = iADX(NULL, PERIOD_W1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_W1,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_W1, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_W1,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_W1, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_W1,Time[i]));
         macd         = iMACD(NULL,PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_W1,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            w1_up[i] = 1.0;
            w1_dn[i] = -1;
            w1_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            w1_dn[i] = 1.0;
            w1_up[i] = -1;
            w1_nt[i] = -1;
         }
         else{
            w1_dn[i] = -1;
            w1_up[i] = -1;
            w1_nt[i] = 1.0;
         }
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
      
      // Day
      if (Period() < 10080){
      
         adx          = iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_D1,Time[i]));
         adx_previous = iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_D1,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_D1,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_D1,Time[i]));
         macd         = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_D1,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            d1_up[i] = 1.5;
            d1_dn[i] = -1;
            d1_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            d1_dn[i] = 1.5;
            d1_up[i] = -1;
            d1_nt[i] = -1;
         }
         else{
            d1_dn[i] = -1;
            d1_up[i] = -1;
            d1_nt[i] = 1.5;
         }
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
      
      // H4
      if (Period() < 1440){
      
         adx          = iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_H4,Time[i]));
         adx_previous = iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_H4,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_H4,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_H4,Time[i]));
         macd         = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_H4,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            h4_up[i] = 2.0;
            h4_dn[i] = -1;
            h4_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            h4_dn[i] = 2.0;
            h4_up[i] = -1;
            h4_nt[i] = -1;
         }
         else{
            h4_dn[i] = -1;
            h4_up[i] = -1;
            h4_nt[i] = 2.0;
         }
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
      
      // H1
      if (Period() < 240){
      
         adx          = iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_H1,Time[i]));
         adx_previous = iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_H1,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_H1,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_H1,Time[i]));
         macd         = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_H1,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            h1_up[i] = 2.5;
            h1_dn[i] = -1;
            h1_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            h1_dn[i] = 2.5;
            h1_up[i] = -1;
            h1_nt[i] = -1;
         }
         else{
            h1_dn[i] = -1;
            h1_up[i] = -1;
            h1_nt[i] = 2.5;
         }
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
      
      // M30
      if (Period() < 60){
      
         adx          = iADX(NULL, PERIOD_M30, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M30,Time[i]));
         adx_previous = iADX(NULL, PERIOD_M30, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M30,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_M30, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_M30,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_M30, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_M30,Time[i]));
         macd         = iMACD(NULL,PERIOD_M30,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_M30,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            m30_up[i] = 3.0;
            m30_dn[i] = -1;
            m30_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            m30_dn[i] = 3.0;
            m30_up[i] = -1;
            m30_nt[i] = -1;
         }
         else{
            m30_dn[i] = -1;
            m30_up[i] = -1;
            m30_nt[i] = 3.0;
         }
         Etiqueta("HeatLbl_M30"," - m30",3.3, Time[0]);
      }
      
      // M15
      if (Period() < 30){
      
         adx          = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M15,Time[i]));
         adx_previous = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M15,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_M15,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_M15,Time[i]));
         macd         = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_M15,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            m15_up[i] = 3.5;
            m15_dn[i] = -1;
            m15_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            m15_dn[i] = 3.5;
            m15_up[i] = -1;
            m15_nt[i] = -1;
         }
         else{
            m15_dn[i] = -1;
            m15_up[i] = -1;
            m15_nt[i] = 3.5;
         }
         Etiqueta("HeatLbl_M15"," - m15",3.8, Time[0]);
      }
      
      // M5
      if (Period() < 15){
      
         adx          = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M5,Time[i]));
         adx_previous = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M5,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_M5,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_M5,Time[i]));
         macd         = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_M5,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            m5_up[i] = 4.0;
            m5_dn[i] = -1;
            m5_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            m5_dn[i] = 4.0;
            m5_up[i] = -1;
            m5_nt[i] = -1;
         }
         else{
            m5_dn[i] = -1;
            m5_up[i] = -1;
            m5_nt[i] = 4.0;
         }
         Etiqueta("HeatLbl_M5"," - m5 ",4.3, Time[0]);
      }
      
      // M1
      if (Period() < 5){
      
         adx          = iADX(NULL, PERIOD_M1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M1,Time[i]));
         adx_previous = iADX(NULL, PERIOD_M1, 14, PRICE_CLOSE, 0, iBarShift(NULL,PERIOD_M1,Time[i])+1);
         plusdmi      = iADX(NULL, PERIOD_M1, 14, PRICE_CLOSE, 1, iBarShift(NULL,PERIOD_M1,Time[i]));
         minusdmi     = iADX(NULL, PERIOD_M1, 14, PRICE_CLOSE, 2, iBarShift(NULL,PERIOD_M1,Time[i]));
         macd         = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,iBarShift(NULL,PERIOD_M1,Time[i]));
         if (adx > adx_previous && plusdmi > minusdmi && macd > 0){
            m1_up[i] = 4.5;
            m1_dn[i] = -1;
            m1_nt[i] = -1;
         }
         else if (adx > adx_previous && plusdmi < minusdmi && macd < 0){
            m1_dn[i] = 4.5;
            m1_up[i] = -1;
            m1_nt[i] = -1;
         }
         else{
            m1_dn[i] = -1;
            m1_up[i] = -1;
            m1_nt[i] = 4.5;
         }
         Etiqueta("HeatLbl_M1"," - m1 ",4.8, Time[0]);
      }

      
   }
   
   Comment("");
   
      
//---- done
   return(0);
  }
  
int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind("MTF HeatMap"), tTime+Period()*60*2, dPrice);
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
   ObjectDelete("HeatLbl_MN1");
}