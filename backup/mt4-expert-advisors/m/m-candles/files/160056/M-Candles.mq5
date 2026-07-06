//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76193

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#include <Trade\Trade.mqh>

//--- input
input ENUM_TIMEFRAMES CandleTimeFrame      = PERIOD_H1;
input bool  FillCandleWithColors = false;
input int   NumberOfBar          = 100;
input color ColorUp              = clrLime;
input color ColorDown            = clrRed;
input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;
input string             btn_text              = "H1 Candle";
input string             btn_Font              = "Arial";
input int                btn_FontSize          = 8;
input color              btn_text_color        = clrWhite;
input color              btn_background_color  = clrDimGray;
input color              btn_border_color      = clrBlack;
input int                button_x              = 20;
input int                button_y              = 13;
input int                btn_Width             = 60;
input int                btn_Height            = 20;
input string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
string buttonId;
bool recalc = true;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try_ = 2;
   while (ChartWindowFind(0, name) != -1)
   {
      name = target + " #" + IntegerToString(try_++);
   }
   return name;
}

//--- Hàm tạo nút bấm
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,button_x);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,button_y);
}

//--- Xóa tất cả object với prefix
void DeleteAllObjects()
{
   for (int i=0; i<NumberOfBar; i++) {
      ObjectDelete(0, "BodyTF"   +CandleTimeFrame+"Bar" + i);
      ObjectDelete(0, "ShadowTFh"+CandleTimeFrame+"Bar" + i);
      ObjectDelete(0, "ShadowTFl"+CandleTimeFrame+"Bar" + i);
   }
}

//--- Hàm vẽ nến timeframe lớn
void DrawCandles()
{
  int shb=0;
  double po, pc, ph, pl;
  datetime to, tc, ts;
  // Kiểm tra hợp lệ ENUM_TIMEFRAMES
  if(CandleTimeFrame!=PERIOD_M1 && CandleTimeFrame!=PERIOD_M5 && CandleTimeFrame!=PERIOD_M15 && CandleTimeFrame!=PERIOD_M30 && CandleTimeFrame!=PERIOD_H1 && CandleTimeFrame!=PERIOD_H4 && CandleTimeFrame!=PERIOD_D1 && CandleTimeFrame!=PERIOD_W1 && CandleTimeFrame!=PERIOD_MN1)
  {
    Comment("CandleTimeFrame phải là 1,5,15,30,60,240,1440,10080,43200!");
    return;
  }
  int tf_sec = PeriodSeconds(CandleTimeFrame);
  if (PeriodSeconds(_Period)>tf_sec)
  {
    Comment("mCandles: CandleTimeFrame<"+_Period);
    return;
  }
  shb=0;
  while (shb<NumberOfBar)
  {
    to = iTime(_Symbol, CandleTimeFrame, shb);
    tc = to + tf_sec;
    po = iOpen(_Symbol, CandleTimeFrame, shb);
    pc = iClose(_Symbol, CandleTimeFrame, shb);
    ph = iHigh(_Symbol, CandleTimeFrame, shb);
    pl = iLow(_Symbol, CandleTimeFrame, shb);
    // Body
    string bodyName = "BodyTF"+CandleTimeFrame+"Bar"+shb;
    if(ObjectFind(0,bodyName)==-1)
      ObjectCreate(0,bodyName,OBJ_RECTANGLE,0,to,po,tc,pc);
    ObjectSetInteger(0,bodyName,OBJPROP_COLOR,po<pc?ColorUp:ColorDown);
    ObjectSetInteger(0,bodyName,OBJPROP_STYLE,STYLE_SOLID);
    ObjectSetInteger(0,bodyName,OBJPROP_WIDTH,2);
    ObjectSetInteger(0,bodyName,OBJPROP_BACK,FillCandleWithColors);
    // Shadow high
    string shName = "ShadowTFh"+CandleTimeFrame+"Bar"+shb;
    ts = to + (tf_sec)/2;
    if(ObjectFind(0,shName)==-1)
      ObjectCreate(0,shName,OBJ_TREND,0,ts,ph,ts,MathMax(po,pc));
    ObjectSetInteger(0,shName,OBJPROP_COLOR,po<pc?ColorUp:ColorDown);
    ObjectSetInteger(0,shName,OBJPROP_STYLE,STYLE_SOLID);
    ObjectSetInteger(0,shName,OBJPROP_WIDTH,3);
    ObjectSetInteger(0,shName,OBJPROP_BACK,FillCandleWithColors);
    ObjectSetInteger(0,shName,OBJPROP_RAY,false);
    // Shadow low
    string slName = "ShadowTFl"+CandleTimeFrame+"Bar"+shb;
    if(ObjectFind(0,slName)==-1)
      ObjectCreate(0,slName,OBJ_TREND,0,ts,MathMin(po,pc),ts,pl);
    ObjectSetInteger(0,slName,OBJPROP_COLOR,po<pc?ColorUp:ColorDown);
    ObjectSetInteger(0,slName,OBJPROP_STYLE,STYLE_SOLID);
    ObjectSetInteger(0,slName,OBJPROP_WIDTH,3);
    ObjectSetInteger(0,slName,OBJPROP_BACK,FillCandleWithColors);
    ObjectSetInteger(0,slName,OBJPROP_RAY,false);
    shb++;
  }
}

int OnInit()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   show_data = true;
   DeleteAllObjects();
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   buttonId = IndicatorObjPrefix + "MCandleH1";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   DeleteAllObjects();
   Comment("");
}

//--- Xử lý click nút
void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      recalc = true;
      ChartRedraw();
   }
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   handleButtonClicks();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[] ,
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(show_data)
   {
      DrawCandles();
   }
   else
   {
      DeleteAllObjects();
   }
   return(rates_total);
} 
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76193

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+