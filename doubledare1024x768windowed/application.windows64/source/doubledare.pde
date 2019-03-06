// Double Dare
// Program designed and created by
// Brian Smith
// brian.codesmith@gmail.com

import controlP5.*;

/*
Double Dare:
issue: no good way to deal with reverse-perspective prob
  reverse screen for examiner
  reverse once at beginngin...
  +25 +50 +10 -> only should be avail to current team
    correct, wrong, dare buttons
    on certain actions (dare), disappear
    buttons for current team and appear
    buttons for new team in control
    dare -> dbl dare -> phys challenge
    phys chall timer + normal timer
  basically, let examiner see correct order at beg
  and then switch to audience flipped view, and after
  that, only have buttons avail for currently acting
  team.
Have additional +25/-25 buttons for every team (always vis)
to correct scoring mistakes.

Highlight current team instead of creating new buttons?
Better way? Best way?

-----------------------------------------------------------

Needed tweaks:

* Everything needs to be a bigger size.  Compare sizes with
  my program.
++++++* Point values for everything need to be doubled.  instead
  of 25 50 100, the increments need to be 50 100 200.  This
  also affects the +25 and -25 buttons - they should be +50
  and -50.
++++++* The "Completed" and "Failed" buttons should stay behind
  when the Physical Challenge timer runs out.  This way if
  a team completes the challenge at the last second we can
  choose to give it to them.
++++++* When the Physical Challenge timer is being stopped, there
  should be a +0:15 and -0:15 button next to it.  Also, the
  default value should be 0:30.
++++++* The "Last Minute" control was really just for debugging;
  this should be removed in the final program.


"Nice" tweaks:

++++++* Change "Switch control" to "Give control".  Saying "Switch
  control" makes me think the button will toggle it.
* It would be nice if the window could be maximized.
++++++* I'd prefer "Complete" and "Incomplete" to "Completed" and
  "Failed" --- just don't like the word "Failed".  :P
++++++* Can we make it so that when a player changes the timer
  before starting the game, the game "remembers" what the
  person put when the game is reset so they wouldn't have
  to change it before every game?  It turns out we won't know
  exactly how much time there is until we get to it because
  it's our last game and we have 12 teams (6 games) to get
  through.
++++++* Have the Dare, Correct, and Incorrect buttons not appear
  until the game is started.

*/

// declare global variables at the top of your sketch
// images
PImage dbldabg;
PImage ddlogo;

// timers
int t1start; // main timer
int t1current;
int t1duration;
int t2start; // dare timer
int t2current;
int t2duration;
int lastTime = 480;

// stats
int team1pts;
int team2pts;

// fonts
ControlFont timeFont;
ControlFont nameFont;
ControlFont buttonFont;
ControlFont dareFont;

// game states
int dareState;
int teamControl;
int win;
boolean timeChanged = false;
boolean started;

// bools
boolean centered;

// interactable objects
ControlP5 cp5;
//end global variables

