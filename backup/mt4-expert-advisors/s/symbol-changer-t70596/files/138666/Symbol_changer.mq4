// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70596

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 0
#property strict
extern string  Symbols="AUDCAD;AUDCHF;AUDJPY;AUDNZD;AUDUSD;*;CADCHF;CADJPY;CHFJPY;*;EURAUD;EURCAD;EURCHF;EURGBP;EURJPY;EURNZD;EURUSD;*;GBPAUD;GBPCAD;GBPCHF;GBPJPY;GBPNZD;GBPUSD;*;NZDCAD;NZDCHF;NZDJPY;NZDUSD;*;USDCAD;USDCHF;USDJPY;*;XAUUSD;XAGUSD"; // List of symbols (separated by ";"
extern string  str1="";                          // and "*" new line)
extern string  prefix        = "";               // prefix Symbol
extern string  suffix        = "";               // suffix Symbol
extern string  UniqueID      = "SymbolChanger1"; // Indicator unique ID
extern int     WindowIndex   = 0;                // SubWIndow
extern int     XShift        = 8;                //  Horizontal shift
extern int     YShift        = 16;               // Vertical shift
extern int     XSize         = 90;               // Width of buttons
extern int     YSize         = 30;               // Height of buttons
extern int     FSize         = 12;                // Font size
extern color   Bcolor        = C'53,53,53';      // Button color
extern string  Ftype         = "Consolas" ;      // Font Type
extern color   Dcolor        = clrDimGray;       // Button border color
extern color   SBcolor       = clrDodgerBlue;    // Button selected color
extern color   SDcolor       = clrDeepSkyBlue;   // Button selected border color
extern color   Tncolor       = clrDarkGray;      // Text color - normal
extern color   Sncolor       = clrGold;          // Text color - selected
extern bool    Transparent   = false;            // Transparent buttons?
// extern bool    ShowTimeframe = false;            // Show Timeframe buttons
extern bool    UseAsMasterChart=true;          // Use this Chart as Master
extern string    sound="tick.wav"; // Play sound on button click
extern string ProfitLossColorInput = "===================================";
extern color  TradeInProfitBColor  = C'53,53,53';  // Trade in PROFIT background color
extern color  TradeInProfitDColor  = clrLimeGreen; // Trade in PROFIT border color
extern color  TradeInLossBColor  = clrMaroon;      // Trade in LOSS background color
extern color  TradeInLossDColor  = clrRed;         // Trade in LOSS border color
extern color  TradeInZeroBColor  = clrGray;        // Trade in ZERO or PENDING background color
extern color  TradeInZeroDColor  = clrWhite;       // Trade in ZERO or PENDING border color

//-----------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------------

string aSymbols[];
int    yswitch;
bool   visibleButtons=true;

bool ShowTimeframe=1;
int ButtonsInARow;
// ------------------------------------------------
int OnInit()
  {
   Symbols=StringTrimLeft(StringTrimRight(Symbols));
   if(StringSubstr(Symbols,StringLen(Symbols)-1,1)!=";")
      Symbols=StringConcatenate(Symbols,";");

   int s=0,i=StringFind(Symbols,";",s);
   string current;
   while(i>0)
     {
      current=StringSubstr(Symbols,s,i-s);
      if(current!="*")
         current=StringConcatenate(prefix,current,suffix);
      ArrayResize(aSymbols,ArraySize(aSymbols)+1);
      aSymbols[ArraySize(aSymbols)-1]=current;
      s = i + 1;
      i = StringFind(Symbols,";",s);
     }

   int xpos=0,ypos=0,maxx=0,maxy=0;

   yswitch=YShift+1;
   createButton(UniqueID+":master:","v",XShift,yswitch,16,16);
   ObjectSet(UniqueID+":master:",OBJPROP_BGCOLOR,White);
   ObjectSetText(UniqueID+":master:","v",FSize,Ftype,Black);
   ObjectSetString(0, UniqueID+":master:", OBJPROP_FONT, Ftype);
   ObjectSetString(WindowIndex,UniqueID+":master:",OBJPROP_TOOLTIP,"Symbol Changer");

   ypos+=YSize+1;
   for(i= 0; i<ArraySize(aSymbols); i++)
     {
      if(aSymbols[i]=="*")
        {
         xpos=0;
         ypos+=YSize+1;
        }
      else
        {
         createButton(UniqueID+":symbol:"+string(i),aSymbols[i],XShift+xpos,YShift+ypos,XSize,YSize);
         xpos+=XSize+1;
        }
     }

   xpos=0;
   ypos+=YSize*2;

   if(ShowTimeframe)
      for(i=0; i<ArraySize(sTfTable); i++)
        {
         if(i>0 && MathMod(i,ButtonsInARow)==0)
           {
            xpos=0;
            ypos+=YSize+1;
           }
         createButton(UniqueID+":time:"+string(i),sTfTable[i],XShift+xpos+25,yswitch,XSize-1,YSize-1);
         xpos+=XSize+1;
        }

   setSymbolButtonColor();
   setPeriodButtonColor();

//  if (ShowTimeframe) setTimeFrameButtonColor();

// Set MasterChart
   if(UseAsMasterChart)
      StoreChartPair();

   IndicatorShortName("");

   EventSetTimer(3);

   return(0);
  }
