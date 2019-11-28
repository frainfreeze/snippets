void pauseX() {
    #if defined(__linux__) || defined(__unix__) || defined(__APPLE__)
        //Implement me!
    #endif

    #if defined(_WIN32) || defined(_WIN64)
        system("PAUSE");
    #endif
}