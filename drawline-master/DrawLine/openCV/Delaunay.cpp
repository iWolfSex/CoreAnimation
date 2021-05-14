/*
 * 使用 opencv 进行三角剖分
 */

using namespace std;
using namespace cv;
#include "Delaunay.h"


static void draw_point(Mat & img, const Point2f &fp, const Scalar &color) {
    circle(img, fp, 2, color, FILLED, LINE_AA, 0);
}

static void draw_triangulation(Mat & img, Subdiv2D & subdiv, const Scalar &delaunay_color) {
    vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    vector<Point> pt(3);
    Size size = img.size();
    Rect rect(0, 0, size.width, size.height);
    for (auto t : triangleList) {
        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));
        // Draw rectangles completely inside the image.
        if ( rect.contains(pt[0]) && rect.contains(pt[1]) && rect.contains(pt[2])) {
            line(img, pt[0], pt[1], delaunay_color, 1, LINE_AA, 0);
            line(img, pt[1], pt[2], delaunay_color, 1, LINE_AA, 0);
            line(img, pt[2], pt[0], delaunay_color, 1, LINE_AA, 0);
        }
    }
}

void read_image(char * path_image, char * path_points, Mat& image, vector<Point2f>& key_points) {
    image = imread(path_image);
//    ifstream ifs(path_points);
//    vector<int> points;
    int x, y;
    for (int i = 150; i < 170; i++) {
        for (int j = 50; j < 51; j++) {
            key_points.emplace_back(j, i);
        }
    }
    key_points.emplace_back(0, 0);
    key_points.emplace_back(0, 799);
    key_points.emplace_back(599, 0);
    key_points.emplace_back(599, 799);
    key_points.emplace_back(0, 400);
    key_points.emplace_back(300, 0);
    key_points.emplace_back(300, 799);
    key_points.emplace_back(599, 400);
//    while (ifs >> x >> y) {
//        key_points.emplace_back(x, y);
//    }
}

void read_image2(char * path_image, char * path_points, Mat& image, vector<Point2f>& key_points) {
    image = imread(path_image);
//    ifstream ifs(path_points);
//    vector<int> points;
//    int x, y;
//    while (ifs >> x >> y) {
//        y = max(0, y-50);
//        key_points.emplace_back(x, y);
//    }
    int x, y;
    for (int i = 180; i < 200; i++) {
        for (int j = 80; j < 81; j++) {
            key_points.emplace_back(j, i);
        }
    }
    key_points.emplace_back(0, 0);
    key_points.emplace_back(0, 799);
    key_points.emplace_back(599, 0);
    key_points.emplace_back(599, 799);
    key_points.emplace_back(0, 400);
    key_points.emplace_back(300, 0);
    key_points.emplace_back(300, 799);
    key_points.emplace_back(599, 400);
}

Subdiv2D get_triangulation(Mat & img, vector<Point2f> & points) {
    Size size = img.size();
    Rect rect(0, 0, size.width, size.height);
    Subdiv2D subdiv(rect);
    for (const auto &point: points) {
        subdiv.insert(point);
    }
    return subdiv;
}

// Apply affine transform calculated using srcTri and dstTri to src
void applyAffineTransform(Mat & warpImage, Mat & src, vector<Point2f> & srcTri, vector<Point2f> & dstTri) {
    // Given a pair of triangles, find the affine transform.
    Mat warpMat = getAffineTransform( srcTri, dstTri);
    // Apply the Affine Transform just found to the src image
    warpAffine( src, warpImage, warpMat, warpImage.size(), INTER_LINEAR, BORDER_REFLECT_101);
}

