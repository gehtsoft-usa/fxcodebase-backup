// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70316


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




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property version   "1.00"
#property strict

struct MyObjectValue
{
public:
   string name;
   string conname;
   int n;
   int type;
   string value;
   int modifier;
   MyObjectValue(){
      name ="*";
      conname ="*";
      type=-1;
      n=0;
      value="*";
      modifier=0;
   }
   
};

struct MyObject
{
public:
   string name;
   string conname;
   int type;
   datetime time;
   double price;
   MyObject(){
      name ="*";
      conname ="*";
      type=-1;
      time=0;
      price=0;
   }
   
};
enum MyType{
   myInt,
   myString,
   myBool,
   myColor,
   myDT,
   myDouble,
   myLong,
   myChar
};

struct MyID{
   int id;
   MyType type;
   int modifier;
   int modifierValue;
};

MyID ObjGet[25];
MyID ObjGetInt[35];
MyID ObjGetStr[7];
MyID ObjGetDbl[5];

#include <MQLMySQL.mqh>
string Host="127.0.0.1", User="admin", Password="admin", Database="test", Socket="0"; // database credentials
int Port = 3306,ClientFlag=0;
int DB; // database identifier

enum CopyOrPaste{
   Copy,
   Paste
};
enum Type
{
   Local,
   MySQL
};
enum OnOff
{
   OFF,
   ON
};
input CopyOrPaste ActionType = 0;
input Type        ConnectionType = 0;
input string      ConnectionName = "Connection1";
input OnOff       AutoCopyPaste = 0;
input int         CopyPasteIntervalSec = 1; 
string MyObjName[500];
MyObject MyObjects[];
MyObjectValue MyObjectValues[]; 
int lastMyObject=0;
int lastMyObjectValue=0;
int N;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   InitArray();

   // reading database credentials from INI file
   
