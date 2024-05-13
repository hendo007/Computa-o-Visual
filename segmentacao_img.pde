import java.util.ArrayList;

void setup() {
  size(400, 267);
  noLoop();
}

void draw() {
  // array para guardar todos os resultados finais em um txt
  ArrayList<String> resultadoFinal = new ArrayList<String>();
  
  //loop de seleção das imagens
  for (int cont = 1; cont <= 5; cont++) {
    String fileImg = selectImg(cont) + "-01-Original.jpg";
    PImage img = loadImage(fileImg);
    Integer limiar = selectLimiar(cont);
  
    int count = 0;
    float resultado = 0.0; 
  
    float total = (float)img.width * (float)img.height;
    PImage imgPB = createImage(img.width, img.height, RGB); 
  
    // Filtro escala de cinza 
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int pos = y * img.width + x; 
        float media = red(img.pixels[pos]);
        imgPB.pixels[pos] = color(media);
      }
    }
    
    image(imgPB, 0, 0); 
    save(selectImg(cont) + "-03-PB.jpg");
  
    //1ª segmentação
    PImage seg1 = createImage(img.width, img.height, RGB);
  
    for (int y = 0; y < imgPB.height; y++) {
      for (int x = 0; x < imgPB.width; x++) { 
        int pos = y * imgPB.width + x; 
        if (red(imgPB.pixels[pos]) > limiar) seg1.pixels[pos] = color(255);
        else seg1.pixels[pos] = color(0);
      }
    }
    
    image(seg1, 0, 0); 
    save(selectImg(cont) + "-04-segmentacaoInicial.jpg");
    
    //Criação da imagem já segmentada
    PImage seg = createImage(img.width, img.height, RGB);
  
    for (int y = 0; y < seg1.height; y++) {
      for (int x = 0; x < seg1.width; x++) { 
        int pos = y * img.width + x; 
        if (seg1.pixels[pos] == color(255)) seg.pixels[pos] = img.pixels[pos];
      }
    }
    
    image(seg, 0, 0); 
    save(selectImg(cont) + "-05-segmentacaoFinal.jpg");
    
    //comparação da segmentada com a imagem segmentada que foi retirada no banco de imagens
    PImage imgGTM = loadImage(selectImg(cont) + "-02-Meta.png");
  
    for (int y = 0; y < seg1.height; y++) {
      for (int x = 0; x < seg1.width; x++) { 
        int pos = y * seg1.width + x; 
        if (seg1.pixels[pos] == imgGTM.pixels[pos]) count++;
      }
    }
  
    resultado = (float)count / total;
    
    resultadoFinal.add("% acerto da Imagem " + selectImg(cont) + " = " + resultado + " | Valor do Limiar: " + limiar + " | Quantidade de Pixels Iguais: " + count + " | Total de pixels: " + total);
  }
  
  // Convertendo ArrayList para array de strings
  String[] resultadoArray = resultadoFinal.toArray(new String[0]);
  
  saveStrings("resultado.txt", resultadoArray);
}

// Função de seleção das imagens
String selectImg(int opImg) {
  String nomeImg = ""; 
    
  switch(opImg) {
    case 1:
      nomeImg = "0282";
      break;
    case 2:
      nomeImg = "0289";
      break;
    case 3:
      nomeImg = "0293";
      break;
    case 4:
      nomeImg = "0295";
      break;
    case 5:
      nomeImg = "0353";
      break;
  }
    
  return nomeImg;
}


// Função de seleção das imagens
Integer selectLimiar(int opImg) {
  Integer opLimiar = 0; 
    
  switch(opImg) {
    case 1:
      opLimiar = 135;
      break;
    case 2:
      opLimiar = 160;
      break;
    case 3:
      opLimiar = 195;
      break;
    case 4:
      opLimiar = 130;
      break;
    case 5:
      opLimiar = 160;
      break;
  }
    
  return opLimiar;
}