// Warps and alpha blends triangular regions from img1 and img2 to img
void morphTriangle(Mat & img1, Mat & img2, Mat & img, vector<Point2f> & t1,
        vector<Point2f> & t2, vector<Point2f> &t, float alpha) {
    // Find bounding rectangle for each triangle
    Rect r = boundingRect(t);
    Rect r1 = boundingRect(t1);
    Rect r2 = boundingRect(t2);
    // Offset points by left top corner of the respective rectangles
    vector<Point2f> t1Rect, t2Rect, tRect;
    vector<Point> tRectInt;
    for(int i = 0; i < 3; i++) {
        tRect.emplace_back(t[i].x - r.x, t[i].y -  r.y);
        tRectInt.emplace_back(t[i].x - r.x, t[i].y - r.y); // for fillConvexPoly
        t1Rect.emplace_back(t1[i].x - r1.x, t1[i].y -  r1.y);
        t2Rect.emplace_back(t2[i].x - r2.x, t2[i].y - r2.y);
    }
    // Get mask by filling triangle
    Mat mask = Mat::zeros(r.height, r.width, CV_32FC3);
    fillConvexPoly(mask, tRectInt, Scalar(1.0, 1.0, 1.0), 16, 0);
    // Apply warpImage to small rectangular patches
    Mat img1Rect, img2Rect;
    img1(r1).copyTo(img1Rect);
    img2(r2).copyTo(img2Rect);

    Mat warpImage1 = Mat::zeros(r.height, r.width, img1Rect.type());
    Mat warpImage2 = Mat::zeros(r.height, r.width, img2Rect.type());

    applyAffineTransform(warpImage1, img1Rect, t1Rect, tRect);
    applyAffineTransform(warpImage2, img2Rect, t2Rect, tRect);
    // Alpha blend rectangular patches
    Mat imgRect = (1.0 - alpha) * warpImage1 + alpha * warpImage2;

    // Copy triangular region of the rectangular patch to the output image
    multiply(imgRect,mask, imgRect);
    multiply(img(r), Scalar(1.0,1.0,1.0) - mask, img(r));
    img(r) = img(r) + imgRect;
}




/* ----------------------------------------------------------------------------------- */

//随机产生一个点集
vector<Point2f> generatePointSet(int n,Rect rect)
{
    vector<Point2f> pointSet;
    for (int i = 0; i < n;i++)
    {
        Point2f fp((float)(rand() % (rect.width - 2*rect.x) + rect.x),
            (float)(rand() % (rect.height - 2*rect.y) + rect.y));
        pointSet.push_back(fp);
    }
    return pointSet;
}

//标记出点
void drawPoint(Mat& img, Point2f fp, Scalar color)
{
    circle(img, fp, 3, color, CV_FILLED, 8, 0);
}

//画出点集
void drawPointSet(Mat& img, vector<Point2f> pointSet, Scalar color)
{
    for (int i = 0; i < pointSet.size();i++)
    {
        drawPoint(img, pointSet[i], color);
    }
}

//画出剖分
void drawSubdiv(Mat& img, Subdiv2D& subdiv, Scalar delaunay_color)
{
    vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    vector<Point> pt(3);
    for (size_t i = 0; i < triangleList.size(); i++)
    {
        Vec6f t = triangleList[i];
        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));
        line(img, pt[0], pt[1], delaunay_color, 1, CV_AA, 0);
        line(img, pt[1], pt[2], delaunay_color, 1, CV_AA, 0);
        line(img, pt[2], pt[0], delaunay_color, 1, CV_AA, 0);
    }
}

