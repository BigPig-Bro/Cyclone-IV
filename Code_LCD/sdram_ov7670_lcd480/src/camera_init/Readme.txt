�÷�:
	ֱ�Ӹ�������Ĵ��뵽�����ļ�����ȿ���

	localparam RGB = 0;
	localparam JPEG = 1;
	
	parameter IMAGE_WIDTH  = 640; //ͼƬ���
	parameter IMAGE_HEIGHT = 480; //ͼƬ�߶�(��720)
	parameter IMAGE_FLIP   = 0;   //0������ת��1�����·�ת
	parameter IMAGE_MIRROR = 0;   //0��������1�����Ҿ���

	//����ͷ��ʼ������
	wire Init_Done;
	camera_init
	#(
		.IMAGE_TYPE(RGB),
		.IMAGE_WIDTH(IMAGE_WIDTH),
		.IMAGE_HEIGHT(IMAGE_HEIGHT),
		.IMAGE_FLIP(IMAGE_FLIP),
		.IMAGE_MIRROR(IMAGE_MIRROR)
	)
	camera_init(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Init_Done(Init_Done),
		.camera_rst_n(camera_rst_n),
		.camera_pwdn(camera_pwdn),
		.i2c_sclk(camera_sclk),
		.i2c_sdat(camera_sdat)
	);