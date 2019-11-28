string line_fat_dots(76,177);

void setConsoleColor(int consoleColorSheme = 0, bool interactive_mode = false) {
    if(interactive_mode==true){
        clearScreen();
        cout << line_fat_dots << endl;
        cout << "Available color schemes: \n";
        cout << "\t\t0 - default\n\t\t1 - inverted\n\t\t2 - blue-white\n\t\t3 - white-purple\n\t\t4 - black-red\n\t\t5 - purple-white\n\t\t6 - black-yellow\n\t\t7 - light aqua-black\n\t\t8 - black-light aqua\n\t\t9 - black-green\n";
        cout << line_fat_dots << endl;
        cout << "Enter color scheme number: ";
        cin >> consoleColorSheme;
        cin.ignore();
    }
	#if defined(__linux__) || defined(__unix__) || defined(__APPLE__)
		cout << "Implement me!\endl";
	#endif

	#if defined(_WIN32) || defined(_WIN64)
        if(consoleColorSheme==0) system("color 0f"); // default
        if(consoleColorSheme==1) system("color f0"); // inverted
        if(consoleColorSheme==2) system("color 97"); // blue-white
        if(consoleColorSheme==3) system("color f5"); // white-purple
        if(consoleColorSheme==4) system("color 0c"); // black-red
        if(consoleColorSheme==5) system("color 5f"); // purple-white
        if(consoleColorSheme==6) system("color 0e"); // black-yellow
        if(consoleColorSheme==7) system("color 30"); // light aqua-black
        if(consoleColorSheme==8) system("color 03"); // black-light aqua
        if(consoleColorSheme==9) system("color 0a"); // black-green
	#endif
}