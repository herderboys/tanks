// Namn: Alexander Herder, alhe5785

class TreeGR04 extends SpriteGR04 {
  
  PVector position;
  String  name; 
  PImage  img;
  float   diameter;
  
  //**************************************************
  TreeGR04(PImage _image, int _posx, int _posy) {
    
    this.img       = _image;
    this.diameter  = this.img.width/2;
    this.name      = "tree";
    this.position  = new PVector(_posx, _posy);
    
  }

  //**************************************************
  


  //**************************************************  
  void display() {
      
  }
}
