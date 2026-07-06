
// More information about this indicator can be found at:
// http://fxcodebase.com/

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

#property	copyright		"Copyright © 2020, Gehtsoft USA LLC"
#property	link				"http://fxcodebase.com"
#property	version			"1.00"
#property	strict

#include <stdlib.mqh>

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
 
#property indicator_level1 30
#property indicator_level2 70

#property indicator_level3 45
#property indicator_level4 55

#property	indicator_level5 50
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Volume bias index MTF" 

//--- input parameters
input	bool						IsCalledByICustom = false;
input	string					MTF_Symbol = "";
input	ENUM_TIMEFRAMES	MTF_TimeFrame = PERIOD_CURRENT;

extern int Volume_Period       = 34;
extern int Volume_Method = MODE_SMA;


extern int Smoothing_Period       = 1;
extern int Smoothing_Method = MODE_EMA;

extern int Trigger_Period       = 1;
extern int Trigger_Method = MODE_EMA;
 
 
double Bias[];
double Smoothing[];
double Trigger[];

double Up[];
double Down[];

//--- variables
string					SymbolNormalized;
ENUM_TIMEFRAMES	TimeFrameNormalized;
datetime				LastAlertTime;
datetime				LastTimeCandleOpen;

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
int	OnInit()
{
	if (MTF_Symbol == "")
	{
		SymbolNormalized	= Symbol();
	}
	else
	{
		SymbolNormalized	= MTF_Symbol;
	}
	
	if (!SymbolSelect(SymbolNormalized, true))
	{
		Alert("[Error] - [" + __FUNCTION__ + "]: Could not select symbol " + SymbolNormalized + "! Error: " + ErrorDescription(GetLastError()) + "!");
		
		return	INIT_PARAMETERS_INCORRECT;
	}
	
	if (MTF_TimeFrame == PERIOD_CURRENT)
	{
		TimeFrameNormalized	= Period();
	}
	else
	{
		TimeFrameNormalized	= MTF_TimeFrame;
		
		if (TimeFrameNormalized < Period())
		{
			Alert("[Warning] - [" + __FUNCTION__ + "]: MTF_TimeFrame is lower than chart's time frame so that chart's time frame will be used for calculation!");
			
			TimeFrameNormalized	= Period();
		}
	}
	
	datetime	tmp1 = iTime(SymbolNormalized, 0, 0);
	datetime	tmp2 = iTime(SymbolNormalized, TimeFrameNormalized, 0);
	
	LastAlertTime	= 0;
	LastTimeCandleOpen	= 0;
	
   //IndicatorName = GenerateIndicatorName("Volume bias index MTF");
   //IndicatorObjPrefix = "__" + IndicatorName + "__";
   //IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(5);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Bias);
   SetIndexLabel(0,"Bias");
   
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Smoothing);
   SetIndexLabel(1,"Smoothing");
   
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Trigger);
   SetIndexLabel(2,"Trigger");
 
   
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, Up);
   
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, Down);
	
	return	INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void	OnDeinit(const int reason)
{
	//ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int	OnCalculate(const	int				rates_total,
								const	int				prev_calculated,
								const	datetime	&time[],
								const	double		&open[],
								const	double		&high[],
								const	double		&low[],
								const	double		&close[],
								const	long			&tick_volume[],
								const	long			&volume[],
								const	int				&spread[])
{
   /*if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 2;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;*/
   
	if ((iTime(SymbolNormalized, 0, 0) != time[0]))	// need to synchronize bar before doing calculation
	{
		return	prev_calculated;
	}
	
	if ((iBars(SymbolNormalized, 0) < 2) || (rates_total < 2))
	{
		return	0;
	}
	
	int	limit = rates_total - prev_calculated;
	
	if ((prev_calculated < 2) || (prev_calculated > rates_total))
	{
		limit	= rates_total - 2;
	}
	
	/*if (LastTimeCandleOpen < iTime(SymbolNormalized, 0, 0))	// new bar?
	{
		LastTimeCandleOpen	= iTime(SymbolNormalized, 0, 0);
		
		limit++;
		
		limit	= MathMin(limit, MathMin(iBars(SymbolNormalized, 0) - 2, rates_total - 2));
	}*/
	
	if (limit > (iBars(SymbolNormalized, 0) - 2))
	{
		limit	= iBars(SymbolNormalized, 0) - 2;
	}
	
	if (TimeFrameNormalized == Period())
	{
   int pos = limit;
 
   while (pos >= 0)
   {
   
   
 
			//if( Close[pos]>= Close[pos+1])
			if (iClose(SymbolNormalized, 0, pos) >= iClose(SymbolNormalized, 0, pos + 1))
			{
			//Up[pos]= Volume[pos];
			
			Up[pos]	= iVolume(SymbolNormalized, 0, pos);
			
			Down[pos]=0;			
			}
			else
			{
			//Down[pos]= Volume[pos];
			
			Down[pos]	= iVolume(SymbolNormalized, 0, pos);
			
			Up[pos]=0;
			}
			
			
                
		 
	  
      pos--;
   } 
   
 
 
 
    pos = limit;
    double MA1;
	double MA2;
	
   while (pos >= 0)
   {
     
	 
	        MA1=iMAOnArray(Up,0,Volume_Period,0,Volume_Method,pos);
			MA2=iMAOnArray(Down,0,Volume_Period,0,Volume_Method,pos);
             
			 
			
			if (MA2!=0)
			{
   			Bias[pos]=100-(100/(1+(MA1/MA2)));
	        }
			else
			{
			Bias[pos]=0;
			
			}

       
	  
      pos--;
   } 
   
    pos = limit;
 
	
   while (pos >= 0)
   {
     
	 
	        Smoothing[pos]=iMAOnArray(Bias,0,Smoothing_Period,0,Smoothing_Method,pos);
            
			 
	  
      pos--;
   } 
   
   
       pos = limit;
 
	
   while (pos >= 0)
   {
     
	 
	        Trigger[pos]=iMAOnArray(Smoothing,0,Trigger_Period,0,Trigger_Method,pos);
				
				if (!IsCalledByICustom)
				{
					if ((pos == 1) && (Trigger[pos] > 50) && (Trigger[pos + 1] < 50) && (LastAlertTime < iTime(SymbolNormalized, 0, pos)))
					{
						Alert("[Infor] - [" + __FUNCTION__ + "]: Cross over 50 on " + SymbolNormalized + " " + EnumToString(TimeFrameNormalized) + "!");
						
						LastAlertTime	= iTime(SymbolNormalized, 0, pos);
					}
					else if ((pos == 1) && (Trigger[pos] < 50) && (Trigger[pos + 1] > 50) && (LastAlertTime < iTime(SymbolNormalized, 0, pos)))
					{
						Alert("[Infor] - [" + __FUNCTION__ + "]: Cross under 50 on " + SymbolNormalized + " " + EnumToString(TimeFrameNormalized) + "!");
						
						LastAlertTime	= iTime(SymbolNormalized, 0, pos);
					}
				}
				
      pos--;
   } 
	}
	else
	{
		int	limit_MTF = iBarShift(SymbolNormalized, TimeFrameNormalized, iTime(SymbolNormalized, 0, limit));
		int	pos_MTF = limit_MTF;
		
		while (pos_MTF >= 0)
		{
			datetime	time_MTF = iTime(SymbolNormalized, TimeFrameNormalized, pos_MTF);
			
			double	bias_MTF = iCustom(SymbolNormalized, TimeFrameNormalized, WindowExpertName(),
																	true, SymbolNormalized, TimeFrameNormalized, Volume_Period, Volume_Method, Smoothing_Period, Smoothing_Method, Trigger_Period, Trigger_Method,
																	0,
																	pos_MTF);
			double	smoothing_MTF = iCustom(SymbolNormalized, TimeFrameNormalized, WindowExpertName(),
																			true, SymbolNormalized, TimeFrameNormalized, Volume_Period, Volume_Method, Smoothing_Period, Smoothing_Method, Trigger_Period, Trigger_Method,
																			1,
																			pos_MTF);
			double	trigger_MTF = iCustom(SymbolNormalized, TimeFrameNormalized, WindowExpertName(),
																		true, SymbolNormalized, TimeFrameNormalized, Volume_Period, Volume_Method, Smoothing_Period, Smoothing_Method, Trigger_Period, Trigger_Method,
																		2,
																		pos_MTF);
			double	up_MTF = iCustom(SymbolNormalized, TimeFrameNormalized, WindowExpertName(),
																true, SymbolNormalized, TimeFrameNormalized, Volume_Period, Volume_Method, Smoothing_Period, Smoothing_Method, Trigger_Period, Trigger_Method,
																3,
																pos_MTF);
			double	down_MTF = iCustom(SymbolNormalized, TimeFrameNormalized, WindowExpertName(),
																	true, SymbolNormalized, TimeFrameNormalized, Volume_Period, Volume_Method, Smoothing_Period, Smoothing_Method, Trigger_Period, Trigger_Method,
																	4,
																	pos_MTF);
			
			int	pos_begin = iBarShift(SymbolNormalized, 0, time_MTF);
			
			if (iTime(SymbolNormalized, 0, pos_begin) < time_MTF)
			{
				pos_begin--;
			}
			
			if (pos_begin > (rates_total - 1))
			{
				pos_begin	= rates_total - 1;
			}
			
			if (pos_begin < 0)
			{
				pos_begin	= 0;
			}
			
			int	pos_end = -1;
			
			if (pos_MTF > 0)
			{
				datetime	time_MTF_Next = iTime(SymbolNormalized, TimeFrameNormalized, pos_MTF - 1);
				
				pos_end	= iBarShift(SymbolNormalized, 0, time_MTF_Next);
				
				if (iTime(SymbolNormalized, 0, pos_end) < time_MTF_Next)
				{
					pos_end--;
				}
			}
			
			for (int pos = pos_begin; pos > pos_end; pos--)
			{
				Bias[pos]	= bias_MTF;
				Smoothing[pos]	= smoothing_MTF;
				Trigger[pos]	= trigger_MTF;
				Up[pos]	= up_MTF;
				Down[pos]	= down_MTF;
			}
			
			if (!IsCalledByICustom)
			{
				if ((pos_MTF == 1) && (Trigger[pos_begin] > 50) && (Trigger[pos_begin + 1] < 50) && (LastAlertTime < time_MTF))
				{
					Alert("[Infor] - [" + __FUNCTION__ + "]: Cross over 50 on " + SymbolNormalized + " " + EnumToString(TimeFrameNormalized) + "!");
					
					LastAlertTime	= time_MTF;
				}
				else if ((pos_MTF == 1) && (Trigger[pos_begin] < 50) && (Trigger[pos_begin + 1] > 50) && (LastAlertTime < time_MTF))
				{
					Alert("[Infor] - [" + __FUNCTION__ + "]: Cross under 50 on " + SymbolNormalized + " " + EnumToString(TimeFrameNormalized) + "!");
					
					LastAlertTime	= time_MTF;
				}
			}
			
			pos_MTF--;
		}
	}
	
   return	rates_total;
}


 