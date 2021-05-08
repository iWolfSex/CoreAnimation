//
//  LCFlowImage.m
//  LCFlowImage
//
//  Created by iWolf on 2021/5/8.
//

#import <GLKit/GLKit.h>
#import "LCFlowImage.h"
@interface LCFlowImage ()
@property (nonatomic, strong) EAGLContext *myContext; // OpenGL context,管理使用opengl es进行绘制的状态,命令及资源
@property (nonatomic, strong) GLKBaseEffect *mEffect;
@property (nonatomic, strong) CAEAGLLayer *myEAGLayer;
@property (nonatomic, assign) GLuint myColorRenderBuffer;
@property (nonatomic, assign) GLuint myColorFrameBuffer;
@property (nonatomic, assign) GLuint myProgramOne;
@property (nonatomic, assign) GLuint myProgramTwo;


@property (nonatomic, assign) GLuint attrBufferTwo;
@property (nonatomic, assign) GLuint attrBufferOne;
 

@end

@implementation LCFlowImage
 GLKTextureInfo *_textureInfoOne;
 GLKTextureInfo *_textureInfoTwo;
int skipnum;
GLfloat* attrArrpos ;
+(Class)layerClass
{
    return [CAEAGLLayer class];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)layoutSubviews
{
     
    //1、设置图层
    [self setUpLayer];
    
    //2、创建上下文
    [self setupContext];
    
    //3、清空缓冲区
    [self deleteRenderAndFrameBuffer];
    
    //4、设置RenderBuffer
    [self setupRenderBuffer];
    
    //5、设置frameBuffer
    [self setupFrameBuffer];
    
    //6、开始绘制
    
    [self makeTwoBuff];
    [self renderLayer];
    
    skipnum=0;
    [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(upFrame) userInfo:nil repeats:YES];
    
}


//1、设置图层
-(void)setUpLayer
{
    //1、设置图层
    self.myEAGLayer = (CAEAGLLayer *)self.layer;
    
    //比例因子决定了内容如何从逻辑坐标空间(以点度量)映射到设备坐标空间(以像素度量)。这个值通常是1.0或2.0。更高的比例因子表明，
    //每一个点在屏幕上都有一个以上的像素表示。例如，如果比例因子为2.0，而绘制矩形的大小为50 x 50，则底层区域的大小为100 x 100像素。
    //2、设置比例因子
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    /**3、我们要绘制的东西是完全不透明的，所以可以去设置为YES
     一个布尔值，该值指示该层是否包含完全不透明的内容。
     此属性的默认值为NO。如果您的应用程序绘制了完全不透明的内容，填充了该层的边界，那么将该属性设置为YES，
     可以让系统优化该层的呈现行为。具体地说，当该层为您的绘图命令创建后备存储时，Core Animation会省略该后备存储器的alpha通道。
     这样做可以提高合成操作的性能。如果将此属性的值设置为YES，则必须使用不透明的内容填充该层的边界。
     设置此属性只影响由Core Animation管理的后台存储。如果将一个带有alpha通道的图像分配给该层的内容属性，则该图像保留其alpha通道，而不考虑该属性的值。
     */
    self.myEAGLayer.opaque=YES;
    
    //4、设置描述属性，
    /*
     kEAGLDrawablePropertyRetainedBacking 设置是否需要保留已经绘制到图层上面的内容 用NSNumber来包装，kEAGLDrawablePropertyRetainedBacking
     为FALSE，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为 TRUE 对性能和资源影像较大，
     因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。
     kEAGLDrawablePropertyColorFormat 设置绘制对象内部的颜色缓冲区的格式 32位的RGBA的形式
     包含的格式
     kEAGLColorFormatRGBA8; 32位RGBA的颜色 4x8=32
     kEAGLColorFormatRGB565; 16位的RGB的颜色
     kEAGLColorFormatSRGBA8 SRGB
     */
    self.myEAGLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],
                                          kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
    
}
-(void)setupContext
{
    //1、指定API版本 1.0-3.0
    /*
     kEAGLRenderingAPIOpenGLES1 = 1,
     kEAGLRenderingAPIOpenGLES2 = 2,
     kEAGLRenderingAPIOpenGLES3 = 3,
     */
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    
    //2、创建图形上下文
    EAGLContext * context = [[EAGLContext alloc]initWithAPI:api];
    
    //3、判断是否创建成功
    if(context==NULL)
    {
        NSLog(@"Create Context Failed!");
        return;
    }
    //4、设置图形上下文
    if(![EAGLContext setCurrentContext:context])
    {
        NSLog(@"setCurrentContext failed!");
        return;
    }
    //5、将局部的context 变成全局的
    self.myContext = context;
}

