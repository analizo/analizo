public class UI {

  private Backend backend = new Backend();

  public static void main(String[] args) {
    System.out.println("test");
  }

  public void callBackend() {
    this.backend.processRequest(0);
  }
}
