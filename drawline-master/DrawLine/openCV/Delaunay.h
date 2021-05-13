#ifndef DELAUCAY_CPP
#define DELAUCAY_CPP

#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <fstream>
#include <string>

using namespace std;
using namespace cv;

//void delaunay(int cols, int rows, vector<Point> &srcPoints, vector<vector<int>> &result);


/*
 * cols     [图像列数]
 * rows        [图像行数]
 * filename [特征点文件]
 * 返回每个三角形的顶点对应的下标
 */

 vector<Point2f> generatePointSet(int n, using Rect rect);

 void drawSubdiv(Mat& img, Subdiv2D& subdiv, Scalar delaunay_color);


#endif
