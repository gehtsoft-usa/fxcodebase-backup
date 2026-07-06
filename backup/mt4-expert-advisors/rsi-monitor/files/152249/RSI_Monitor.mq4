//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74079

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 


#property version   "2"
#property description "Clean panel that shows RSI values on all timeframes with Oversold and Overbought Notification"
#property strict
#property indicator_chart_window

input string               lb_0              = "";              // ----------- PANEL -----------
extern ENUM_BASE_CORNER    Corner            = 1;               // Panel Side
extern bool                AllowSubwindow    = true;           // Allow sub window
extern color               Pbgc              = C'10,10,10';     // Panel Backgroud color
extern color               Ptc               = clrTomato;       // Panel Title color
extern string              Pfn               = "Calibri";       // Panel Font Name
extern color               Pfc               = clrBlack;       // Panel Text Color
extern color               Pvc               = clrDodgerBlue;   // Panel Values Color
extern color               obic              = clrLime;         // OverBought icon color
extern color               osic              = clrRed;          // OverSold icon color
extern color               nic               = clrBlack;         // Normal icon color
input bool showLastCandleClose = true; // Show last candle close

input string               lb_1 = "";              // ----------- RSI -----------
extern int                 RSIPeriod         = 14;              // RSI period 
extern ENUM_APPLIED_PRICE  RSIApplied        = 0;               // RSI Applied Price 
extern double              MinRSI            = 60;              // RSI OverSold Level
extern double              MaxRSI            = 40;              // RSI OverBought Level
input string               lb_2              = "";              // ----------- NOTIFICATION -----------
input bool                 UseAlert          = false;           // Enable Alert
input bool                 UseEmail          = false;           // Enable Email
input bool                 UseNotification   = false;           // Enable Notification 
input bool                 UseSound          = true;           // Enable Sound
extern string               SoundName         = "1h.wav";    // Sound Name

string iName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   iName="RSI Monitor H1";
   IndicatorShortName(iName);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   for(int i=ObjectsTotal(); i>=0; i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,iName)==0) ObjectDelete(name);
     }
//---
  }
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
//--- draw background "webdings" font
 //  Draw("BG","ggg",25,"Webdings",Pbgc,Corner,1,1);
//--- draw background title
  // Draw("Title","RSI",10,Pfn,Ptc,Corner,70,10);
//--- define arrays and vars
   string TimeFrames[1]={"H1"};
   int period[1]={60};
   double rsi[1]={};
//--- create timeframe labels 
   for(int i=0; i<1; i++)
     {
      Draw("Period "+(string)i,TimeFrames[i],8,Pfn,Pfc,Corner,i*40+90,5);
      //--- create values and icons 
      rsi[i]=iRSI(NULL,period[i],RSIPeriod,RSIApplied,0);
      Draw("Value "+(string)i,DoubleToStr(rsi[i],1),8,Pfn,Pvc,Corner,i*30+90,20);
      //--- overbought, oversold icons and alert
      if(rsi[i]>MaxRSI)
        {
         Draw("Overbought "+(string)i,CharToStr(108),1,"Wingdings",obic,Corner,i*30+95,32);
         doAlert("RSI has entered in OVERBOUGHT Zone at "+Symbol()+" on "+PeriodToStr(period[i])+" time frame");
        }
      else if(rsi[i]<MinRSI)
        {
         Draw("Oversold "+(string)i,CharToStr(108),1,"Wingdings",osic,Corner,i*30+95,32);
         doAlert("RSI has entered in OVERSOLD Zone at "+Symbol()+" on "+PeriodToStr(period[i])+" time frame");
        }
      else Draw("Normal "+(string)i,CharToStr(108),1,"Wingdings",nic,Corner,i*30+95,32);
   }


   if(showLastCandleClose)
   {
       double rsiLast = iRSI(NULL, PERIOD_H1, RSIPeriod, RSIApplied, 1);
       Draw("Lb Last ","Last",8,Pfn,Pfc,Corner,1*40+90,5);
       Draw("Last Value", DoubleToStr(rsiLast), 8, Pfn, Pvc, Corner, 1 * 30 + 90, 20);

       color clr = rsiLast > MaxRSI ? obic : rsiLast < MinRSI ? osic : nic;
       Draw("Last Icon ", CharToStr(108), 1, "Wingdings", clr, Corner, 1 * 30 + 95, 32);
   }
   //--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| alert function
//+------------------------------------------------------------------+
bool doAlert(string message)
  {
//--- See if this bar is new and conditions are met
   static datetime TimeNow;
   if(TimeNow!=Time[0])
     {
      if(UseAlert) Alert(message);
      if(UseEmail) SendMail("RSI Notification!",message);
      if(UseSound) PlaySound(SoundName);
      if(UseNotification) SendNotification(message);
      // Store the time of the current bar, preventing further action during this bar
      TimeNow=Time[0];
      return(true);
     }
   return(false);
//---
  }
//+------------------------------------------------------------------+
//| draw function
//+------------------------------------------------------------------+
void Draw(string name,string label,int size,string font,color clr,int corner,int x,int y)
  {
//---
   name=iName+": "+name;
   int windows=0;
   if(AllowSubwindow && WindowsTotal()>1) windows=1;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,windows,0,0);
   ObjectSetText(name,label,size,font,clr);
   ObjectSet(name,OBJPROP_CORNER,corner);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
//---
  }
//+------------------------------------------------------------------+
//| Period To String - Credit to the author
//+------------------------------------------------------------------+

string PeriodToStr(int tf)
  {
//---
   if(tf == NULL) return(PeriodToStr(Period()));
   int p []={60};
   string sp[1]={"H1"};
   for(int i= 0; i < 1; i++) if(p[i] == tf) return(sp[i]);
   return("--");
//---
  }
//+-------------------------- END -----------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+