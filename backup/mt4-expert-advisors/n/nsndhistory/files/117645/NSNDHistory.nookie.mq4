// Id: 
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65708

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_buffers 1
extern int barcount=500;
extern int NSNDcount=2;

extern bool Use_ADX_Filter=true;
extern int ADX_Period=5;
extern double ADX_Level=20;

extern bool Send_Email=false;
extern bool Snow_Alert=true;

string comment[10];
static int prevtime=0;
static int prevfirstbar=0;
static double prevpricemax=0;
#property indicator_chart_window

double spread[];
datetime LastAlertTime;
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
    SetIndexStyle(0, DRAW_NONE);
    SetIndexBuffer(0, spread);  
    IndicatorName = GenerateIndicatorName("NSNDHistory.nookie");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    //----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
bool CheckADX(int index)
{
 if (!Use_ADX_Filter) return (true);
 double ADX=iADX(NULL, 0, ADX_Period, PRICE_CLOSE, MODE_MAIN, index);
 
 if (ADX>ADX_Level)
 {
  return (true);
 }
 else
 {
  return (false);
 }
}

void CallAlert(string Msg)
{
 if (Send_Email)
 {
  SendMail("NSND History Alert", Msg);
 }

 if (Snow_Alert)
 {
  Alert(Msg);
 }
 
}

bool IsNoSupply(const int i)
{
    for(int ix = i + 1; ix < i + NSNDcount + 1 && ix < Bars; ix++)
    {
        if (Close[ix] <= Close[i])
        {
            return false;
        }
        if (spread[ix] == EMPTY_VALUE || spread[ix] > spread[i])
        {
            return false;
        }
        if (Volume[ix] > Volume[i])
        {
            return false;
        }
    }
    if (MathAbs(Open[i] - Close[i]) / (High[i] - Low[i]) < 0.4)
    {
        return false;
    }
    return true;
}

bool IsNoDemand(const int i)
{
    for(int ix = i + 1; ix < i + NSNDcount + 1 && ix < Bars; ix++)
    {
        if (Close[ix] >= Close[i])
        {
            return false;
        }
        if (spread[ix] == EMPTY_VALUE || spread[ix] > spread[i])
        {
            return false;
        }
        if (Volume[ix] > Volume[i])
        {
            return false;
        }
    }
    if (MathAbs(Open[i] - Close[i]) / (High[i] - Low[i]) > 0.6)
    {
        return false;
    }
    return true;
}

int start()
  {

   int    counted_bars=IndicatorCounted();
   string obj_nameND;
   string label;
   double chartheight=WindowPriceMax()-WindowPriceMin();
   double addhigh=6.00/100.00*chartheight;
//   Comment(WindowFirstVisibleBar(),"  ",prevfirstbar);
//----
  if(WindowFirstVisibleBar()!=prevfirstbar)
  {
   prevtime=0;
  }
  if(WindowPriceMax()!=prevpricemax)
  {
   prevtime=0;
  }
    spread[0] = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
 
    if (Time[0] != prevtime)
    {
        for(int i=WindowFirstVisibleBar();i>=WindowFirstVisibleBar()-barcount && i>=0 ;i--)
        {
            label=TimeYear(Time[i])+DoubleToStr(TimeMonth(Time[i]),0)+DoubleToStr(TimeDay(Time[i]),0);
            label=label+DoubleToStr(TimeHour(Time[i]),0)+DoubleToStr(TimeMinute(Time[i]),0);  
            if (IsNoDemand(i) && CheckADX(i))
            {
                if (i==0)
                {
                    if (LastAlertTime!=Time[0])
                    {
                        LastAlertTime=Time[0];
                        CallAlert("No demand");
                    }
                }
                obj_nameND=IndicatorObjPrefix + "No Demand - "+i+" - "+label;
                ObjectCreate(obj_nameND,OBJ_TEXT,0,Time[i],High[i]+(addhigh));
                ObjectSetText(obj_nameND,"v",18,"Arial",Red);
                ObjectSet(obj_nameND,OBJPROP_PRICE1,High[i]+(addhigh));
                ObjectSet(obj_nameND,OBJPROP_TIME1,Time[i]);
                if(High[i]-Close[i]>Open[i]-Low[i])
                {
                    ObjectSetText(obj_nameND,"v",18,"Arial",Red);
                }
            }
            if(IsNoSupply(i) && CheckADX(i))
            {
                if (i==0)
                {
                    if (LastAlertTime!=Time[0])
                    {
                        LastAlertTime=Time[0];
                        CallAlert("No supply");
                    }
                }
                string obj_nameNS=IndicatorObjPrefix + "No Supply - "+i+" - "+label;
                ObjectCreate(obj_nameNS,OBJ_TEXT,0,Time[i],Low[i]);//-spread-0.0005);
                ObjectSetText(obj_nameNS,"^",22,"Arial",Lime);
                ObjectSet(obj_nameNS,OBJPROP_PRICE1,Low[i]);
                ObjectSet(obj_nameNS,OBJPROP_TIME1,Time[i]);
                if(High[i]-Open[i]<Close[i]-Low[i])
                {
                    ObjectSetText(obj_nameNS,"^",18,"Arial",Lime);
                }
            }
        }//end for i 
        prevtime=Time[0];
        prevfirstbar=WindowFirstVisibleBar();
        prevpricemax=WindowPriceMax();
    }//endif if prevtime
//---- 

    return(0);
}
  