// ------------------------------------------------
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_CHARTCHANGE :
      case REASON_RECOMPILE   :
      case REASON_CLOSE       :
         break;
      default :
        {
         string lookFor       = UniqueID+":";
         int    lookForLength = StringLen(lookFor);
         for(int i=ObjectsTotal()-1; i>=0; i--)
           {
            string objectName=ObjectName(i);
            if(StringSubstr(objectName,0,lookForLength)==lookFor)
               ObjectDelete(objectName);
           }
        }
     }
   EventKillTimer();
  }
// ------------------------------------------------
void createButton(string name,string caption,int xpos,int ypos,int xsize,int ysize)
  {
   if(ObjectFind(name)!=0)
      ObjectCreate(0,name,OBJ_BUTTON,WindowIndex,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,xpos);
   ObjectSet(name,OBJPROP_YDISTANCE,ypos);
   ObjectSet(name,OBJPROP_XSIZE,xsize);
   ObjectSet(name,OBJPROP_YSIZE,ysize);
   ObjectSetText(name,caption,FSize,Ftype,Tncolor);
   ObjectSetString(0, name, OBJPROP_FONT, Ftype);
   ObjectSet(name,OBJPROP_FONTSIZE,FSize);
   ObjectSet(name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSet(name,OBJPROP_COLOR,Tncolor);
   ObjectSet(name,OBJPROP_BGCOLOR,Bcolor);
   ObjectSet(name,OBJPROP_BACK,Transparent);
   ObjectSet(name,OBJPROP_BORDER_COLOR,Dcolor);
   ObjectSet(name,OBJPROP_STATE,false);
   ObjectSet(name,OBJPROP_HIDDEN,true);
  }
// ------------------------------------------------
void setSymbolButtonColor()
  {
   string lookFor       = UniqueID+":symbol:";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objectName=ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         string symbol=ObjectGetString(0,objectName,OBJPROP_TEXT);
         if(symbol!=_Symbol)
            ObjectSet(objectName,OBJPROP_COLOR,Tncolor);
         else
            ObjectSet(objectName,OBJPROP_COLOR,Sncolor);
        }
     }
  }
// ------------------------------------------------
void setPeriodButtonColor()
  {
   string lookFor       = UniqueID+":time:";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objectName=ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         string period=ObjectGetString(0,objectName,OBJPROP_TEXT);
         if(stringToTimeFrame(period)!=_Period)
            ObjectSet(objectName,OBJPROP_COLOR,Tncolor);
         else
            ObjectSet(objectName,OBJPROP_COLOR,Sncolor);
        }
     }
  }
// ------------------------------------------------
void setTimeFrameButtonColor()
  {
   string lookFor       = UniqueID+":time:";
   int    lookForLength = StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string objectName=ObjectName(i);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         int time = stringToTimeFrame(ObjectGetString(0,objectName,OBJPROP_TEXT));
         if(time != _Period)
            ObjectSet(objectName,OBJPROP_COLOR,Tncolor);
         else
            ObjectSet(objectName,OBJPROP_COLOR,Sncolor);
        }
     }
  }