void setup() {
    size(1024,768); // size(width, height) must be the first line in setup()
    //surface.setResizable(true); // set the window to be resizable
    
    // create the controlP5 controller
    cp5 = new ControlP5(this);
    // set it to not auto-draw
    cp5.setAutoDraw(false);
    
    // load images
    dbldabg = loadImage("bgfullwsmlogo1024x768.png");
    ddlogo = loadImage("ddlogo.png");
    
    // create fonts
    timeFont = new ControlFont(createFont("numfont.ttf",46));
    nameFont = new ControlFont(createFont("ddfont.ttf",40));
    dareFont = new ControlFont(createFont("ddboldfont.ttf",30));
    buttonFont = new ControlFont(createFont("buttonfont.ttf",38));
    
    // button setup ####### attach keys to these functions #######
    cp5.addButton("t1p25").setSize(100,40).setPosition(255,458).setLabel("+50").getCaptionLabel().setFont(timeFont);
    cp5.getController("t1p25").getCaptionLabel().getStyle().marginTop = -5;
    cp5.addButton("t1m25").setSize(100,40).setPosition(145,458).setLabel("-50").getCaptionLabel().setFont(timeFont);
    cp5.getController("t1m25").getCaptionLabel().getStyle().marginTop = -5;
    
    cp5.addButton("t2p25").setSize(100,40).setPosition(779,458).setLabel("+50").getCaptionLabel().setFont(timeFont);
    cp5.getController("t2p25").getCaptionLabel().getStyle().marginTop = -5;
    cp5.addButton("t2m25").setSize(100,40).setPosition(669,458).setLabel("-50").getCaptionLabel().setFont(timeFont);
    cp5.getController("t2m25").getCaptionLabel().getStyle().marginTop = -5;
    
    cp5.addButton("correct").hide().setSize(150,70).setPosition(352,670).setLabel("Correct").getCaptionLabel().setFont(buttonFont);
    cp5.addButton("incorrect").hide().setSize(150,70).setPosition(522,670).setLabel("Incorrect").getCaptionLabel().setFont(buttonFont);
    cp5.addButton("dare").hide().setSize(320,70).setPosition(352,580).setLabel("Dare").getCaptionLabel().setFont(dareFont);
    //490,450 -> 352,580 => -138,+130
    cp5.addButton("timetog").setSize(120,50).setPosition(115,200).setLabel("Start").getCaptionLabel().setFont(buttonFont);
    cp5.addButton("dtimetog").setSize(120,50).setPosition(759,200).setLabel("Start").hide().getCaptionLabel().setFont(buttonFont);
    
    cp5.addButton("t1control").setSize(130,90).setPosition(40,638).setLabel("  Give\nControl").getCaptionLabel().setFont(buttonFont);
    cp5.getController("t1control").getCaptionLabel().getStyle().marginTop = -22;
    cp5.addButton("t2control").setSize(130,90).setPosition(854,638).setLabel("  Give\nControl").getCaptionLabel().setFont(buttonFont);
    cp5.getController("t2control").getCaptionLabel().getStyle().marginTop = -22;
    
    // added these two after looking at your UI
    cp5.addButton("reset").setSize(180,40).setPosition(10,10).setLabel("Reset Game").getCaptionLabel().setFont(buttonFont);
    cp5.getController("reset").getCaptionLabel().getStyle().marginTop = -4;
    cp5.addButton("onemin").hide().setSize(190,40).setPosition(210,10).setLabel("Last Minute").getCaptionLabel().setFont(buttonFont);
    cp5.getController("onemin").getCaptionLabel().getStyle().marginTop = -4;
    
    cp5.addButton("chalp15").hide().setSize(75,40).setPosition(894,95).setLabel("+15").getCaptionLabel().setFont(timeFont);
    cp5.getController("chalp15").getCaptionLabel().getStyle().marginTop = -5;
    cp5.addButton("chalm15").hide().setSize(75,40).setPosition(894,145).setLabel("-15").getCaptionLabel().setFont(timeFont);
    cp5.getController("chalm15").getCaptionLabel().getStyle().marginTop = -5;//1122,90+100
    
    // text field setup
    cp5.addTextfield("t1name").setAutoClear(false).setSize(240,60).setPosition(130,298).setText("Team : ").setLabel("");
    cp5.getController("t1name").getValueLabel().setFont(nameFont);
    cp5.getController("t1name").getValueLabel().setPaddingX(10);
    cp5.addTextfield("t2name").setAutoClear(false).setSize(240,60).setPosition(654,298).setText("Team : ").setLabel("");
    cp5.getController("t2name").getValueLabel().setFont(nameFont);
    cp5.getController("t2name").getValueLabel().setPaddingX(10);
    
    // timer setup
    t1start = 0;
    if (timeChanged) {
      t1current = lastTime;
      t1duration = lastTime;
    } else {
      t1current = 480;
      t1duration = 480; // 8 minutes in seconds
    }
    t2start = 0;
    t2current = 30;
    t2duration = 30; // 30 seconds
    
    // timer display setup
    cp5.addTextfield("mainTimer").setColorCursor(255).setAutoClear(false).setColorBackground(0).setSize(240,100).setPosition(55,90).setText(formatMT()).setLabel("").getValueLabel().setColor(color(227,242,97));
    cp5.getController("mainTimer").getValueLabel().setFont(timeFont).setSize(122).getStyle().marginTop = -15;
    cp5.getController("mainTimer").getValueLabel().getStyle().marginLeft = 5;
    
    cp5.addTextfield("challengeTimer").hide().setColorBackground(0).setSize(130,100).setPosition(754,90).setText(str(t2duration)).setLabel("").getValueLabel().setColor(color(227,242,97));
    cp5.getController("challengeTimer").getValueLabel().setFont(timeFont).setSize(122).getStyle().marginTop = -15;
    cp5.getController("challengeTimer").getValueLabel().getStyle().marginLeft = 9;
    
    // points setup
    team1pts = 0;
    team2pts = 0;
    
    // score display setup
    cp5.addTextlabel("t1score").setSize(230,100).setPosition(140,398).setText(formatScore(team1pts)).setLabel("").getValueLabel().setColor(color(227,242,97));
    cp5.getController("t1score").getValueLabel().setFont(timeFont).setSize(92).getStyle().marginTop = -15;
    cp5.getController("t1score").getValueLabel().getStyle().marginLeft = 20;
    
    cp5.addTextlabel("t2score").setSize(230,100).setPosition(664,398).setText(formatScore(team2pts)).setLabel("").getValueLabel().setColor(color(227,242,97));
    cp5.getController("t2score").getValueLabel().setFont(timeFont).setSize(92).getStyle().marginTop = -15;
    cp5.getController("t2score").getValueLabel().getStyle().marginLeft = 20;
    
    // other setup
    centered = false;
    dareState = 1;
    teamControl = 1;
    win = 0;
    started = false;
}

