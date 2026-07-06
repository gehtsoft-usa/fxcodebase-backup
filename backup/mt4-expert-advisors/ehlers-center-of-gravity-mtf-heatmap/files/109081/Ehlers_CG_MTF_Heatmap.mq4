// Id: 17029
//+------------------------------------------------------------------+
//|                                        Ehlers_CG_MTF_HeatMap.mq4 |
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
#property  indicator_buffers 36
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
#property indicator_color19 clrGreen
#property indicator_color20 clrMaroon
#property indicator_color21 clrGreen
#property indicator_color22 clrMaroon
#property indicator_color23 clrGreen
#property indicator_color24 clrMaroon
#property indicator_color25 clrGreen
#property indicator_color26 clrMaroon
#property indicator_color27 clrGreen
#property indicator_color28 clrMaroon
#property indicator_color29 clrGreen
#property indicator_color30 clrMaroon
#property indicator_color31 clrGreen
#property indicator_color32 clrMaroon
#property indicator_color33 clrGreen
#property indicator_color34 clrMaroon
#property indicator_color35 clrGreen
#property indicator_color36 clrMaroon
#property indicator_minimum 0
#property indicator_maximum 6

//---- indicator parameters

extern int Lenght     = 10;
extern int limit_bars = 500;

//---- indicator buffers
double     mn_up1[];
double     mn_dn1[];
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

