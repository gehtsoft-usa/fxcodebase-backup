// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71263

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 8

#define X_BARSPACING		   22
#define Y_BARSPACING		   1
#define BAR_STR				"I"
#define BAR_ANGLE			   90
#define X_BASELINE0			0
#define X_BASELINE1			200
#define X_BASELINE2			500
#define X_CUROFF			   0
#define X_DIVOFF			   -5
#define Y_BASELINE0			70
#define Y_BASELINE1			70
#define Y_BASELINE2			85
#define Y_BASELINE3			135
#define Y_BASELINE4			138
#define FTSIZE_BAR			13
#define FTSIZE_CUR			7
#define FTSIZE_SYM			6
#define SCALE				   10000
#define PIXEL_SCALE			0.5
#define SUGCHT_HEIGHT		40
#define LINECHARTHEIGHT0	50
#define LINECHARTHEIGHT1	90

#define MAX					   50
#define MIN					   -50

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Timeframe
int		StrengthBase	= 1;
int		RecentCHBase	= 1;
input bool    SessionStrength = true;
input int     DefaultBars    = 20;
input int     LineWidth      = 2;
int            MaxBars        = 10000;
int		      LineChartBars	= 10000;
input string	Currencies		= "USD,EUR,GBP,JPY,CHF,CAD,AUD,NZD";
input string	CurrDisplay		= "1,1,1,1,1,1,1,1";
input string	SymbolFixes		= "";									//for irregular Symbols
input string	ShowSignal		= "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
input bool		ShowLineChart	= true;
input bool		ShowBarChart	= false;
input bool		UpdateOnTick	= true;
input bool		AllowAlert		= false;
input bool		AllowSound		= false;
input int		MinimumAlertInterval	= 30;
input int		LegendOffsetY	= 20;
input int		MeterPosition	= 20;
input color	BullColor		= LimeGreen;
input color	BearColor		= Red;
input color	Color0			= Magenta;
input color	Color1			= Blue;
input color	Color2			= Red;
input color	Color3			= Gold;
input color	Color4			= Gray;
input color	Color5			= LimeGreen;
input color	Color6			= Orange;
input color	Color7			= DeepSkyBlue;
input color	TextColor		= Black;
input int bars_limit = 1000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double out[];
int StartHour;

datetime	   gSymbolLastNotifyTime[];

double	   oLine0[],oLine1[],oLine2[],oLine3[],oLine4[],oLine5[],oLine6[],oLine7[];
double		gPairBuffer[],gPairLineBuffer[][8],gSymbolWeight[],gCurrencyWeight[];

string		gCurrencyArray[],gSymbolArray[];
string		gPrefix,gSuffix;

color		   gCurrencyColor[8];

bool		   gShow[],gShowSymbol[];

int			gCurrencyCount,gSymbols;
int			gBarCount,gWindow,gXoffset,gYoffset;
int			gSymbolCurrencyLeft[],gSymbolCurrencyRight[];
int			gSymbolLastNotifyDirection[],gSymbolNotifyList[];

void OnInit()
{
   gBarCount=0;
	setPairs();
	gXoffset=MeterPosition;
   IndicatorObjPrefix = GenerateIndicatorPrefix("SMSession");
   IndicatorSetString(INDICATOR_SHORTNAME, "SMSession");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(out, EMPTY_VALUE);
   }
   if (!UpdateOnTick) 
   {
      if (gBarCount==iBars(Symbol(),_Period)) 
         return(0);
      gBarCount=iBars(Symbol(),_Period);
   }

   ObjectsDeleteAll(gWindow);
   drawLines();
   drawMeter();
   return rates_total;
}

void drawLabel(string name, int x, int y, 
				string text, color clr, double angle=90,
				int fontsize=12, string font="Arial")
{
   string id = IndicatorObjPrefix + name;
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, id, OBJPROP_FONT, font);
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontsize);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetDouble(0, id, OBJPROP_ANGLE, angle);
   }
   ObjectSetString(0, id, OBJPROP_TEXT, text);
}

void drawTexts()
{
   int j = 0;
	for (int i = 0; i < gCurrencyCount; i++) 
	{
		if (!gShow[i]) 
		   continue;
		   
		string name = "0_" + i + "_SYM";
		drawLabel(name, j * X_BARSPACING + X_BASELINE0 + X_CUROFF, Y_BASELINE0, gCurrencyArray[i], gCurrencyColor[i], 0, 12);
		name = "1_" + i + "_SYM";
		drawLabel(name, j * X_BARSPACING + X_BASELINE1 + X_CUROFF, Y_BASELINE0, gCurrencyArray[i], gCurrencyColor[i], 0, 12);
		j++;
	}
}