// format string for main timer
public String formatMT() {
  String min = str(floor(t1current/60));
  String sec = str(t1current%60);
  if (sec.length() == 1) sec = "0" + sec;
  return min + ":" + sec;
}

// format string for scores
public String formatScore(int pts) {
  String score = str(pts);
  switch(score.length()) {
    case 0: score = "000" + score;
            break;
    case 1: score = "000" + score;
            break;
    case 2: score = "00" + score;
            break;
    case 3: score = "0" + score;
            break;
  }
  
  return score;
}

// update main clock
public void updateMT() {
  cp5.get(Textfield.class,"mainTimer").setText(formatMT());
}

// update challenge clock
public void updateCT() {
  if (str(t2current).length() == 1) {
    cp5.get(Textfield.class,"challengeTimer").setText("0" + str(t2current));
  } else {
    cp5.get(Textfield.class,"challengeTimer").setText(str(t2current));
  }
}

// update team scores
public void updateScore() {
  cp5.getController("t1score").setStringValue(formatScore(team1pts));
  cp5.getController("t2score").setStringValue(formatScore(team2pts));
}

/*// format string for main timer
public String formatCT() {
  String min = str(floor(t2duration/60));
  String sec = str(t2duration%60);
  if (sec.length() == 1) sec = "0" + sec;
  return min + ":" + sec;
}*/

// called by cp5 when the reset game button is pressed
public void reset() {
  setup();
}

// called by cp5 when the last minute button is pressed
public void onemin() {
  t1start = millis();
  t1current = 60;
  t1duration = 60;
}

// called by cp5 when the add 25 pts to team 1 button is pressed
public void t1p25() {team1pts += 50; updateScore();}

// called by cp5 when the subtract 25 pts from team 1 button is pressed
public void t1m25() {if (team1pts != 0) {team1pts -= 50; updateScore();}}

// called by cp5 when the add 25 pts to team 2 button is pressed
public void t2p25() {team2pts += 50; updateScore();}

// called by cp5 when the subtract 25 pts from team 2 button is pressed
public void t2m25() {if (team2pts != 0) {team2pts -= 50; updateScore();}}

// called by cp5 when the add 15 seconds to challenge timer button is pressed
public void chalp15() {
  t2start = millis();
  t2current += 15;
  t2duration = t2current;
  updateCT();
}

// called by cp5 when the subtract 15 seconds to challenge timer button is pressed
public void chalm15() {
  if (t2current > 15) {
  t2start = millis();
  t2current -= 15;
  t2duration = t2current;
  updateCT();
  }
}

