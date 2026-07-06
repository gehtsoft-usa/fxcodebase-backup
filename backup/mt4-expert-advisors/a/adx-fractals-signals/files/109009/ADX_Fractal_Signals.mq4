//+------------------------------------------------------------------+
//|                                          ADX_Fractal_Signals.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 2
#property indicator_chart_window
#property indicator_color1 clrLime
#property indicator_width1 2
#property indicator_color2 clrRed
#property indicator_width2 2

extern int    ADX_Period         = 14;
extern int    CCI_Period         = 200;
extern int    CCI_Buy_Level      = 0;
extern int    CCI_Sell_Level     = 0;
extern bool   Alert_ON          = true;

double ADX[];
double DMI_Positive[];
double DMI_Negative[];
double CCI[];
double Fractal_Upper[];
double Fractal_Lower[];
double BUY[];
double SELL[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("ADX Fractal Signals");
   IndicatorBuffers(8);
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0,BUY);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1,SELL);
   
   SetIndexBuffer(2,ADX);
   SetIndexBuffer(3,DMI_Positive);
   SetIndexBuffer(4,DMI_Negative);
   SetIndexBuffer(5,CCI);
   SetIndexBuffer(6,Fractal_Upper);
   SetIndexBuffer(7,Fractal_Lower);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   string Alerta = "";
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
        
   for (i=limit; i>=0; i--){
      
      ADX[i]           = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MAIN,i);
      DMI_Positive[i]  = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,i);
      DMI_Negative[i]  = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,i);
      CCI[i]           = iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      Fractal_Upper[i] = iFractals(NULL,0,MODE_UPPER,i);
      Fractal_Lower[i] = iFractals(NULL,0,MODE_LOWER,i);
      
   }
   
   for (i=limit; i>=0; i--){
   
      //BUY:
      if (   ADX[i] > ADX[i+1] && ADX[i+1] > ADX[i+2]                                           // 1. ADX IS INCREASING IN PAST 2 BARS
          && DMI_Positive[i] > DMI_Negative[i]                                                  // 2. DMI POSITIVE> DMI NEGATIVE
          && CCI[i] > CCI_Buy_Level && CCI[i+1] > CCI_Buy_Level && CCI[i+2] > CCI_Buy_Level     // 3. CCI > BUY LEVEL IN PAST 3 BARS
          && Fractal_Lower[i] > 0                                                               // 4. APPEARANCE OF NEW SUPPORT FRACTAL(DOWN FRACTAL)
         ){
         
         BUY[i] = Low[i] - (20*pipSize);
         if (i == 0) Alerta = "ADX Fractal Signal: BUY";
         
      }
      
      //SELL:
      if (   ADX[i] > ADX[i+1] && ADX[i+1] > ADX[i+2]                                           // 1. ADX IS INCREACING IN PAST 2 BARS
          && DMI_Negative[i] > DMI_Positive[i]                                                  // 2. DMI NEGATIVE> DMI POSITIVE
          && CCI[i] < CCI_Sell_Level && CCI[i+1] < CCI_Sell_Level && CCI[i+2] < CCI_Sell_Level  // 3. CCI < SELL LEVEL IN PAST 3 BARS
          && Fractal_Upper[i] > 0                                                               // 4. APPEARANCE OF NEW RESISTANCE FRACTAL(UP FRACTAL)
         ){
         
         SELL[i] = High[i] + (20*pipSize);
         if (i == 0) Alerta = "ADX Fractal Signal: SELL";
         
      }
   
   }
   
   // Alerta
   if (Alert_ON && Time[0] > LastAlert && Alerta!=""){
      Alert(Symbol() + " " + TFToStr(Period()) + ": "+Alerta);
      LastAlert = TimeCurrent();
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