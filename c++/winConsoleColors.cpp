#include<windows.h>
#include<iostream>
using namespace std;

enum cons_color{
	black=0,
	dark_blue=1,
	dark_green=2,
	dark_aqua,dark_cyan=3,
	dark_red=4,
	dark_purple=5,dark_pink=5,dark_magenta=5,
	dark_yellow=6,
	dark_white=7,
	gray=8,
	blue=9,
	green=10,
	aqua=11,cyan=11,
	red=12,
	purple=13,pink=13,magenta=13,
	yellow=14,
	white=15
};

int textcolor(){
    // returns current text color
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&csbi);
	int a=csbi.wAttributes;
	return a%16;
}

int backcolor(){
    // returns current background color
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&csbi);
	int a=csbi.wAttributes;
	return (a/16)%16;
}

// overloading for different calls
void setcolor(int textcol,int backcol){
	textcol%=16;backcol%=16;
	unsigned short wAttributes = ((unsigned)backcol<<4) | (unsigned)textcol;
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), wAttributes);
}

void setcolor(cons_color textcol,cons_color backcol){
    setcolor(int(textcol),int(backcol));
}
//////////////////////////////////////////////////////


ostream& operator<<(ostream& os,cons_color c){
    os.flush();
    setcolor(c,backcolor());
    return os;
}


int main(){
	SetConsoleTitle("Color test");
  
	// zapamti default postavke
	cons_color foo = cons_color(textcolor());
	cons_color bar = cons_color(backcolor());

	cout<<red<<"Primjer 1"<<endl;
  
	setcolor(red,yellow);
	cout<<"Primjer 2"<<endl;
  
	setcolor(cyan,bar);
	cout<<"Primjer 3"<<endl;

	setcolor(foo,bar); // back to default
}