//---
   if(ConnectionType)
   {
      DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
       
      if (DB == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); return INIT_FAILED; }
      
      string Query = "show tables like 'object'";
      int Cursor = MySqlCursorOpen(DB, Query);
      bool create = true;
      if (Cursor >= 0)
       {
        int Rows = MySqlCursorRows(Cursor);
        if(Rows == 1)
        {
         create = false;
        }
               
       }
      MySqlCursorClose(Cursor);
      if(create)
      {
         string Query = "create table object("+
                     	"id int auto_increment not null primary key,"+
                         "name varchar(30),"+
                         "conname varchar(30),"+
                         "type int,"+
                         "time datetime,"+
                         "price double);";
         int Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
      }
       Query = "show tables like 'objectValues'";
       Cursor = MySqlCursorOpen(DB, Query);
       create = true;
      if (Cursor >= 0)
       {
        int Rows = MySqlCursorRows(Cursor);
        if(Rows == 1)
        {
         create = false;
        }
               
       }
      if(create)
      {
         string Query = "create table objectValues("+
                     	 "id int auto_increment not null primary key,"+
                         "name varchar(30),"+
                         "conname varchar(30),"+
                         "n int,"+
                         "type int,"+
                         "value double,"+
                         "modifier double);";
         int Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
      }
      
      Update();
   }
   else
   {
      ArrayResize(MyObjects,10000);
      ArrayResize(MyObjectValues,10000);
      int h = FileOpen(ConnectionName+"object.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
      lastMyObject = StringToInteger(FileReadString(h));
      for(int i=0;i<lastMyObject;i++)
      {
         MyObjects[i].name = FileReadString(h);
         MyObjects[i].conname = FileReadString(h);
         MyObjects[i].price = StringToDouble(FileReadString(h));
         MyObjects[i].time = StringToInteger(FileReadString(h));
         MyObjects[i].type = StringToInteger(FileReadString(h));
         
      }
      FileClose(h);
      h = FileOpen(ConnectionName+"objectValues.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
      lastMyObjectValue = StringToInteger(FileReadString(h));
      for(int i=0;i<lastMyObjectValue;i++)
      {
         MyObjectValues[i].name = FileReadString(h);
         MyObjectValues[i].conname = FileReadString(h);
         MyObjectValues[i].n = StringToInteger(FileReadString(h));
         MyObjectValues[i].type = StringToInteger(FileReadString(h));
         MyObjectValues[i].value = FileReadString(h);
         MyObjectValues[i].modifier = StringToInteger(FileReadString(h));
      }
      FileClose(h);
   }
   
   if(!ActionType)
   {
      UpdateLocal();
      Button("But","COPY",30,30,50,25,clrRed,12);
   }
   else
   {
      Button("But","PASTE",30,30,50,25,clrRed,12);
   }
   if(AutoCopyPaste)
   {
      EventSetTimer(CopyPasteIntervalSec);
   }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    ObjectDelete("But");
    MySqlDisconnect(DB);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
void OnTimer()
{
   if(!ActionType)
   {
      if(ConnectionType)
         Copy();
      else
         CopyLocal();
   }
   else
   {
      if(ConnectionType)
         Paste();
      else
         PasteLocal();
   }
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(ObjectGetInteger(0,"But",OBJPROP_STATE))
   {
      if(!ActionType)
      {
         if(ConnectionType)
            Copy();
         else
            CopyLocal();
      }
      else
      {
         if(ConnectionType)
            Paste();
         else
            PasteLocal();
      }
     ObjectSetInteger(0,"But",OBJPROP_STATE,false);
   }

}

void UpdateLocal()
{
   string DeleteNames[];
   ArrayResize(DeleteNames,lastMyObject);
   int cnt=0;
   for(int j=0;j<lastMyObject;j++)
   {
      bool find = false;
      for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
      {
         if(MyObjects[j].name == ObjectName(0,i))
         {
            find = true;
            break;
         }
      }
      if(!find)
      {
         DeleteNames[cnt]=MyObjects[j].name;
         cnt++;
         MyObjects[j].name = MyObjects[lastMyObject-1].name;
         MyObjects[j].conname = MyObjects[lastMyObject-1].conname;
         MyObjects[j].price = MyObjects[lastMyObject-1].price;
         MyObjects[j].time = MyObjects[lastMyObject-1].time;
         MyObjects[j].type= MyObjects[lastMyObject-1].type;
         lastMyObject--;
         j--;
      }
   }
   for(int j=0;j<lastMyObjectValue;j++)
   {
      for(int i = 0;i<cnt;i++)
      {
         if(DeleteNames[i]==MyObjectValues[j].name)
         {
            MyObjectValues[j].name = MyObjectValues[lastMyObjectValue-1].name;
            MyObjectValues[j].conname = MyObjectValues[lastMyObjectValue-1].conname;
            MyObjectValues[j].n = MyObjectValues[lastMyObjectValue-1].n;
            MyObjectValues[j].type = MyObjectValues[lastMyObjectValue-1].type;
            MyObjectValues[j].modifier= MyObjectValues[lastMyObjectValue-1].modifier;
            MyObjectValues[j].value= MyObjectValues[lastMyObjectValue-1].value;
            lastMyObjectValue--;
            j--;
            break;
         }
      }
      
   }
   WriteLocal();
}
void Update()
{
   for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
   {
      MyObjName[i] = ObjectName(0,i);
      N = i;
   }
   string Query = "SELECT name,conname FROM object where conname = '"+ConnectionName+"';";
   int Cursor = MySqlCursorOpen(DB, Query);
   if (Cursor >= 0)
    {
     int Rows = MySqlCursorRows(Cursor);
     for (int i=0; i<Rows; i++)
         if (MySqlCursorFetchRow(Cursor))
            {
                string name = MySqlGetFieldAsString(Cursor, 0);
                bool find = false;
                for(int j = 0;j<=N;j++)
                {
                  if(MyObjName[j] == name)
                  {
                     find = true;
                     break;
                  }
                }
                if(!find)
                {
                  string q = "delete from object where name = '"+name+"' and conname = '"+ConnectionName+"';";
                  int c = MySqlCursorOpen(DB,q);
                  MySqlCursorClose(c);
                  q = "delete from objectValues where name = '"+name+"' and conname = '"+ ConnectionName+"';";
                  c = MySqlCursorOpen(DB,q);
                  MySqlCursorClose(c);
                }
            }
            
     MySqlCursorClose(Cursor);
    }
   
}
void CheckIfDeleteLocal()
{
   for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
   {
      if(ObjectName(0,i) == "But")
         continue;
      double found = false;
      for(int j=0;j<lastMyObject;j++)
      {
         if(MyObjects[j].name == ObjectName(0,i))
         {
            found = true;
            break;
         }
      }
      if(!found)
         ObjectDelete(0,ObjectName(0,i));
       
   }
   
   
}
void CheckIfDelete()
{

   for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
   {
      if(ObjectName(0,i) == "But")
         continue;
      string Query = "SELECT name,conname FROM object where conname = '"+ConnectionName+"' and name = '"+ObjectName(0,i)+"';";
      int Cursor = MySqlCursorOpen(DB, Query);
      
      if (Cursor >= 0)
       {
        int Rows = MySqlCursorRows(Cursor);
        if(Rows == 0)
        {
         ObjectDelete(0,ObjectName(0,i));
        }
               
        MySqlCursorClose(Cursor);
       }
   }
   
   
}
void PasteLocal()
{
   string Query;
   int Cursor;
   ReadForPasteLocal();
   CheckIfDeleteLocal();
   for(int i=0;i<lastMyObject;i++)
   {
       string name = MyObjects[i].name;
       int type = MyObjects[i].type;
       datetime time = MyObjects[i].time;
       double price = MyObjects[i].price;
       ObjectDelete(0,name);
       ObjectCreate(0,name,type,0,time,NormalizeDouble(price,Digits()));
       for(int j=0;j<lastMyObjectValue;j++)
       {
         if(MyObjectValues[j].name == name)
         {
            int n = MyObjectValues[j].n;
            int mytype = MyObjectValues[j].type;
            switch(mytype)
            {
               case 0:
               {
                  int value = StringToInteger(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 1:
               {
                  string value = MyObjectValues[j].value;
                  ObjectSet(name,n,value);
                  break;
               }
               case 2:
               {
                  int value = StringToInteger(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 3:
               {
                  color value = StringToInteger(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 4:
               {
                  int value = StringToInteger(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 5:
               {
                  double value = StringToDouble(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 6:
               {
                  long value = (long)StringToInteger(MyObjectValues[j].value);
                  ObjectSet(name,n,value);
                  break;
               }
               case 7:
               {
                  char value = (char)MyObjectValues[j].value;
                  ObjectSet(name,n,value);
                  break;
               }
               case 8:
               {
                  int value = StringToInteger(MyObjectValues[j].value);
                  int modifier = MyObjectValues[j].modifier;
                  if(modifier!=-1)
                  {
                     ObjectSetInteger(0,name,n,modifier,value);
                     break;
                  }
                  ObjectSetInteger(0,name,n,value);
                  break;
               }
               case 9:
               {
                  string value = MyObjectValues[j].value;
                  int modifier = MyObjectValues[j].modifier;
                  if(modifier!=-1)
                  {
                     ObjectSetString(0,name,n,modifier,value);
                     break;
                  }
                  ObjectSetString(0,name,n,value);
                  break;
               }
               case 10:
               {
                  double value = StringToDouble(MyObjectValues[j].value);
                  int modifier = MyObjectValues[j].modifier;
                  if(modifier!=-1)
                  {
                     ObjectSetDouble(0,name,n,modifier,value);
                     break;
                  }
                  ObjectSetDouble(0,name,n,value);
                  break;
               }
            }
         }
      }
    }
}
void Paste()
{
   string Query;
   int Cursor;
   CheckIfDelete();
   
   Query = "SELECT name,conname,type,time,price FROM object where conname = '"+ConnectionName+"';";
   Cursor = MySqlCursorOpen(DB, Query);
   if (Cursor >= 0)
    {
     int Rows = MySqlCursorRows(Cursor);
     for (int i=0; i<Rows; i++)
         if (MySqlCursorFetchRow(Cursor))
            { // id
                string name = MySqlGetFieldAsString(Cursor, 0);
                string symbol = MySqlGetFieldAsString(Cursor, 1);
                int type = MySqlGetFieldAsInt(Cursor,2);
                datetime time = StringToTime(MySqlGetFieldAsString(Cursor,3));
                double price = MySqlGetFieldAsDouble(Cursor,4);
                ObjectDelete(0,name);
                ObjectCreate(0,name,type,0,time,NormalizeDouble(price,Digits()));
                Query = "SELECT n,type,value,modifier FROM objectValues where name = '"+name+"' and conname = '"+ConnectionName+"';";
                int c1 = MySqlCursorOpen(DB, Query);
                
                if (c1 >= 0)
                {
                  int r = MySqlCursorRows(c1);
                  for (int j=0; j<r; j++)
                     if (MySqlCursorFetchRow(c1))
                     {
                        int n = MySqlGetFieldAsInt(c1,0);
                        int mytype = MySqlGetFieldAsInt(c1,1);
                        switch(mytype)
                        {
                           case 0:
                           {
                              int value = StringToInteger(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 1:
                           {
                              string value = MySqlGetFieldAsString(c1,2);
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 2:
                           {
                              int value = StringToInteger(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 3:
                           {
                              color value = StringToInteger(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 4:
                           {
                              int value = StringToInteger(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 5:
                           {
                              double value = StringToDouble(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 6:
                           {
                              long value = (long)StringToInteger(MySqlGetFieldAsString(c1,2));
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 7:
                           {
                              char value = (char)MySqlGetFieldAsString(c1,2);
                              ObjectSet(name,n,value);
                              break;
                           }
                           case 8:
                           {
                              int value = StringToInteger(MySqlGetFieldAsString(c1,2));
                              int modifier = MySqlGetFieldAsInt(c1,3);
                              if(modifier!=-1)
                              {
                                 ObjectSetInteger(0,name,n,modifier,value);
                                 break;
                              }
                              ObjectSetInteger(0,name,n,value);
                              break;
                           }
                           case 9:
                           {
                              string value = MySqlGetFieldAsString(c1,2);
                              int modifier = MySqlGetFieldAsInt(c1,3);
                              if(modifier!=-1)
                              {
                                 ObjectSetString(0,name,n,modifier,value);
                                 break;
                              }
                              ObjectSetString(0,name,n,value);
                              break;
                           }
                           case 10:
                           {
                              double value = StringToDouble(MySqlGetFieldAsString(c1,2));
                              int modifier = MySqlGetFieldAsInt(c1,3);
                              if(modifier!=-1)
                              {
                                 ObjectSetDouble(0,name,n,modifier,value);
                                 break;
                              }
                              ObjectSetDouble(0,name,n,value);
                              break;
                           }
                        }
                  }
                }
                
            }
     MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
    }
}
void DoItLocal(string name)
{
   string Query;
   int Cursor;
   int type = ObjectGetInteger(0,name,OBJPROP_TYPE);
   datetime time = ObjectGet(name,OBJPROP_TIME1);
   double price = ObjectGet(name,OBJPROP_PRICE1);
   MyObjects[lastMyObject].name = name;
   MyObjects[lastMyObject].conname = ConnectionName;
   MyObjects[lastMyObject].type = type;
   MyObjects[lastMyObject].time = time;
   MyObjects[lastMyObject].price = price;
   lastMyObject++;
   int id = 0;
   ObjectDelete(id,name+"C");
   //ObjectCreate(id,name+"C",type,0,time,price);
   for(int i = 0;i<25;i++)
   {
      ObjectGet(name,ObjGet[i].id);
      if(GetLastError() == 0)
      {
         ObjectSet(name+"C",ObjGet[i].id,ObjectGet(name,ObjGet[i].id));
         MyObjectValues[lastMyObjectValue].name=name;
         MyObjectValues[lastMyObjectValue].conname=ConnectionName;
         MyObjectValues[lastMyObjectValue].n=ObjGet[i].id;
         MyObjectValues[lastMyObjectValue].type=ObjGet[i].type;
         MyObjectValues[lastMyObjectValue].value=ObjectGet(name,ObjGet[i].id);
         MyObjectValues[lastMyObjectValue].modifier=-1;
         lastMyObjectValue++;
      }
   }
   for(int i=210;i<252;i++)
   {
      ObjectGet(name,i);
      if(GetLastError() == 0)
      {
         ObjectSet(name+"C",i,ObjectGet(name,i));
         MyObjectValues[lastMyObjectValue].name=name;
         MyObjectValues[lastMyObjectValue].conname=ConnectionName;
         MyObjectValues[lastMyObjectValue].n=i;
         MyObjectValues[lastMyObjectValue].type=5;
         MyObjectValues[lastMyObjectValue].value=ObjectGet(name,i);
         MyObjectValues[lastMyObjectValue].modifier=-1;
         lastMyObjectValue++;
      }
   }
   for(int i = 0;i<35;i++)
   {
      if(ObjGetInt[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetInt[i].modifier].id);j++)
         {
            ObjectGetInteger(id,name,ObjGetInt[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetInteger(id,name+"C",ObjGetInt[i].id,j,ObjectGetInteger(0,name,ObjGetInt[i].id,j));
               MyObjectValues[lastMyObjectValue].name=name;
               MyObjectValues[lastMyObjectValue].conname=ConnectionName;
               MyObjectValues[lastMyObjectValue].n=ObjGetInt[i].id;
               MyObjectValues[lastMyObjectValue].type=8;
               MyObjectValues[lastMyObjectValue].value=ObjectGetInteger(0,name,ObjGetInt[i].id,j);
               MyObjectValues[lastMyObjectValue].modifier=j;
               lastMyObjectValue++;
               
            }
         }
         continue;
      }
      ObjectGetInteger(id,name,ObjGetInt[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetInteger(id,name+"C",ObjGetInt[i].id,ObjectGetInteger(0,name,ObjGetInt[i].id));
         MyObjectValues[lastMyObjectValue].name=name;
         MyObjectValues[lastMyObjectValue].conname=ConnectionName;
         MyObjectValues[lastMyObjectValue].n=ObjGetInt[i].id;
         MyObjectValues[lastMyObjectValue].type=8;
         MyObjectValues[lastMyObjectValue].value=ObjectGetInteger(0,name,ObjGetInt[i].id);
         MyObjectValues[lastMyObjectValue].modifier=-1;
         lastMyObjectValue++;
         
      }
   }
   for(int i = 0;i<7;i++)
   {            
      if(ObjGetStr[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetStr[i].modifier].id);j++)
         {
            ObjectGetString(id,name,ObjGetStr[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetString(id,name+"C",ObjGetStr[i].id,ObjectGetString(0,name,ObjGetStr[i].id,j));
               MyObjectValues[lastMyObjectValue].name=name;
               MyObjectValues[lastMyObjectValue].conname=ConnectionName;
               MyObjectValues[lastMyObjectValue].n=ObjGetStr[i].id;
               MyObjectValues[lastMyObjectValue].type=9;
               MyObjectValues[lastMyObjectValue].value=ObjectGetString(0,name,ObjGetStr[i].id,j);
               MyObjectValues[lastMyObjectValue].modifier=j;
               lastMyObjectValue++;
               
            }
         }
         continue;
      } 
      ObjectGetString(id,name,ObjGetStr[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetString(id,name+"C",ObjGetStr[i].id,ObjectGetString(0,name,ObjGetStr[i].id));
         MyObjectValues[lastMyObjectValue].name=name;
         MyObjectValues[lastMyObjectValue].conname=ConnectionName;
         MyObjectValues[lastMyObjectValue].n=ObjGetStr[i].id;
         MyObjectValues[lastMyObjectValue].type=9;
         MyObjectValues[lastMyObjectValue].value=ObjectGetString(0,name,ObjGetStr[i].id);
         MyObjectValues[lastMyObjectValue].modifier=-1;
         lastMyObjectValue++;
      }
   }
   for(int i = 0;i<5;i++)
   {
      if(ObjGetDbl[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetDbl[i].modifier].id);j++)
         {
            ObjectGetDouble(id,name,ObjGetDbl[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetInteger(id,name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id,j));
               MyObjectValues[lastMyObjectValue].name=name;
               MyObjectValues[lastMyObjectValue].conname=ConnectionName;
               MyObjectValues[lastMyObjectValue].n=ObjGetDbl[i].id;
               MyObjectValues[lastMyObjectValue].type=10;
               MyObjectValues[lastMyObjectValue].value=ObjectGetDouble(0,name,ObjGetDbl[i].id,j);
               MyObjectValues[lastMyObjectValue].modifier=j;
               lastMyObjectValue++;
               
            }
         }
         continue;
      }
      ObjectGetDouble(id,name,ObjGetDbl[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetDouble(id,name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id));
         MyObjectValues[lastMyObjectValue].name=name;
         MyObjectValues[lastMyObjectValue].conname=ConnectionName;
         MyObjectValues[lastMyObjectValue].n=ObjGetDbl[i].id;
         MyObjectValues[lastMyObjectValue].type=10;
         MyObjectValues[lastMyObjectValue].value=ObjectGetDouble(0,name,ObjGetDbl[i].id);
         MyObjectValues[lastMyObjectValue].modifier=-1;
         lastMyObjectValue++;
      }
   }
}
void DoIt(string name)
{
   string Query;
   int Cursor;
   int type = ObjectGetInteger(0,name,OBJPROP_TYPE);
   datetime time = ObjectGet(name,OBJPROP_TIME1);
   double price = ObjectGet(name,OBJPROP_PRICE1);
   Query = "Insert into object(name,conname,type,time,price) values('"+name+"','"+ConnectionName+"',"+type+",'"+TimeToStr(time)+"',"+price+");";
   int id = 0;

   ObjectDelete(id,name+"C");
   //ObjectCreate(id,name+"C",type,0,time,price);
   Cursor = MySqlCursorOpen(DB, Query);
   MySqlCursorClose(Cursor);
   for(int i = 0;i<25;i++)
   {
      ObjectGet(name,ObjGet[i].id);
      if(GetLastError() == 0)
      {
         ObjectSet(name+"C",ObjGet[i].id,ObjectGet(name,ObjGet[i].id));
         Query = "Insert into objectValues(name,conname,n,type,value) values('"+name+"','"+ConnectionName+"',"+ObjGet[i].id+","+ObjGet[i].type+",'"+ObjectGet(name,ObjGet[i].id)+"');";
         Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
      }
   }
   for(int i=210;i<252;i++)
   {
      ObjectGet(name,i);
      if(GetLastError() == 0)
      {
         ObjectSet(name+"C",i,ObjectGet(name,i));
         Query = "Insert into objectValues(name,conname,n,type,value) values('"+name+"','"+ConnectionName+"',"+i+","+5+",'"+ObjectGet(name,i)+"');";
         Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
      }
   }
   for(int i = 0;i<35;i++)
   {
      if(ObjGetInt[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetInt[i].modifier].id);j++)
         {
            ObjectGetInteger(id,name,ObjGetInt[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetInteger(id,name+"C",ObjGetInt[i].id,j,ObjectGetInteger(0,name,ObjGetInt[i].id,j));
               Query = "Insert into objectValues(name,conname,n,type,value,modifier) values('"+name+"','"+ConnectionName+"',"+ObjGetInt[i].id+","+8+",'"+ObjectGetInteger(0,name,ObjGetInt[i].id,j)+"',"+j+");";
               Cursor = MySqlCursorOpen(DB, Query);
               MySqlCursorClose(Cursor);
               
            }
         }
         continue;
      }
      ObjectGetInteger(id,name,ObjGetInt[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetInteger(id,name+"C",ObjGetInt[i].id,ObjectGetInteger(0,name,ObjGetInt[i].id));
         Query = "Insert into objectValues(name,conname,n,type,value) values('"+name+"','"+ConnectionName+"',"+ObjGetInt[i].id+","+8+",'"+ObjectGetInteger(0,name,ObjGetInt[i].id)+"');";
         Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
         
      }
   }
   for(int i = 0;i<7;i++)
   {            
      if(ObjGetStr[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetStr[i].modifier].id);j++)
         {
            ObjectGetString(id,name,ObjGetStr[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetString(id,name+"C",ObjGetStr[i].id,ObjectGetString(0,name,ObjGetStr[i].id,j));
               Query = "Insert into objectValues(name,conname,n,type,value,modifier) values('"+name+"','"+ConnectionName+"',"+ObjGetStr[i].id+","+9+",'"+ObjectGetString(0,name,ObjGetStr[i].id,j)+"',"+j+");";
               Cursor = MySqlCursorOpen(DB, Query);
               MySqlCursorClose(Cursor);
               
            }
         }
         continue;
      } 
      ObjectGetString(id,name,ObjGetStr[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetString(id,name+"C",ObjGetStr[i].id,ObjectGetString(0,name,ObjGetStr[i].id));
         Query = "Insert into objectValues(name,conname,n,type,value) values('"+name+"','"+ConnectionName+"',"+ObjGetStr[i].id+","+9+",'"+ObjectGetString(0,name,ObjGetStr[i].id)+"');";
         Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
      
      }
   }
   for(int i = 0;i<5;i++)
   {
      if(ObjGetDbl[i].modifier)
      {
         for(int j=0;j<ObjectGet(name,ObjGet[ObjGetDbl[i].modifier].id);j++)
         {
            ObjectGetDouble(id,name,ObjGetDbl[i].id,j);
            if(GetLastError() == 0)
            {
               ObjectSetInteger(id,name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id,j));
               Query = "Insert into objectValues(name,conname,n,type,value,modifier) values('"+name+"','"+ConnectionName+"',"+ObjGetDbl[i].id+","+10+",'"+ObjectGetDouble(0,name,ObjGetDbl[i].id,j)+"',"+j+");";
               Cursor = MySqlCursorOpen(DB, Query);
               MySqlCursorClose(Cursor);
               
            }
         }
         continue;
      }
      ObjectGetDouble(id,name,ObjGetDbl[i].id);
      if(GetLastError() == 0)
      {
         ObjectSetDouble(id,name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id));
         Query = "Insert into objectValues(name,conname,n,type,value) values('"+name+"','"+ConnectionName+"',"+ObjGetDbl[i].id+","+10+",'"+ObjectGetDouble(0,name,ObjGetDbl[i].id)+"');";
         Cursor = MySqlCursorOpen(DB, Query);
         MySqlCursorClose(Cursor);
         
      }
   }
}

void ReadForPasteLocal()
{
   int h = FileOpen(ConnectionName+"object.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   lastMyObject = StringToInteger(FileReadString(h));
   for(int i=0;i<lastMyObject;i++)
   {
      
      MyObjects[i].name = FileReadString(h);
      MyObjects[i].conname = FileReadString(h);
      MyObjects[i].price = StringToDouble(FileReadString(h));
      MyObjects[i].time = StringToInteger(FileReadString(h));
      MyObjects[i].type = StringToInteger(FileReadString(h));
   }
   FileClose(h);
   h = FileOpen(ConnectionName+"objectValues.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   lastMyObjectValue = StringToInteger(FileReadString(h));
   for(int i=0;i<lastMyObjectValue;i++)
   {
      MyObjectValues[i].name = FileReadString(h);
      MyObjectValues[i].conname = FileReadString(h);
      MyObjectValues[i].n = StringToInteger(FileReadString(h));
      MyObjectValues[i].type = StringToInteger(FileReadString(h));
      MyObjectValues[i].value = FileReadString(h);
      MyObjectValues[i].modifier = StringToInteger(FileReadString(h));
   }
   FileClose(h);
}

void WriteLocal()
{
   int h = FileOpen(ConnectionName+"object.csv",FILE_CSV|FILE_ANSI|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   FileWriteString(h,lastMyObject);
   FileWriteString(h,";");
   for(int i=0;i<lastMyObject;i++)
   {
      FileWriteString(h,MyObjects[i].name);
   FileWriteString(h,";");
      FileWriteString(h,MyObjects[i].conname);
   FileWriteString(h,";");
      FileWriteString(h,MyObjects[i].price,Digits());
   FileWriteString(h,";");
      FileWriteString(h,MyObjects[i].time);
   FileWriteString(h,";");
      FileWriteString(h,MyObjects[i].type);
   FileWriteString(h,";");
   }
   FileClose(h);
   h = FileOpen(ConnectionName+"objectValues.csv",FILE_CSV|FILE_ANSI|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   FileWriteString(h,lastMyObjectValue);
   FileWriteString(h,";");
   for(int i=0;i<lastMyObjectValue;i++)
   {
      FileWriteString(h,MyObjectValues[i].name);
   FileWriteString(h,";");
      FileWriteString(h,MyObjectValues[i].conname);
   FileWriteString(h,";");
      FileWriteString(h,MyObjectValues[i].n);
   FileWriteString(h,";");
      FileWriteString(h,MyObjectValues[i].type);
   FileWriteString(h,";");
      FileWriteString(h,MyObjectValues[i].value);
   FileWriteString(h,";");
      FileWriteString(h,MyObjectValues[i].modifier);
   FileWriteString(h,";");
   }
   FileClose(h);
}
void CopyLocal()
{
   string Names[];
   ArrayResize(Names,ObjectsTotal(0,-1,-1));
   int cnt=0;
   for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
   {
      if(ObjectName(0,i) == "But")
         continue;
      double found = false;
      for(int j=0;j<lastMyObject;j++)
      {
         if(MyObjects[j].name == ObjectName(0,i))
         {
            found = true;
            break;
         }
      }
      if(!found)
      {
         Names[cnt]=ObjectName(0,i);
         cnt++;
      }
   }
   for(int i =0;i<cnt;i++)
   {
      DoItLocal(Names[i]);
   }
   WriteLocal();
   UpdateLocal();
   /*
   for(int i = 0;i<35;i++)
   {
      ObjectGetDouble(0,name,ObjGetInt[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetInt[i].id,ObjectGetDouble(0,name,ObjGetInt[i].id));
   }
   for(int i = 0;i<7;i++)
   {              
      ObjectGetDouble(0,name,ObjGetStr[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetStr[i].id,ObjectGetDouble(0,name,ObjGetStr[i].id));
   }
   for(int i = 0;i<5;i++)
   {
      ObjectGetDouble(0,name,ObjGetDbl[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id));
   }*/
}
void Copy()
{
   for(int i = 0;i<ObjectsTotal(0,-1,-1);i++)
   {
      if(ObjectName(0,i) == "But")
         continue;
      string Query = "SELECT name,conname FROM object where conname = '"+ConnectionName+"' and name = '"+ObjectName(0,i)+"';";
      int Cursor = MySqlCursorOpen(DB, Query);
      
      if (Cursor >= 0)
       {
        int Rows = MySqlCursorRows(Cursor);
        if(Rows == 0)
        {
            DoIt(ObjectName(0,i));
        }
               
        MySqlCursorClose(Cursor);
       }
   }
   Update();
   /*
   for(int i = 0;i<35;i++)
   {
      ObjectGetDouble(0,name,ObjGetInt[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetInt[i].id,ObjectGetDouble(0,name,ObjGetInt[i].id));
   }
   for(int i = 0;i<7;i++)
   {              
      ObjectGetDouble(0,name,ObjGetStr[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetStr[i].id,ObjectGetDouble(0,name,ObjGetStr[i].id));
   }
   for(int i = 0;i<5;i++)
   {
      ObjectGetDouble(0,name,ObjGetDbl[i].id);
      if(GetLastError() == 0)
         ObjectSet(name+"C",ObjGetDbl[i].id,ObjectGetDouble(0,name,ObjGetDbl[i].id));
   }*/
}

void Button(string name,string txt,int x,int y,int x1,int y1,color clrf,color clrtxt)
{
if(ObjectFind(0,name)==0)
  {
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   return;
  }
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,x1);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,y1);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrf);
   ObjectSetInteger(0,name,OBJPROP_CORNER,0);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetString(0,name,OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrtxt);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrf);

return;
}
  
void InitArray()
{
   //OBJPROP_TIME1
   ObjGet[0].id = OBJPROP_TIME1;
   ObjGet[0].type = 4;
   ObjGet[0].modifier = 0;
   //OBJPROP_PRICE1
   ObjGet[1].id = OBJPROP_PRICE1;
   ObjGet[1].type = 5;
   ObjGet[1].modifier = 0;
   //OBJPROP_TIME2
   ObjGet[2].id = OBJPROP_TIME2;
   ObjGet[2].type = 4;
   ObjGet[2].modifier = 0;
   //OBJPROP_PRICE2
   ObjGet[3].id = OBJPROP_PRICE2;
   ObjGet[3].type = 5;
   ObjGet[3].modifier = 0;
   //OBJPROP_TIME3
   ObjGet[4].id = OBJPROP_TIME3;
   ObjGet[4].type = 4;
   ObjGet[4].modifier = 0;
   //OBJPROP_PRICE3
   ObjGet[5].id = OBJPROP_PRICE3;
   ObjGet[5].type = 5;
   ObjGet[5].modifier = 0;
   //OBJPROP_COLOR
   ObjGet[6].id = OBJPROP_COLOR;
   ObjGet[6].type = 3;
   ObjGet[6].modifier = 0;
   //OBJPROP_STYLE
   ObjGet[7].id = OBJPROP_STYLE;
   ObjGet[7].type = 0;
   ObjGet[7].modifier = 0;
   //OBJPROP_WIDTH
   ObjGet[8].id = OBJPROP_WIDTH;
   ObjGet[8].type = 0;
   ObjGet[8].modifier = 0;
   //OBJPROP_BACK
   ObjGet[9].id = OBJPROP_BACK;
   ObjGet[9].type = 2;
   ObjGet[9].modifier = 0;
   //OBJPROP_RAY
   ObjGet[10].id = OBJPROP_RAY;
   ObjGet[10].type = 2;
   ObjGet[10].modifier = 0;
   //OBJPROP_ELLIPSE
   ObjGet[11].id = OBJPROP_ELLIPSE;
   ObjGet[11].type = 2;
   ObjGet[11].modifier = 0;
   //OBJPROP_SCALE
   ObjGet[12].id = OBJPROP_SCALE;
   ObjGet[12].type = 5;
   ObjGet[12].modifier = 0;
   //OBJPROP_ANGLE
   ObjGet[13].id = OBJPROP_ANGLE;
   ObjGet[13].type = 5;
   ObjGet[13].modifier = 0;
   //OBJPROP_ARROWCODE
   ObjGet[14].id = OBJPROP_ARROWCODE;
   ObjGet[14].type = 0;
   ObjGet[14].modifier = 0;
   //OBJPROP_TIMEFRAMES
   ObjGet[15].id = OBJPROP_TIMEFRAMES;
   ObjGet[15].type = 0;
   ObjGet[15].modifier = 0;
   //OBJPROP_DEVIATION
   ObjGet[16].id = OBJPROP_DEVIATION;
   ObjGet[16].type = 5;
   ObjGet[16].modifier = 0;
   //OBJPROP_FONTSIZE
   ObjGet[17].id = OBJPROP_FONTSIZE;
   ObjGet[17].type = 0;
   ObjGet[17].modifier = 0;
   //OBJPROP_CORNER
   ObjGet[18].id = OBJPROP_CORNER;
   ObjGet[18].type = 0;
   ObjGet[18].modifier = 0;
   //OBJPROP_XDISTANCE
   ObjGet[19].id = OBJPROP_XDISTANCE;
   ObjGet[19].type = 0;
   ObjGet[19].modifier = 0;
   //OBJPROP_YDISTANCE
   ObjGet[20].id = OBJPROP_YDISTANCE;
   ObjGet[20].type = 0;
   ObjGet[20].modifier = 0;
   //OBJPROP_FIBOLEVELS
   ObjGet[21].id = OBJPROP_FIBOLEVELS;
   ObjGet[21].type = 0;
   ObjGet[21].modifier = 0;
   //OBJPROP_LEVELCOLOR
   ObjGet[22].id = OBJPROP_LEVELCOLOR;
   ObjGet[22].type = 3;
   ObjGet[22].modifier = 0;
   //OBJPROP_LEVELSTYLE
   ObjGet[23].id = OBJPROP_LEVELSTYLE;
   ObjGet[23].type = 0;
   ObjGet[23].modifier = 0;
   //OBJPROP_LEVELWIDTH
   ObjGet[24].id = OBJPROP_LEVELWIDTH;
   ObjGet[24].type = 0;
   ObjGet[24].modifier = 0;
   
   // Integer ////
   
   //OBJPROP_COLOR
   ObjGetInt[0].id = OBJPROP_COLOR;
   ObjGetInt[0].type = 3;
   ObjGetInt[0].modifier = 0;
   //OBJPROP_STYLE
   ObjGetInt[1].id = OBJPROP_STYLE;
   ObjGetInt[1].type = 0;
   ObjGetInt[1].modifier = 0;
   //OBJPROP_WIDTH
   ObjGetInt[2].id = OBJPROP_WIDTH;
   ObjGetInt[2].type = 0;
   ObjGetInt[2].modifier = 0;
   //OBJPROP_BACK
   ObjGetInt[3].id = OBJPROP_BACK;
   ObjGetInt[3].type = 2;
   ObjGetInt[3].modifier = 0;
   //OBJPROP_ZORDER
   ObjGetInt[4].id = OBJPROP_ZORDER;
   ObjGetInt[4].type = 6;
   ObjGetInt[4].modifier = 0;
   //OBJPROP_HIDDEN
   ObjGetInt[5].id = OBJPROP_HIDDEN;
   ObjGetInt[5].type = 2;
   ObjGetInt[5].modifier = 0;
   //OBJPROP_SELECTED
   ObjGetInt[6].id = OBJPROP_SELECTED;
   ObjGetInt[6].type = 2;
   ObjGetInt[6].modifier = 0;
   //OBJPROP_READONLY
   ObjGetInt[7].id = OBJPROP_READONLY;
   ObjGetInt[7].type = 2;
   ObjGetInt[7].modifier = 0;
   //OBJPROP_TYPE
   ObjGetInt[8].id = OBJPROP_TYPE;
   ObjGetInt[8].type = 0;
   ObjGetInt[8].modifier = 0;
   //OBJPROP_TIME
   ObjGetInt[9].id = OBJPROP_TIME;
   ObjGetInt[9].type = 4;
   ObjGetInt[9].modifier = 18;
   //OBJPROP_SELECTABLE
   ObjGetInt[10].id = OBJPROP_SELECTABLE;
   ObjGetInt[10].type = 2;
   ObjGetInt[10].modifier = 0;
   //OBJPROP_CREATETIME
   ObjGetInt[11].id = OBJPROP_CREATETIME;
   ObjGetInt[11].type = 4;
   ObjGetInt[11].modifier = 0;
   //OBJPROP_LEVELS
   ObjGetInt[12].id = OBJPROP_LEVELS;
   ObjGetInt[12].type = 0;
   ObjGetInt[12].modifier = 0;
   //OBJPROP_LEVELCOLOR
   ObjGetInt[13].id = OBJPROP_LEVELCOLOR;
   ObjGetInt[13].type = 3;
   ObjGetInt[13].modifier = 21;
   //OBJPROP_LEVELSTYLE
   ObjGetInt[14].id = OBJPROP_LEVELSTYLE;
   ObjGetInt[14].type = 0;
   ObjGetInt[14].modifier = 21;
   //OBJPROP_LEVELWIDTH
   ObjGetInt[15].id = OBJPROP_LEVELWIDTH;
   ObjGetInt[15].type = 0;
   ObjGetInt[15].modifier = 21;
   //OBJPROP_ALIGN
   ObjGetInt[16].id = OBJPROP_ALIGN;
   ObjGetInt[16].type = 0;
   ObjGetInt[16].modifier = false;
   //OBJPROP_FONTSIZE
   ObjGetInt[17].id = OBJPROP_FONTSIZE;
   ObjGetInt[17].type = 0;
   ObjGetInt[17].modifier = false;
   //OBJPROP_RAY_RIGHT
   ObjGetInt[18].id = OBJPROP_RAY_RIGHT;
   ObjGetInt[18].type = 2;
   ObjGetInt[18].modifier = false;
   //OBJPROP_ELLIPSE
   ObjGetInt[19].id = OBJPROP_ELLIPSE;
   ObjGetInt[19].type = 2;
   ObjGetInt[19].modifier = false;
   //OBJPROP_ARROWCODE
   ObjGetInt[20].id = OBJPROP_ARROWCODE;
   ObjGetInt[20].type = 7;
   ObjGetInt[20].modifier = false;
   //OBJPROP_TIMEFRAMES
   ObjGetInt[21].id = OBJPROP_TIMEFRAMES;
   ObjGetInt[21].type = 0;
   ObjGetInt[21].modifier = false;
   //OBJPROP_ANCHOR
   ObjGetInt[22].id = OBJPROP_ANCHOR;
   ObjGetInt[22].type = 0;
   ObjGetInt[22].modifier = false;
   //OBJPROP_XDISTANCE
   ObjGetInt[23].id = OBJPROP_XDISTANCE;
   ObjGetInt[23].type = 0;
   ObjGetInt[23].modifier = false;
   //OBJPROP_YDISTANCE
   ObjGetInt[24].id = OBJPROP_YDISTANCE;
   ObjGetInt[24].type = 0;
   ObjGetInt[24].modifier = false;
   //OBJPROP_DRAWLINES ////////////////////////////////// CHECK OBJPROP_DRAWLINES ??//////////////////////////////////////////////////////////
   ObjGetInt[25].id = OBJPROP_YDISTANCE;
   ObjGetInt[25].type = 0;
   ObjGetInt[25].modifier = false;
   //OBJPROP_STATE
   ObjGetInt[26].id = OBJPROP_STATE;
   ObjGetInt[26].type = 2;
   ObjGetInt[26].modifier = false;
   //OBJPROP_XSIZE
   ObjGetInt[27].id = OBJPROP_XSIZE;
   ObjGetInt[27].type = 0;
   ObjGetInt[27].modifier = false;
   //OBJPROP_YSIZE
   ObjGetInt[28].id = OBJPROP_YSIZE;
   ObjGetInt[28].type = 0;
   ObjGetInt[28].modifier = false;
   //OBJPROP_XOFFSET
   ObjGetInt[29].id = OBJPROP_XOFFSET;
   ObjGetInt[29].type = 0;
   ObjGetInt[29].modifier = false;
   //OBJPROP_YOFFSET
   ObjGetInt[30].id = OBJPROP_YOFFSET;
   ObjGetInt[30].type = 0;
   ObjGetInt[30].modifier = false;
   //OBJPROP_BGCOLOR
   ObjGetInt[31].id = OBJPROP_BGCOLOR;
   ObjGetInt[31].type = 3;
   ObjGetInt[31].modifier = false;
   //OBJPROP_CORNER
   ObjGetInt[32].id = OBJPROP_CORNER;
   ObjGetInt[32].type = 0;
   ObjGetInt[32].modifier = false;
   //OBJPROP_BORDER_TYPE
   ObjGetInt[33].id = OBJPROP_BORDER_TYPE;
   ObjGetInt[33].type = 0;
   ObjGetInt[33].modifier = false;
   //OBJPROP_BORDER_COLOR
   ObjGetInt[34].id = OBJPROP_BORDER_COLOR;
   ObjGetInt[34].type = 3;
   ObjGetInt[34].modifier = false;
   
   // DOUBLE //
   
   //OBJPROP_PRICE
   ObjGetDbl[0].id = OBJPROP_PRICE;
   ObjGetDbl[0].type = 5;
   ObjGetDbl[0].modifier = 18;
   //OBJPROP_LEVELVALUE
   ObjGetDbl[1].id = OBJPROP_LEVELVALUE;
   ObjGetDbl[1].type = 5;
   ObjGetDbl[1].modifier = 21;
   //OBJPROP_SCALE
   ObjGetDbl[2].id = OBJPROP_SCALE;
   ObjGetDbl[2].type = 5;
   ObjGetDbl[2].modifier = false;
   //OBJPROP_ANGLE
   ObjGetDbl[3].id = OBJPROP_ANGLE;
   ObjGetDbl[3].type = 5;
   ObjGetDbl[3].modifier = false;
   //OBJPROP_DEVIATION
   ObjGetDbl[4].id = OBJPROP_DEVIATION;
   ObjGetDbl[4].type = 5;
   ObjGetDbl[4].modifier = false;
   
   
   // STRING //
   
   //OBJPROP_NAME
   ObjGetStr[0].id = OBJPROP_NAME;
   ObjGetStr[0].type = 1;
   ObjGetStr[0].modifier = false;
   //OBJPROP_TEXT
   ObjGetStr[1].id = OBJPROP_TEXT;
   ObjGetStr[1].type = 1;
   ObjGetStr[1].modifier = false;
   //OBJPROP_TOOLTIP
   ObjGetStr[2].id = OBJPROP_TOOLTIP;
   ObjGetStr[2].type = 1;
   ObjGetStr[2].modifier = false;
   //OBJPROP_LEVELTEXT
   ObjGetStr[3].id = OBJPROP_LEVELTEXT;
   ObjGetStr[3].type = 1;
   ObjGetStr[3].modifier = 21;
   //OBJPROP_FONT
   ObjGetStr[4].id = OBJPROP_FONT;
   ObjGetStr[4].type = 1;
   ObjGetStr[4].modifier = false;
   //OBJPROP_BMPFILE
   ObjGetStr[5].id = OBJPROP_BMPFILE;
   ObjGetStr[5].type = 1;
   ObjGetStr[5].modifier = false;
   //OBJPROP_SYMBOL
   ObjGetStr[6].id = OBJPROP_SYMBOL;
   ObjGetStr[6].type = 1;
   ObjGetStr[6].modifier = false;
}
