import java.util.Arrays; // Adicionando a importação necessária

void setup() {
  size(301, 400);
  noLoop();
}

void draw() {
  
  String nomeImg = "0342";
  String fileImg = nomeImg + ".jpg";
  String tipoFiltro = "media"; // media - mediana - gaussiano
  String colorChannel = "red"; // red - green - blue
  
  PImage img = loadImage(fileImg);
  
  // Aplicar filtro Preto  e Branco
  PImage imgPB = applyFilter(img, colorChannel, tipoFiltro);
  image(imgPB, 0, 0);
  save(nomeImg + " (imgPB - " + colorChannel + " - " + tipoFiltro + ").png");

  // Segmentar imagens com limiar alto
  PImage seg = segment(imgPB, 155, "high", colorChannel);
  image(seg, 0, 0);
  save(nomeImg + " (seg - " + colorChannel + " - " + tipoFiltro + ").png");
  
}

PImage applyFilter(PImage img, String colorChannel, String filterType) {
  PImage imgFiltered = createImage(img.width, img.height, RGB);

  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;
      float value = getColorValue(img.pixels[pos], colorChannel);
      imgFiltered.pixels[pos] = applyFilterToPixel(img, x, y, colorChannel, filterType);
    }
  }

  imgFiltered.updatePixels();
  return imgFiltered;
}

color applyFilterToPixel(PImage img, int x, int y, String colorChannel, String filterType) {
  switch (filterType) {
    case "media":
      return filtermedia(img, x, y, colorChannel);
    case "mediana":
      return filtermediana(img, x, y, colorChannel);
    case "gaussiano":
      return filtergaussiano(img, x, y, colorChannel);
    default:
      return color(0);
  }
}

float getColorValue(int pixel, String colorChannel) {
  switch (colorChannel) {
    case "blue":
      return blue(pixel);
    case "red":
      return red(pixel);
    case "green":
      return green(pixel);
    default:
      return 0;
  }
}

PImage segment(PImage imgFiltered, int threshold, String type, String colorChannel) {
  PImage seg = createImage(imgFiltered.width, imgFiltered.height, RGB);
  
  switch (colorChannel) {
    case "blue":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          float value = blue(imgFiltered.pixels[pos]);
          seg.pixels[pos] = segmentPixel(value, threshold, type);
        }
      }
    case "red":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          float value = red(imgFiltered.pixels[pos]);
          seg.pixels[pos] = segmentPixel(value, threshold, type);
        }
      }
    case "green":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          float value = green(imgFiltered.pixels[pos]);
          seg.pixels[pos] = segmentPixel(value, threshold, type);
        }
      }
  }
  seg.updatePixels();
  return seg;
}

color segmentPixel(float value, int threshold, String type) {
  if (type.equals("low") && value < threshold)
    return color(255);
  else if (type.equals("high") && value > threshold)
    return color(255);
  else
    return color(0);
}

PImage combineSegments(PImage seg1, PImage seg2, String colorChannel) {
  PImage seg = createImage(seg1.width, seg1.height, RGB);

  switch (colorChannel) {
    case "blue":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          if (blue(seg1.pixels[pos]) == 255 || blue(seg2.pixels[pos]) == 255) {
            seg.pixels[pos] = color(255);
          } else {
            seg.pixels[pos] = color(0);
          }
        }
      }
    case "green":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          if (green(seg1.pixels[pos]) == 255 || green(seg2.pixels[pos]) == 255) {
            seg.pixels[pos] = color(255);
          } else {
            seg.pixels[pos] = color(0);
          }
        }
      }
    case "red":
      for (int y = 0; y < seg.height; y++) {
        for (int x = 0; x < seg.width; x++) {
          int pos = y * seg.width + x;
          if (red(seg1.pixels[pos]) == 255 || red(seg2.pixels[pos]) == 255) {
            seg.pixels[pos] = color(255);
          } else {
            seg.pixels[pos] = color(0);
          }
        }
      }
  }

  seg.updatePixels();
  return seg;
}

color filtermedia(PImage img, int x, int y, String colorChannel) {
  float sum = 0;
  int count = 0;

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int px = constrain(x + i, 0, img.width - 1);
      int py = constrain(y + j, 0, img.height - 1);
      int pos = py * img.width + px;
      sum += getColorValue(img.pixels[pos], colorChannel);
      count++;
    }
  }

  int media = int(sum / count);
  return color(media);
}

color filtermediana(PImage img, int x, int y, String colorChannel) {
  int[] values = new int[9];
  int index = 0;

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int px = constrain(x + i, 0, img.width - 1);
      int py = constrain(y + j, 0, img.height - 1);
      int pos = py * img.width + px;
      values[index++] = int(getColorValue(img.pixels[pos], colorChannel));
    }
  }

  Arrays.sort(values);
  int mediana = values[4];
  return color(mediana);
}

color filtergaussiano(PImage img, int x, int y, String colorChannel) {
  float[] weights = {1, 2, 1, 2, 4, 2, 1, 2, 1};
  float sum = 0;
  int index = 0;

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int px = constrain(x + i, 0, img.width - 1);
      int py = constrain(y + j, 0, img.height - 1);
      int pos = py * img.width + px;
      sum += getColorValue(img.pixels[pos], colorChannel) * weights[index++];
    }
  }

  int gaussiano = int(sum / 16);
  return color(gaussiano);
}
