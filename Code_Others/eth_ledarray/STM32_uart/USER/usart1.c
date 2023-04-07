/***************************************
 * 文件名  ：usart1.c
 * 描述    ：配置USART1         
 * 实验平台：MINI STM32开发板 基于STM32F103C8T6
 * 硬件连接：------------------------
 *          | PA9  - USART1(Tx)      |
 *          | PA10 - USART1(Rx)      |
 *           ------------------------
 * 库版本  ：ST3.0.0  

**********************************************************************************/

#include "usart1.h"
#include <stdarg.h>


void USART1_Config(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	USART_InitTypeDef USART_InitStructure;

	/* 使能 USART1 时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1 | RCC_APB2Periph_GPIOA, ENABLE); 

	/* USART1 使用IO端口配置 */    
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP; //复用推挽输出
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);    
  
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;	//浮空输入
  GPIO_Init(GPIOA, &GPIO_InitStructure);   //初始化GPIOA
	
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1; //光敏接口
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz; 
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU; //端口配置为上拉输入
	GPIO_Init(GPIOA, &GPIO_InitStructure);	//初始化端口
	  
	/* USART1 工作模式配置 */
	USART_InitStructure.USART_BaudRate = 115200;	//波特率设置：115200
	USART_InitStructure.USART_WordLength = USART_WordLength_8b;	//数据位数设置：8位
	USART_InitStructure.USART_StopBits = USART_StopBits_1; 	//停止位设置：1位
	USART_InitStructure.USART_Parity = USART_Parity_No ;  //是否奇偶校验：无
	USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;	//硬件流控制模式设置：没有使能
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;//接收与发送都使能
	USART_Init(USART1, &USART_InitStructure);  //初始化USART1
	USART_Cmd(USART1, ENABLE);// USART1使能
}

 /*发送一个字节数据*/
 void UART1SendByte(unsigned char SendData)
{	   
        USART_SendData(USART1,SendData);
        while(USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);	    
}  

/*接收一个字节数据*/
unsigned char UART1GetByte(unsigned char* GetData)
{   	   
        if(USART_GetFlagStatus(USART1, USART_FLAG_RXNE) == RESET)
        {  return 0;//没有收到数据 
		}
        *GetData = USART_ReceiveData(USART1); 
        return 1;//收到数据
}
/*接收一个数据，马上返回接收到的这个数据*/
void UART1Test(void)
{
       unsigned char i = 0,j=0;

       while(1)
       {    
				while(UART1GetByte(&i))
        {
					
         		if (i >= 0x41 && i <= 0x5a) //A-Z
					USART_SendData(USART1,i);
         		else if (i >= 0x30 && i <= 0x39)//0-9
					USART_SendData(USART1,i);
				else if (j == 0xBE && i == 0xA9){i = 0x40 +  0; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBD && i == 0xF2){i = 0x40 +  1; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBC && i == 0xBD){i = 0x40 +  2; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBD && i == 0xFA){i = 0x40 +  3; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC3 && i == 0xC9){i = 0x40 +  4; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC1 && i == 0xC9){i = 0x40 +  5; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBC && i == 0xAA){i = 0x40 +  6; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBA && i == 0xDA){i = 0x40 +  7; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xBB && i == 0xA6){i = 0x40 +  8; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD5 && i == 0xE3){i = 0x40 +  9; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xCB && i == 0xD5){i = 0x40 + 10; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xCD && i == 0xEE){i = 0x40 + 11; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC3 && i == 0xF6){i = 0x40 + 12; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB8 && i == 0xD3){i = 0x40 + 13; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC2 && i == 0xB3){i = 0x40 + 14; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD4 && i == 0xA5){i = 0x40 + 15; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB6 && i == 0xF5){i = 0x40 + 16; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xCF && i == 0xE6){i = 0x40 + 17; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD4 && i == 0xC1){i = 0x40 + 18; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB9 && i == 0xF0){i = 0x40 + 19; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC7 && i == 0xED){i = 0x40 + 20; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD3 && i == 0xE5){i = 0x40 + 21; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB4 && i == 0xA8){i = 0x40 + 22; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB9 && i == 0xF3){i = 0x40 + 23; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD4 && i == 0xC6){i = 0x40 + 24; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB2 && i == 0xD8){i = 0x40 + 25; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC9 && i == 0xC2){i = 0x40 + 26; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB8 && i == 0xCA){i = 0x40 + 27; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC7 && i == 0xE0){i = 0x40 + 28; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xC4 && i == 0xFE){i = 0x40 + 29; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xD0 && i == 0xC2){i = 0x40 + 30; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB8 && i == 0xDB){i = 0x40 + 31; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xB0 && i == 0xC4){i = 0x40 + 32; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);} 
				else if (j == 0xCC && i == 0xA8){i = 0x40 + 33; i += GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0) * 0X80; USART_SendData(USART1,i);}
				else j = i;
        }      
       }     
}
/*字库
BE A9 京
BD F2 津
BC BD 冀
BD FA 晋
C3 C9 蒙
C1 C9 辽
BC AA 吉
BA DA 黑
BB A6 沪
D5 E3 浙
CB D5 苏
CD EE 皖
C3 F6 闽
B8 D3 赣
C2 B3 鲁
D4 A5 豫
B6 F5 鄂
CF E6 湘
D4 C1 粤
B9 F0 桂
C7 ED 琼
D3 E5 渝
B4 A8 川
B9 F3 贵
D4 C6 云
B2 D8 藏
C9 C2 陕
B8 CA 甘
C7 E0 青
C4 FE 宁
D0 C2 新
B8 DB 港
B0 C4 澳
CC A8 台
41-5A A-Z 
30-39 0-9
*/


