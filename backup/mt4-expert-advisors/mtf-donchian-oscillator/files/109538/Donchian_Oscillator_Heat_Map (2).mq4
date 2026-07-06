// Id: 17161
//+------------------------------------------------------------------+
//|                                  Donchian_Oscillator_HeatMap.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 18
#property indicator_color1 clrLime
#property indicator_color2 clrRed
#property indicator_color3 clrLime
#property indicator_color4 clrRed
#property indicator_color5 clrLime
#property indicator_color6 clrRed
#property indicator_color7 clrLime
#property indicator_color8 clrRed
#property indicator_color9 clrLime
#property indicator_color10 clrRed
#property indicator_color11 clrLime
#property indicator_color12 clrRed
#property indicator_color13 clrLime
#property indicator_color14 clrRed
#property indicator_color15 clrLime
#property indicator_color16 clrRed
#property indicator_color17 clrLime
#property indicator_color18 clrRed
#property indicator_minimum 0
#property indicator_maximum 6

//---- indicator parameters
extern double Periods    = 10;

//---- indicator buffers
double     mn_up[];
double     mn_dn[];
double     w1_up[];
double     w1_dn[];
double     d1_up[];
double     d1_dn[];
double     h4_up[];
double     h4_dn[];
double     h1_up[];
double     h1_dn[];
double     m30_up[];
double     m30_dn[];
double     m15_up[];
double     m15_dn[];
double     m5_up[];
double     m5_dn[];
double     m1_up[];
double     m1_dn[];

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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
//   IndicatorBuffers(3);
   
   int arrow = 159;
   
   SetIndexBuffer(0,mn_up);
   SetIndexBuffer(1,mn_dn);
   SetIndexBuffer(2,w1_up);
   SetIndexBuffer(3,w1_dn);
   SetIndexBuffer(4,d1_up);
   SetIndexBuffer(5,d1_dn);
   SetIndexBuffer(6,h4_up);
   SetIndexBuffer(7,h4_dn);
   SetIndexBuffer(8,h1_up);
   SetIndexBuffer(9,h1_dn);
   SetIndexBuffer(10,m30_up);
   SetIndexBuffer(11,m30_dn);
   SetIndexBuffer(12,m15_up);
   SetIndexBuffer(13,m15_dn);
   SetIndexBuffer(14,m5_up);
   SetIndexBuffer(15,m5_dn);
   SetIndexBuffer(16,m1_up);
   SetIndexBuffer(17,m1_dn);
   
   for (int i = 0; i < 18; i++) {
      SetIndexStyle(i,DRAW_ARROW,STYLE_SOLID,1);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndicatorName = GenerateIndicatorName("Donchian_Oscillator_MTF_HeatMap");
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
   int limit, i, j;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   double Max_High, Min_Low, jHigh, jLow, iCLOSE;
   int BarShift;
   
   Limpiar();
   
   for (i=limit; i>=0; i--){
      
      // Month
      Max_High = 0; Min_Low = 0;
      BarShift = iBarShift(NULL,PERIOD_MN1,Time[i]);
      iCLOSE   = iClose(NULL,PERIOD_MN1,BarShift);
      for (j=(BarShift+Periods-1); j>BarShift; j--){  
         jHigh = iHigh(NULL,PERIOD_MN1,j);
         jLow  = iLow(NULL,PERIOD_MN1,j);
         if (j==(BarShift+Periods-1)){
            Max_High = jHigh;
            Min_Low  = jLow;
         }else{
            if (jHigh > Max_High) Max_High = jHigh;
            if (jLow  < Min_Low)  Min_Low  = jLow;
         }
      }
      if (iCLOSE > Max_High){
         mn_up[i] = 0.5;
         mn_dn[i] = -1;
      }
      if (iCLOSE < Min_Low){
         mn_dn[i] = 0.5;
         mn_up[i] = -1;
      }
      Etiqueta("HeatLbl_MN1"," - MN1",0.8, Time[0]);
      
      // Week
      if (Period() < 43200){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_W1,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_W1,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_W1,j);
            jLow  = iLow(NULL,PERIOD_W1,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            w1_up[i] = 1.0;
            w1_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            w1_dn[i] = 1.0;
            w1_up[i] = -1;
         }
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
      
      // Day
      if (Period() < 10080){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_D1,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_D1,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_D1,j);
            jLow  = iLow(NULL,PERIOD_D1,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            d1_up[i] = 1.5;
            d1_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            d1_dn[i] = 1.5;
            d1_up[i] = -1;
         }
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
      
      // H4
      if (Period() < 1440){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_H4,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_H4,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_H4,j);
            jLow  = iLow(NULL,PERIOD_H4,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            h4_up[i] = 2.0;
            h4_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            h4_dn[i] = 2.0;
            h4_up[i] = -1;
         }
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
      
      // H1
      if (Period() < 240){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_H1,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_H1,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_H1,j);
            jLow  = iLow(NULL,PERIOD_H1,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            h1_up[i] = 2.5;
            h1_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            h1_dn[i] = 2.5;
            h1_up[i] = -1;
         }
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
      
      // M30
      if (Period() < 60){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_M30,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_M30,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_M30,j);
            jLow  = iLow(NULL,PERIOD_M30,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            m30_up[i] = 3.0;
            m30_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            m30_dn[i] = 3.0;
            m30_up[i] = -1;
         }
         Etiqueta("HeatLbl_M30"," - m30",3.3, Time[0]);
      }
      
      // M15
      if (Period() < 30){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_M15,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_M15,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_M15,j);
            jLow  = iLow(NULL,PERIOD_M15,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            m15_up[i] = 3.5;
            m15_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            m15_dn[i] = 3.5;
            m15_up[i] = -1;
         }
         Etiqueta("HeatLbl_M15"," - m15",3.8, Time[0]);
      }
      
      // M5
      if (Period() < 15){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_M5,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_M5,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_M5,j);
            jLow  = iLow(NULL,PERIOD_M5,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            m5_up[i] = 4.0;
            m5_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            m5_dn[i] = 4.0;
            m5_up[i] = -1;
         }
         Etiqueta("HeatLbl_M5"," - m5 ",4.3, Time[0]);
      }
      
      // M1
      if (Period() < 5){
      
         Max_High = 0; Min_Low = 0;
         BarShift = iBarShift(NULL,PERIOD_M1,Time[i]);
         iCLOSE   = iClose(NULL,PERIOD_M1,BarShift);
         for (j=(BarShift+Periods-1); j>BarShift; j--){  
            jHigh = iHigh(NULL,PERIOD_M1,j);
            jLow  = iLow(NULL,PERIOD_M1,j);
            if (j==(BarShift+Periods-1)){
               Max_High = jHigh;
               Min_Low  = jLow;
            }else{
               if (jHigh > Max_High) Max_High = jHigh;
               if (jLow  < Min_Low)  Min_Low  = jLow;
            }
         }
         if (iCLOSE > Max_High){
            m1_up[i] = 4.5;
            m1_dn[i] = -1;
         }
         if (iCLOSE < Min_Low){
            m1_dn[i] = 4.5;
            m1_up[i] = -1;
         }
         Etiqueta("HeatLbl_M1"," - m1 ",4.8, Time[0]);
      }

      
   }
   
   Comment("");
   
      
//---- done
   return(0);
  }
  
int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind("Donchian_Oscillator_MTF_HeatMap"), tTime+Period()*60*2, dPrice);
  ObjectSetText(IndicatorObjPrefix + sName, " "+sLabel, 8, "Lucida Console", clrWhite);
  ObjectMove(IndicatorObjPrefix + sName,0,tTime+Period()*60*2, dPrice);
  return(0);
}

void Limpiar(){
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_M1");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_M5");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_M15");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_M30");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_H1");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_H4");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_D1");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_W1");
   ObjectDelete(IndicatorObjPrefix + "HeatLbl_MN1");
}