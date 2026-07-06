// Id: 19701
#property version "38.1"

#include <Controls\Dialog.mqh> 
#include <Controls\Button.mqh> 
#include <Controls\Label.mqh> 
#include <Controls\ComboBox.mqh> 
#include <Canvas\Canvas.mqh> 

#define X_START 0 
#define Y_START 0 
#define X_SIZE 600 
#define Y_SIZE 600 

extern string TFs="m1,m5,m30,H1";
extern color UpClr=clrGreen;
extern color DnClr=clrRed;
extern color NEClr=clrYellow;
extern color LClr=clrBlack;

int TF_Shift;
int ArrTF[101];
string ArrTFStr[101];
int ArrTFCount;
string ArrSymb[101];
int ArrSymbCount;
string ArrRes[101][101];
datetime LastTime[101][101];
datetime LastTimeSort[101];
int ResSort[101];
int FontSize;
int VSize, HSize;
string Symbs[101];
int SymbsCount;
string Symbs2[101];
int Ranks2[101];
datetime LastAlertTime[101];

string ResStatus(int index)
{
 string Str="";
 int i;
 for (i=1; i<=ArrTFCount; i++)
 {
  if (Str!="") Str=Str+", ";
  Str=Str+ArrTFStr[i]+": "+ArrRes[i][index];
 } 
 
 return Str;
}

int FindTF(string TFstr)
{
 if (TFstr=="m1") return (1);
 if (TFstr=="m5") return (5);
 if (TFstr=="m15") return (15);
 if (TFstr=="m30") return (30);
 if (TFstr=="H1") return (60);
 if (TFstr=="H4") return (240);
 if (TFstr=="D1") return (1440);
 if (TFstr=="W1") return (10080);
 if (TFstr=="MN") return (43200);
 
 return (-1);
}

string GetRes(int SymbIndex, string TFStr)
{
 string _Symb=ArrSymb[SymbIndex];
 int _TF=FindTF(TFStr);
 int res=iCustom(_Symb, _TF, "Fractal_Bar_Indicator", 1, 0)-iCustom(_Symb, _TF, "Fractal_Bar_Indicator", 2, 0);      
 
 return (ResToStr(res));
}

void ParsePair(string Pair, string &Symb1, string &Symb2)
{
 Symb1=StringSubstr(Pair, 0, 3);
 Symb2=StringSubstr(Pair, 3, 3);
 
 return;
}

void ParseTF()
{
 string str=TFs+",";
 string str2;
 int tf;
 int Pos;
 ArrTFCount=0;
 
 while (str!="")
 {
  Pos=StringFind(str, ",");
  str2=StringSubstr(str, 0, Pos);
  str=StringSubstr(str, Pos+1);
  tf=FindTF(str2);
  if (tf>0)
  {
   ArrTFCount++;
   ArrTF[ArrTFCount]=tf;
   ArrTFStr[ArrTFCount]=str2;
  }
 }
 return;
}

int FindSymb(string Symb)
{
 int i;
 for (i=1; i<=SymbsCount; i++)
 {
  if (Symbs[i]==Symb)
  {
   return (i);
  }
 }
 return (-1);
}

void ParseSymb()
{
 ArrSymbCount=0;
 int i;
 SymbsCount=0;
 string Symb1, Symb2, SName;
 for (i=0; i<SymbolsTotal(true); i++)
 {
  ArrSymbCount++;
  SName=SymbolName(i, true);
  ArrSymb[ArrSymbCount]=SName;
  ParsePair(SName, Symb1, Symb2);
  
  if (FindSymb(Symb1)==-1)
  {
   SymbsCount++;
   Symbs[SymbsCount]=Symb1;
  }

  if (FindSymb(Symb2)==-1)
  {
   SymbsCount++;
   Symbs[SymbsCount]=Symb2;
  }
 }
 
 return;
}