// called by cp5 when the correct button is pressed
public void correct() {
  if (teamControl == 1) {
    switch(dareState) {
      case 0: team1pts += 200;
              break;
      case 1: team1pts += 50;
              break;
      case 2: team1pts += 100;
              break;
      case 3: team1pts += 200;
              break;
    }
  } else {
    switch(dareState) {
      case 0: team2pts += 200;
              break;
      case 1: team2pts += 50;
              break;
      case 2: team2pts += 100;
              break;
      case 3: team2pts += 200;
              break;
    }
  }
  resetDare(); // reset dare multi button & state
  updateScore();
}

// called by cp5 when the incorrect button is pressed
public void incorrect() {
  if (teamControl == 1) {
    switch(dareState) {
      case 0: team2pts += 200;
              break;
      case 1: break; // do not give points to other team in this case
      case 2: team2pts += 100;
              break;
      case 3: team2pts += 200;
              break;
    }
  } else {
    switch(dareState) {
      case 0: team1pts += 200;
              break;
      case 1: break; // do not give points to other team in this case
      case 2: team1pts += 100;
              break;
      case 3: team1pts += 200;
              break;
    }
  }
  resetDare(); // reset dare multi button & state
  updateScore();
  toggleControl(); // change control to other team
}

// called by cp5 when the dare multi button is pressed
public void dare() {
  switch (dareState) {
    case 1: dareState = 2; // if on 'dare' change to 'double dare', change team control
            cp5.getController("dare").setLabel("Double Dare");
            toggleControl();
            break;
    case 2: dareState = 3; // if on 'double dare' change to 'physical challenge', change team control
            cp5.getController("dare").setLabel("Physical Challenge");
            toggleControl();
            break;
    // if on 'physical challenge' change back to dare, change to physical challenge state,
    // hide button, change correct/incorrect to completed/failed. 0 used as check for physchall state
    case 3: dareState = 0;
            cp5.getController("dare").setLabel("Dare");
            cp5.getController("dare").hide();
            cp5.getController("correct").setLabel("Complete");
            cp5.getController("incorrect").setLabel("Incomplete");
            cp5.getController("dtimetog").show();
            cp5.getController("challengeTimer").show();
            cp5.getController("chalp15").show();
            cp5.getController("chalm15").show();
            //startPhysChall(); // not necessary?
            break;
  }
}

// sets time of main timer to value in the Textfield
public void checkTime() {
  String tdisp = cp5.getController("mainTimer").getValueLabel().getText();
  int count = tdisp.length() - tdisp.replaceAll(":","").length();
  if (tdisp.contains(":") && count == 1) {
    String[] m = ("0" + tdisp + "0").split(":");
    t1duration = (60 * int(m[0])) + int(m[1].substring(0,m[1].length()-1));
    if (!started) {
      lastTime = t1duration;
    }
  } else if (tdisp.matches("[0-9]+") && tdisp.length() > 0) {
    t1duration = int(tdisp);
    if (!started) {
      lastTime = t1duration;
    }
  }
}

// called by cp5 when the start/stop button is pressed
public void timetog() {
  if (cp5.getController("timetog").getLabel() == "Start") {
    checkTime();
    if (!started) {
      if(cp5.get(Textfield.class,"t1name").getText().equals("Team : ") || cp5.get(Textfield.class,"t2name").getText().equals("Team : ")) {
        return;
      }
      started = true;
      timeChanged = true;
      cp5.getController("correct").show();
      cp5.getController("incorrect").show();
      cp5.getController("dare").show();
    }
    cp5.getController("timetog").setLabel("Stop");
    t1start = millis(); // millisecond when timer was started
  } else {
    cp5.getController("timetog").setLabel("Start");
    t1duration = t1current;
    t1start = 0; // reset to 0 to avoid further seconds being removed
  }
}

// called by cp5 when the physical challenge timer start/stop button is pressed
public void dtimetog() {
  if (cp5.getController("dtimetog").getLabel() == "Start") {
    cp5.getController("dtimetog").setLabel("Stop");
    t2start = millis(); // millisecond when timer was started
  } else {
    cp5.getController("dtimetog").setLabel("Start");
    t2duration = t2current;
    t2start = 0; // reset to 0 to avoid further seconds being removed
  }
}

