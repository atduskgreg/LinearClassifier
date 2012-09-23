import linearclassifier.*;
import processing.data.*;

Table data;
LinearClassifier classifier;

void setup() {
  size(500, 500);
  
  // load the data and automatically parse the csv
  data = new Table(this, "height_and_weight.csv");
  
  classifier = new LinearClassifier(this);
  
  ArrayList<ArrayList<Float>> men = new ArrayList<ArrayList<Float>>();
  ArrayList<ArrayList<Float>> women = new ArrayList<ArrayList<Float>>();
  
  data.removeTitleRow();
  
  // iterate through the data in the csv
  for(TableRow row : data){
    // put the height and weight data into an ArrayList
    ArrayList<Float> entry = new ArrayList<Float>(); 
    
    entry.add(row.getFloat(1));
    entry.add(row.getFloat(2));    
    
    // based on the f/m column
    // put the Pvector in the right ArrayList for men or women
    if(row.getString(3).equals("f")){
      women.add(entry);
    } else {
      men.add(entry);
    }
  }
  
  // pass the data to the classifier
  classifier.loadSet1(men);
  classifier.loadSet2(women);
  
  ArrayList<PVector> scales = new ArrayList<PVector>();
  scales.add(new PVector(0, 500));
  scales.add(new PVector(500, 0));
  classifier.setOutputScale(scales);  
}

void draw(){
  background(255);
  noStroke();
  
  // display the data
  fill(0,0,255);
  classifier.drawSet1();
  fill(255,0,0);
  classifier.drawSet2();

  // get the average of each set
  ArrayList<Float> set1Ave = classifier.getSet1Average();
  ArrayList<Float> set2Ave = classifier.getSet2Average();
  
  // draw them as black boxes
  fill(0);
  rectMode(CENTER);
  rect(set1Ave.get(0), set1Ave.get(1), 10, 10);
  text("Men\nAverage", set1Ave.get(0)+10, set1Ave.get(1)+10);
  rect(set2Ave.get(0), set2Ave.get(1), 10, 10);
  text("Women\nAverage", set2Ave.get(0)+10, set2Ave.get(1)+10);

  // draw a line connecting the two averages
  // and a point at the center of that line
  fill(0,255,0);
  stroke(0,255,0);
  line(set1Ave.get(0), set1Ave.get(1), set2Ave.get(0), set2Ave.get(1));
  ellipse(classifier.getCenterPoint().x, classifier.getCenterPoint().y, 10, 10);
  
  // draw a line perpendicualr to the line
  // between the cetner points
  // this line should divide the two sets after classification
  stroke(0);
  drawPerpindicularLine(set1Ave.get(0), set1Ave.get(1), set2Ave.get(0), set2Ave.get(1));
  
  noStroke();
  if(classifier.isInSet1( new PVector(mouseX, mouseY))){
    fill(0,0,255);
  } else {
    fill(255,0,0);
  }
  
  ellipse(mouseX, mouseY, 10, 10);  
 
  PVector p = classifier.getUnscaledPoint(new PVector(mouseX, mouseY));
  text("H: " + round(p.x) + "\"\nW: " + round(p.y) + "lbs", mouseX+7, mouseY+7);
}

void drawPerpindicularLine(float x1, float y1, float x2, float y2){
  
  PVector axis = PVector.sub(new PVector(x1, y1), new PVector(x2, y2));
  PVector perp = axis.cross(new PVector(0,0,1));

  perp.setMag(500);

  PVector lineStart = PVector.sub(classifier.getCenterPoint(), perp);
  PVector lineEnd = PVector.add(classifier.getCenterPoint(), perp);
  
  line(lineStart.x, lineStart.y, lineEnd.x, lineEnd.y);
}
