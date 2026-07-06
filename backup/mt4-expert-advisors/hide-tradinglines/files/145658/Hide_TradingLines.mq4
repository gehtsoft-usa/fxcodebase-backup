// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=27&t=72034

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
#property version   "1.00"

#property indicator_chart_window

input bool magicNumberFilter = false;
input color tradeLineColor = clrWhite;
input ENUM_LINE_STYLE   tradeLineStyle = 0;
input int tradeLineWidth = 1;
input color slLineColor = clrRed;
input ENUM_LINE_STYLE   slLineStyle = 0;
input int slLineWidth = 1;
input color tpLineColor = clrGreen;
input ENUM_LINE_STYLE   tpLineStyle = 0;
input int tpLineWidth = 1;

input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
input string             btn_text              = "Hide";
input string             btn_Font              = "Impact";
input int                btn_FontSize          = 10;                             //btn__font size
input color              btn_text_color        = clrWhite;
input color              btn_background_color  = clrDarkRed;
input color              btn_border_color      = clrBlack;
input int                button_x              = 240;                                     //btn__x
input int                button_y              = 20;                                     //btn__y
input int                btn_Width             = 100;                                 //btn__width
input int                btn_Height            = 20;                                //btn__height
input string             button_note2          = "------------------------------";

input string             field_note1             = "------------------------------";
input ENUM_BASE_CORNER   field_corner            = CORNER_LEFT_LOWER; // chart field_corner for anchoring
input string             field_text                = "Magic Number";
input string             field_Font                = "Impact";
input int                field_FontSize            = 10;      //field__font size
input color              field_Text_Color        = clrWhite;
input color              field_Background_Color  = clrDarkRed;
input color              field_Border_Color      = clrBlack;
input int                field_x                 = 240;
input int                field_y                 = 40;
input int                field_Width             = 100;
input int                field_Height            = 20;
input string             field_note2             = "------------------------------";



static bool show_data ;
string IndicatorName, IndicatorObjPrefix;
static string magicNumber = "Magic number";
bool read_original_color = false;
color original_trade_color, original_stop_color;
string buttonId, Fieldname;
int init()
  {
   IndicatorName = "Hide_Tradingline";
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if(GlobalVariableGet(IndicatorName + "_visibility") == 0)
      show_data = false;
   else
      show_data = true;
   buttonId = IndicatorObjPrefix + "CloseButton";
   Fieldname = IndicatorObjPrefix + "Magic";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   if(ObjectFind(0, Fieldname) < 0)
     {
      CreateInput(Fieldname);
      ObjectSetInteger(0, Fieldname, OBJPROP_YDISTANCE, field_y);
      ObjectSetInteger(0, Fieldname, OBJPROP_XDISTANCE, field_x);
     }
   if(!read_original_color)
     {
      original_trade_color = ChartGetInteger(0, CHART_COLOR_VOLUME);
      original_stop_color = ChartGetInteger(0, CHART_COLOR_STOP_LEVEL);
      read_original_color = true;
     }
   ChartSetInteger(0, CHART_COLOR_VOLUME, clrNONE);
   ChartSetInteger(0, CHART_COLOR_STOP_LEVEL, clrNONE);
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(0, buttonID);
   ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(0, buttonID, OBJPROP_FONT, font);
   ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateInput(string Fieldname)
  {
   ObjectCreate(0, Fieldname, OBJ_EDIT, 0, 0, 0);
   ObjectSetString(0, Fieldname, OBJPROP_TEXT, "Magic number");
   ObjectSetInteger(0, Fieldname, OBJPROP_XSIZE, field_Width);
   ObjectSetInteger(0, Fieldname, OBJPROP_YSIZE, field_Height);
   ObjectSetInteger(0, Fieldname, OBJPROP_CORNER, field_corner);
   ObjectSetInteger(0, Fieldname, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, Fieldname, OBJPROP_FONTSIZE, field_FontSize);
   ObjectSetInteger(0, Fieldname, OBJPROP_BGCOLOR, field_Background_Color);
   ObjectSetInteger(0, Fieldname, OBJPROP_COLOR, field_Text_Color);
   ObjectSetInteger(0, Fieldname, OBJPROP_BORDER_COLOR, field_Border_Color);
   ObjectSetInteger(0, Fieldname, OBJPROP_BACK, 0);
   ObjectSetInteger(0, Fieldname, OBJPROP_ZORDER, 110);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int reason)
  {
   if(reason != 3 && reason != 5)
     {
      ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
     }
   ChartSetInteger(0, CHART_COLOR_VOLUME, original_trade_color);
   ChartSetInteger(0, CHART_COLOR_STOP_LEVEL, original_stop_color);
   return 0;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(show_data)
     {
      show_data = false;
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
     }
   else
     {
      show_data = true;
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
     }
   start();
  }


//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK &&  sparam == buttonId)
     {
      handleButtonClicks();
     }
   if(id == CHARTEVENT_CLICK || id == CHARTEVENT_OBJECT_ENDEDIT)
     {
      magicNumber = ObjectGetString(0, Fieldname, OBJPROP_TEXT);
      if(magicNumber == "" || magicNumber == "0")
        {
         ObjectSetString(0, Fieldname, OBJPROP_TEXT, "Magic number");
        }
      start();
     }
  }
