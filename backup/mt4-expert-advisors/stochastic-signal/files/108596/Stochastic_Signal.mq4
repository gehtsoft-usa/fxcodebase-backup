//+------------------------------------------------------------------+
//|                                            Stochastic_Signal.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 4
#property indicator_separate_window
#property indicator_levelcolor clrYellow

extern int    K_Period          = 8;
extern int    D_Period          = 3;
extern int    Slowing           = 3;
extern int    OB_Level          = 80;
extern int    OS_Level          = 20;
extern color  K_Color           = clrLime;
extern color  D_Color           = clrRed;
extern color  Buy_Color         = clrAqua;
extern color  Sell_Color        = clrOrange;
extern bool   Alert_ON          = true;
extern string Comment0          = "- Types of Signals to Generate: -";
extern bool   OBOS_Rise_or_Fall = true;
extern bool   Simple_Crossover  = true;
extern bool   OBOS_Crossover    = true;

double MAIN[];
double SIGNAL[];
double BUY[];
double SELL[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Stochastic_Signal");
   IndicatorBuffers(4);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,K_Color);
   SetIndexBuffer(0,MAIN);
   SetIndexLabel(0,"Stochastic Main");
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,D_Color);
   SetIndexBuffer(1,SIGNAL);
   SetIndexLabel(1,"Stochastic Signal");
   
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Buy_Color);
   SetIndexArrow(2, 233);
   SetIndexBuffer(2,BUY);
   
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Sell_Color);
   SetIndexArrow(3, 234);
   SetIndexBuffer(3,SELL);
   
   SetLevelValue(0,OB_Level);
   SetLevelValue(1,OS_Level);
   SetLevelValue(2,50);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   string Alerta = "";
        
   for (i=limit; i>=0; i--){
      
      MAIN[i]   = iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,i);
      SIGNAL[i] = iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,i);
      
   }
   
   for (i=limit; i>=0; i--){
   
      // Stochastic simply going to the OBOS areas
      if (OBOS_Rise_or_Fall){
      
         //if ((MAIN[i] > OB_Level && MAIN[i+1] < OB_Level) || (SIGNAL[i] > OB_Level && SIGNAL[i+1] < OB_Level)){
         if (MAIN[i] > OB_Level && MAIN[i+1] < OB_Level){ // Only Main to avoid double Signal
         
            SELL[i] = OB_Level;
            if (i == 0) Alerta = "Stochastic K%/D% above OB Level: SELL";
         
         }
         
         //if ((MAIN[i] < OS_Level && MAIN[i+1] > OS_Level) || (SIGNAL[i] < OS_Level && SIGNAL[i+1] > OS_Level)){
         if (MAIN[i] < OS_Level && MAIN[i+1] > OS_Level){
         
            BUY[i] = OS_Level;
            if (i == 0) Alerta = "Stochastic K%/D% below OS Level: BUY";
         
         }
      
      }
      
      // Crossover to Buy
      if (MAIN[i] > SIGNAL[i] && MAIN[i+1] < SIGNAL[i+1]){
      
         // If it happens in the OB area
         if (OBOS_Crossover && SIGNAL[i+1] < OS_Level){
            
            BUY[i] = SIGNAL[i];
            if (i == 0) Alerta = "Stochastic K%/D% Crossover in OB Level: BUY";
            
         }
         // Or anywhere else
         else if (Simple_Crossover){
         
            BUY[i] = SIGNAL[i];
            if (i == 0) Alerta = "Simple Stochastic K%/D% Crossover: BUY";
         
         }
      
      }
      
      // Crossover to Sell
      if (MAIN[i] < SIGNAL[i] && MAIN[i+1] > SIGNAL[i+1]){
      
         // If it happens in the OS area
         if (OBOS_Crossover && SIGNAL[i+1] > OB_Level){
            
            SELL[i] = SIGNAL[i];
            if (i == 0) Alerta = "Stochastic K%/D% Crossover in OS Level: SELL";
            
         }
         // Or anywhere else
         else if (Simple_Crossover){
         
            SELL[i] = SIGNAL[i];
            if (i == 0) Alerta = "Simple Stochastic K%/D% Crossover: SELL";
         
         }
      
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