//3、清空缓冲区
-(void)deleteRenderAndFrameBuffer
{
    /**
     buffer分为FrameBuffer和Render Buffer 两大类
     frameBuffer(FBO)相当于renderBuffer的管理者
     renderBuffer分为3类，一个是colorBuffer，depthBuffer,stencilBuffer
     删除缓存空间
     */
    glDeleteBuffers(1, &_myColorRenderBuffer);
    
    //为了安全释放，所以将myColorRenderBuffer置为0
    self.myColorRenderBuffer = 0;
    
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer=0;
    
}


-(void)setupRenderBuffer
{
    //1、定义一个缓冲区
    GLuint buffer;
    
    //2、申请一个缓冲区标记
    glGenRenderbuffers(1, &buffer);
    
    //3、赋值给全局属性
    self.myColorRenderBuffer = buffer;
    
    //4、将缓冲区绑定到指定的空间中，把colorRenderbuffer绑定在OpenGL ES的渲染缓存GL_RENDERBUFFER上
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    
    /*5、
     通过调用上下文的renderbufferStorage:fromDrawable:方法并传递层对象作为参数来分配其存储空间。宽度，高度和像素格式取自层，
     用于为renderbuffer分配存储空间*/
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLayer];
    
    
}
-(void)setupFrameBuffer
{
    //1、定义一个缓冲区标记
    
    GLuint buffer;
    
    //2、申请一个缓存区标记
    glGenFramebuffers(1, &buffer);
    
    //3、设置给全局属性
    self.myColorFrameBuffer = buffer;
    
    //4、将缓冲区绑定到指定的空间中
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    
    //5、把GL_RENDERBUFFER里的colorRenderbuffer附在GL_FRAMEBUFFER的GL_COLOR_ATTACHMENT0（颜色附着点0）上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
    
}
-(void)setupTextureOne:(NSString *)value
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:value ofType:@"png"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft,NULL];
    _textureInfoOne = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:NULL];
    
    //  _mEffect = [[GLKBaseEffect alloc]init];
    //  _mEffect.texture2d0.enabled = GL_TRUE;
    //纹理的名字
    //  _mEffect.texture2d0.name = textureInfo.name;
}
-(void)setupTextureTwo
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"brdf_ltu" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft,NULL];
    _textureInfoTwo= [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:NULL];
    
    // _mEffect = [[GLKBaseEffect alloc]init];
    
    
    
    
    
    //  _mEffect.texture2d0.enabled = GL_TRUE;
    //纹理的名字
    //  _mEffect.texture2d0.name = textureInfo.name;
}
-(void)makeTwoBuff{
    
    GLfloat attrArr[] = {
        
        0.7f, -0.7f, 0.0f,     1.0f, 0.0f,
        -0.7f, 0.7f, 0.0f,     0.0f, 1.0f,
        -0.7f, -0.7f, 0.0f,    0.0f, 0.0f,
        0.7f, 0.7f, 0.0f,      1.0f, 1.0f,
        -0.7f, 0.7f, 0.0f,     0.0f, 1.0f,
        0.7f, -0.7f, 0.0f,     1.0f, 0.0f,
    };
    glGenBuffers(1, &_attrBufferOne);
    glBindBuffer(GL_ARRAY_BUFFER, _attrBufferOne);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
}
-(void)upFrame{
    
    NSLog(@"-----skipnum=>%d",skipnum++);
    glClearColor(    1,0, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    //6、加载并使用链接好的程序
    
    GLuint selectProgram=self.myProgramOne;
 
  
    
    if(skipnum  %10==0){
        selectProgram=self.myProgramOne;
               glUseProgram(selectProgram);
        glBindBuffer(GL_ARRAY_BUFFER, _attrBufferOne);
        glBindTexture(_textureInfoOne.target,_textureInfoOne.name);
    }else{
        selectProgram=self.myProgramTwo;
               glUseProgram(selectProgram);
        glBindTexture(_textureInfoTwo.target,_textureInfoTwo.name);
        glBindBuffer(GL_ARRAY_BUFFER, _attrBufferTwo);
    }

    
//    GLuint rotateID = glGetUniformLocation( selectProgram, "rotateMatrix");
//      [self.posMatrix3d prependTranslation:0.001 y:0 z:0];
//      glUniformMatrix4fv(rotateID, 1, GL_FALSE, self.posMatrix3d.m);
    
    GLuint position = glGetAttribLocation( selectProgram, "position");
    
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*5, NULL);
    
    GLuint textCoor = glGetAttribLocation( selectProgram, "textCoordinate");
    
    glEnableVertexAttribArray(textCoor);
    
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    // [self setupTexture:@"03"];
    
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
    
}
//6、开始绘制
-(void)renderLayer
{
    //1、开始写入顶点着色器、片元着色器
    //Vextex Shader
    //Fragment Shader
    
    //已经写好了顶点shaderv.vsh、片元着色器shaderf.fsh
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    
    //清除颜色缓冲区
    glClear(GL_COLOR_BUFFER_BIT);
    
    //2、设置视口大小
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    glViewport(self.frame.origin.x*scale, self.frame.origin.y*scale, self.frame.size.width*scale, self.frame.size.height*scale);
    //3、读取顶点、片元着色器程序
    //读取存储路径
 
    
     
    self.myProgramOne = [self LoadShader:[[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"] WithFrag: [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"]];
    
    //5、链接
    glLinkProgram(self.myProgramOne);
    
    //获取link的状态
    GLint linkStatus;
    //program是一个着色器程序的id；pname是GL_LINK_STATUS；param是返回值，在连接阶段使用glGetProgramiv获取连接情况
    
    /*首先通过glCreateProgram程序创建 OpenGL 程序，然后通过glAttachShader将着色器程序 ID 添加上 OpenGL 程序，
     接下来通过glLinkProgram链接 OpenGL 程序，最后通过glGetProgramiv来验证链接是否失败。*/
    glGetProgramiv(self.myProgramOne, GL_LINK_STATUS, &linkStatus);
    
    
     self.myProgramTwo = [self LoadShader:[[NSBundle mainBundle]pathForResource:@"shadertwo" ofType:@"vsh"] WithFrag: [[NSBundle mainBundle]pathForResource:@"shadertwo" ofType:@"fsh"]];
 
    //5、链接
    glLinkProgram(self.myProgramTwo);
    glGetProgramiv(self.myProgramTwo, GL_LINK_STATUS, &linkStatus);
    
    //判断linkStatus的状态
    if(linkStatus==GL_FALSE)
    {
        //获取失败信息
        GLchar message[512];
        //来检查是否有error，并输出信息
        /*
         作用:连接着色器程序也可能出现错误，我们需要进行查询，获取错误日志信息
         参数1: program 着色器程序标识
         参数2: bufsize 最大日志长度
         参数3: length 返回日志信息的长度
         参数4：infoLog 保存在缓冲区中
         */
        glGetProgramInfoLog(self.myProgramOne, sizeof(message), 0, &message[0]);
        
        //将C语言字符串转换成OC字符串
        NSString * messageStr = [NSString stringWithUTF8String:message];
        
        NSLog(@"Program Link Error:%@",messageStr);
        
        return;
    }
    NSLog(@"Program Link Success!");
    
    //6、加载并使用链接好的程序
    glUseProgram(self.myProgramOne);
    
    //7.设置顶点,前三个是顶点的坐标，后两个是纹理的坐标
    GLfloat attrArr[] = {
        
        0.5f, -0.5f, 0.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, 0.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, 0.0f,    0.0f, 0.0f,
        0.5f, 0.5f, 0.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, 0.0f,     0.0f, 1.0f,
        0.5f, -0.5f, 0.0f,     1.0f, 0.0f,
    };
    attrArrpos=attrArr;
    //8、----处理顶点数据-----
    
    //申请一个缓存标记
    glGenBuffers(1, &_attrBufferTwo);
    //确认缓存区是干什么的，就是绑定缓存区,在这里是存储顶点数组的
    glBindBuffer(GL_ARRAY_BUFFER, _attrBufferTwo);
    
    //将顶点缓冲区的CPU内存复制到GPU内存中
    /*
     参数 target：与 glBindBuffer 中的参数 target 相同；
     参数 size ：指定顶点缓存区的大小，以字节为单位计数；
     data ：用于初始化顶点缓存区的数据，可以为 NULL，表示只分配空间，之后再由 glBufferSubData 进行初始化；
     usage ：表示该缓存区域将会被如何使用，它的主要目的是用于提示OpenGL该对该缓存区域做何种程度的优化。其参数为以下三个之一：
     GL_STATIC_DRAW：表示该缓存区不会被修改；
     GL_DyNAMIC_DRAW：表示该缓存区会被周期性更改；
     GL_STREAM_DRAW：表示该缓存区会被频繁更改；
     */
    
    NSLog(@"长度%lu",sizeof(attrArr));
    glBufferData(GL_ARRAY_BUFFER, 120, attrArrpos, GL_DYNAMIC_DRAW);
    
    /*glGetAttribLocation是用来获得vertex attribute的入口的,在我们要传递数据之前，首先要告诉OpenGL，所以要调用glEnableVertexAttribArray。
     最后的数据通过glVertexAttribPointer传进来。它的第一个参数就是glGetAttribLocation返回的值。*/
    
    //9、获取着色器程序中，指定为attribute类型变量的id
    GLuint position = glGetAttribLocation(self.myProgramOne, "position");
    
    //告诉OpenGL，允许使用顶点坐标数组
    glEnableVertexAttribArray(position);
    
    //设置读取的方式
    
    /**第一个参数指定我们要配置哪一个顶点属性
     第二个参数指定顶点属性的大小。就比如三维的位置，x,y,z它由3个数值组成
     第三个参数指定数据的类型，这里是GL_FLOAT
     第四个参数定义我们是否希望数据被标准化归一化。如果我们设置为GL_TRUE，所有数据都会被映射到0(对于有符号型signed数据是-1)到1之间。
     我们把它设置为GL_FALSE
     第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性之间间隔有多少。由于下个位置数据在5个GLfloat后面的位置，我们把步长设置为5 * sizeof(GLfloat)
     第六个参数：GLvoid*的强制类型转换。它表示我们的位置数据在缓冲中起始位置的偏移量。由于位置数据是数组的开始，所以这里是0,NULL就是0，告诉OpenGL ES
     可以从当前绑定的顶点缓存的位置访问顶点数据
     */
    //每次读取三个数据
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*5, NULL);
    
    //通过三个设置就可以往着色器语言中传入数据
    
    //处理纹理数据，也就是纹理坐标
    GLuint textCoor = glGetAttribLocation(self.myProgramOne, "textCoordinate");
    //参数：index：指定了需要启用的顶点属性数组的索引，注意：它只在OpenGL2.0及其以上版本才有。
    glEnableVertexAttribArray(textCoor);
    
    //设置读取方式
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    
    //10、加载纹理,通过一个自定义的方法来解决加载纹理的方法
    [self setupTextureOne:@"WechatIMG13"];
    [self setupTextureTwo];
    
    //直接通过3D数学的公式来实现旋转
    //uniform只是从外部传入到顶点着色器或者片元着色器里面，内部不能改变
    //旋转 矩阵->Uniform 传递到vsh,fsh中
    
    //需求：旋转10度 -> 弧度
    float rotate = 0 * 3.141592f /180.0f;
    
    //旋转的矩阵公式
    float s = sin(rotate);
    float c = cos(rotate);
    
    //构建旋转的矩阵公式
    GLfloat zRotation[16]={
        c,-s,0,0,
        s,c,0,0,
        0,0,1.0,0,
        0,0,0,1.0,
    };
    
    
    // NSLog(@"--------%@",  [self.posMatrix3d getddm] );
    
    /*
     glGetUniformLocation函数得到名字为“RotationMatrix”在shader中的位置，然后再判断该变量是否存在（如果不存在，则会返回-1）。
     如果存在，在通过glUniformMatrix4fv函数向其传递数据。该函数的第一个参数是该变量在shader中的位置，第二个参数是被赋值的矩阵的数目（
     因为uniform变量可以是一个数组）。第三个参数表明在向uniform变量赋值时该矩阵是否需要转置。如果你正在使用一个数组来实现矩阵，
     并且这个矩阵是按行定义的，那么你就需要设置这个参数为GL_TRUE。最后一个参数就是传递给uniform变量的数据的指针了。
     */
    //获取着色器程序中，指定为uniform类型变量的id
    GLuint rotateID = glGetUniformLocation(self.myProgramOne, "rotateMatrix");
    
    
    
    //将这个旋转矩阵传进顶点着色器里面的uniform中,uniform不仅可以传矩阵还可以是变量
    
    
    glUniformMatrix4fv(rotateID, 1, GL_FALSE, zRotation);
    
    
    //数据是放入缓冲区了，但是还没有绘制,
    /*
     参数1：绘制的方式
     参数2：从哪里开始取
     参数3：数组元素数量
     */
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    /*
     - (BOOL)presentRenderbuffer:(NSUInteger)target 是将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前
     renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。在前面设置 drawable 属性时，
     我们设置 kEAGLDrawablePropertyRetainedBacking 为FALSE，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。
     将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。
     */
    //请求本机窗口系统显示OpenGL ES renderbuffer绑定到target
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

-(GLuint)LoadShader:(NSString *)vert WithFrag:(NSString *)frag
{
    //1、定义两个临时的着色器对象
    GLuint verShader,fragShader;
    //2、glCreateProgram，顾名思义，这个接口就是创建一个着色器程序对象
    GLuint program = glCreateProgram();
    
    //3、编译shader
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    
    //4、创建最终的程序,关联着色器对象到着色器程序对象
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //5、释放已经使用完毕的verShader\fragShader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
    
}

-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    //1、读取shader路径，已经知道编码，明确要求用这种编码来读取文件内容，返回一个字符串，该字符串是通过使用给定编码在给定路径中读取数据而创建的。
    NSString * content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    //2、将OC字符串->C语言字符串
    const GLchar * source = (GLchar *)[content UTF8String];
    
    /*3、对每一个着色器类型，通过glCreateShader创建一个管理着色器源代码的着色器对象，type    ——待创建的着色器对象类型
     返回值   ——着色器对象的ID
     */
    *shader = glCreateShader(type);
    
    //4、对每一个着色器文件名，通过调用_ReadShaderSourceCode读入文件中的着色器程序源代码。
    
    /*
     void glShaderSource(GLuint shader, GLsizei count, const GLchar **string, const GLchar* length);
     
     shader    ——标识着色器对象的ID（可理解为Handler）
     count     ——着色器源代码的数量
     string    ——着色器源代码（可能由多个，根据count而定）
     length    ——每个着色器源代码的长度, ，每个字符串的长度或NULL，这意味着这些字符串是NULL终止的,可以为NULL 代表字符串为NULL 结尾的，否则，length就代表具有就有count个元素，每个元素指定了string中对应字符串的长度，如果length数组中的某个元素对应一个正整数，就代表string数组中对应字符串的长度，如果是负整数，对应的字符串就是以NULL 结尾的.
     
     */
    glShaderSource(*shader, 1, &source,NULL);
    
    /*
     4/着色器源代码也已经有了，并和着色器对象做了关联，接下来就是把编译着色器源代码成为目标代码了，这就是glCompileShader的功能，其函数签名为：
     
     void glCompileShader(GLuint shader)
     
     shader    ——标识着色器对象的ID
     */
    glCompileShader(*shader);
    
    
}

@end
