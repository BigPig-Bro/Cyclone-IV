用法:
	直接复制下面的代码到顶层文件里面既可以

	localparam RGB = 0;
	localparam JPEG = 1;
	
	parameter IMAGE_WIDTH  = 640; //图片宽度
	parameter IMAGE_HEIGHT = 480; //图片高度(≤720)
	parameter IMAGE_FLIP   = 0;   //0：不翻转，1：上下翻转
	parameter IMAGE_MIRROR = 0;   //0：不镜像，1：左右镜像

	//摄像头初始化配置
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