//+------------------------------------------------------------------+
//|                                                  PVA_Overlay.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 20
#property indicator_chart_window

/* Candles */
#property indicator_color1 clrGray
#property indicator_color2 clrGray
#property indicator_color3 clrGray
#property indicator_color4 clrGray
#property indicator_color5 clrDodgerBlue
#property indicator_color6 clrDodgerBlue
#property indicator_color7 clrDodgerBlue
#property indicator_color8 clrDodgerBlue
#property indicator_color9 clrDeepPink
#property indicator_color10 clrDeepPink
#property indicator_color11 clrDeepPink
#property indicator_color12 clrDeepPink
#property indicator_color13 clrLime
#property indicator_color14 clrLime
#property indicator_color15 clrLime
#property indicator_color16 clrLime
#property indicator_color17 clrRed
#property indicator_color18 clrRed
#property indicator_color19 clrRed
#property indicator_color20 clrRed

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3
#property indicator_width9 1
#property indicator_width10 1
#property indicator_width11 3
#property indicator_width12 3
#property indicator_width13 1
#property indicator_width14 1
#property indicator_width15 3
#property indicator_width16 3
#property indicator_width17 1
#property indicator_width18 1
#property indicator_width19 3
#property indicator_width20 3

extern int    Climax_Period  = 10;
extern int    Rising_Period  = 10;
extern double Rising_Factor  = 1.;
extern double Extreme_Factor = 2.;
extern bool   Alert_ON       = true;

double V[];
double Range[];

double High_0[], Low_0[], Open_0[], Close_0[];
double High_1[], Low_1[], Open_1[], Close_1[];
double High_2[], Low_2[], Open_2[], Close_2[];
double High_3[], Low_3[], Open_3[], Close_3[];
double High_4[], Low_4[], Open_4[], Close_4[];

datetime LastAlert;
int      LastV=0;

int init(){
   
   IndicatorShortName("PVA Overlay");
   IndicatorBuffers(22);
   
   SetIndexBuffer(0,High_0);
   SetIndexBuffer(1,Low_0);
   SetIndexBuffer(2,Open_0);
   SetIndexBuffer(3,Close_0);
   SetIndexBuffer(4,High_1);
   SetIndexBuffer(5,Low_1);
   SetIndexBuffer(6,Open_1);
   SetIndexBuffer(7,Close_1);
   SetIndexBuffer(8,High_2);
   SetIndexBuffer(9,Low_2);
   SetIndexBuffer(10,Open_2);
   SetIndexBuffer(11,Close_2);
   SetIndexBuffer(12,High_3);
   SetIndexBuffer(13,Low_3);
   SetIndexBuffer(14,Open_3);
   SetIndexBuffer(15,Close_3);
   SetIndexBuffer(16,High_4);
   SetIndexBuffer(17,Low_4);
   SetIndexBuffer(18,Open_4);
   SetIndexBuffer(19,Close_4);
   
   SetIndexBuffer(20,V);
   SetIndexBuffer(21,Range);
   
   for (int i=0; i<20; i++){
      SetIndexStyle(i,DRAW_HISTOGRAM);
   }
   
   return(0);
}

int start(){
   
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int pos;
   pos=limit;
   
   while(pos>=0){
      V[pos]=Volume[pos];
      Range[pos]=(High[pos]-Low[pos])*Volume[pos];
      pos--;
   } 
   
   double MA;
   double Max;
   pos=limit;
   while(pos>=0){
      MA=iMAOnArray(V, 0, Rising_Period, 0, MODE_SMA, pos);
      Max=Range[ArrayMaximum(Range, Climax_Period, pos+1)];
   
      High_0[pos]  = iHigh(NULL,0,pos);
      Low_0[pos]   = iLow(NULL,0,pos);
      Open_0[pos]  = iOpen(NULL,0,pos);
      Close_0[pos] = iClose(NULL,0,pos);
      
      if (V[pos]>=MA*Rising_Factor){
         if (Close[pos]>Open[pos]){
            High_1[pos]  = iHigh(NULL,0,pos);
            Low_1[pos]   = iLow(NULL,0,pos);
            Open_1[pos]  = iOpen(NULL,0,pos);
            Close_1[pos] = iClose(NULL,0,pos);
            if (Alert_ON && pos==0 && Time[0] > LastAlert && LastV!=1){
               Alert(Symbol() + " " + TFToStr(Period()) + ": PVA Overlay Candle Changed Color");
               LastAlert = TimeCurrent();
               LastV = 1;
            }
         }
         else{
            High_2[pos]  = iHigh(NULL,0,pos);
            Low_2[pos]   = iLow(NULL,0,pos);
            Open_2[pos]  = iOpen(NULL,0,pos);
            Close_2[pos] = iClose(NULL,0,pos);
            if (Alert_ON && pos==0 && Time[0] > LastAlert && LastV!=2){
               Alert(Symbol() + " " + TFToStr(Period()) + ": PVA Overlay Candle Changed Color");
               LastAlert = TimeCurrent();
               LastV = 2;
            }
         }
      }
   
      if (Range[pos]>=Max || Volume[pos]>=MA*Extreme_Factor){
         if (Close[pos]>Open[pos]){
            High_3[pos]  = iHigh(NULL,0,pos);
            Low_3[pos]   = iLow(NULL,0,pos);
            Open_3[pos]  = iOpen(NULL,0,pos);
            Close_3[pos] = iClose(NULL,0,pos);
            if (Alert_ON && pos==0 && Time[0] > LastAlert && LastV!=3){
               Alert(Symbol() + " " + TFToStr(Period()) + ": PVA Overlay Candle Changed Color");
               LastAlert = TimeCurrent();
               LastV = 3;
            }
         }
         else{
            High_4[pos]  = iHigh(NULL,0,pos);
            Low_4[pos]   = iLow(NULL,0,pos);
            Open_4[pos]  = iOpen(NULL,0,pos);
            Close_4[pos] = iClose(NULL,0,pos);
            if (Alert_ON && pos==0 && Time[0] > LastAlert && LastV!=4){
               Alert(Symbol() + " " + TFToStr(Period()) + ": PVA Overlay Candle Changed Color");
               LastAlert = TimeCurrent();
               LastV = 4;
            }
         }
      }
   
      pos--;
   }
   
//----
   return(0);
}

string TFToStr(int tf)   { 
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return(""); 
}