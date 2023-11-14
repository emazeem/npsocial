
class Role{
  static int User=3;
  static int Organization=4;
  static getTitle(int value){
    return value==3
        ? 'User'
        : value == 4
        ? 'Organization'
        : 'NA';
  }
}