// ------------------------------------------------
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};
//string sTfTable[] = {"H4","D1","W1","MN"};
//int    iTfTable[] = {240,1440,10080,43200};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i])
         return(sTfTable[i]);
   return("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tf)
  {
   for(int i=ArraySize(sTfTable)-1; i>=0; i--)
      if(tf==sTfTable[i])
         return(iTfTable[i]);
   return(0);
  }
// ------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StoreChartPair()
  {
   string n="SC-"+Symbol();
   varDel("SC-");
   GlobalVariableSet(n,0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string varDel(string sVarPrefix)
  {
   string text;
   int nVar=GlobalVariablesTotal();

   for(int jVar=0; jVar<nVar; jVar++)
     {
      string sVarName=GlobalVariableName(jVar);
      int x= StringFind(sVarName, sVarPrefix);
      if(x>=0)
        {
         GlobalVariableDel(sVarName);
        }
     }

   return(text);
  }
// ------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
     {

      if(StringFind(sparam,UniqueID+":symbol:",0)==0)
         ChartSetSymbolPeriod(0,ObjectGetString(0,sparam,OBJPROP_TEXT),_Period);

      if(StringFind(sparam,UniqueID+":time:",0)==0)
         ChartSetSymbolPeriod(0,_Symbol,stringToTimeFrame(ObjectGetString(0,sparam,OBJPROP_TEXT)));
      if(StringFind(sparam,UniqueID+":back:",0)==0)
         ObjectSet(sparam,OBJPROP_STATE,false);
      if(StringFind(sparam,UniqueID+":master:",0)==0)
        {
         hideButtons();
         visibleButtons=!visibleButtons;
        }
      if(UseAsMasterChart)
         StoreChartPair();
      if(sound!="")
         PlaySound(sound);
      setSymbolButtonColorProfit();
     }
  }
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   setSymbolButtonColorProfit();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   setSymbolButtonColorProfit();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void hideButtons()
  {

   string lookFor=UniqueID+":";
   int    lookForLength=StringLen(lookFor);
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {

      string objectName=ObjectName(i);
      if(objectName==UniqueID+":master:")
         continue;
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         // ObjectDelete(objectName);
         if(visibleButtons)
            ObjectSetInteger(WindowIndex,objectName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
         else
            ObjectSetInteger(WindowIndex,objectName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setSymbolButtonColorProfit()
  {
   if(!visibleButtons)
      return;
   int tip,b,s,bo,so;
   int i;
   string objectName,symbol;
   double Profit,profit;
   string lookFor       = UniqueID+":symbol:";
   int    lookForLength = StringLen(lookFor);
   for(int j=ObjectsTotal()-1; j>=0; j--)
     {
      objectName=ObjectName(j);
      if(StringSubstr(objectName,0,lookForLength)==lookFor)
        {
         symbol=ObjectGetString(0,objectName,OBJPROP_TEXT);
         b=0;
         s=0;
         bo=0;
         so=0;
         profit=0.0;
         Profit=0.0;
         for(i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               // && (Magic == OrderMagicNumber() || Magic == -1)
               if(OrderSymbol()==symbol)
                 {
                  profit = OrderProfit()+OrderSwap()+OrderCommission();
                  Profit+= profit;
                  //                  price = OrderOpenPrice();
                  //                  lot = OrderLots();
                  tip=OrderType();
                  if(tip==OP_BUY)
                    {
                     //                     ProfitB += profit;
                     //                   price_b += price*lot;
                     b++;
                     //                     lot_b+=lot;
                    }
                  if(tip==OP_SELL)
                    {
                     //                     ProfitS += profit;
                     //                     price_s += price*lot;
                     s++;
                     //                     lot_s+=lot;
                    }
                  if(tip==OP_BUYSTOP || tip==OP_BUYLIMIT)
                    {
                     //                     price_bo += price*lot;
                     //                     lot_bo+=lot;
                     bo++;
                    }
                  if(tip==OP_SELLSTOP || tip==OP_SELLLIMIT)
                    {
                     //                     price_so += price*lot;
                     //                     lot_so+=lot;
                     so++;
                    }
                 }
              }
           }

         if(Profit>0)
           {
            ObjectSet(objectName,OBJPROP_BGCOLOR,TradeInProfitBColor);
            if(bo+so>0)
               ObjectSet(objectName,OBJPROP_BORDER_COLOR,TradeInZeroDColor);
            else
               ObjectSet(objectName,OBJPROP_BORDER_COLOR,TradeInProfitDColor);
           }
         else
           {
            if(Profit<0)
              {
               ObjectSet(objectName,OBJPROP_BGCOLOR,TradeInLossBColor);
               if(bo+so>0)
                  ObjectSet(objectName,OBJPROP_BORDER_COLOR,TradeInZeroDColor);
               else
                  ObjectSet(objectName,OBJPROP_BORDER_COLOR,TradeInLossDColor);
              }
            else
              {
               if(Profit==0.0 && b+s+bo+so>0)
                 {
                  ObjectSet(objectName,OBJPROP_BGCOLOR,TradeInZeroBColor);
                  ObjectSet(objectName,OBJPROP_BORDER_COLOR,TradeInZeroDColor);
                 }
               else
                 {
                  if(symbol!=_Symbol)
                    {
                     ObjectSet(objectName,OBJPROP_BGCOLOR,Bcolor);
                     ObjectSet(objectName,OBJPROP_BORDER_COLOR,Dcolor);
                    }
                  else
                    {
                     ObjectSet(objectName,OBJPROP_BGCOLOR,SBcolor);
                     ObjectSet(objectName,OBJPROP_BORDER_COLOR,SDcolor);
                    }
                 }
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
