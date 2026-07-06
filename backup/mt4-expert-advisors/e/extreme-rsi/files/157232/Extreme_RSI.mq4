//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75349

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrAqua
#property indicator_color2 clrRed

extern int rsiperiod   = 14; // RSI Periods:

input int  UpArrowCode = 233;            // Up Arrow Code 
input int  DnArrowCode = 234;            // Down Arrow Code 
input int  ArrowsWidth = 1;              // Arrows Width

input bool INP_Popup_Alert = true;           //Popup Alert
input bool INP_Email_Alert = false;          //Email Alert
input bool INP_Push_Alert  = false;          //Push Alert

double Up[];
double Down[];
datetime AlertTime=0;

int lastSignal = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(2);
   SetIndexBuffer(0,Up);   SetIndexStyle(0,DRAW_ARROW,1,ArrowsWidth); SetIndexArrow(0,UpArrowCode);
   SetIndexBuffer(1,Down); SetIndexStyle(1,DRAW_ARROW,1,ArrowsWidth); SetIndexArrow(1,DnArrowCode);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit= rates_total-prev_calculated;
   limit = MathMin(limit,rates_total-10);
   
   for(int i=limit;i>0;i--)
     {
//---     
   double r1 = iRSI(NULL,0,rsiperiod,PRICE_CLOSE,i);
   double r2 = iRSI(NULL,0,rsiperiod,PRICE_CLOSE,i+1);  
//---
    if (r1<70 && r2>70 && (lastSignal == 1 ||  lastSignal == 0))
       {
        Down[i]=High[i]+iATR(Symbol(),0,Period(),i)/2.0;
        lastSignal = -1;
       }
  
    if (r1>30 && r2<30 && (lastSignal == -1 ||  lastSignal == 0))
       { 
        Up[i]=Low[i]-iATR(Symbol(),0,Period(),i)/2.0; 
        lastSignal = 1;
       }     
 
  
//--- Buy Alert
      if(Up[1]!= EMPTY_VALUE && AlertTime!=Time[0])
        {
         AlertTime=Time[0];
         SendAlert(StringConcatenate("Buy Signal On | ",Symbol()," | ",TF_Str()," | ",Time[0]));
        }  

//--- Sell Alert
      if(Down[1]!= EMPTY_VALUE && AlertTime!=Time[0]) 
        {
         AlertTime=Time[0];
         SendAlert(StringConcatenate("Sell Signal On | ",Symbol()," | ",TF_Str()," | ",Time[0]));
        }
     }
  return(0); 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string msg)
  {
   if(INP_Popup_Alert)  Alert(msg);
   if(INP_Email_Alert)  SendMail("Alert",msg);
   if(INP_Push_Alert)   SendNotification(msg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TF_Str()
  {
   int tf = Period();
   if(tf >= 43200)      return("MN");
   if(tf >= 10080)      return("W1");
   if(tf >=  1440)      return("D1");
   if(tf >=   240)      return("H4");
   if(tf >=    60)      return("H1");
   if(tf >=    30)      return("M30");
   if(tf >=    15)      return("M15");
   if(tf >=     5)      return("M5");
   if(tf >=     1)      return("M1");
   return("");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 