//计算仿射变换
Mat affineTransform(Mat& img, Subdiv2D& subdiv)
{
    
    /**  旋转 */
    cv::Size dst_image_size(img.cols, img.rows);// 设置旋转后图像的尺寸
    cv::Point2f rotation_center(static_cast<float>(img.cols / 2.), static_cast<float>(img.rows / 2.));// 指定旋转中心
    std::cout << "旋转中心:\n" << rotation_center << std::endl;
    cv::Mat rotation_matrix = cv::getRotationMatrix2D(rotation_center, 45, 1.0); // 构造旋转矩阵
    std::cout << "旋转矩阵:\n" << rotation_matrix << std::endl;
    /**
    * 调用 cv::getRotationMatrix2D 获得图像绕着中心点旋转45度的旋转矩阵
    * 函数原型：
    * Mat getRotationMatrix2D(Point2f center, double angle, double scale)
    * 参数详解：
    * Point2f center：表示旋转的中心点
    * double angle：表示旋转的角度
    * double scale：图像缩放因子
    */
    cv::Mat rotation_image;// 旋转后的图像
    cv::warpAffine(img, rotation_image, rotation_matrix, dst_image_size,cv::INTER_LINEAR);
    return rotation_image;
    
    
    /**   平移 图形*/
    cv::Mat translation_matrix =cv::Mat::zeros(2, 3, CV_32FC1);// 构造平移矩阵
    translation_matrix.at<float>(0, 0) = 1;
    translation_matrix.at<float>(0, 2) = 150;// 水平平移量
    translation_matrix.at<float>(1, 1) = 1;
    translation_matrix.at<float>(1, 2) = 150;// 竖直平移量
    std::cout << "平移矩阵:\n"<< translation_matrix << std::endl;
    cv::Mat translation_image;// 创建平移后的图像
    cv::warpAffine(img, translation_image, translation_matrix, dst_image_size);
    return translation_image;
    
    
    /* 矩阵仿射变换 */
    //设置原图变换顶点
    Point2f warpAffine_AffinePoints0[3] = { cv::Point2f(100, 50), cv::Point2f(100, 390), cv::Point2f(600, 50) };
    //设置目标图像变换顶点
    Point2f warpAffine_AffinePoints1[3] = { cv::Point2f(200, 100), cv::Point2f(200, 330), cv::Point2f(500, 50) };

    // 设置目标图像变换顶点
    cv::Mat affine_transform_matrix = cv::getAffineTransform(warpAffine_AffinePoints0, warpAffine_AffinePoints1);
    std::cout << "仿射变换矩阵:\n"<< affine_transform_matrix << std::endl;
    /**
    * 用函数Mat getAffineTransform( const Point2f src[], const Point2f dst[] );生成变换矩阵
    * 参数 const Point2f* src:原图的三个固定顶点
    * 参数 const Point2f* dst:目标图像的三个固定顶点
    * 返回值:Mat型变换矩阵,可直接用于warpAffine()函数
    * 注意:顶点数组长度超过3个,则会自动以前3个为变换顶点,数组可用Point2f[]或Point2f*表示
    */
    cv::Mat affine_transform_image;// 变换后的图像
    warpAffine(img, affine_transform_image, affine_transform_matrix, cv::Size(img.cols, img.rows));
    
    
    for (int i = 0; i <3; i++){
        circle(img, warpAffine_AffinePoints0[i], 2, cv::Scalar(0, 0, 255),2);
        circle(affine_transform_image, warpAffine_AffinePoints1[i], 2,cv::Scalar(0, 0, 255), 2);
    }

    cv::Point2f Points0[4] = { cv::Point2f(100, 50), cv::Point2f(100, 390), cv::Point2f(600, 50), cv::Point2f(600, 390) };
    cv::Point2f Points1[4] = { cv::Point2f(200, 100), cv::Point2f(200, 330), cv::Point2f(500, 50), cv::Point2f(600, 390) };
    cv::Mat perspective_trans_matrix = getPerspectiveTransform(Points0, Points1);// 设定变换对应的几个点getPerspectiveTransform生成变换矩阵
    std::cout << "透视变换矩阵:\n"<< perspective_trans_matrix << std::endl;
    cv::Mat warp_perspective_image;
    
    
    warpPerspective(img, warp_perspective_image, perspective_trans_matrix,cv::Size(img.cols, img.rows), CV_INTER_CUBIC);
    /**
    透视变换是图像基于4个固定顶点3D平面的变换,主要作用是对图像进行变形,仿射等是透视变换的特殊形式,经过透视变换之后的图片通常不是平行四边形除非映射视平面和原来平面平行的
    函数原型:
    void warpPerspective(InputArray src, OutputArray dst, InputArray M, Size dsize, int flags=INTER_LINEAR, int borderMode=BORDER_CONSTANT,
    　　　　　　　　　　　　const Scalar& borderValue=Scalar())
    参数详解:
    InputArray　src:输入的图像
    OutputArray dst:输出的图像
    InputArray M:透视变换的矩阵
    Size dsize:输出图像的大小
    int flags=INTER_LINEAR:输出图像的插值方法
    int borderMode=BORDER_CONSTANT:图像边界的处理方式
    const Scalar& borderValue=Scalar():边界的颜色设置,一般默认是0
    */
    for (int i = 0; i < 4; i++){
        circle(img, Points0[i], 2, cv::Scalar(0, 0,255), 2);
        circle(warp_perspective_image, Points1[i], 2, cv::Scalar(0, 0, 255), 2);
    }
    
    
    return warp_perspective_image;
}





