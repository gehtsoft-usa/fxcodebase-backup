// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72039

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers   4
#property indicator_color1    Green
#property indicator_width1    4 
#property indicator_color2    Red
#property indicator_width2    4
#property indicator_color3    Green
#property indicator_width3    2 
#property indicator_color4    Red
#property indicator_width4    2

//---- input parameters
extern int       Mode   =  0; // 0-RSI method; 1-Stoch method
extern int       Length =  9; // Period
extern int       Smooth =  1; // Period of smoothing
extern int       Signal =  4; // Period of Signal Line
extern int       Price  =  0; // Price mode : 0-Close,1-Open,2-High,3-Low,4-Median,5-Typical,6-Weighted
extern int       ModeMA =  3; // Mode of Moving Average
extern int       Mode_Histo  = 3; 
//---- buffers
double Bulls[];
double Bears[];
double AvgBulls[];
double AvgBears[];
double SmthBulls[];
double SmthBears[];
double SigBulls[];
double SigBears[];

// ------------------------------------------------------------------
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
// ------------------------------------------------------------------
class CNewCandle
{
  private:
   int    _initialCandles;
   string _symbol;
   int    _tf;

  public:
   CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
   CNewCandle()
   {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
   }
   ~CNewCandle() { ; }

   bool IsNewCandle()
   {
      int _currentCandles = iBars(_symbol, _tf);
      if (_currentCandles > _initialCandles)
      {
         _initialCandles = _currentCandles;
         return true;
      }

      return false;
   }
};
CNewCandle newCandle();
class Arrow
{
  string   _name;
  datetime _iniTm;
  double   _price;
  color    _clr;
  string   _txt;
  string   _type;
  int      _count;

 public:
  Arrow() { ;}
  Arrow(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "", string inpType="up")
  {
    _name  = inpName;
    _iniTm = inpIniTm;
    _price = inpPrice;
    _clr   = inpClr;
    _txt   = inpLabelTxt;
    _type  = inpType;
  }
  ~Arrow() { ; }

  Arrow* price(double inpPrice)
  {
    _price = inpPrice;
    return &this;
  }
  Arrow* txt(string inpTxt)
  {
    _txt = inpTxt;
    return &this;
  }
  Arrow* Color(color clr)
  {
     _clr = clr;
     return &this;
  }
  Arrow* Type(string direction)
  {
     _type    = direction;
     return &this;
  }
  Arrow* candle(int shift)
  {
     _iniTm = TimeByCandles(shift);
     return &this;
  }
  
  datetime TimeByCandles(int candlesBack)
  {
     _iniTm = Time[candlesBack];
     return _iniTm;
  }

  void draw()
  {
    // draw arrow
    if(_type =="up")
    {
       _name = AutoName();
      //  _iniTm = TimeByCandles(1);
       ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, 0, 0, 0);
       ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, 233);                     // Set the arrow code
       ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_TOP);            // Set the arrow Anchor
      //  ObjectSetDouble(0, _name, OBJPROP_PRICE, iLow(Symbol(), Period(), 1) -100*_Point);  // Set price 
       ObjectSetDouble(0, _name, OBJPROP_PRICE, _price);  // Set price 
    }

    if(_type =="down")
    {
      _name = AutoName();
      // _iniTm = TimeByCandles(1);
      ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, _price, TimeCurrent(), _price);
      ObjectSetInteger(0,_name,OBJPROP_ARROWCODE,234);    // Set the arrow code 
      ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);    // Set the arrow Anchor
      // ObjectSetDouble(0,_name,OBJPROP_PRICE,iHigh(Symbol(),Period(),1)+100*_Point);// Set price 
      ObjectSetDouble(0,_name,OBJPROP_PRICE,_price);// Set price 
    }
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

    // draw label
    if (_txt != NULL) {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
      // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
    }
  }

  void erase()
  {
    ObjectDelete(0, _name);
    ObjectDelete(0, _name + "Label");
  }

  Arrow* redraw()
  {
    erase();
    draw();
    return &this;
  }

string AutoName()
{
   _count++;
   _name = "arrow ";
   return _name + _count;
}

void EraseAll()
{
  ObjectsDeleteAll(0, OBJ_ARROW);
}

};
Arrow arrows();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(0,SmthBulls);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(1,SmthBears);

   SetIndexStyle(2,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(2,SigBulls);
   SetIndexStyle(3,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(3,SigBears);

   SetIndexBuffer(4,Bulls);
   SetIndexBuffer(5,Bears);
   SetIndexBuffer(6,AvgBulls);
   SetIndexBuffer(7,AvgBears);
//---- name for DataWindow and indicator subwindow label
   string short_name="AbsoluteStrengthHistogram("+Mode+","+Length+","+Smooth+","+Signal+",,"+ModeMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Bulls");
   SetIndexLabel(1,"Bears");
   SetIndexLabel(2,"Bulls");
   SetIndexLabel(3,"Bears");      

//----
   SetIndexDrawBegin(0,Length+Smooth+Signal);
   SetIndexDrawBegin(1,Length+Smooth+Signal);
   SetIndexDrawBegin(2,Length+Smooth+Signal);
   SetIndexDrawBegin(3,Length+Smooth+Signal);
 
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);



   return(0);
  }