class CMemoryControl : public CAppDialog 
  { 
private: 
   int               m_arr_size; 
   char              m_arr_char[]; 
   int               m_arr_int[]; 
   float             m_arr_float[]; 
   double            m_arr_double[]; 
   long              m_arr_long[]; 
   CLabel TFLabel[101];
   CLabel SymbLabel[101];
   CLabel ResLabel[101][101];
   
   CLabel CurrencyLabel[101];
   CLabel CurrencyWeightLabel[101];
   
   CLabel            m_lbl_memory_physical; 
   CLabel            m_lbl_memory_total; 
   CLabel            m_lbl_memory_available; 
   CLabel            m_lbl_memory_used; 
   CLabel            m_lbl_array_size; 
   CLabel            m_lbl_array_type; 
   CLabel            m_lbl_error; 
   CLabel            m_lbl_change_type; 
   CLabel            m_lbl_add_size; 
   CButton           m_button_add; 
   CButton           m_button_free; 
   CComboBox         m_combo_box_step; 
   CComboBox         m_combo_box_type; 
   int               m_combo_box_type_value; 
  
public: 
                     CMemoryControl(void); 
                    ~CMemoryControl(void); 
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2); 
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam); 
   virtual void      PutData(const int i1, const int i2, const string res, const color clr);
   virtual void      CMemoryControl::PutCData(const int i, const string Curr, const int Rank);
   virtual void      PutSymb(const int i, const string res);
  
protected: 
   bool              CreateLabel(CLabel &lbl,const string name,const int x,const int y,const string str,const int font_size,const int clr); 
   bool              CreateButton(CButton &button,const string name,const int x,const int y,const int sx,const int sy,const string str,const int font_size,const int clr); 
   bool              CreateComboBoxStep(void); 
   bool              CreateComboBoxType(void); 
   void              OnClickButtonFSP(void); 
   void              OnClickButtonFSM(void); 
   void              OnClickButtonVSP(void); 
   void              OnClickButtonVSM(void); 
   void              OnClickButtonHSP(void); 
   void              OnClickButtonHSM(void); 
   void              OnChangeComboBoxType(void); 
   void              CurrentArrayFree(void); 
   bool              CurrentArrayAdd(void); 
  }; 

void CMemoryControl::CurrentArrayFree(void) 
  { 
   m_arr_size=0; 
   if(m_combo_box_type_value==0) 
      ArrayFree(m_arr_char); 
   if(m_combo_box_type_value==1) 
      ArrayFree(m_arr_int); 
   if(m_combo_box_type_value==2) 
      ArrayFree(m_arr_float); 
   if(m_combo_box_type_value==3) 
      ArrayFree(m_arr_double); 
   if(m_combo_box_type_value==4) 
      ArrayFree(m_arr_long); 
  }   

bool CMemoryControl::CurrentArrayAdd(void) 
  { 
   if(TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL)/TerminalInfoInteger(TERMINAL_MEMORY_USED)<2) 
      return(false); 
   if(m_combo_box_type_value==0 && ArrayResize(m_arr_char,m_arr_size)==-1) 
      return(false); 
   if(m_combo_box_type_value==1 && ArrayResize(m_arr_int,m_arr_size)==-1) 
      return(false); 
   if(m_combo_box_type_value==2 && ArrayResize(m_arr_float,m_arr_size)==-1) 
      return(false); 
   if(m_combo_box_type_value==3 && ArrayResize(m_arr_double,m_arr_size)==-1) 
      return(false); 
   if(m_combo_box_type_value==4 && ArrayResize(m_arr_long,m_arr_size)==-1) 
      return(false); 
   return(true); 
  }   

EVENT_MAP_BEGIN(CMemoryControl) 
ON_EVENT(ON_CHANGE,m_combo_box_type,OnChangeComboBoxType) 
EVENT_MAP_END(CAppDialog) 

CMemoryControl::CMemoryControl(void) 
  { 
  } 

CMemoryControl::~CMemoryControl(void) 
  { 
  } 

void CMemoryControl::PutData(const int i1, const int i2, const string res, const color clr)
{
 ResLabel[i1][i2].Text(res);
 ResLabel[i1][i2].Color(clr);
}

void CMemoryControl::PutCData(const int i, const string Curr, const int Rank)
{
 CurrencyLabel[i].Text(Curr);
 CurrencyWeightLabel[i].Text(Rank);
}

void CMemoryControl::PutSymb(const int i, const string res)
{
 SymbLabel[i].Text(res);
}

bool CMemoryControl::Create(const long chart,const string name,const int subwin, 
                            const int x1,const int y1,const int x2,const int y2) 
  { 
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) 
      return(false); 
      
      int i1, i2;
      
      int i;
      
      for (i=1; i<=ArrTFCount;i++)
      {
         CreateLabel(TFLabel[i],"TF"+i,X_START+TF_Shift+HSize*i,Y_START+5,ArrTFStr[i],FontSize,LClr);       
      }
      
      for (i=1; i<=ArrSymbCount; i++)
      {
         CreateLabel(SymbLabel[i],"Symb"+i,X_START,Y_START+10+VSize*i,ArrSymb[i],FontSize,LClr);       
      }
      
      for (i1=1; i1<=ArrTFCount; i1++)
      {
       for (i2=1; i2<=ArrSymbCount; i2++)
       {
         CreateLabel(ResLabel[i1][i2],"Res"+i1+"_"+i2,X_START+TF_Shift+HSize*i1,Y_START+10+VSize*i2,"N/D",FontSize,NEClr);       
       }
      }   
      
   m_arr_size=0; 
   return(true); 
  } 

