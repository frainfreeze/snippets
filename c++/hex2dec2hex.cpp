#include <iostream>
#include <sstream>
#include <iomanip>

void dec2hex()
{
    int input;
    std::cout << "Enter decimal number: ";
    std::cin >> input;
    std::cout << "0x" << std::hex << input << '\n' ;
}

void hex2dec()
{
    std::string s;
    std::cout << "Enter hexadecimal number: ";
    getline(std::cin, s);
    unsigned int x = std::stoul(s, nullptr, 16);
    std::cout << x << '\n' ;
}

int main()
{
    for(;;){
        int input ;
        std::cout << "1. Dec to hex 2. Hex to dec, 3. exit: ";
        std::cin >> input;
        std::cin.ignore();
        switch (input){
        case 1:
            dec2hex();
            break;
        case 2:
            hex2dec();
            break;
        case 3:
            return 0;        
        default:
            break;
        }
    }
}