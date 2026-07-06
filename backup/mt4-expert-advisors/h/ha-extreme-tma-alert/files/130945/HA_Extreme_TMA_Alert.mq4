// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69354

//--+------------------------------------------------------------------+
//--|                               Copyright © 2020, Gehtsoft USA LLC | 
//--|                                            http://fxcodebase.com |
//--+------------------------------------------------------------------+
//--|                                      Developed by : Mario Jemic  |                    
//--|                                          mario.jemic@gmail.com   |
//--|                           https://AppliedMachineLearning.systems |
//--+------------------------------------------------------------------+
//--|                                 Support our efforts by donating  | 
//--|                                    Paypal: https://goo.gl/9Rj74e |
//--+------------------------------------------------------------------+
//--|                                Patreon :  https://goo.gl/GdXWeN  |  
//--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//--+------------------------------------------------------------------+


#property description "Alert will be given if HA trend changes occur outside TMA Line band"

#property indicator_buffers 5
#property indicator_chart_window
#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_color2 clrOliveDrab
#property indicator_width2 1
#property indicator_style2 STYLE_DASH
#property indicator_color3 clrOliveDrab
#property indicator_width3 1
#property indicator_style3 STYLE_DASH
#property indicator_color4 clrLime
#property indicator_width4 2
#property indicator_color5 clrRed
#property indicator_width5 2

extern int    TMA_Period  = 56;
extern int    ATR_Period  = 100;
extern double AtrMult     = 2.0;
extern bool   Sound_Alert = true;
extern bool   Email_Alert = true;

double TMA[];
double TOP[];
double BOT[];
double Up[];
double Dn[];

datetime LastAlert;

int init()
{
   IndicatorShortName("HA Extreme TMA Line Alert");
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TMA);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TOP);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BOT);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,Up);
   SetIndexArrow(3,233);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,234);
   SetIndexBuffer(4,Dn);
   
   return(0);
}

int start()
{
   int i, j, k;
   int counted_bars=IndicatorCounted();
   int limit = MathMax(1, Bars-counted_bars-1);
   
   double sum, sumw, range;
   double Open0, Open1, Close0, Close1;
   
   for (i=limit; i>=0; i--)
   {
      sum  = (TMA_Period+1)*iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i);
      sumw = (TMA_Period+1);
      for(j=1, k=TMA_Period; j<=TMA_Period; j++, k--)
      {
         sum  += k*iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i+j);
         sumw += k;
         if (j<=i)
         {
            sum  += k*iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i-j);
            sumw += k;
         }
      }
      range = iATR(NULL,0,ATR_Period,i+10)*AtrMult;
      TMA[i] = sum/sumw;
      TOP[i] = TMA[i]+range;
      BOT[i] = TMA[i]-range;

      Open0  = iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i);
      Close0 = iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i);
      Open1  = iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,2,i+1);
      Close1 = iCustom(NULL,0,"Heiken Ashi",clrRed,clrWhite,clrRed,clrWhite,3,i+1);
      
      if (Close[i] > TOP[i] && Open0 > Close0 && Open1 < Close1)
      {
         Dn[i] = High[i];
         if (i == 1 && Time[0] > LastAlert)
         {
            if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": HA Extreme TMA - SELL!");
            if (Email_Alert) SendMail("HA Extreme TMA Signal", Symbol() + "," + TFToStr(Period()) + ": HA Extreme TMA - SELL!");
            LastAlert = TimeCurrent();
         }
      }
      
      if (Close[i] < BOT[i] && Open0 < Close0 && Open1 > Close1)
      {
         Up[i] = Low[i];
         if (i == 1 && Time[0] > LastAlert)
         {
            if (Sound_Alert) Alert(Symbol() + "," + TFToStr(Period()) + ": HA Extreme TMA - BUY!");
            if (Email_Alert) SendMail("HA Extreme TMA Signal", Symbol() + "," + TFToStr(Period()) + ": HA Extreme TMA - BUY!");
            LastAlert = TimeCurrent();
         }
      }
   }
   
   return(0);
}
  
string TFToStr(int tf)
{
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