bool CMemoryControl::CreateButton(CButton &button,const string name,const int x, 
                                  const int y, const int sx, const int sy, const string str,const int font_size, 
                                  const int clr) 
  { 
   if(!button.Create(m_chart_id,name,m_subwin,x,y,x+sx,y+sy)) 
      return(false); 
   if(!button.Text(str)) 
      return(false); 
   if(!button.FontSize(font_size)) 
      return(false); 
   if(!button.Color(clr)) 
      return(false); 
   if(!Add(button)) 
      return(false); 
   return(true); 
  } 

bool CMemoryControl::CreateComboBoxStep(void) 
  { 
   if(!m_combo_box_step.Create(m_chart_id,"step_combobox",m_subwin,X_START+100,Y_START+185,X_START+200,Y_START+205)) 
      return(false); 
   if(!m_combo_box_step.ItemAdd("100 000",100000)) 
      return(false); 
   if(!m_combo_box_step.ItemAdd("1 000 000",1000000)) 
      return(false); 
   if(!m_combo_box_step.ItemAdd("10 000 000",10000000)) 
      return(false); 
   if(!m_combo_box_step.ItemAdd("100 000 000",100000000)) 
      return(false); 
   if(!m_combo_box_step.SelectByValue(1000000)) 
      return(false); 
   if(!Add(m_combo_box_step)) 
      return(false); 
   return(true); 
  } 

bool CMemoryControl::CreateComboBoxType(void) 
  { 
   if(!m_combo_box_type.Create(m_chart_id,"type_combobox",m_subwin,X_START+100,Y_START+210,X_START+200,Y_START+230)) 
      return(false); 
   if(!m_combo_box_type.ItemAdd("char",0)) 
      return(false); 
   if(!m_combo_box_type.ItemAdd("int",1)) 
      return(false); 
   if(!m_combo_box_type.ItemAdd("float",2)) 
      return(false); 
   if(!m_combo_box_type.ItemAdd("double",3)) 
      return(false); 
   if(!m_combo_box_type.ItemAdd("long",4)) 
      return(false); 
   if(!m_combo_box_type.SelectByValue(3)) 
      return(false); 
   m_combo_box_type_value=3; 
   if(!Add(m_combo_box_type)) 
      return(false); 
   return(true); 
  } 

bool CMemoryControl::CreateLabel(CLabel &lbl,const string name,const int x, 
                                 const int y,const string str,const int font_size, 
                                 const int clr) 
  { 
   if(!lbl.Create(m_chart_id,name,m_subwin,x,y,0,0)) 
      return(false); 
   if(!lbl.Text(str)) 
      return(false); 
   if(!lbl.FontSize(font_size)) 
      return(false); 
   if(!lbl.Color(clr)) 
      return(false); 
   if(!Add(lbl)) 
      return(false); 
   return(true); 
  } 

void CMemoryControl::OnClickButtonVSP(void) 
{
   VSize++;

   int i1, i2;
   
   for (i1=1; i1<=ArrSymbCount; i1++)
   {
      SymbLabel[i1].Shift(0, i1);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].Shift(0, i2);
    }
   }      

}

void CMemoryControl::OnClickButtonVSM(void) 
{
   VSize--;

   int i1, i2;
   
   for (i1=1; i1<=ArrSymbCount; i1++)
   {
      SymbLabel[i1].Shift(0, -i1);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].Shift(0, -i2);
    }
   }      

}

void CMemoryControl::OnClickButtonHSP(void) 
{
   HSize++;

   int i1, i2;
   
   for (i1=1; i1<=ArrTFCount; i1++)
   {
      TFLabel[i1].Shift(i1, 0);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].Shift(i1, 0);
    }
   }      

}

void CMemoryControl::OnClickButtonHSM(void) 
{
   HSize--;

   int i1, i2;
   
   for (i1=1; i1<=ArrTFCount; i1++)
   {
      TFLabel[i1].Shift(-i1, 0);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].Shift(-i1, 0);
    }
   }      

}