void drawBars(int section,int isym,double level)
{
	int i, x, y0, ystep, yend, b;
	static int offsetX[] = { X_BASELINE0, X_BASELINE1, X_BASELINE2 };
	string name;
	color clr;
	x = offsetX[section] + isym * X_BARSPACING;
	if (level > 0) 
	{
		b = MathRound(level * PIXEL_SCALE);
		yend = Y_BASELINE1 - b;
		y0 = Y_BASELINE1;
		ystep = -Y_BARSPACING;
		clr = BullColor;
	}
	else 
	{
		b = MathRound(-level * PIXEL_SCALE);
		yend = Y_BASELINE2 + b;
		y0 = Y_BASELINE2;
		ystep = Y_BARSPACING;
		clr = BearColor;
	}
	
	b = b / Y_BARSPACING;
	for (i = 0; i < b; i++) 
	{
		name= section + "_" + isym + "_" + i;
		drawLabel(name,x,y0+i*ystep,BAR_STR,clr);
	}
	
	return;
}

void DrawLine(string ZeroLine, color LineColor, double LinePrice, int WinNum)
{
   ResetLastError();
   string id = IndicatorObjPrefix + ZeroLine;
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, LinePrice))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, LineColor);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_DOT);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, LinePrice);
}

bool findNaddPair(int left,int right,int c)
{
	string sym=makeSymbol(left,right);
	int s=lookupSymbol(sym);

	if (s<0) 
	{
		if (testSym(sym)) 
		{
			gSymbolArray[gSymbols]=sym;
			gSymbolCurrencyLeft[gSymbols]=left;
			gSymbolCurrencyRight[gSymbols]=right;
			gSymbols++;
		} 
		else 
		   return(false);
	}
	return (true);
}

string makeSymbol(int left, int right)
{
 	return gPrefix + gCurrencyArray[left] + gCurrencyArray[right] + gSuffix;
}

int lookupSymbol(string sym)
{
	for (int i=0;i<gSymbols;i++)
		if (gSymbolArray[i]==sym) 
		   return (i);
	return (-1);
}

bool testSym(string sym)
{
	GetLastError();
	
	if (iBars(sym,_Period)>0) 
	   return (true);
	   
	int error=GetLastError();
	if (4066==error) 
	{
		Print("Waiting for data of [",sym,"].");
		return (true);
	}
	
	return (false);
}

string normalizeStr(string s,string div)
{
   StringTrimRight(s);
	StringTrimLeft(s);
   string workstr = s;
	
	if (StringSubstr(workstr,StringLen(workstr),1) != div)
		workstr = workstr + div;

	return (workstr);
}

void calc(int start,int end,int bars_back, int pairbufferlength)
{
	int i,j,l,r;
	double ratio,base;
	double weight[];
	
	ArrayResize(weight,gCurrencyCount); //gCurrencyCount = 8
	
	for (i=0;i<gCurrencyCount;i++) 
	   weight[i]=gCurrencyWeight[i];
	
	ArrayInitialize(gPairBuffer,0);
	
	for (i=0;i<gSymbols;i++) 
	{
		l=gSymbolCurrencyLeft[i];
		r=gSymbolCurrencyRight[i];
		l*=pairbufferlength;
		r*=pairbufferlength;
		
		for (j=0;j<pairbufferlength;j++) 
		{
			base=iOpen(gSymbolArray[i],_Period,bars_back);
		
			if (base==0) 
			   continue;
			   
			ratio=iClose(gSymbolArray[i],_Period,j)/base;
			gPairBuffer[l+j]+=gSymbolWeight[i]*ratio;
			gPairBuffer[r+j]+=gSymbolWeight[i]/ratio;
		}
	}
	
	for (i=0;i<gCurrencyCount;i++)  //gCurrencyCount = 8
	{
		l=i*pairbufferlength;
		
		for (j=0;j<pairbufferlength;j++) 
		{
			if (weight[i]==0) 
			   continue;
			   
			gPairBuffer[l+j]/=weight[i];
			gPairBuffer[l+j]-=SCALE;
		}
	}

}