// called by cp5 when the team 1 control button is pressed
public void t1control() {teamControl = 1;}

// called by cp5 when the team 2 control button is pressed
public void t2control() {teamControl = 2;}

/*// called by cp5 when team 1 name is edited
public void t1name() {
}

// called by cp5 when team 2 name is edited
public void t2name() {
}*/

/*// called by cp5 when team 1 name is edited
public void mainTimer() {
}

// called by cp5 when team 2 name is edited
public void challengeTimer() {
}*/

/* not necessary?
    cp5.addButton("timetog").setLabel("Start");
    cp5.addButton("dtimetog").setLabel("Start");
    
    cp5.addButton("t1control").setLabel("Switch Control");
    cp5.addButton("t2control").setLabel("Switch Control");
// start the physical challenge
public void startPhysChall() {
  cp5.getController("dtimetog").show();
}*/

// reset dare button
public void resetDare() {
  cp5.getController("dare").setLabel("Dare");
  cp5.getController("dare").show();
  dareState = 1;
  cp5.getController("dtimetog").hide();
  cp5.getController("challengeTimer").hide();
  cp5.getController("chalp15").hide();
  cp5.getController("chalm15").hide();
  t2start = 0;
  t2current = 30;
  t2duration = 30;
  updateCT();
  cp5.getController("dtimetog").setLabel("Start");
  cp5.getController("correct").setLabel("Correct");
  cp5.getController("incorrect").setLabel("Incorrect");
}

// toggle team control
public void toggleControl() {
  if (teamControl == 1) teamControl = 2;
    else teamControl = 1;
}

// set state to end game state
public void endGame() {
  if (team1pts > team2pts) {
    win = 1;
    
  } else if (team2pts > team1pts) {
    win = 2;
    
  } else {
  }
}

void centerme() {
  frame.setLocation(displayWidth/2-width/2,displayHeight/2-height/2);
  centered = true;
}

void draw() {
  // center window
  if (!centered) {centerme();}
  // draw bg graphic
  background(dbldabg);
  
  // draw UI graphics                     size(1280, 720) --- MAY NEED TO BE 1024x768
  pushStyle();
  strokeWeight(20);
  fill(0);
  stroke(#264589);
  triangle(50,372,450,372,250,718);
  stroke(#da1425);
  triangle(574,372,974,372,774,718);
  if (teamControl == 2) {
    fill(#da1425);
    ellipse(774,558,90,90);
    image(ddlogo,732,513,90,90);
  } else {
    stroke(#264589);
    fill(#264589);
    ellipse(250,558,90,90);
    image(ddlogo,208,513,90,90);
  }
  popStyle();
  
  // start button keeper
  if (cp5.get(Textfield.class,"t1name").getText().equals("Team : ") || cp5.get(Textfield.class,"t2name").getText().equals("Team : ")) {
    cp5.getController("timetog").hide();
  } else {cp5.getController("timetog").show();}
  
  // timer(s)
  if (cp5.getController("timetog").getLabel() == "Stop") {
    t1current = t1duration - ((millis()-t1start)/1000);
    updateMT();
    if (t1current == 0) {
      //println("i have a zero1");
      timetog();
      endGame();
    }
  }
  if (cp5.getController("dtimetog").getLabel() == "Stop") {
    t2current = t2duration - ((millis()-t2start)/1000);
    updateCT();
    if (t2current == 0) {
      //println("i have a zero2");
      dtimetog();
      //incorrect();
    }
  }
  
  // draw ControlP5 components
  cp5.draw();
  
  // win condition UI
  if (win == 1) {
    pushStyle();
    noFill();
    stroke(color(0,255,0));
    strokeWeight(20);
    rect(140,288,220,180,7);
    popStyle();
  } else if (win == 2) {
    pushStyle();
    noFill();
    stroke(color(0,255,0));
    strokeWeight(20);
    rect(664,288,220,180,7);
    popStyle();
  }
}