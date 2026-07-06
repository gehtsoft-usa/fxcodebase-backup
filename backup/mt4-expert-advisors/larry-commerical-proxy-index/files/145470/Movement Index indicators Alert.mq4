//+------------------------------------------------------------------+
//|Copyright 2020, Carlos Valloggia - TheTradingRobots.com
//|https://www.thetradingrobots.com
//+------------------------------------------------------------------+
#property copyright "Copyright 2021. Carlos Valloggia"
#property link "https://www.mql5.com/en/users/cvalloggia"
#property version "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2
//--- plot Linea1
#property indicator_label1 "MI_1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "MI_2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_level1 50

//--- indicator buffers
double MI1Buffer[];
double MI2Buffer[];

input string tMI1                   = "== set Movement Index 1 ==";  // == set Movement Index 1 ==
input int    Length1                = 8;
input int    Movement_Index_Period1 = 8;
input string tMI2                   = "== set Movement Index 2 ==";  // == set Movement Index 2 ==
input int    Length2                = 16;
input int    Movement_Index_Period2 = 16;
input string TZ                     = "== Notifications ==";  // Notifications
input bool   AlertTouch             = true;                   // Alert When Touch?
input bool   AlertCandle            = true;                   // Alert When Candle Cross?
input bool   drawArrows             = true;                   // Draw Arrows?
input bool   notifications          = false;                  // Notifications On
input bool   desktop_notifications  = false;                  // Desktop MT4 Notifications
input bool   email_notifications    = false;                  // Email Notifications
input bool   push_notifications     = false;                  // Push Mobile Notifications

// ------------------------------------------------------------------
class Arrow
{
  string   _name;
  datetime _iniTm;
  double   _price;
  color    _clr;
  string   _txt;
  string   _type;

 public:
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

  Arrow* fromCandle(int candle)
  {
     _iniTm  = iTime(Symbol(), Period(), candle);
     return &this;
  }

  void draw()
  {
    // draw arrow
    if(_type =="up")
    {
      ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, 0,0,0);
      ObjectSetInteger(0,_name,OBJPROP_ARROWCODE,233);    // Set the arrow code 
      ObjectSetDouble(0,_name,OBJPROP_PRICE,iLow(Symbol(),Period(),1));// Set price 
    }

    if(_type =="down")
    {
      ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, _price, TimeCurrent(), _price);
      ObjectSetInteger(0,_name,OBJPROP_ARROWCODE,234);    // Set the arrow code 
      ObjectSetDouble(0,_name,OBJPROP_PRICE,iHigh(Symbol(),Period(),1));// Set price 
    }
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

    // draw label
    if (_txt != "") {
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
};
Arrow* arrow;

class CNewCandle
{
  private:
   int    velasInicio;
   string m_symbol;
   int    m_tf;

  public:
   CNewCandle();
   CNewCandle(string symbol, int tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
   ~CNewCandle();

   bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
   // toma los valores del chart actual
   velasInicio = iBars(Symbol(), Period());
   m_symbol    = Symbol();
   m_tf        = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
   int velasActuales = iBars(m_symbol, m_tf);
   if (velasActuales > velasInicio)
   {
      velasInicio = velasActuales;
      return true;
   }

   //---
   return false;
}
CNewCandle newCandle();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   double temp = iCustom(NULL, 0, "LWPI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Movement Index' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59355");
      return INIT_FAILED;
   }
   //--- indicator buffers mapping
   SetIndexBuffer(0, MI1Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, MI2Buffer, INDICATOR_DATA);
   //---
   return (INIT_SUCCEEDED);
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
   //---
   //--- return value of prev_calculated for next call
   if (Bars <= Length1) return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return (-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2) limit = Bars - ExtCountedBars - 1;

   int pos;
   pos = limit;
   while (pos >= 0)
   {
      MI1Buffer[pos] = iCustom(NULL, 0, "Movement Index.ex4", Length1, Movement_Index_Period1, 0, pos);
      MI2Buffer[pos] = iCustom(NULL, 0, "Movement Index.ex4", Length2, Movement_Index_Period2, 0, pos);
      pos--;
   }

   if (AlertTouch)
   {
      NotificationsCrossesTouch(pos + 1);
   }

   if (newCandle.IsNewCandle())
   {
      if (AlertCandle)
      {
         NotificationsCrossesCandle(pos + 1);
         if (drawArrows)
         {
            if (UpCross(pos + 1))
            {
               drawArrowUp(pos + 1);
            }
            if (DnCross(pos + 1))
            {
               drawArrowDn(pos + 1);
            }
         }
      }
   }

   return (rates_total);
}

//+------------------------------------------------------------------+

bool UpCross(int i)
{
   if (MI1Buffer[i] > MI2Buffer[i] && MI1Buffer[i + 1] < MI2Buffer[i + 1])
   {
      return true;
   }
   return false;
}
bool DnCross(int i)
{
   if (MI1Buffer[i] < MI2Buffer[i] && MI1Buffer[i + 1] > MI2Buffer[i + 1])
   {
      return true;
   }
   return false;
}
bool UpTouch(int i)
{
   if (MI1Buffer[i] >= MI2Buffer[i] && MI1Buffer[i + 1] < MI2Buffer[i + 1])
   {
      return true;
   }
   return false;
}
bool DnTouch(int i)
{
   if (MI1Buffer[i] <= MI2Buffer[i] && MI1Buffer[i + 1] > MI2Buffer[i + 1])
   {
      return true;
   }
   return false;
}

void NotificationsCrossesTouch(int i)
{
   if (UpTouch(i))
   {
      Notifications(0);
   }
   if (DnTouch(i))
   {
      Notifications(1);
   }
}
void NotificationsCrossesCandle(int i)
{
   if (UpCross(i))
   {
      Notifications(0);
   }
   if (DnCross(i))
   {
      Notifications(1);
   }
}

void drawArrowUp(int i)
{
   arrow = new Arrow("Up" + Ask, Time[i], 0, clrBlue, "", "up");
   arrow.draw();
   delete arrow;
}

void drawArrowDn(int i)
{
   arrow = new Arrow("Dn" + Ask, Time[i], 0, clrRed, "", "down");
   arrow.draw();
   delete arrow;
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
