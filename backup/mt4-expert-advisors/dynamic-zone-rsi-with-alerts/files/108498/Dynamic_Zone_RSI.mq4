//+------------------------------------------------------------------+
//|                                             Dynamic_Zone_RSI.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 6
#property indicator_separate_window
#property indicator_color5 Green
#property indicator_color6 Red

extern int    RSI_Frame         = 5;
extern int    Band_Period       = 30;
extern double Std_Dev           = 1.3185;
extern color  RSI_Color         = clrBlue;
extern color  Bands_Color       = clrRed;
extern color  Middle_Line_Color = clrLime;
extern int    Bands_Width       = 1;
extern int    RSI_Width         = 2;
extern bool   Alert_ON          = true;
extern bool Show_Arrow=true;
extern int Arrow_Size=1;

double RSI[];
double TOP[];
double MIDDLE[];
double BOTTOM[];

double Up_Arrow[], Dn_Arrow[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Dynamic_Zone_RSI");
   IndicatorBuffers(4);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,RSI_Width,RSI_Color);
   SetIndexBuffer(0,RSI);
   SetIndexLabel(0,"RSI");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,Bands_Width,Bands_Color);
   SetIndexBuffer(1,TOP);
   SetIndexLabel(1,"TOP");
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,Bands_Width,Middle_Line_Color);
   SetIndexBuffer(2,MIDDLE);
   SetIndexLabel(2,"MIDDLE");
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,Bands_Width,Bands_Color);
   SetIndexBuffer(3,BOTTOM);
   SetIndexLabel(3,"BOTTOM");

   SetIndexStyle(4,DRAW_ARROW,0,Arrow_Size);
   SetIndexArrow(4,233);
   SetIndexBuffer(4,Up_Arrow);
   SetIndexStyle(5,DRAW_ARROW,0,Arrow_Size);
   SetIndexArrow(5,234);
   SetIndexBuffer(5,Dn_Arrow);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
        
   for (i=limit; i>=0; i--){
      
      RSI[i]    = iRSI(NULL,0,RSI_Frame,PRICE_CLOSE,i);
      
   }
   
   for (i=limit; i>=0; i--){
     
      TOP[i]    = iBandsOnArray(RSI,0,Band_Period,Std_Dev,0,MODE_UPPER,i);
      MIDDLE[i] = iBandsOnArray(RSI,0,Band_Period,Std_Dev,0,MODE_MAIN,i);
      BOTTOM[i] = iBandsOnArray(RSI,0,Band_Period,Std_Dev,0,MODE_LOWER,i);
      
      if (Show_Arrow)
      {
       if ((RSI[i+1]<=TOP[i+1] && RSI[i]>TOP[i]) || (RSI[i+1]<=MIDDLE[i+1] && RSI[i]>MIDDLE[i]) || (RSI[i+1]<=BOTTOM[i+1] && RSI[i]>BOTTOM[i]))
       {
        Up_Arrow[i]=RSI[i];
       }
       if ((RSI[i+1]>=TOP[i+1] && RSI[i]<TOP[i]) || (RSI[i+1]>=MIDDLE[i+1] && RSI[i]<MIDDLE[i]) || (RSI[i+1]>=BOTTOM[i+1] && RSI[i]<BOTTOM[i]))
       {
        Dn_Arrow[i]=RSI[i];
       } 
      }
      
   }
   
   if (Alert_ON && Time[0] > LastAlert){
      if (RSI[0] > TOP[0] && RSI[1] < TOP[1]){
         Alert(Symbol() + " " + TFToStr(Period()) + ": RSI Above Top Band");
         LastAlert = TimeCurrent();
      }
      if (RSI[0] < BOTTOM[0] && RSI[1] > BOTTOM[1]){
         Alert(Symbol() + " " + TFToStr(Period()) + ": RSI Below Bottom Band");
         LastAlert = TimeCurrent();
      }
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