import linearclassifier.*;
import processing.data.*;

Table data;
LinearClassifier classifier;

void setup() {
  size(500, 500);

  // load the data and automatically parse the csv
  data = new Table(this, "matchmaker.csv");

  classifier = new LinearClassifier(this);
  
  ArrayList<ArrayList<Float>> matches = new ArrayList<ArrayList<Float>>();
  ArrayList<ArrayList<Float>> noMatches = new ArrayList<ArrayList<Float>>();

  // iterate through the data in the csv
  for (TableRow row : data) {
    ArrayList<Float> entry = new ArrayList<Float>();

    entry.add(row.getFloat(0)); // age1
    entry.add(parseYesNo(row.getString(1)));
    entry.add(parseYesNo(row.getString(2)));

    entry.add(row.getFloat(5)); // age2
    entry.add(parseYesNo(row.getString(6)));
    entry.add(parseYesNo(row.getString(7)));

    entry.add(matchCount( row.getString(3), row.getString(8) ));
    entry.add(row.getFloat(11)); // distance

    if (row.getInt(10) == 1) {
      matches.add(entry);
    } 
    else {
      noMatches.add(entry);
    }
  }

  // pass the data to the classifier
  classifier.loadSet1(matches);
  classifier.loadSet2(noMatches);

  // scale all the data to be between 0 and 1
  // to give each component equal weight
  classifier.scaleData(0,1);
  displayNewResults();
}

// picks 5 entries randomly from both set 1 and set 2
// runs them through the classifier to see if it
// categorizes them correctly
// all examples from set 2 should be "no match", i.e. red
// and all from set 1 should be "match", i.e. green
// the classifier won't always be right but should be most of the time
// this gets called in keyPressed() to display new data
void displayNewResults() {
  background(255);
  fill(0);
  text("Set 1: These should all be matches", 10, 20);

  for (int i = 0; i < 5; i ++) {
    int j = (int)random(classifier.set1.size());
    ArrayList<Float> entry = classifier.set1.get(j);
    if (classifier.isInSet1(entry)) {
      fill(0, 255, 0);
    } 
    else {
      fill(255, 0, 0);
    }
    text("["+ toString(entry) + "]\nPredicted match? " + classifier.isInSet1(entry), 10, 40 + i*35);
  }

  fill(0);
  text("Set 2: None of these should be matches", 10, 40 + 5*35 + 20);

  for (int i = 0; i < 5; i ++) {
    int j = (int)random(classifier.set2.size());
    ArrayList<Float> entry = classifier.set2.get(j);
    if (classifier.isInSet2(entry)) {
      fill(0, 255, 0);
    } 
    else {
      fill(255, 0, 0);
    }
    text("["+ toString(entry) + "]\nPredicted match? " + classifier.isInSet2(entry), 10, 40 + 5*35 + 40 + i*35);
  }
}

void draw() {
  fill(0);
  text("(PRESS ANY KEY FOR MORE DATA)", 10, height-20);
}

void keyPressed(){
  displayNewResults();
}

// helper function to turn a "yes" or "no"
// string into a -1 or 1 for numerical comparison
float parseYesNo(String s) {
  if (s.equals("yes")) {
    return 1;
  } 
  else if (s.equals("no")) {
    return -1;
  } 
  else {
    return 0;
  }
}

// helper function to turn the list of interests
// into a float based on how many are shared
float matchCount(String interests1, String interests2) {
  String[] i1 = split(interests1, ":");
  String[] i2 = split(interests2, ":");

  float result = 0;
  for (int i = 0; i < i1.length; i++) {
    if (i < i2.length && i1[i].equals(i2[i])) {
      result = result + 1;
    }
  }

  return result;
}

// helper function to display an ArrayList as a string
String toString(ArrayList<Float> a) {
  String s = "";
  for (int i = 0; i < a.size(); i++) {
    float e = a.get(i);
    if (i == a.size() - 1) {
      s = s + e;
    } 
    else {
      s = s + e + ", ";
    }
  }
  return s;
}