void drawMeter()
{
	int i,j,k;
	double value,level,max,min;
	int sdir[],rdir[];
	
	ArrayResize(sdir,gCurrencyCount);
	ArrayResize(rdir,gCurrencyCount);
	ArrayInitialize(sdir,0);
	ArrayInitialize(rdir,0);

	calc(0,0,StrengthBase,1);

	max=0;min=0;
	
	for (i=0;i<gCurrencyCount;i++) 
	{
		value=gPairBuffer[i];
		
		if (value>0) 
		{
			sdir[i]=1;
			
			if (value>max) 
			   max=value;
		}
		else if (value<0) 
		{
			sdir[i]=-1;
			
			if (value<min) 
			   min=value;
		}
	}

	if (ShowBarChart) 
	{
		k=0;
		
		for (i=0;i<gCurrencyCount;i++) 
		{
			if (!gShow[i]) 
			   continue;
			   
			value=gPairBuffer[i];
			
			if (value>0) 
			   level=MathRound(100*value/max);
			else 
			   level=-MathRound(100*value/min);
			   
			drawBars(0,k,level);
			k++;
		}
	}

	calc(0,0,RecentCHBase,1);

	max=0;min=0;
	
	for (i=0;i<gCurrencyCount;i++) 
	{
		value=gPairBuffer[i];
		
		if (value>0) 
		{
			rdir[i]=1;
			
			if (value>max) 
			   max=value;
		}
		else if (value<0) 
		{
			rdir[i]=-1;
			
			if (value<min) 
			   min=value;
		}
	}

	if (ShowBarChart) 
	{
		k=0;
		
		for (i=0;i<gCurrencyCount;i++) 
		{
			if (!gShow[i]) 
			   continue;
			   
			value=gPairBuffer[i];
			
			if (value>0) 
			   level=MathRound(100*value/max);
			else 
			   level=-MathRound(100*value/min);
			   
			drawBars(1,k,level);
			k++;
		}
		
		drawTexts();
	}

	string sym,name;
	int symidx;
	k=0;
	
	for (i=0;i<gCurrencyCount;i++) 
	{
		if (!gShow[i]) 
		   continue;
		   
		if (sdir[i]!=rdir[i]) 
		   continue;
		   
		for (j=i+1;j<gCurrencyCount;j++) 
		{
			if (!gShow[j]) 
			   continue;
			   
			if (sdir[j]!=rdir[j]) 
			   continue;
			   
			if (sdir[i]==sdir[j]) 
			   continue;
			   
			sym=makeSymbol(i,j);
			symidx=lookupSymbol(sym);
			
			if (symidx<0) 
			{
				sym=makeSymbol(j,i);
				symidx=lookupSymbol(sym);
				
				if (symidx<0) 
				   continue;
				   
				if (sdir[i]>0) 
				   level=-SUGCHT_HEIGHT;
				else 
				   level=SUGCHT_HEIGHT;
			}
			else
			{
   			if (sdir[i]>0) 
   			   level=SUGCHT_HEIGHT;
   			else 
   			   level=-SUGCHT_HEIGHT;
         }
         			
			if (!gShowSymbol[symidx]) 
			   continue;
			   
			if (ShowBarChart) 
			{
				drawBars(2,k*2,level);
				name= "_" + k + "_DIV";
				drawLabel(name,k*2*X_BARSPACING+X_BASELINE2+X_DIVOFF,Y_BASELINE0,sym,TextColor,0,FTSIZE_SYM);
			}
			
			gSymbolNotifyList[symidx]=level;
			k++;
		}
	}

	if (AllowAlert || AllowSound) 
	   doNotify();
}

void drawLegend()
{
	int i,y;
	string name;

	y=FTSIZE_CUR*2;
	
	if (ShowBarChart) 
	   y+=LegendOffsetY+Y_BASELINE0+100*PIXEL_SCALE;

	for (i=0;i<gCurrencyCount;i++) 
	{
		name = i + "_LEGT";
		drawLabel(name,i*X_BARSPACING+X_BASELINE0+X_CUROFF,y,gCurrencyArray[i],gCurrencyColor[i],0,FTSIZE_CUR);
		
		if (!gShow[i] || i>=8) 
		   continue;
		
		name = i + "_LEGL";
		drawLabel(name,i*X_BARSPACING+X_BASELINE0+X_CUROFF,y+3," ___",gCurrencyColor[i],0,FTSIZE_CUR);
	}
}