void CMemoryControl::OnClickButtonFSP(void) 
  { 
   FontSize++;
   int i1, i2;
   
   for (i1=1; i1<=ArrTFCount;i1++)
   {
      TFLabel[i1].FontSize(FontSize);
   }
      
   for (i1=1; i1<=ArrSymbCount; i1++)
   {
      SymbLabel[i1].FontSize(FontSize);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].FontSize(FontSize);
    }
   }      
  } 

void CMemoryControl::OnClickButtonFSM(void) 
  { 
   FontSize--;
   int i1, i2;
   
   for (i1=1; i1<=ArrTFCount;i1++)
   {
      TFLabel[i1].FontSize(FontSize);
   }
      
   for (i1=1; i1<=ArrSymbCount; i1++)
   {
      SymbLabel[i1].FontSize(FontSize);
   }
      
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
      ResLabel[i1][i2].FontSize(FontSize);
    }
   }      

  } 

void CMemoryControl::OnChangeComboBoxType(void) 
  { 
   if(m_combo_box_type.Value()!=m_combo_box_type_value) 
     { 
      m_combo_box_type_value=(int)m_combo_box_type.Value(); 
      if(m_combo_box_type_value==0) 
         m_lbl_array_type.Text("Array type = char"); 
      if(m_combo_box_type_value==1) 
         m_lbl_array_type.Text("Array type = int"); 
      if(m_combo_box_type_value==2) 
         m_lbl_array_type.Text("Array type = float"); 
      if(m_combo_box_type_value==3) 
         m_lbl_array_type.Text("Array type = double"); 
      if(m_combo_box_type_value==4) 
         m_lbl_array_type.Text("Array type = long"); 
     } 
  } 
CMemoryControl ExtDialog; 

void SaveParams()
{
   GlobalVariableSet("FT_DB_FontSize", FontSize);
   GlobalVariableSet("FT_DB_VSize", VSize);
   GlobalVariableSet("FT_DB_HSize", HSize);
   
   return;
}

void LoadParams()
{
 if (GlobalVariableCheck("FT_DB_FontSize"))
 {
  FontSize=GlobalVariableGet("FT_DB_FontSize");
 }
 if (GlobalVariableCheck("FT_DB_VSize"))
 {
  VSize=GlobalVariableGet("FT_DB_VSize");
 }
 if (GlobalVariableCheck("FT_DB_HSize"))
 {
  HSize=GlobalVariableGet("FT_DB_HSize");
 }
 
 return;
}

int OnInit() 
  { 
       double temp = iCustom(NULL, 0, "Fractal_Bar_Indicator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Fractal_Bar_Indicator' indicator");
       return INIT_FAILED;
   }
   TF_Shift=30;
   
   ParseTF();
   ParseSymb();
   EventSetTimer(1);
   FontSize=12;
   VSize=20;
   HSize=45;
   LoadParams();

   if(!ExtDialog.Create(0,"MTF MCP Fractal",0,X_START,Y_START,X_SIZE,Y_SIZE)) 
      return(INIT_FAILED); 
   ExtDialog.Run(); 
   
   return(INIT_SUCCEEDED); 
  } 

void OnDeinit(const int reason) 
  { 
   SaveParams();
   EventKillTimer();
   ExtDialog.Destroy(reason); 
  } 

void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam) 
  { 
  
   ExtDialog.ChartEvent(id,lparam,dparam,sparam); 
  }
  
string ResToStr(int res)
{
 if (res==1) return ("Up");
 if (res==-1) return ("Dn");
 return ("NE");
}  

color ResToClr(int res)
{
 if (res==1) return (UpClr);
 if (res==-1) return (DnClr);
 return (NEClr);
}

void OnTimer()
{
   int i1, i2, _i;
   datetime CurDT;
   int res;
   color clr;
   
   for (i1=1; i1<=ArrTFCount; i1++)
   {
    for (i2=1; i2<=ArrSymbCount; i2++)
    {
     _i=i2;
     CurDT=iTime(ArrSymb[_i], ArrTF[i1], 1);
     if (LastTime[i1][_i]!=CurDT)
     {
      LastTime[i1][_i]=CurDT;
      res=iCustom(ArrSymb[_i], ArrTF[i1], "Fractal_Bar_Indicator", 1, 0)-iCustom(ArrSymb[_i], ArrTF[i1], "Fractal_Bar_Indicator", 2, 0);
      ArrRes[i1][_i]=ResToStr(res); 
      clr=ResToClr(res);
      
      ExtDialog.PutData(i1, i2, ArrRes[i1][_i], clr);
     }
    }
   } 
   
}