# alignvideo

### Overview
This purpose of the alignvideo task is to have participants watch nearly 90 minutes of videos that vary in content.
The videos include scenes intended to feature various kinds of empathic states, appetitive states, aversive states, social relationships, 
scenescapes (e.g. mountains, oceans/beaches, outer space, urban/rural, natural disasters), animals, body parts,
emotions, narratives, spoken languages, humor, music, sports, and organism/environment interactions. The neural data collected
while participants view these videos can be used to test the efficacy of functional alignment methods.

Because all participants view these videos in addition to completing the pain, emotion, and cognitive control tasks in the 
spatial topology studyverse, these videos serve as training data that can be used to align neural data across participants. 

---

![Screenshot 2023-08-08 at 9 02 17 AM](https://github.com/spatialtopology/alignvideos/assets/18406041/9c5c1341-fb50-49be-9097-9912f3b17ac3)

---

![Screenshot 2023-08-08 at 9 02 33 AM](https://github.com/spatialtopology/alignvideos/assets/18406041/5b9114a4-3012-4c9d-bf5f-0a7d273eb2c1)


### Emotional ratings
In this task, participants view one video at a time. After each video they make a series of ratings about how the video made
them feel. There are 7 separate ratings: 1. Personal Relevance, 2. Happy, 3. Sad, 4. Afraid, 5. Disgusted, 6. Warm and Tender, 7. Engaged

Participants have 5 seconds to make each of the 7 ratings. 

For each rating, the phrase "In relation to the previous video, how do you feel?" is presented, followed by 1 of the 7 keywords.
A triangle is drawn across the screen with the anchors "barely at all" on the left-most side and "strongest imagineable" on the
right-most side. Participants use a trackball in the scanner to slide left-to-right across the screen to designate how strongly
they felt each of the dimensions of interest. For example, in the image below the participant is indicating that they felt 
a low level of disgust during the video they just viewed:

<img src="disgust.png" alt="Disgust" width="500">

---

### Running the Code
* Using matlab, run the following code: `../alignvideos/scripts/RUN_alignvideos.m`
* This code is a wrapper script for `../alignvideos/scripts/alignvideos.m`

### Folder Structure and Description
* `design`: hosts metadata, `../alignvideos/design/spacetop_alignvideos_design.csv`, which identifies how many videos are presented per session & run.
* `scripts`:
    * `RUN_alignvideos.m`: wrapper script. USER: run this script
        * `alignvideos.m`: function instigated by `RUN_alignvideos.m`
            * `biopac_video.m`: function utilized in `alignvideos.m`. Toggles biopac channel
            * `rating_scale.m`: function utilized in `alignvideos.m`. Presents emotional rating scale and tracks participant's mouse position along linear scale.
  
* `stimuli`:
    * cues: images of the 7 emotional ratings
    * instructions: images for the beginning/end of the experiment
    * videos: video stimuli, presented during the experiment
