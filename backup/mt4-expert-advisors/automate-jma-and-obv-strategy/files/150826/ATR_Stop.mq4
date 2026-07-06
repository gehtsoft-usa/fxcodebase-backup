// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73717

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
#property  link      ""
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  clrLime
#property  indicator_color2  clrRed
#property  indicator_color3  clrCornflowerBlue
#property  indicator_width3  1

#define EMPV	-1

//---- indicator parameters
extern int ATRPeriod = 14;
extern double Factor = 3;
extern bool MedianPrice = true;
extern bool MedianBase = true;
extern bool CloseBase = true;
extern double distance = 0;

//---- indicator buffers
double     up_line[];
double     dn_line[];
double     sig_dot[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	//---- drawing settings  
	SetIndexStyle(0,DRAW_LINE);
	SetIndexDrawBegin(0,ATRPeriod);
	SetIndexBuffer(0,up_line);
	SetIndexEmptyValue(0,EMPV);
	SetIndexStyle(1,DRAW_LINE);
	SetIndexDrawBegin(1,ATRPeriod);
	SetIndexBuffer(1,dn_line);
	SetIndexEmptyValue(1,EMPV);
	SetIndexStyle(2,DRAW_ARROW);
	SetIndexArrow(2,108);
	SetIndexDrawBegin(2,ATRPeriod);
	SetIndexBuffer(2,sig_dot);
	SetIndexEmptyValue(2,EMPV);

	IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
	//---- name for DataWindow and indicator subwindow label
	IndicatorShortName("BAT ATR("+ATRPeriod+" * "+Factor+")");
	SetIndexLabel(0,"Support");
	SetIndexLabel(1,"Resistance");
	//---- initialization done
	return(0);
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
{
	int counted_bars=IndicatorCounted();
	int limit;
	static int dir=1;
	double PrevUp, PrevDn;
	double CurrUp, CurrDn;
	double PriceLvl;
	double PriceHLorC;
	static double LvlUp=0,LvlDn=100000;
	//---- check for possible errors
	if (counted_bars<0) return(-1);
	//---- last counted bar will be recounted
	if (counted_bars>=ATRPeriod) limit=Bars-counted_bars;
	else limit=Bars-ATRPeriod-1;
	if (limit<0) return (-1);
	//---- fill in buffervalues
	for(int i=limit; i>0; i--) {
		if (MedianPrice) PriceLvl = (High[i] + Low[i])/2;
		else PriceLvl = Close[i];  
		
		CurrUp=PriceLvl - (iATR(NULL,0,ATRPeriod,i) * Factor);
		CurrDn=PriceLvl + (iATR(NULL,0,ATRPeriod,i) * Factor);

		up_line[i]=EMPV;
		dn_line[i]=EMPV;
		sig_dot[i]=EMPV;

		if (dir>0) {
			if (CloseBase) PriceHLorC = Close[i]; else PriceHLorC=Low[i];
			if (PriceHLorC<LvlUp) {
				dir=-1;
				LvlDn=CurrDn;
				dn_line[i]=LvlDn+distance;
				sig_dot[i]=LvlDn+distance;
			} else {
				if (CurrUp>LvlUp) LvlUp=CurrUp;
				up_line[i] = LvlUp-distance;
			}
		} else {
			if (CloseBase) PriceHLorC = Close[i]; else PriceHLorC=High[i];
			if (PriceHLorC>LvlDn) {
				dir=1;
				LvlUp=CurrUp;
				up_line[i]=LvlUp-distance;
				sig_dot[i]=LvlUp-distance;
			} else {
				if (CurrDn<LvlDn) LvlDn=CurrDn;
				dn_line[i] = LvlDn+distance;
			}
		}
	}
	sig_dot[0]=EMPV;
	CurrUp=PriceLvl - (iATR(NULL,0,ATRPeriod,0) * Factor);
	CurrDn=PriceLvl + (iATR(NULL,0,ATRPeriod,0) * Factor);
	if (dir>0) {
		if (CloseBase) PriceHLorC = Close[0]; else PriceHLorC=Low[0];
		if (PriceHLorC<LvlUp) {
			dn_line[0]=CurrDn+distance;
			sig_dot[0]=CurrDn+distance;
		} else {
			if (CurrUp>LvlUp) up_line[0] = CurrUp-distance;
			up_line[0] = LvlUp-distance;
		}
	} else {
		if (CloseBase) PriceHLorC = Close[0]; else PriceHLorC=High[0];
		if (PriceHLorC>LvlDn) {
			up_line[0]=CurrUp-distance;
			sig_dot[0]=CurrUp-distance;
		} else {
			if (CurrDn<LvlDn) dn_line[0] = CurrDn+distance;
			dn_line[0] = LvlDn+distance;
		}
	}
	//---- done
	return(0);
}
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