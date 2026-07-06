//+------------------------------------------------------------------+
//|                                                       VORTEX.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 4
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_color3 clrLime
#property indicator_width3 1
#property indicator_color4 clrRed
#property indicator_width4 1
#property indicator_levelcolor clrYellow

extern int   Periods            = 14;
extern int   Overbought_Level   = 150;
extern int   Oversold_Level     = 50;
extern color Up_Signal          = clrLime;
extern color Dn_Signal          = clrRed;
extern bool  Positive_OB_Signal = true;
extern bool  Positive_OS_Signal = false;
extern bool  Negative_OB_Signal = false;
extern bool  Negative_OS_Signal = true;
extern bool  Sound_Alert        = true;
extern bool  Email_Alert        = true;

double V_Pos[];
double V_Neg[];
double V_High[];
double V_Low[];
double ATR[];
double up[];
double dn[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("VORTEX");
   IndicatorBuffers(7);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,V_Pos);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,V_Neg);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,up);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,dn);
   
   SetIndexBuffer(4,V_High);
   SetIndexBuffer(5,V_Low);
   SetIndexBuffer(6,ATR);
   
   SetLevelValue(0,100);
   SetLevelValue(1,Overbought_Level);
   SetLevelValue(2,Oversold_Level);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);

}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      
      V_High[i] = MathAbs(High[i] - Low[i+1]);
      V_Low[i]  = MathAbs(Low[i] - High[i+1]);
         
   }
   
   double sum_v_high, sum_v_low, sum_atr;
   string Alerta;
   
   for(i=limit; i>=0; i--){
      
      sum_v_high = 0;
      sum_v_low  = 0;
      sum_atr    = 0;
      
      for (j=(i+Periods-1); j>=i; j--){
         
         sum_v_high += V_High[j];
         sum_v_low  += V_Low[j];
         sum_atr    += iATR(NULL,0,1,j);
      
      }
      
      V_Pos[i] = sum_v_high/sum_atr * 100;
      V_Neg[i] = sum_v_low /sum_atr * 100;
      
      Alerta = "";
      
      if (Positive_OB_Signal && V_Pos[i+1] < Overbought_Level && V_Pos[i] > Overbought_Level){
         dn[i]  = Overbought_Level;
         if (i==0) Alerta = "Vortex VI+ Overbought Signal";
      }
      if (Negative_OS_Signal && V_Neg[i+1] > Oversold_Level   && V_Neg[i] < Oversold_Level  ){
         up[i] = Oversold_Level;
         if (i==0) Alerta = "Vortex VI+ Oversold Signal";
      }
      if (Negative_OB_Signal && V_Neg[i+1] < Overbought_Level && V_Neg[i] > Overbought_Level){
         dn[i]  = Overbought_Level;
         if (i==0) Alerta = "Vortex VI- Overbought Signal";
      }
      if (Positive_OS_Signal && V_Pos[i+1] > Oversold_Level   && V_Pos[i] < Oversold_Level  ){
         up[i] = Oversold_Level;
         if (i==0) Alerta = "Vortex VI+ Oversold Signal";
      }
      
      if (i==0 && Time[0] > LastAlert && Alerta!=""){
         if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": "+Alerta);
         if (Email_Alert) SendMail("Vortex Signal", Symbol() + "," + TFToStr(Period()) + ": "+Alerta);
         LastAlert = TimeCurrent();
      }
         
   }
   
//----
   return(0);
}

string TFToStr(int tf){
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