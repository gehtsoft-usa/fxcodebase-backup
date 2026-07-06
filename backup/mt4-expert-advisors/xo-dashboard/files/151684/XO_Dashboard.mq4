//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=73949

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
 
#property indicator_chart_window
#property indicator_buffers 1

extern double KirPER = 10;
extern color LabelColor  = LightSkyBlue;
extern int Corner        = 1;
extern color UpColor     = LimeGreen;
extern color DownColor   = Red;
extern color NetralColor = Silver;

int TF[] = {43200, 10080, 1440, 240, 60, 30, 15, 5, 1};
string Label[] = {"MN", "W1", "D1", "H4", "H1", "M30", "M15", "M5", "M1"};
double ExtBuff[];
//
double cb, valuel, valueh, CurrentBar;
double Kir, Hi, Lo, KirUp, KirDn, mode, cnt, cnt1, cur, kr, no;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0, ExtBuff, INDICATOR_DATA);
   for(int i = 0; i <= 8; i++)
     {
      ObjectCreate(Label[i], OBJ_LABEL, 0, 0, 0);
      ObjectCreate(Label[i] + " ARROW", OBJ_LABEL, 0, 0, 0);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i = 0; i <= 8; i++)
     {
      ObjectDelete(Label[i]);
      ObjectDelete(Label[i] + " ARROW");
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int val(int tf)
  {
   for(int i = 20; i >= 0; i--)
     {
      if(Kir < 1)
        {
         Hi = iClose(Symbol(), tf, i);
         Lo = iClose(Symbol(), tf, i);
         Kir = 1;
        }
      cur = (iClose(Symbol(), tf, i));
      if(cur > (Hi + KirPER * Point))
        {
         Kir = Kir + 1;
         Hi = cur;
         Lo = cur - KirPER * Point;
         KirUp = 1;
         KirDn = 0;
         kr = kr + 1;
         no = 0;
        }
      if(cur < (Lo - KirPER * Point))
        {
         Lo = cur;
         Hi = cur + KirPER * Point;
         KirUp = 0;
         KirDn = 1;
         Kir = Kir + 1;
         no = no + 1;
         kr = 0;
        }
      valueh = kr;
      valuel = 0 - no;
     }
   if(valueh > 0)
      return 1;
   if(valuel < 0)
      return 2;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObSetLabel(string name, string text, int x, int y)
  {
   ObjectSetText(name, text, 10, "Impact", LabelColor);
   ObjectSet(name, OBJPROP_CORNER, Corner);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSet(name, OBJPROP_BACK, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObSetArrow(string name, int code, int x, int y, color clr)
  {
   ObjectSetText(name, CharToStr(code), 14, "Wingdings", clr);
   ObjectSet(name, OBJPROP_CORNER, Corner);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSet(name, OBJPROP_BACK, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//----
   int X_Start = 0;
   int Y_Start = 20;
   color clr;
   for(int i = 0; i <= 8; i++)
     {
      X_Start = X_Start + 30;
      ObSetLabel(Label[i], Label[i], X_Start, Y_Start);
      if(val(TF[i]) == 1)
        {
         clr = UpColor;
         ExtBuff[i] = 1;
        }
      if(val(TF[i]) == 2)
        {
         clr = DownColor;
         ExtBuff[i] = 2;
        }
      if(val(TF[i]) == 0)
        {
         clr = NetralColor;
         ExtBuff[i] = 0;
        }
      ObSetArrow(Label[i] + " ARROW", 110, X_Start, Y_Start + 20, clr);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
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