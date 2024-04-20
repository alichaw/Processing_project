import hypermedia.net.*;

UDP udp;  // Create a UDP object to receive data

float arousal = 0.5;
float valence = 0.5;
ArrayList<EmotionShape> shapes = new ArrayList<EmotionShape>();

void setup() {
  size(800, 600);
  udp = new UDP(this, 5005);  // Initialize UDP on port 5005
  udp.listen(true);           // Start listening to incoming data
  noStroke();
}

void draw() {
  background(255);  // Set background to white
  for (int i = shapes.size() - 1; i >= 0; i--) {
    EmotionShape shape = shapes.get(i);
    if (!shape.display()) {
      shapes.remove(i);
    }
  }
}

void receive(byte[] data, String ip, int port) {
  println("Data received from IP " + ip + " on port " + port);
  String receivedString = new String(data).trim();
  println("Received string: " + receivedString);

  try {
    String[] values = receivedString.split(",");  // 按逗號分割字符串
    if (values.length == 2) {
      arousal = Float.parseFloat(values[0]);
      valence = Float.parseFloat(values[1]);
      println("Parsed Arousal: " + arousal + ", Valence: " + valence);  // 輸出解析後的數據
      addShape(arousal, valence);
    }
  } catch (Exception e) {
    println("Error parsing data: " + e.getMessage());  // 捕獲並輸出任何解析錯誤
  }
}


void addShape(float arousal, float valence) {
    int fillColor;
    int shapeType;
    float baseSize = 50;  // 基本大小
    float sizeMultiplier = 100;  // 大小調整的倍數因子
    float size = baseSize + (arousal * sizeMultiplier);  // 根據 Arousal 調整大小

    float x = random(width);
    float y = random(height);

    if (arousal > 0.75 && valence > 0.5) {
        fillColor = color(255, 255, 0);  // 黃色
        shapeType = ELLIPSE;
    } else if (arousal > 0.75 && valence <= 0.5) {
        fillColor = color(255, 0, 0);  // 紅色
        shapeType = TRIANGLE;
    } else if (arousal <= 0.75 && valence > 0.5) {
        fillColor = color(0, 0, 255);  // 藍色
        shapeType = RECT;
    } else {
        fillColor = color(128);  // 灰色
        shapeType = ELLIPSE;
        size *= 1.2;  // 低 Arousal 和 Valence 的情況下增加大小
    }

    // 將新形狀添加到列表的開頭
    shapes.add(0, new EmotionShape(x, y, fillColor, shapeType, size));
}
//int calculateColor(float arousal, float valence) {
//    float hue = map(valence, 0, 1, 0, 255); // 將 valence 映射到 0 到 255 的範圍內（色相）
//    float brightness = map(arousal, 0, 1, 128, 255); // 將 arousal 映射到 128 到 255 的範圍內（亮度）
//    colorMode(HSB, 255); // 切換到 HSB 色彩模式
//    int fillColor = color(hue, 255, brightness); // 使用全飽和度和動態亮度創建顏色
//    colorMode(RGB, 255); // 切回 RGB 色彩模式
//    return fillColor;
//}
//void addShape(float arousal, float valence) {
//    float size = 150 + arousal * 100; // 根據 Arousal 調整大小
//    float x = random(width);
//    float y = random(height);
//    int fillColor = calculateColor(arousal, valence); // 獲取根據情緒計算的顏色

//    int shapeType;
//    if (arousal > 0.5) {
//        shapeType = (valence > 0.5) ? ELLIPSE : TRIANGLE;
//    } else {
//        shapeType = (valence > 0.5) ? RECT : ELLIPSE;
//    }

//    // 將新形狀添加到列表的開頭
//    shapes.add(0, new EmotionShape(x, y, fillColor, shapeType, size));
//}



//class EmotionShape {
//  float x, y; // Location of the shape
//  int fillColor; // Color of the shape
//  int shapeType; // Type of the shape
//  float size; // Size of the shape
//  int lifespan = 300; // Lifespan in frames

//  EmotionShape(float x, float y, int fillColor, int shapeType, float size) {
//    this.x = x;
//    this.y = y;
//    this.fillColor = fillColor;
//    this.shapeType = shapeType;
//    this.size = size;
//  }

//  boolean display() {
//    fill(fillColor);
//    switch(shapeType) {
//      case ELLIPSE:
//        ellipse(x, y, size, size);
//        break;
//      case TRIANGLE:
//        triangle(x - size, y + size / 2, x, y - size, x + size, y + size / 2);
//        break;
//      case RECT:
//        rect(x - size / 2, y - size / 2, size, size);
//        break;
//    }
//    lifespan--;
//    return lifespan > 0;
//  }
//}

//void addShape(float arousal, float valence) {
//    float size = 150 + arousal * 100;  // Adjust size based on arousal
//    float x = random(width);
//    float y = random(height);
//    int fillColor = calculateColor(arousal, valence);  // Get color based on emotions

//    int shapeType;
//    if (arousal > 0.5) {
//        shapeType = (valence > 0.5) ? ELLIPSE : TRIANGLE;
//    } else {
//        shapeType = (valence > 0.5) ? RECT : ELLIPSE;
//    }

//    shapes.add(0, new EmotionShape(x, y, fillColor, shapeType, size));
//}

// Calculate color based on emotional indices
//int calculateColor(float arousal, float valence) {
//    colorMode(HSB, 255);
//    float hue = (valence > 0.5) ? map(valence, 0.5, 1, 60, 120) : map(valence, 0, 0.5, 0, 60);
//    float brightness = map(arousal, 0, 1, 128, 255);
//    int fillColor = color(hue, 255, brightness);
//    colorMode(RGB, 255);
//    return fillColor;
//}
int calculateColor(float arousal, float valence) {
    colorMode(HSB, 360, 100, 100); // 调整HSB模式参数范围
    float hue = map(valence, 0, 1, 0, 360); // 将valence映射到0-360度的色相
    float saturation = 100; // 设置饱和度为最大
    float brightness = map(arousal, 0, 1, 50, 100); // 将arousal映射到50-100的亮度
    int fillColor = color(hue, saturation, brightness); // 生成颜色
    colorMode(RGB, 255); // 切回RGB模式
    return fillColor;
}


class EmotionShape {
    float x, y;
    int fillColor;
    int shapeType;
    float size;
    int lifespan = 300; // Lifespan in frames

    EmotionShape(float x, float y, int fillColor, int shapeType, float size) {
        this.x = x;
        this.y = y;
        this.fillColor = fillColor;
        this.shapeType = shapeType;
        this.size = size;
    }

    boolean display() {
        fill(fillColor);
        switch(shapeType) {
            case ELLIPSE:
                ellipse(x, y, size, size);
                break;
            case TRIANGLE:
                triangle(x - size, y + size / 2, x, y - size, x + size, y + size / 2);
                break;
            case RECT:
                rect(x - size / 2, y - size / 2, size, size);
                break;
        }
        lifespan--;
        return lifespan > 0;
    }
}
