// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68676

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_label1	"HA Low/High"
#property indicator_type1		DRAW_HISTOGRAM
#property indicator_color1	clrRed
#property indicator_width1	1

#property indicator_label2	"HA High/Low"
#property indicator_type2		DRAW_HISTOGRAM
#property indicator_color2	clrRoyalBlue
#property indicator_width2	1

#property indicator_label3	"HA Down"
#property indicator_type3		DRAW_HISTOGRAM
#property indicator_color3	clrRed
#property indicator_width3	3

#property indicator_label4	"HA Up"
#property indicator_type4		DRAW_HISTOGRAM
#property indicator_color4	clrRoyalBlue
#property indicator_width4	3

input color	Color_Bullish = clrRoyalBlue;	// Bullish Color
input color	Color_Bearish = clrRed;				// Bearish Color
extern int button_x = 20;
extern int button_y = 30;

double
	buff_HA_Open[], buff_HA_Close[],
	buff_HA_HighLow[], buff_HA_LowHigh[]
;
int
	gi_Chart_Scale = WRONG_VALUE
;

string IndicatorName;
string IndicatorObjPrefix;
bool show_data = true;

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

string buttonId;

void OnDeinit(const int reason) 
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int OnInit() {
	SetIndexBuffer(0, buff_HA_LowHigh); SetIndexEmptyValue(0, 0);
	SetIndexBuffer(1, buff_HA_HighLow); SetIndexEmptyValue(1, 0);
	SetIndexBuffer(2, buff_HA_Open); SetIndexEmptyValue(2, 0);
	SetIndexBuffer(3, buff_HA_Close); SetIndexEmptyValue(3, 0);

	SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1, Color_Bearish);
	SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 1, Color_Bullish);
	f_Set_Buffers();
	
	IndicatorDigits(_Digits);
	IndicatorName = GenerateIndicatorName("Heiken Ashi (auto width candle)");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "CloseButton";
   createButton(buttonId, "Show/Hide", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
	
	return(INIT_SUCCEEDED);
}

bool recalc = true;

void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   ObjectDelete(0,buttonID);
   ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
   ObjectSetString(0,buttonID,OBJPROP_FONT,font);
   ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
   ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
}

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   if(IsStopped()) return;
	f_Set_Buffers();
}

int start() 
{
   handleButtonClicks();
	f_Set_Buffers();
   int pc = recalc ? 0 : IndicatorCounted();
	int i_Bar = fmax(1, Bars - pc + (pc > 0));
   recalc = false;
	if (pc == 0)
   {
		i_Bar--;
      if (show_data)
      {
         if(Open[i_Bar] < Close[i_Bar]) {
            buff_HA_LowHigh[i_Bar] = Low[i_Bar];
            buff_HA_HighLow[i_Bar] = High[i_Bar];
         } else {
            buff_HA_LowHigh[i_Bar] = High[i_Bar];
            buff_HA_HighLow[i_Bar] = Low[i_Bar];
         }
         buff_HA_Open[i_Bar] = Open[i_Bar];
         buff_HA_Close[i_Bar] = Close[i_Bar];
      }
      else
      {
         buff_HA_LowHigh[i_Bar] = EMPTY_VALUE;
         buff_HA_HighLow[i_Bar] = EMPTY_VALUE;
         buff_HA_Open[i_Bar] = EMPTY_VALUE;
         buff_HA_Close[i_Bar] = EMPTY_VALUE;
      }
	}
	double d_Open, d_Close, d_High, d_Low;
	
	i_Bar = fmin(Bars - 2, i_Bar);
	while(i_Bar-- > 0) 
   {
		d_Open = (buff_HA_Open[i_Bar + 1] + buff_HA_Close[i_Bar + 1]) / 2;
		d_Close = (Open[i_Bar] + High[i_Bar] + Low[i_Bar] + Close[i_Bar]) / 4;
		d_High = fmax(High[i_Bar], fmax(d_Open, d_Close));
		d_Low = fmin(Low[i_Bar], fmin(d_Open, d_Close));
		
      if (show_data)
      {
         if(d_Open < d_Close) {
            buff_HA_LowHigh[i_Bar] = d_Low;
            buff_HA_HighLow[i_Bar] = d_High;
         } else {
            buff_HA_LowHigh[i_Bar] = d_High;
            buff_HA_HighLow[i_Bar] = d_Low;
         }
         buff_HA_Open[i_Bar] = d_Open;
         buff_HA_Close[i_Bar] = d_Close;
      }
      else
      {
         buff_HA_LowHigh[i_Bar] = EMPTY_VALUE;
         buff_HA_HighLow[i_Bar] = EMPTY_VALUE;
         buff_HA_Open[i_Bar] = EMPTY_VALUE;
         buff_HA_Close[i_Bar] = EMPTY_VALUE;
      }
	}
	
	return(Bars);
}

void f_Set_Buffers() {
	int i_Chart_Scale = int(ChartGetInteger(0, CHART_SCALE));
	if(gi_Chart_Scale == i_Chart_Scale) return;
	
	gi_Chart_Scale = i_Chart_Scale;
	
	int i_Width = 0;
	switch(i_Chart_Scale) {
		case 0: i_Width = 1; break;
		case 1: i_Width = 1; break;
		case 2: i_Width = 2; break;
		case 3: i_Width = 3; break;
		case 4: i_Width = 6; break;
		case 5: i_Width = 14; break;
	}
	SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, i_Width, Color_Bearish);
	SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, i_Width, Color_Bullish);
	ChartRedraw();
}