//+------------------------------------------------------------------+
int start()
  {
   magicNumber = ObjectGetString(0, Fieldname, OBJPROP_TEXT);
   int mn = StringToInteger(magicNumber);
   if(show_data)
     {
      ObjectsDeleteAll(0, IndicatorObjPrefix, 0, OBJ_HLINE);
      for(int pos = 0; pos < OrdersTotal(); pos++)
        {
         OrderSelect(pos, SELECT_BY_POS);
         if(OrderSymbol() == _Symbol)
           {
            if((magicNumberFilter && OrderMagicNumber() == (int)magicNumber && (int)magicNumber > 0) || !magicNumberFilter)
              {
               ProcessLines(true, OrderOpenPrice(), OrderStopLoss(), OrderTakeProfit(), OrderTicket());
              }
           }
        }
     }
   else
     {
      ProcessLines(false);
     }
   return 0;
  }
//+------------------------------------------------------------------+
void ProcessLines(bool show, double openPrice = 0, double slPrice = 0, double tpPrice = 0, int ticket = 0)
  {
   string name = IndicatorObjPrefix + "_" + ticket;
   if(show)
     {
      ObjectCreate(0, name + "_open", OBJ_HLINE, 0, 0, openPrice);
      ObjectSetInteger(0, name + "_open", OBJPROP_COLOR, tradeLineColor);
      ObjectSetInteger(0, name + "_open", OBJPROP_WIDTH, tradeLineWidth);
      ObjectSetInteger(0, name + "_open", OBJPROP_STYLE, tradeLineStyle);
      ObjectCreate(0, name + "_sl", OBJ_HLINE, 0, 0, slPrice);
      ObjectSetInteger(0, name + "_sl", OBJPROP_COLOR, slLineColor);
      ObjectSetInteger(0, name + "_sl", OBJPROP_WIDTH, slLineWidth);
      ObjectSetInteger(0, name + "_sl", OBJPROP_STYLE, slLineStyle);
      ObjectCreate(0, name + "_tp", OBJ_HLINE, 0, 0, tpPrice);
      ObjectSetInteger(0, name + "_tp", OBJPROP_COLOR, tpLineColor);
      ObjectSetInteger(0, name + "_tp", OBJPROP_WIDTH, tpLineWidth);
      ObjectSetInteger(0, name + "_tp", OBJPROP_STYLE, tpLineStyle);
     }
   else
     {
      ObjectsDeleteAll(0, IndicatorObjPrefix, 0, OBJ_HLINE);
     }
  }
//+------------------------------------------------------------------+