void drawLines()
{
	int i,j,bm;
	double k,b,max,min,upper,lower;
	if(SessionStrength)
	{
     	LineChartBars = DefaultBars;
   }

	calc(0,LineChartBars,LineChartBars-1,LineChartBars);
	lower=MIN;
	
	if (!ShowLineChart) 
	   return;
	   
	if (ShowBarChart) 
	   upper=(LINECHARTHEIGHT0*MAX+(100-LINECHARTHEIGHT0)*MIN)/100;
	else 
	   upper=(LINECHARTHEIGHT1*MAX+(100-LINECHARTHEIGHT1)*MIN)/100;
	   
	max=0;
	min=0;
	
	for (i=0;i<gCurrencyCount;i++) 
	{
		bm=i*LineChartBars;
		
		for (j=0;j<LineChartBars;j++) 
		{
			if (gPairBuffer[bm+j]>max) 
			   max=gPairBuffer[bm+j];
			   
			if (gPairBuffer[bm+j]<min) 
			   min=gPairBuffer[bm+j];
		} 
	}
	
	if (max-min==0) 
	   return;
	
	k=(upper-lower)/(max-min);
	b=lower-min*k;
	
	for (i=0;i<gCurrencyCount && i<8;i++) 
	{
		if (!gShow[i]) 
		   continue;
		   
		bm=i*LineChartBars;
		int bars = iBars(_Symbol, _Period);
		for (j=0;j<MathMin(bars, LineChartBars);j++) 
		{
			switch (i) 
			{
   			case 0:
               oLine0[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 1:
               oLine1[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 2:
               oLine2[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 3:
               oLine3[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 4:
               oLine4[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 5:
               oLine5[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 6:
               oLine6[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
   			case 7:
               oLine7[bars - 1 - j]=k*gPairBuffer[bm+j]+b;
               break;
			}
		}
	}
	
	int WindowNum = ChartWindowFind();
   DrawLine("Zero line Session", Silver, k*gPairBuffer[7*LineChartBars+LineChartBars-1]+b, WindowNum);

	drawLegend();
}

void create(int id, color clr)
{
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, clr);
   PlotIndexSetString(id, PLOT_LABEL, gCurrencyArray[id]);
   gCurrencyColor[id] = clr;
}
void setPairs()
{
	int i,j,k,s;
	string current,workstr;
	
	workstr = normalizeStr(SymbolFixes,",");
	s=0;i=StringFind(workstr,",",s);

	if (i>0) 
	   gPrefix = StringSubstr(workstr,s,i-s);
	else 
	   gPrefix="";
	   
	s=i+1;i=StringFind(workstr,",",s);
	if (i>s) 
	   gSuffix = StringSubstr(workstr,s,i-s);
	else 
	   gSuffix="";

	workstr = normalizeStr(Currencies,",");
   StringSplit(workstr, ',', gCurrencyArray);
   gCurrencyCount = ArraySize(gCurrencyArray);
	
	ArrayResize(gSymbolArray,(gCurrencyCount-1)*gCurrencyCount/2);
	ArrayResize(gSymbolCurrencyLeft,(gCurrencyCount-1)*gCurrencyCount/2);
	ArrayResize(gSymbolCurrencyRight,(gCurrencyCount-1)*gCurrencyCount/2);
	ArrayResize(gPairBuffer,LineChartBars*gCurrencyCount);
	ArrayResize(gCurrencyWeight,gCurrencyCount);
	ArrayResize(gShow,gCurrencyCount);

	gSymbols=0;
	
	for (i=0;i<gCurrencyCount;i++) 
	{
		k=0;current="";
		for (j=0;j<gCurrencyCount;j++) 
		{
			if (i==j) 
			   continue;
			if (findNaddPair(i,j,i)) 
			{
			   k++;
			   current=current+"["+makeSymbol(i,j)+"]";
			   continue;
			}
			
			if (findNaddPair(j,i,i)) 
			{
			   k++;
			   current=current+"["+makeSymbol(j,i)+"]";
			   continue;
			}
		}

		if (k>0) 
		{
			Print (k," Symbols found for currency [",gCurrencyArray[i],"]:",current);
			continue;
		}

		Print ("No symbol found for currency [",gCurrencyArray[i],"], removed from list.");
		gCurrencyCount--;
		for (j=i;j<gCurrencyCount;j++) 
		   gCurrencyArray[j]=gCurrencyArray[j+1];
		   
		i--;
	}
	
	ArrayResize(gShowSymbol,gSymbols);
	ArrayResize(gSymbolWeight,gSymbols);
	ArrayResize(gSymbolLastNotifyDirection,gSymbols);
	ArrayResize(gSymbolLastNotifyTime,gSymbols);
	ArrayResize(gSymbolNotifyList,gSymbols);
	ArrayInitialize(gCurrencyWeight,0);
	ArrayInitialize(gSymbolLastNotifyDirection,0);
	ArrayInitialize(gSymbolLastNotifyTime,0);
	ArrayInitialize(gSymbolNotifyList,0);
	ArrayInitialize(gSymbolWeight,100);
	
	for (i=0;i<gSymbols;i++) 
	{
		gCurrencyWeight[gSymbolCurrencyLeft[i]]+=gSymbolWeight[i];
		gCurrencyWeight[gSymbolCurrencyRight[i]]+=gSymbolWeight[i];
		gSymbolWeight[i]*=SCALE;
		gShowSymbol[i]=false;
	}
	
	workstr = normalizeStr(ShowSignal,",");
	s = 0;i = StringFind(workstr,",",s);
	
	while (i > 0)
	{
		if (i-s>0) 
		{
			current = StringSubstr(workstr,s,i-s);
			k=lookupSymbol(gPrefix + current + gSuffix);
			if (k>=0) 
			{
				gShowSymbol[k]=true;
			}
		}
		
		s = i + 1;
		i = StringFind(workstr,",",s);
	}
	
	current="";
	
	for (i=0;i<gSymbols;i++) 
	   if (gShowSymbol[i]) 
	      current=current + "[" + gSymbolArray[i] + "]";

	Print("Show signal of ",current);
	Print("Symbols setting finished.");
	
	int lines;
	if (gCurrencyCount>8) 
	   lines=8;
	else 
	   lines=gCurrencyCount;
	   
	if (lines > 0)
   {
      SetIndexBuffer(0, oLine0, INDICATOR_DATA);
      create(0, Color0);
   }
	if (lines>1)
   {
      SetIndexBuffer(1, oLine1, INDICATOR_DATA);
      create(1, Color1);
   }
	if (lines>2)
   {
      SetIndexBuffer(2, oLine2, INDICATOR_DATA);
      create(2, Color2);
   }
	if (lines>3)
   {
      SetIndexBuffer(3, oLine3, INDICATOR_DATA);
      create(3, Color3);
   }
	if (lines>4)
   {
      SetIndexBuffer(4, oLine4, INDICATOR_DATA);
      create(4, Color4);
   }
	if (lines>5)
   {
      SetIndexBuffer(5, oLine5, INDICATOR_DATA);
      create(5, Color5);
   }
	if (lines>6)
   {
      SetIndexBuffer(6, oLine6, INDICATOR_DATA);
      create(6, Color6);
   }
	if (lines>7)
   {
      SetIndexBuffer(7, oLine7, INDICATOR_DATA);
      create(7, Color7);
   }
	
	for (i=0;i<lines;i++) 
	   gShow[i]=true;
	   
	workstr = normalizeStr(CurrDisplay,",");
	j=0;
	s=0;
	i = StringFind(workstr,",",s);
	
	while (i>=0 && j<lines) 
	{
		k = StringToInteger(StringSubstr(workstr,s,i-s));
		
		if (k==0) 
		   gShow[j]=false;
		   
		j++;
		s = i + 1;
		i = StringFind(workstr,",",s);
	}
}

void doNotify()
{
	int i,j;
	datetime dt;
	string alstr="Suggested pairs:";

	dt=TimeCurrent();
	j=0;
	
	for (i=0;i<gSymbols;i++) 
	{
		if (gSymbolNotifyList[i]==0) 
		   continue;
		   
		if (gSymbolNotifyList[i]!=gSymbolLastNotifyDirection[i] || dt-gSymbolLastNotifyTime[i]>MinimumAlertInterval) 
		{
			j++;
			gSymbolLastNotifyDirection[i]=gSymbolNotifyList[i];
			alstr=alstr + "[" + gSymbolArray[i] + "]";
		}
		
		gSymbolLastNotifyTime[i]=dt;
	}
	
	if (j==0) 
	   return;
	   
	if (AllowAlert) 
	   Alert(alstr);
	   
	if (AllowSound) 
	   PlaySound("alert.wav");
}