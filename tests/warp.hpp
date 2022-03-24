void fillGradient(cv::Mat& img, int delta = 5);
void smoothBorder(cv::Mat& img, const cv::Scalar& color, int delta = 3);

void fillGradient(cv::Mat& img, int delta) {
  const int ch = img.channels();
  assert(!img.empty() && img.depth() == CV_8U && ch <= 4);
  int n = 255 / delta;
  int r, c, i;
  for (r = 0; r < img.rows; ++r) {
    int kR = r % (2*n);
    int valR = (kR<=n) ? delta*kR : delta*(2*n-kR);
    for (c = 0; c < img.cols; ++c) {
      int kC = c % (2*n);
      int valC = (kC<=n) ? delta*kC : delta*(2*n-kC);
      uchar vals[] = {uchar(valR), uchar(valC), uchar(200*r/img.rows), uchar(255)};
      uchar *p = img.ptr(r, c);
      for (i = 0; i < ch; ++i)
        p[i] = vals[i];
    }
  }
}

void smoothBorder(cv::Mat& img, const cv::Scalar& color, int delta) {
  const int ch = img.channels();
  assert(!img.empty() && img.depth() == CV_8U && ch <= 4);

  cv::Scalar s;
  uchar *p = NULL;
  int n = 100/delta;
  int nR = std::min(n, (img.rows+1)/2), nC = std::min(n, (img.cols+1)/2);

  int r, c, i;
  for (r = 0; r < nR; ++r) {
      double k1 = r*delta/100., k2 = 1-k1;
      for (c = 0; c < img.cols; ++c) {
          p = img.ptr(r, c);
          for (i = 0; i < ch; ++i)
            s[i] = p[i];
          s = s * k1 + color * k2;
          for (i = 0; i < ch; ++i)
            p[i] = uchar(s[i]);
      }
      for (c = 0; c < img.cols; ++c) {
          p = img.ptr(img.rows-r-1, c);
          for (i = 0; i < ch; ++i)
            s[i] = p[i];
          s = s * k1 + color * k2;
          for (i = 0; i < ch; ++i)
            p[i] = uchar(s[i]);
      }
  }

  for (r = 0; r < img.rows; ++r) {
      for (c = 0; c < nC; ++c) {
          double k1 = c*delta/100., k2 = 1-k1;
          p = img.ptr(r, c);
          for (i = 0; i < ch; ++i)
            s[i] = p[i];
          s = s * k1 + color * k2;
          for (i = 0; i < ch; ++i)
            p[i] = uchar(s[i]);
      }
      for (c = 0; c < n; ++c) {
          double k1 = c*delta/100., k2 = 1-k1;
          p = img.ptr(r, img.cols-c-1);
          for (i = 0; i < ch; ++i)
            s[i] = p[i];
          s = s * k1 + color * k2;
          for (i = 0; i < ch; ++i)
            p[i] = uchar(s[i]);
      }
  }
}
