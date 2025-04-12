#include "platform.h"
#define DEADLY_SERIOUS_EVENT 50

struct RX_HANDLE* rx_ptr = CAST(struct RX_HANDLE*, 0x05000000);

struct TX_HANDLE* tx_ptr = CAST(struct TX_HANDLE*, 0x06000000);

int main(int argc, char** argv)
{
    while (1) {
        while(!(rx_ptr->rst)){
    rx_ptr->baudrate = 115200;
    tx_ptr->baudrate = 115200;
    // for (int i = 0; i < 8; i++)
    // {
    //     a[i] = rx_ptr->data;
    // }
    out (0);
        }
    }
//    while(1) {
//       while(!());
//    }
}

int out (int rx)
{   
    int func_o [8];
    if (rx == 2) {
        for (int i = 0; i < 8; i++)
            {
                if (i % 2 == 0)
                    tx_ptr->data = func_o[i]; 
            }
        }
    if (rx == 0) {
        for (int i = 0; i < 8; i++) {
            func_o[i] = rx_ptr->data;
        }
        for (int i = 0; i < 8; i++) {
             if (func_o[i] == 48){
                func_o[i] = 0;
             }
             else if (func_o[i] == 49) {
                func_o[i] = 1;
             }
        }
    }
}

extern "C" void int_handler()
{
    if(DEADLY_SERIOUS_EVENT == rx_ptr->data)
        {
              out(2);
        }
}