//画出Voronoi图
void paintVoronoi(Mat& img, Subdiv2D& subdiv)
{
    vector<vector<Point2f> > facets;
    vector<Point2f> centers;
    subdiv.getVoronoiFacetList(vector<int>(), facets, centers);
    vector<Point> ifacet;
    vector<vector<Point> > ifacets(1);
    for (size_t i = 0; i < facets.size(); i++)
    {
        ifacet.resize(facets[i].size());
        for (size_t j = 0; j < facets[i].size(); j++)
            ifacet[j] = facets[i][j];
        Scalar color;
        color[0] = rand() & 255;
        color[1] = rand() & 255;
        color[2] = rand() & 255;
        fillConvexPoly(img, ifacet, color, 8, 0);
        ifacets[0] = ifacet;
        polylines(img, ifacets, true, Scalar(), 1, CV_AA, 0);
        circle(img, centers[i], 3, Scalar(), CV_FILLED, CV_AA, 0);
    }
}



/*
 * 获取三角剖分结果
 */
void disTriangles(int cols, int rows, Subdiv2D& subdiv, vector<vector<Point>> &triangles) {
    vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
	vector<Point> pt(3);

    bool ok;
    Vec6f t;

    for(size_t i = 0; i < triangleList.size(); ++i) {
    	t = triangleList[i];
        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));
		ok = true;
		for(int i = 0; i < 3; ++i) {
		 	if(pt[i].x > cols || pt[i].y > rows || pt[i].x < 0 || pt[i].y < 0)
				ok = false;
		}
		if (ok) {
			triangles.push_back(pt);
		}
    }
}

void indexMap(vector<vector<Point>> &triangles, vector<Point> &srcPoints, vector<vector<int>> &result) {
	vector<int> index(3);
	int i, j, k;
	for (i = 0; i < triangles.size(); ++i) {
		for (j = 0; j < 3; ++j) {
			for (k = 0; k < srcPoints.size(); ++k) {
				if (triangles[i][j] == srcPoints[k]) {
					index[j] = k;
					break;
				}
			}
		}
		result.push_back(index);
	}
}

void debug(vector<vector<Point>> &triangles, vector<Point> &srcPoints, vector<vector<int>> &result) {
	Scalar active_facet_color(0, 0, 255), delaunay_color(255,255,255);
	Mat img1 = imread("../input/2.bmp");
	Mat img2 = img1.clone();
	for (int i = 0; i < triangles.size(); ++i) {
		line(img1, triangles[i][0], triangles[i][1], active_facet_color);
		line(img1, triangles[i][0], triangles[i][2], active_facet_color);
		line(img1, triangles[i][2], triangles[i][1], active_facet_color);
	}
	for (int i = 0; i < result.size(); ++i) {
		line(img2, srcPoints[result[i][0]], srcPoints[result[i][1]], delaunay_color);
		line(img2, srcPoints[result[i][0]], srcPoints[result[i][2]], delaunay_color);
		line(img2, srcPoints[result[i][2]], srcPoints[result[i][1]], delaunay_color);
	}
	imshow("img1", img1);
	imshow("img2", img2);
	waitKey(5000);
}

/*
 * cols     [图像列数]
 * rows		[图像行数]
 * filename [特征点文件]
 * 返回每个三角形的顶点对应的下标
 */
void delaunay(int cols, int rows, vector<Point> &srcPoints, vector<vector<int>> &result) {
	Rect rect(0, 0, cols, rows);
    Subdiv2D subdiv(rect);	

	// [1] 读入特征点坐标
	for (int i = 0; i < srcPoints.size(); ++i) {
		subdiv.insert(srcPoints[i]);
	}
	// [2] 三角剖分
	vector<vector<Point>> triangles;
	disTriangles(cols, rows, subdiv, triangles);
	// [3] 找出三角行的三个顶点原先的下标
	indexMap(triangles, srcPoints, result);

	// debug(triangles, srcPoints, result);
}