void OnDeinit(const int reason)
{
   arrows.EraseAll();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
  {
   int      shift, limit, counted_bars=IndicatorCounted();
   double   Price1, Price2, smax, smin;
//---- 
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-Length+Smooth+Signal-1;
   if ( counted_bars < 1 ) 
   for(int i=1;i<Length+Smooth+Signal;i++) 
   {
   Bulls[Bars-i]=0;    
   Bears[Bars-i]=0;  
   AvgBulls[Bars-i]=0;    
   AvgBears[Bars-i]=0;  
   SmthBulls[Bars-i]=0;    
   SmthBears[Bars-i]=0;  
   SigBulls[Bars-i]=0;    
   SigBears[Bars-i]=0;  
   }
   
   
   
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( shift=limit; shift>=0; shift--)
      {
      Price1 = iMA(NULL,0,1,0,0,Price,shift);
      Price2 = iMA(NULL,0,1,0,0,Price,shift+1); 
      
         if (Mode==0)
         {
         Bulls[shift] = 0.5*(MathAbs(Price1-Price2)+(Price1-Price2));
         Bears[shift] = 0.5*(MathAbs(Price1-Price2)-(Price1-Price2));
         }
        
         if (Mode==1)
         {
         smax=High[Highest(NULL,0,MODE_HIGH,Length,shift)];
         smin=Low[Lowest(NULL,0,MODE_LOW,Length,shift)];
         
         Bulls[shift] = Price1 - smin;
         Bears[shift] = smax - Price1;
         }
      }
      
      for( shift=limit; shift>=0; shift--)
      {
      AvgBulls[shift]=iMAOnArray(Bulls,0,Length,0,ModeMA,shift);     
      AvgBears[shift]=iMAOnArray(Bears,0,Length,0,ModeMA,shift);
      }
      
      for( shift=limit; shift>=0; shift--)
      {
      SmthBulls[shift]=iMAOnArray(AvgBulls,0,Smooth,0,ModeMA,shift);     
      SmthBears[shift]=iMAOnArray(AvgBears,0,Smooth,0,ModeMA,shift);
      }

      if(Mode_Histo == 1)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,5);
               SetIndexStyle(1,DRAW_LINE,EMPTY,2);
               SmthBears[shift]= SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
            else
            {
               SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,5);
               SetIndexStyle(0,DRAW_LINE,EMPTY,2);
               SmthBears[shift]= SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
         }  //end for( shift=limit; shift>=0; shift--)
      }     // end if(Mode_Histo == 1)
      else
      if(Mode_Histo == 2)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SmthBears[shift]=-SmthBears[shift]/Point;
               SmthBulls[shift]= SmthBulls[shift]/Point;
            }
            else
            {
               SmthBulls[shift]=-SmthBulls[shift]/Point;
               SmthBears[shift]= SmthBears[shift]/Point;
            }
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 2)
      else
      if(Mode_Histo == 3)
      {
         for( shift=limit; shift>=0; shift--)
         {
            SigBulls[shift]=  SmthBulls[shift];
            SigBears[shift]=  SmthBears[shift];            
            if(SmthBulls[shift]-SmthBears[shift]>0)
               SmthBears[shift]=0;
            else
               SmthBulls[shift]=0;  
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 3)
      else
      if(Mode_Histo == 4)
      {
         for( shift=limit; shift>=0; shift--)
         {
            if(SmthBulls[shift]-SmthBears[shift]>0)
            {
               SigBears[shift]=  SmthBears[shift];
               SmthBears[shift]=0;
            }
            else
            {
               SigBulls[shift]=  SmthBulls[shift];
               SmthBulls[shift]=0;         
            }
         }  //end for( shift=limit; shift>=0; shift--)      
      }     //end if(Mode_Histo == 4)
      
   //---- Arrows and Notifications:
   // int j = rates_total - prev_calculated + 1;
   int j = 100 - prev_calculated + 1;
   if (j < 0) return 0;

   // if (j >= rates_total) j = rates_total - 1;
   for (; j > 0; j--)
   {
      if (haveSignalUp(j))
      {
         // ArrowUp[j] = Low[j];

         if(ArrowsOn)
         arrows.price(Low[j]).Color(ArrowUpClr).Type("up").candle(j).draw();

         if (newCandle.IsNewCandle())
         {
            Notifications(0);
         }
      }
      if (haveSignalDown(j))
      {
         // ArrowDn[j] = High[j];
         
         if(ArrowsOn)
			arrows.price(High[j]).Color(ArrowDnClr).Type("down").candle(j).draw();
			
         if (newCandle.IsNewCandle())
         {
            Notifications(1);
         }
      }
   }
   return (0);
}
//+------------------------------------------------------------------+

bool haveSignalUp(int i)
{
   // TODO: signal up
   if (SigBulls[i + 1] <= SigBears[i + 1] && SigBulls[i] > SigBears[i])
   {
      return true;
   }

   return false;
}

bool haveSignalDown(int i)
{
   // TODO: signal down
   if (SigBulls[i + 1] >= SigBears[i + 1] && SigBulls[i] < SigBears[i])
   {
      return true;
   }

   return false;
}

void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}