double     mn_up2[];
double     mn_dn2[];
double     w1_up2[];
double     w1_dn2[];
double     d1_up2[];
double     d1_dn2[];
double     h4_up2[];
double     h4_dn2[];
double     h1_up2[];
double     h1_dn2[];
double     m30_up2[];
double     m30_dn2[];
double     m15_up2[];
double     m15_dn2[];
double     m5_up2[];
double     m5_dn2[];
double     m1_up2[];
double     m1_dn2[];

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
int init()
  {
    double temp = iCustom(NULL, 0, "Ehlers_CG", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Ehlers_CG' indicator");
       return INIT_FAILED;
   }
   //---- drawing settings
//   IndicatorBuffers(3);
   
   int arrow = 110;
   
   SetIndexBuffer(0,mn_up1);
   SetIndexBuffer(1,mn_dn1);
   SetIndexBuffer(2,w1_up1);
   SetIndexBuffer(3,w1_dn1);
   SetIndexBuffer(4,d1_up1);
   SetIndexBuffer(5,d1_dn1);
   SetIndexBuffer(6,h4_up1);
   SetIndexBuffer(7,h4_dn1);
   SetIndexBuffer(8,h1_up1);
   SetIndexBuffer(9,h1_dn1);
   SetIndexBuffer(10,m30_up1);
   SetIndexBuffer(11,m30_dn1);
   SetIndexBuffer(12,m15_up1);
   SetIndexBuffer(13,m15_dn1);
   SetIndexBuffer(14,m5_up1);
   SetIndexBuffer(15,m5_dn1);
   SetIndexBuffer(16,m1_up1);
   SetIndexBuffer(17,m1_dn1);
   
   SetIndexBuffer(18,mn_up2);
   SetIndexBuffer(19,mn_dn2);
   SetIndexBuffer(20,w1_up2);
   SetIndexBuffer(21,w1_dn2);
   SetIndexBuffer(22,d1_up2);
   SetIndexBuffer(23,d1_dn2);
   SetIndexBuffer(24,h4_up2);
   SetIndexBuffer(25,h4_dn2);
   SetIndexBuffer(26,h1_up2);
   SetIndexBuffer(27,h1_dn2);
   SetIndexBuffer(28,m30_up2);
   SetIndexBuffer(29,m30_dn2);
   SetIndexBuffer(30,m15_up2);
   SetIndexBuffer(31,m15_dn2);
   SetIndexBuffer(32,m5_up2);
   SetIndexBuffer(33,m5_dn2);
   SetIndexBuffer(34,m1_up2);
   SetIndexBuffer(35,m1_dn2);
   
   for (int i = 0; i < 36; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
      SetIndexLabel(i,"");
   }
   
   IndName = "Ehlers Center of Gravity MTF Heatmap";
   IndicatorName = GenerateIndicatorName(IndName);
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
   
   if (limit_bars>0) limit = limit_bars;
      
   int mtf_i;
   int previous_mtf_mn1=-1; int previous_mtf_w1=-1; int previous_mtf_d1=-1; int previous_mtf_h4=-1;
   int previous_mtf_h1=-1; int previous_mtf_m30=-1; int previous_mtf_m15=-1; int previous_mtf_m5=-1; int previous_mtf_m1=-1;
   double cog_mn1, cog_w1, cog_d1, cog_h4, cog_h1, cog_m30, cog_m15, cog_m5, cog_m1;
   double cog1_mn1, cog1_w1, cog1_d1, cog1_h4, cog1_h1, cog1_m30, cog1_m15, cog1_m5, cog1_m1;
   
   Limpiar();
   
   for (i=limit_bars; i>=0; i--){
      
      // Month
      mtf_i = iBarShift(NULL,PERIOD_MN1,Time[i]);
      if (mtf_i!=previous_mtf_mn1){
         cog_mn1 = COG(PERIOD_MN1, mtf_i,0);
         cog1_mn1= COG(PERIOD_MN1, mtf_i,1);
         previous_mtf_mn1 = mtf_i;
      }
      if (cog_mn1 > 0){
         if (cog_mn1 > cog1_mn1){
            mn_up1[i] = 0.5;
            mn_dn1[i] = -1;
            mn_up2[i] = -1;
            mn_dn2[i] = -1;
         }else{
            mn_up1[i] = -1;
            mn_dn1[i] = -1;
            mn_up2[i] = 0.5;
            mn_dn2[i] = -1;
         }
      }else{
         if (cog_mn1 < cog1_mn1){
            mn_up1[i] = -1;
            mn_dn1[i] = 0.5;
            mn_up2[i] = -1;
            mn_dn2[i] = -1;
         }else{
            mn_up1[i] = -1;
            mn_dn1[i] = -1;
            mn_up2[i] = -1;
            mn_dn2[i] = 0.5;
         }
      }
      Etiqueta("HeatLbl_MN1"," - MN1",0.8, Time[0]);
      
      // Week
      if (Period() < 43200){
      
         mtf_i = iBarShift(NULL,PERIOD_W1,Time[i]);
         if (mtf_i!=previous_mtf_w1){
            cog_w1 = COG(PERIOD_W1, mtf_i, 0);
            cog1_w1= COG(PERIOD_W1, mtf_i, 1);
            previous_mtf_w1 = mtf_i;
         }
         if (cog_w1 > 0){
            if (cog_w1 > cog1_w1){
               w1_up1[i] = 1.0;
               w1_dn1[i] = -1;
               w1_up2[i] = -1;
               w1_dn2[i] = -1;
            }else{
               w1_up1[i] = -1;
               w1_dn1[i] = -1;
               w1_up2[i] = 1.0;
               w1_dn2[i] = -1;
            }
         }else{
            if (cog_w1 < cog1_w1){
               w1_up1[i] = -1;
               w1_dn1[i] = 1.0;
               w1_up2[i] = -1;
               w1_dn2[i] = -1;
            }else{
               w1_up1[i] = -1;
               w1_dn1[i] = -1;
               w1_up2[i] = -1;
               w1_dn2[i] = 1.0;
            }
         }      
         Etiqueta("HeatLbl_W1"," - W1 ",1.3, Time[0]);
      }
      
      // Day
      if (Period() < 10080){
      
         mtf_i = iBarShift(NULL,PERIOD_D1,Time[i]);
         if (mtf_i!=previous_mtf_d1){
            cog_d1 = COG(PERIOD_D1, mtf_i, 0);
            cog1_d1= COG(PERIOD_D1, mtf_i, 1);
            previous_mtf_d1 = mtf_i;
         }
         if (cog_d1 > 0){
            if (cog_d1 > cog1_d1){
               d1_up1[i] = 1.5;
               d1_dn1[i] = -1;
               d1_up2[i] = -1;
               d1_dn2[i] = -1;
            }else{
               d1_up1[i] = -1;
               d1_dn1[i] = -1;
               d1_up2[i] = 1.5;
               d1_dn2[i] = -1;
            }
         }else{
            if (cog_d1 < cog1_d1){
               d1_up1[i] = -1;
               d1_dn1[i] = 1.5;
               d1_up2[i] = -1;
               d1_dn2[i] = -1;
            }else{
               d1_up1[i] = -1;
               d1_dn1[i] = -1;
               d1_up2[i] = -1;
               d1_dn2[i] = 1.5;
            }
         }
         Etiqueta("HeatLbl_D1"," - D1 ",1.8, Time[0]);
      }
      
      // H4
      if (Period() < 1440){
      
         mtf_i = iBarShift(NULL,PERIOD_H4,Time[i]);
         if (mtf_i!=previous_mtf_h4){
            cog_h4 = COG(PERIOD_H4, mtf_i, 0);
            cog1_h4= COG(PERIOD_H4, mtf_i, 1);
            previous_mtf_h4 = mtf_i;
         }
         if (cog_h4 > 0){
            if (cog_h4 > cog1_h4){
               h4_up1[i] = 2.0;
               h4_dn1[i] = -1;
               h4_up2[i] = -1;
               h4_dn2[i] = -1;
            }else{
               h4_up1[i] = -1;
               h4_dn1[i] = -1;
               h4_up2[i] = 2.0;
               h4_dn2[i] = -1;
            }
         }else{
            if (cog_h4 < cog1_h4){
               h4_up1[i] = -1;
               h4_dn1[i] = 2.0;
               h4_up2[i] = -1;
               h4_dn2[i] = -1;
            }else{
               h4_up1[i] = -1;
               h4_dn1[i] = -1;
               h4_up2[i] = -1;
               h4_dn2[i] = 2.0;
            }
         }
         Etiqueta("HeatLbl_H4"," - H4 ",2.3, Time[0]);
      }
      
      // H1
      if (Period() < 240){
      
         mtf_i = iBarShift(NULL,PERIOD_H1,Time[i]);
         if (mtf_i!=previous_mtf_h1){
            cog_h1 = COG(PERIOD_H1, mtf_i, 0);
            cog1_h1= COG(PERIOD_H1, mtf_i, 1);
            previous_mtf_h1 = mtf_i;
         }
         if (cog_h1 > 0){
            if (cog_h1 > cog1_h1){
               h1_up1[i] = 2.5;
               h1_dn1[i] = -1;
               h1_up2[i] = -1;
               h1_dn2[i] = -1;
            }else{
               h1_up1[i] = -1;
               h1_dn1[i] = -1;
               h1_up2[i] = 2.5;
               h1_dn2[i] = -1;
            }
         }else{
            if (cog_h1 < cog1_h1){
               h1_up1[i] = -1;
               h1_dn1[i] = 2.5;
               h1_up2[i] = -1;
               h1_dn2[i] = -1;
            }else{
               h1_up1[i] = -1;
               h1_dn1[i] = -1;
               h1_up2[i] = -1;
               h1_dn2[i] = 2.5;
            }
         }
         Etiqueta("HeatLbl_H1"," - H1 ",2.8, Time[0]);
      }
      
      // M30
      if (Period() < 60){
      
         mtf_i = iBarShift(NULL,PERIOD_M30,Time[i]);
         if (mtf_i!=previous_mtf_m30){
            cog_m30 = COG(PERIOD_M30, mtf_i, 0);
            cog1_m30= COG(PERIOD_M30, mtf_i, 1);
            previous_mtf_m30 = mtf_i;
         }
         if (cog_m30 > 0){
            if (cog_m30 > cog1_m30){
               m30_up1[i] = 3.0;
               m30_dn1[i] = -1;
               m30_up2[i] = -1;
               m30_dn2[i] = -1;
            }else{
               m30_up1[i] = -1;
               m30_dn1[i] = -1;
               m30_up2[i] = 3.0;
               m30_dn2[i] = -1;
            }
         }else{
            if (cog_m30 < cog1_m30){
               m30_up1[i] = -1;
               m30_dn1[i] = 3.0;
               m30_up2[i] = -1;
               m30_dn2[i] = -1;
            }else{
               m30_up1[i] = -1;
               m30_dn1[i] = -1;
               m30_up2[i] = -1;
               m30_dn2[i] = 3.0;
            }
         }
         Etiqueta("HeatLbl_M30"," - m30",3.3, Time[0]);
      }
      
      // M15
      if (Period() < 30){
      
         mtf_i = iBarShift(NULL,PERIOD_M15,Time[i]);
         if (mtf_i!=previous_mtf_m15){
            cog_m15 = COG(PERIOD_M15, mtf_i, 0);
            cog1_m15= COG(PERIOD_M15, mtf_i, 1);
            previous_mtf_m15 = mtf_i;
         }
         if (cog_m15 > 0){
            if (cog_m15 > cog1_m15){
               m15_up1[i] = 3.5;
               m15_dn1[i] = -1;
               m15_up2[i] = -1;
               m15_dn2[i] = -1;
            }else{
               m15_up1[i] = -1;
               m15_dn1[i] = -1;
               m15_up2[i] = 3.5;
               m15_dn2[i] = -1;
            }
         }else{
            if (cog_m15 < cog1_m15){
               m15_up1[i] = -1;
               m15_dn1[i] = 3.5;
               m15_up2[i] = -1;
               m15_dn2[i] = -1;
            }else{
               m15_up1[i] = -1;
               m15_dn1[i] = -1;
               m15_up2[i] = -1;
               m15_dn2[i] = 3.5;
            }
         }
         Etiqueta("HeatLbl_M15"," - m15",3.8, Time[0]);
      }
      
      // M5
      if (Period() < 15){
      
         mtf_i = iBarShift(NULL,PERIOD_M5,Time[i]);
         if (mtf_i!=previous_mtf_m5){
            cog_m5 = COG(PERIOD_M5, mtf_i, 0);
            cog1_m5= COG(PERIOD_M5, mtf_i, 1);
            previous_mtf_m5 = mtf_i;
         }
         if (cog_m5 > 0){
            if (cog_m5 > cog1_m5){
               m5_up1[i] = 4.0;
               m5_dn1[i] = -1;
               m5_up2[i] = -1;
               m5_dn2[i] = -1;
            }else{
               m5_up1[i] = -1;
               m5_dn1[i] = -1;
               m5_up2[i] = 4.0;
               m5_dn2[i] = -1;
            }
         }else{
            if (cog_m5 < cog1_m5){
               m5_up1[i] = -1;
               m5_dn1[i] = 4.0;
               m5_up2[i] = -1;
               m5_dn2[i] = -1;
            }else{
               m5_up1[i] = -1;
               m5_dn1[i] = -1;
               m5_up2[i] = -1;
               m5_dn2[i] = 4.0;
            }
         }
         Etiqueta("HeatLbl_M5"," - m5 ",4.3, Time[0]);
      }
      
      // M1
      if (Period() < 5){
      
         mtf_i = iBarShift(NULL,PERIOD_M1,Time[i]);
         if (mtf_i!=previous_mtf_m1){
            cog_m1 = COG(PERIOD_M1, mtf_i, 0);
            cog1_m1= COG(PERIOD_M1, mtf_i, 1);
            previous_mtf_m1 = mtf_i;
         }
         if (cog_m1 > 0){
            if (cog_m1 > cog1_m1){
               m1_up1[i] = 4.5;
               m1_dn1[i] = -1;
               m1_up2[i] = -1;
               m1_dn2[i] = -1;
            }else{
               m1_up1[i] = -1;
               m1_dn1[i] = -1;
               m1_up2[i] = 4.5;
               m1_dn2[i] = -1;
            }
         }else{
            if (cog_m1 < cog1_m1){
               m1_up1[i] = -1;
               m1_dn1[i] = 4.5;
               m1_up2[i] = -1;
               m1_dn2[i] = -1;
            }else{
               m1_up1[i] = -1;
               m1_dn1[i] = -1;
               m1_up2[i] = -1;
               m1_dn2[i] = 4.5;
            }
         }
         Etiqueta("HeatLbl_M1"," - m1 ",4.8, Time[0]);
      }

      
   }
   
      
//---- done
   return(0);
}

double COG(int TF, int shift, int mode = 0){
   
   return(iCustom(NULL, TF, "Ehlers_CG", Lenght, mode, shift));
   
}
  
int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
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