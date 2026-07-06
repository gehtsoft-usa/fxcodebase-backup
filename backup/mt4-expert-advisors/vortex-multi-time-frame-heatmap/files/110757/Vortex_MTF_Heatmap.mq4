// Id: 17485
//+------------------------------------------------------------------+
//|                                           Vortex_MTF_HeatMap.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 16
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
#property indicator_minimum 0
#property indicator_maximum 6

//---- indicator parameters

extern int Periods    = 14;
extern int limit_bars = 1000;

//---- indicator buffers
double     w1_up1[];
double     w1_dn1[];
double     d1_up1[];
double     d1_dn1[];
double     h4_up1[];
double     h4_dn1[];
double     h1_up1[];
double     h1_dn1[];
double     m30_up1[];
double     m30_dn1[];
double     m15_up1[];
double     m15_dn1[];
double     m5_up1[];
double     m5_dn1[];
double     m1_up1[];
double     m1_dn1[];

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

//---- variables

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   int arrow = 110;
   
   SetIndexBuffer(0,w1_up1);
   SetIndexBuffer(1,w1_dn1);
   SetIndexBuffer(2,d1_up1);
   SetIndexBuffer(3,d1_dn1);
   SetIndexBuffer(4,h4_up1);
   SetIndexBuffer(5,h4_dn1);
   SetIndexBuffer(6,h1_up1);
   SetIndexBuffer(7,h1_dn1);
   SetIndexBuffer(8,m30_up1);
   SetIndexBuffer(9,m30_dn1);
   SetIndexBuffer(10,m15_up1);
   SetIndexBuffer(11,m15_dn1);
   SetIndexBuffer(12,m5_up1);
   SetIndexBuffer(13,m5_dn1);
   SetIndexBuffer(14,m1_up1);
   SetIndexBuffer(15,m1_dn1);
   
   for (int i = 0; i < 16; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndName = "Vortex MTF Heatmap";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndName = IndicatorName;
   
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
   
   if (limit_bars>0) limit = limit_bars;
      
   int mtf_i;
   int previous_mtf_w1=-1; int previous_mtf_d1=-1; int previous_mtf_h4=-1; int previous_mtf_h1=-1; int previous_mtf_m30=-1; int previous_mtf_m15=-1; int previous_mtf_m5=-1; int previous_mtf_m1=-1;
   
   double v_high_w1, v_high_d1, v_high_h4, v_high_h1, v_high_m30, v_high_m15, v_high_m5, v_high_m1;
   double v_low_w1, v_low_d1, v_low_h4, v_low_h1, v_low_m30, v_low_m15, v_low_m5, v_low_m1;
   double sum_v_high, sum_v_low, sum_atr;
   
   Limpiar();
   
   for (i=limit_bars; i>=0; i--){
      
      // Week
      if (Period() > 15 && Period() < 43200){
      
         mtf_i = iBarShift(NULL,PERIOD_W1,Time[i]);
         if (mtf_i!=previous_mtf_w1){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_W1,j) - iLow(NULL,PERIOD_W1,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_W1,j) - iHigh(NULL,PERIOD_W1,j+1));
               sum_atr    += iATR(NULL,PERIOD_W1,1,j);
            }
            v_high_w1 = sum_v_high/sum_atr * 100;
            v_low_w1 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_w1 = mtf_i;
         }
         if (v_high_w1 > 100){
            w1_up1[i] = 1.0;
            w1_dn1[i] = -1;
         }else{
            w1_up1[i] = -1;
            w1_dn1[i] = 1.0;
         }   
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
      
      // Day
      if (Period() > 5 && Period() < 10080){
      
         mtf_i = iBarShift(NULL,PERIOD_D1,Time[i]);
         if (mtf_i!=previous_mtf_d1){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_D1,j) - iLow(NULL,PERIOD_D1,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_D1,j) - iHigh(NULL,PERIOD_D1,j+1));
               sum_atr    += iATR(NULL,PERIOD_D1,1,j);
            }
            v_high_d1 = sum_v_high/sum_atr * 100;
            v_low_d1 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_d1 = mtf_i;
         }
         if (v_high_d1 > 100){
            d1_up1[i] = 1.5;
            d1_dn1[i] = -1;
         }else{
            d1_up1[i] = -1;
            d1_dn1[i] = 1.5;
         } 
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
      
      // H4
      if (Period() < 1440){
      
         mtf_i = iBarShift(NULL,PERIOD_H4,Time[i]);
         if (mtf_i!=previous_mtf_h4){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_H4,j) - iLow(NULL,PERIOD_H4,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_H4,j) - iHigh(NULL,PERIOD_H4,j+1));
               sum_atr    += iATR(NULL,PERIOD_H4,1,j);
            }
            v_high_h4 = sum_v_high/sum_atr * 100;
            v_low_h4 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_h4 = mtf_i;
         }
         if (v_high_h4 > 100){
            h4_up1[i] = 2.0;
            h4_dn1[i] = -1;
         }else{
            h4_up1[i] = -1;
            h4_dn1[i] = 2.0;
         } 
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
      
      // H1
      if (Period() < 240){
      
         mtf_i = iBarShift(NULL,PERIOD_H1,Time[i]);
         if (mtf_i!=previous_mtf_h1){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_H1,j) - iLow(NULL,PERIOD_H1,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_H1,j) - iHigh(NULL,PERIOD_H1,j+1));
               sum_atr    += iATR(NULL,PERIOD_H1,1,j);
            }
            v_high_h1 = sum_v_high/sum_atr * 100;
            v_low_h1 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_h1 = mtf_i;
         }
         if (v_high_h1 > 100){
            h1_up1[i] = 2.5;
            h1_dn1[i] = -1;
         }else{
            h1_up1[i] = -1;
            h1_dn1[i] = 2.5;
         } 
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
      
      // M30
      if (Period() < 60){
      
         mtf_i = iBarShift(NULL,PERIOD_M30,Time[i]);
         if (mtf_i!=previous_mtf_m30){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_M30,j) - iLow(NULL,PERIOD_M30,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_M30,j) - iHigh(NULL,PERIOD_M30,j+1));
               sum_atr    += iATR(NULL,PERIOD_M30,1,j);
            }
            v_high_m30 = sum_v_high/sum_atr * 100;
            v_low_m30 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_m30 = mtf_i;
         }
         if (v_high_m30 > 100){
            m30_up1[i] = 3.0;
            m30_dn1[i] = -1;
         }else{
            m30_up1[i] = -1;
            m30_dn1[i] = 3.0;
         } 
         Etiqueta("HeatLbl_M30"," - m30",3.3, Time[0]);
      }
      
      // M15
      if (Period() < 30){
      
         mtf_i = iBarShift(NULL,PERIOD_M15,Time[i]);
         if (mtf_i!=previous_mtf_m15){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_M15,j) - iLow(NULL,PERIOD_M15,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_M15,j) - iHigh(NULL,PERIOD_M15,j+1));
               sum_atr    += iATR(NULL,PERIOD_M15,1,j);
            }
            v_high_m15 = sum_v_high/sum_atr * 100;
            v_low_m15 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_m15 = mtf_i;
         }
         if (v_high_m15 > 100){
            m15_up1[i] = 3.5;
            m15_dn1[i] = -1;
         }else{
            m15_up1[i] = -1;
            m15_dn1[i] = 3.5;
         } 
         Etiqueta("HeatLbl_M15"," - m15",3.8, Time[0]);
      }
      
      // M5
      if (Period() < 15){
      
         mtf_i = iBarShift(NULL,PERIOD_M5,Time[i]);
         if (mtf_i!=previous_mtf_m5){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_M5,j) - iLow(NULL,PERIOD_M5,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_M5,j) - iHigh(NULL,PERIOD_M5,j+1));
               sum_atr    += iATR(NULL,PERIOD_M5,1,j);
            }
            v_high_m5 = sum_v_high/sum_atr * 100;
            v_low_m5 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_m5 = mtf_i;
         }
         if (v_high_m5 > 100){
            m5_up1[i] = 4.0;
            m5_dn1[i] = -1;
         }else{
            m5_up1[i] = -1;
            m5_dn1[i] = 4.0;
         } 
         Etiqueta("HeatLbl_M5"," - m5 ",4.3, Time[0]);
      }
      
      // M1
      if (Period() < 5){
      
         mtf_i = iBarShift(NULL,PERIOD_M1,Time[i]);
         if (mtf_i!=previous_mtf_m1){
            /* */
            sum_v_high = 0;
            sum_v_low  = 0;
            sum_atr    = 0;
            for (j=(i+Periods-1); j>=i; j--){  
               sum_v_high += MathAbs(iHigh(NULL,PERIOD_M1,j) - iLow(NULL,PERIOD_M1,j+1));
               sum_v_low  += MathAbs(iLow(NULL,PERIOD_M1,j) - iHigh(NULL,PERIOD_M1,j+1));
               sum_atr    += iATR(NULL,PERIOD_M1,1,j);
            }
            v_high_m1 = sum_v_high/sum_atr * 100;
            v_low_m1 = sum_v_low /sum_atr * 100;
            /* */
            previous_mtf_m1 = mtf_i;
         }
         if (v_high_m1 > 100){
            m1_up1[i] = 4.5;
            m1_dn1[i] = -1;
         }else{
            m1_up1[i] = -1;
            m1_dn1[i] = 4.5;
         } 
         Etiqueta("HeatLbl_M1"," - m1 ",4.8, Time[0]);
      }

      
   }
   
      
//---- done
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