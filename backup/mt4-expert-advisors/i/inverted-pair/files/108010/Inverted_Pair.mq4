// Id: 16616
//+------------------------------------------------------------------+
//|                                                Inverted_Pair.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 9

extern int	 Wick_Width           = 1;
extern int	 Candle_Width	       = 6;
extern color Bullish_Wick_Color   = clrAqua;
extern color Bullish_Candle_Color = clrDodgerBlue;
extern color Bearish_Wick_Color   = clrLightPink;
extern color Bearish_Candle_Color = clrCrimson;
extern color Price_Color          = clrDarkGray;

double Bullish_Wick_High[];
double Bullish_Wick_Low[];
double Bullish_Candle_High[];
double Bullish_Candle_Low[];
double Bearish_Wick_High[];
double Bearish_Wick_Low[];
double Bearish_Candle_High[];
double Bearish_Candle_Low[];
double Empty[];

string WindowName;

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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
	WindowName = StringSubstr(Symbol(),3,3)+"/"+StringSubstr(Symbol(),0,3)+" (Inverted Pair of "+Symbol()+")";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
	IndicatorBuffers(9);
					
	color BGColor = BackgroundColor();
	
	SetIndexBuffer(0,Bullish_Wick_High);
	SetIndexBuffer(1,Bullish_Candle_High);
	SetIndexBuffer(2,Bullish_Candle_Low);
	SetIndexBuffer(3,Bullish_Wick_Low);
	
	SetIndexBuffer(4,Bearish_Wick_High);
	SetIndexBuffer(5,Bearish_Candle_High);
	SetIndexBuffer(6,Bearish_Candle_Low);
	SetIndexBuffer(7,Bearish_Wick_Low);
	SetIndexBuffer(8,Empty);
	
	SetIndexStyle(0,DRAW_HISTOGRAM,0,Wick_Width,Bullish_Wick_Color);
	SetIndexStyle(1,DRAW_HISTOGRAM,0,Candle_Width,Bullish_Candle_Color);
	SetIndexStyle(2,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	SetIndexStyle(3,DRAW_HISTOGRAM,0,Wick_Width,Bullish_Wick_Color);
	
	SetIndexStyle(4,DRAW_HISTOGRAM,0,Wick_Width,Bearish_Wick_Color);
	SetIndexStyle(5,DRAW_HISTOGRAM,0,Candle_Width,Bearish_Candle_Color);
	SetIndexStyle(6,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	SetIndexStyle(7,DRAW_HISTOGRAM,0,Wick_Width,Bearish_Wick_Color);
	
	SetIndexStyle(8,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	
	SetIndexLabel(0,"Bullish High");
	SetIndexLabel(1,"Bullish Close");
	SetIndexLabel(2,"Bullish Open");
	SetIndexLabel(4,"Bearish High");
	SetIndexLabel(5,"Bearish Open");
	SetIndexLabel(6,"Bearish Close");
	SetIndexLabel(8,"Candle Low");

	return(0);
}
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
		
	for(int i = MathMax(Bars-1-IndicatorCounted(),1); i>=0; i--){

   	// Bulish Candle
   	if (Open[i]>=Close[i]){
   	
   	   Bullish_Wick_High[i]   = 1/Low[i];
   	   Bullish_Candle_High[i] = 1/Close[i];
   	   Bullish_Candle_Low[i] = 1/Open[i];
   	   Bullish_Wick_Low[i]    = 1/Open[i];   
   	
   	}
   	// Bearish Candle
   	else{
   	
   	   Bearish_Wick_High[i]   = 1/Low[i];
   	   Bearish_Candle_High[i] = 1/Open[i];
   	   Bearish_Candle_Low[i] = 1/Close[i];
   	   Bearish_Wick_Low[i]    = 1/Close[i];
   	
   	}
   	
   	// Down Empty
   	Empty[i] = 1/High[i];
		
	}
	
	Price((1/Close[0]),Price_Color);

	return(0);
}
//+------------------------------------------------------------------+

color BackgroundColor(){
   long bgcolor=clrNONE;
   ResetLastError();
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,bgcolor)){
      Print(__FUNCTION__+", Error_Code = ",GetLastError());
   }
   return((color)bgcolor);
}

void Price(double precio, color P_Color){
   ObjectDelete(IndicatorObjPrefix + "Price");
   ObjectCreate(IndicatorObjPrefix + "Price", OBJ_HLINE, WindowFind(WindowName),0,precio);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_COLOR, P_Color);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_WIDTH, 0);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_BACK, False);
}
